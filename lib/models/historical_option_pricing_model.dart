library models.historical_option_pricing;

import 'dart:math' as math show max;

import 'package:dama/dama.dart';
import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec/risk_system.dart';
import 'package:elec_server/client/dalmp.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/screens/common/signal/dropdown.dart';
import 'package:flutter_quiver/screens/common/signal/multiselect2.dart';
import 'package:http/http.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';

enum Location {
  massHub(name: 'ISONE Mass Hub'),
  zoneA(name: 'NYISO Zone A'),
  zoneG(name: 'NYISO Zone G'),
  westernHub(name: 'PJM WH');

  const Location({required this.name});

  final String name;

  @override
  String toString() => name;
}

// main row
final term = getDefaultTerm().toSignal();
final termError = signal<String?>(null);
final location = signal<Location>(Location.massHub);
final market = signal<Market>(Market.da);
final bucket = signal<String>('Peak');
final strike = signal<num>(getDefaultStrikePrice(location.value, term.value));
final strikeError = signal<String?>(null);
final callPut = signal<CallPut>(CallPut.call);
final optionType = signal<String>('Daily');
// second row
final historicalTerm = getDefaultHistoricalTerm().toSignal();
final historicalTermError = signal<String?>(null);
final rescalingMethod = signal<String>('None');

final locationD =
    DropdownModel<Location>(selection: location, choices: {...Location.values});
final marketD =
    DropdownModel<Market>(selection: market, choices: {Market.da, Market.rt});
final bucketD = DropdownModel(selection: bucket, choices: {'Peak'});
final callPutD = DropdownModel<CallPut>(
    selection: callPut, choices: {CallPut.call, CallPut.put});
final optionTypeD = DropdownModel(
    selection: optionType,
    choices: {'Daily', 'Monthly', '1x', 'Average Price'});
final rescalingModelD = DropdownModel(
    selection: rescalingMethod, choices: {'None', 'Mean', 'Mean, keep Max'});

final showD = computed(() {
  if (optionType.value == 'Daily') {
    return Selection2Model(
        initialSelection: <String>{},
        choices: <String>{'Sorted', 'Cumulative'});
  } else {
    return Selection2Model(initialSelection: <String>{}, choices: <String>{});
  }
});
final show = computed(() {
  return showD.value.selection;
});

final tableData = <Map<String, dynamic>>[].toSignal();

/// What to plot
final traces = futureSignal(() async {
  if (!cacheTerm.interval.containsInterval(historicalTerm.value.interval)) {
    cache.clear();
    cacheTerm = historicalTerm.value;
  }
  try {
    await getData(historicalTerm.value, location.value, market.value);
  } catch (e) {
    rethrow;
  }
  return makeTraces(
      term.value,
      historicalTerm.value,
      location.value,
      market.value,
      Bucket.parse(bucket.value),
      strike.value,
      callPut.value,
      optionType.value,
      showD.value.selection.value);
}, dependencies: [
  term,
  historicalTerm,
  location,
  market,
  bucket,
  strike,
  callPut,
  optionType,
  showD,
  show,
]);

/// Keep hourly historical data
final cache = <({Location location, Market market}), TimeSeries<double>>{};

/// Keep forward marks data as of last trading date
final fwdCache = <({Location location, Date asOfDate, Month month}), num>{};

/// Recalculate the data for the table
// final tableData = <Map<String, dynamic>>[];

///
Term cacheTerm = getDefaultTerm();

Future<TimeSeries<double>> getData(
    Term term, Location location, Market market) async {
  if (market == Market.rt) {
    throw StateError('Unsupported RT market!');
  }
  final t2 = (location: location, market: market);
  if (!cache.containsKey(t2)) {
    final lmp = DaLmp(Client(), rootUrl: dotenv.env['ROOT_URL']!);
    final hTerm =
        Term.fromInterval(term.interval.withTimeZone(IsoNewEngland.location));
    final ts = switch (location) {
      Location.massHub => await lmp.getHourlyLmp(Iso.newEngland, 4000,
          LmpComponent.lmp, hTerm.startDate, hTerm.endDate),
      _ => StateError('Unsupported location $location'),
    };
    cache[t2] = ts as TimeSeries<double>;
  }
  return cache[t2]!;
}

List<Map<String, dynamic>> makeTraces(
  Term term,
  Term historicalTerm,
  Location location,
  Market market,
  Bucket bucket,
  num strike,
  CallPut callPut,
  String optionType,
  Set<String> show,
) {
  final t2 = (location: location, market: market);
  final terms = getHistoricalTerms(term, historicalTerm);

  var traces = <Map<String, dynamic>>[];
  var tbl = <Map<String, dynamic>>[];
  for (var i = 0; i < terms.length; i++) {
    // calculate daily price for this bucket
    final ts = cache[t2]!
        .window(terms[i].interval)
        .where((e) => bucket.containsHour(e.interval as Hour))
        .toDaily(mean);

    if (optionType == 'Daily') {
      final payoff = switch (callPut) {
        CallPut.call => ts.apply((e) => math.max(e - strike, 0)),
        CallPut.put => ts.apply((e) => math.max(strike - e, 0)),
        _ => throw StateError('Wrong value for $callPut'),
      };

      var y = payoff.values.toList();
      final meanY = y.mean();
      layout['yaxis']['title'] = 'Daily payoff, \$/MWh';
      if (show.contains('Sorted')) {
        y.sort((a, b) => -a.compareTo(b));
        layout['yaxis']['title'] = 'Daily payoff (sorted), \$/MWh';
      }
      if (show.contains('Cumulative')) {
        y = cumSum(y).toList();
        layout['yaxis']['title'] = 'Cumulative ${layout['yaxis']['title']}';
      }
      traces.add({
        'x': List.generate(ts.length, (i) => i + 1),
        'y': y,
        'name': terms[i].toString(),
        'text': ts.map((e) => e.interval.toString()).toList(),
        'type': 'bar',
      });

      tbl.add({
        'Term': terms[i],
        'Value, \$/MWh': meanY,
        'dailyPrice': ts,
        'dailyPayoff': payoff,
      });

      //
      //
      //
      //
    } else if (optionType == 'Average Price') {
      final avgPrice = TimeSeries.from(ts.intervals, cumMean(ts.values));
      final payoff = switch (callPut) {
        CallPut.call => avgPrice.apply((e) => math.max(e - strike, 0)),
        CallPut.put => avgPrice.apply((e) => math.max(strike - e, 0)),
        _ => throw StateError('Wrong value for $callPut'),
      };
      var y = payoff.values.toList();
      layout['yaxis']['title'] = 'Average payoff, \$/MWh';
      traces.add({
        'x': List.generate(ts.length, (i) => i + 1),
        'y': y,
        'name': terms[i].toString(),
        'text': ts.map((e) => e.interval.toString()).toList(),
        'type': 'bar',
      });
      //
      //
      //
      //
    } else if (optionType == 'Monthly') {
      // What to do here?
    }
  }
  tableData.value = [...tbl];
  return traces;
}

/// Default forward term for the option, in UTC
Term getDefaultTerm() {
  final month = Date.today(location: UTC).month;
  final year = Date.today(location: UTC).year;
  late final Date start, end;
  if (month <= 6) {
    start = Date.utc(year, 7, 1);
    end = Date.utc(year, 8, 31);
  } else {
    start = Date.utc(year + 1, 1, 1);
    end = Date.utc(year + 1, 3, 1).previous;
  }
  return Term(start, end);
}

// in UTC
Term getDefaultHistoricalTerm() {
  final year = Date.today(location: UTC).year;
  final start = Date.utc(year - 6, 1, 1);
  final end = Date.today(location: UTC);
  return Term(start, end);
}

num getDefaultStrikePrice(Location location, Term term) {
  if (term.startDate.month < 3) {
    return switch (location) {
      Location.massHub => 150,
      _ => 100,
    };
  } else {
    return switch (location) {
      Location.massHub => 100,
      _ => 75,
    };
  }
}

/// Get the comparable terms from history.
/// For example, if [forwardTerm] is Jul24-Aug24, and [historicalTerm] is
/// Jan18-Dec23, the function will return
/// [Jul18-Aug18, Jul19-Aug19, ..., Jul23-Aug23].
///
/// Special care should be taken when the [forwardTerm] crosses a New Year, e.g.
/// Dec23-Feb24.
///
List<Term> getHistoricalTerms(Term forwardTerm, Term historicalTerm) {
  final startYear = historicalTerm.startDate.year;
  final endYear = historicalTerm.endDate.year;
  final years = List.generate(endYear - startYear + 1, (i) => startYear + i);

  var terms = Term.generate(
      years: years,
      monthRange: (forwardTerm.startDate.month, forwardTerm.endDate.month),
      location: forwardTerm.location);
  if (terms.last.endDate.isAfter(forwardTerm.startDate)) {
    terms.removeLast();
  }

  return terms;
}

final Map<String, dynamic> layout = {
  'width': 900,
  'height': 600,
  'title': '',
  'xaxis': {
    'title': 'Day in term',
    'showgrid': true,
  },
  'yaxis': {
    'showgrid': true,
    'zeroline': false,
    'title': '',
  },
  'showlegend': true,
  // 'legend': {
  //   'orientation': 'h',
  //   'xanchor': 'center',
  //   'x': 0.5,
  //   'y': 1.1,
  //   'traceorder': 'reversed',
  // },
  'barmode': 'stack',
  'hovermode': 'closest',
  // 'margin': {
  //   't': 40,
  // },
};
