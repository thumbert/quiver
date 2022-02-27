library models.weather;

import 'package:date/date.dart';
import 'package:elec/calculators/weather.dart';
import 'package:elec/risk_system.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_quiver/models/weather/month_range_model.dart';
import 'package:flutter_quiver/models/weather/weather_deal.dart';
import 'package:http/http.dart';
import 'package:elec_server/client/weather/noaa_daily_summary.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';
import 'package:tuple/tuple.dart';
import 'package:elec/src/weather/lib_weather_utils.dart';

class WeatherModel extends ChangeNotifier {
  WeatherModel() {
    client = NoaaDailySummary(Client(), rootUrl: dotenv.env['ROOT_URL']!);
  }

  late List<WeatherDeal> deals;
  late NoaaDailySummary client;

  /// airportCode -> 30 years of history
  final _cacheTemps = <String, TimeSeries<num>>{};
  final _cacheSummaryTable =
      <Tuple2<String, String>, List<Map<String, dynamic>>>{};

  // late Iterable<Map<String,dynamic>> _tableData;

  /// Calculate the 30y, 20y, 10y, 5y HDD or CDD averages for this location
  ///
  Future<List<Map<String, dynamic>>> getSummaryData(
      {required int row, List<Interval>? terms}) async {
    var _airports = deals.map((e) => e.airport).toList();
    if (!_cacheTemps.containsKey(_airports[row])) {
      await getHistoricalTemperature(_airports[row]);
    }
    var deal = deals[row];
    deal.weatherInstrument.temperature = _cacheTemps[deal.airport]!;

    var monthRange = MonthRangeModel.ranges[deal.monthRange]!;
    // get last 30 terms, if not specified
    terms ??= makeHistoricalTerm(monthRange[0], monthRange[1], n: 30);

    var out = <Map<String, dynamic>>[];
    for (var term in terms) {
      var one = {
        'airport': deal.airport,
        'term': Term.fromInterval(term).toString(),
        'value': deal.cappedValue(term),
      };

      /// add the HDD or CDD value for the term
      if (deal.instrumentType.contains('HDD')) {
        var swap = HddSwap(
            buySell: BuySell.buy,
            term: term,
            quantity: 1,
            strike: TimeSeries.fromIterable([IntervalTuple(term, 0)]))
          ..temperature = _cacheTemps[deal.airport]!;
        one['HDD'] = swap.value();
      } else if (deal.instrumentType.contains('HDD')) {
        var swap = CddSwap(
            buySell: BuySell.buy,
            term: term,
            quantity: 1,
            strike: TimeSeries.fromIterable([IntervalTuple(term, 0)]))
          ..temperature = _cacheTemps[deal.airport]!;
        one['CDD'] = swap.value();
      }
      out.add(one);
    }

    return out;
  }

  /// Make the historical 30 year table for the deals in the table.
  /// Given an airport code and a month start, end calculate some historical
  /// stats.  For example for Nov-Mar period, the [startMonth] is 11,
  /// [endMonth] is 3.
  /// Return term, tAvg, HDD, CDD, value_1, value_2, ..., value_all
  Future<List<Map<String, dynamic>>> make30YearTable() async {
    var _airports = deals.map((e) => e.airport).toList();
    for (var airportCode in _airports) {
      if (!_cacheTemps.containsKey(airportCode)) {
        await getHistoricalTemperature(airportCode);
      }
    }

    var out = <Map<String, dynamic>>[];

    /// TODO:  need to loop over the rows, and make the total interval be the
    /// union interval.  For example, if row 0 is Jan-Feb and row 1 is Dec-Mar,
    /// the term column in the table should be Dec-Mar.
    var deal = deals[0];
    deal.weatherInstrument.temperature = _cacheTemps[deal.airport]!;
    var monthRange = MonthRangeModel.ranges[deal.monthRange]!;
    var terms = makeHistoricalTerm(monthRange[0], monthRange[1], n: 30);

    for (var term in terms) {
      out.add({
        'airport': deal.airport,
        'term': Term.fromInterval(term),
        'value': deal.cappedValue(term),
      });
    }

    return [];
  }

  /// Copy the deal deal at location [index] one row down
  void copyRow(int index) {
    var deal = deals[index];
    deals.insert(index, deal);
    notifyListeners();
  }

  void removeAt(int index) {
    if (deals.length > 1) {
      deals.removeAt(index);
    }
    notifyListeners();
  }

  /// Get 30 years data from the webservice.
  Future<void> getHistoricalTemperature(String airportCode) async {
    if (!_cacheTemps.containsKey(airportCode)) {
      var _current = Month.fromTZDateTime(TZDateTime.now(UTC));
      var _start = _current.subtract(30 * 12 + 1).start;
      var _end = _current.start;
      var interval = Interval(_start, _end);
      _cacheTemps[airportCode] =
          await client.getDailyHistoricalTemperature(airportCode, interval);
    }
  }
}

// set term(String value) {
//   _term = value;
//   notifyListeners();
// }
//
// String get term => _term;
//
// set underlying(String value) {
//   _underlying = value;
//   notifyListeners();
// }
//
// String get underlying => _underlying;
//
// set instrument(String value) {
//   _instrument = value;
//   notifyListeners();
// }
//
// String get instrument => _instrument;
//
// set notional(num value) {
//   _notional = value;
//   notifyListeners();
// }
//
// num get notional => _notional;
//
// set maxPayoff(num value) {
//   _maxPayoff = value;
//   notifyListeners();
// }
//
// num get maxPayoff => _maxPayoff;
//
// set strike(num value) {
//   _strike = value;
//   notifyListeners();
// }
//
// num get strike => _strike;
