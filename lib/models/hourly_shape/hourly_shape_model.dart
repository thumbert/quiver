library models.hourly_shape.hourly_shape_model;

import 'package:collection/collection.dart';
import 'package:dama/dama.dart';
import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec/risk_system.dart';
import 'package:elec_server/client/isoexpress/zonal_demand.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/hourly_shape/day_filter.dart';
import 'package:flutter_quiver/models/hourly_shape/settings.dart';
import 'package:http/http.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';

class HourlyShapeModel {
  static Term term =
      Term.fromInterval(Interval(TZDateTime.utc(2020), TZDateTime.utc(2025)));

  /// Keep all the historical data.  Filtering happens later.
  static TimeSeries<num> ts = TimeSeries<num>();

  /// Map of Date to load values
  static Map<Date, List<num>> _dailyGroupsDemand = <Date, List<num>>{};

  // static Map<Date, List<num>> _dailyGroupsWeights = <Date, List<num>>{};

  static const allNames = <String>[
    'ISONE RT Demand, Pool',
    'ISONE RT Demand, zone: Maine',
    'ISONE RT Demand, zone: NH',
    'ISONE RT Demand, zone: VT',
    'ISONE RT Demand, zone: CT',
    'ISONE RT Demand, zone: RI',
    'ISONE RT Demand, zone: SEMA',
    'ISONE RT Demand, zone: WCMA',
    'ISONE RT Demand, zone: NEMA',
    'NYISO RT Demand, Pool',
    'NYISO RT Demand, zone A',
    'NYISO RT Demand, zone B',
    'NYISO RT Demand, zone C',
    'NYISO RT Demand, zone D',
    'NYISO RT Demand, zone E',
    'NYISO RT Demand, zone F',
    'NYISO RT Demand, zone G',
    'NYISO RT Demand, zone H',
    'NYISO RT Demand, zone I',
    'NYISO RT Demand, zone J',
    'NYISO RT Demand, zone K',
    'IESO RT Demand, Pool',
    'IESO RT Demand, zone: Bruce',
    'IESO RT Demand, zone: East',
    'IESO RT Demand, zone: Essa',
    'IESO RT Demand, zone: Niagara',
    'IESO RT Demand, zone: Northeast',
    'IESO RT Demand, zone: Northwest',
    'IESO RT Demand, zone: Ottawa',
    'IESO RT Demand, zone: Southwest',
    'IESO RT Demand, zone: Toronto',
    'IESO RT Demand, zone: West',
    'PJM RT Demand, Pool',
    'PJM RT Demand, zone: AECO',
    'PJM RT Demand, zone: AEP',
    'PJM RT Demand, zone: ATSI',
    'PJM RT Demand, zone: BGE',
    'PJM RT Demand, zone: COMED',
    'PJM RT Demand, zone: DAY',
    'PJM RT Demand, zone: DEOK',
    'PJM RT Demand, zone: DOM',
    'PJM RT Demand, zone: DPL',
    'PJM RT Demand, zone: DUQ',
    'PJM RT Demand, zone: EKPC',
    'PJM RT Demand, zone: JCPL',
    'PJM RT Demand, zone: METED',
    'PJM RT Demand, zone: OVEC',
    'PJM RT Demand, zone: PECO',
    'PJM RT Demand, zone: PENELEC',
    'PJM RT Demand, zone: PEPCO',
    'PJM RT Demand, zone: PPL',
    'PJM RT Demand, zone: PSEG',
    'PJM RT Demand, zone: RECO',
  ];

  static Future<TimeSeries<num>> getData(String seriesName) async {
    if (ts.isEmpty) {
      _dailyGroupsDemand = <Date, List<num>>{};
      if (seriesName.startsWith('ISONE RT Demand')) {
        final start = Date(
            term.startDate.year, term.startDate.month, term.startDate.day,
            location: IsoNewEngland.location);
        final end = Date(
            term.endDate.year, term.endDate.month, term.endDate.day,
            location: IsoNewEngland.location);
        final client =
            IsoneZonalDemand(Client(), rootUrl: dotenv.env['ROOT_URL']!);
        if (seriesName.contains('Pool')) {
          ts = await client.getPoolDemand(Market.rt, start, end);
        } else {
          var zoneName = seriesName.replaceAll('ISONE RT Demand, zone: ', '');
          var ptid = Iso.newEngland.loadZones[zoneName]!;
          ts = await client.getZonalDemand(ptid, Market.rt, start, end);
        }
        //
        //
      } else if (seriesName.startsWith('NYISO RT Demand')) {
      } else {
        throw StateError('Series $seriesName not yet supported!');
      }
      var aux = groupBy(ts, (e) => Date.containing(e.interval.start));
      _dailyGroupsDemand = aux.map(
          (key, value) => MapEntry(key, value.map((f) => f.value).toList()));
    }
    return ts;
  }

  static List<Map<String, dynamic>> getTraces(
      DayFilter dayFilter, Settings settings) {
    return switch (settings) {
      SettingsIndividualDays() => _getTracesWeightsByDay(dayFilter),
      SettingsForMedianByYear() => _getTracesMedianByYear(dayFilter),
    };
  }

  static List<Map<String, dynamic>> _getTracesWeightsByDay(
      DayFilter dayFilter) {
    var traces = <Map<String, dynamic>>[];
    var aux = dayFilter.getDays(Term.fromInterval(
        term.interval.withTimeZone(_dailyGroupsDemand.keys.first.location)));
    var days = _dailyGroupsDemand.keys.toSet().intersection(aux.toSet());
    for (var day in days) {
      var v = _dailyGroupsDemand[day]!;
      var avg = v.mean();
      var weights = v.map((e) => e / avg).toList();
      traces.add({
        'x': List.generate(weights.length, (i) => i),
        'y': weights,
        'date': day.toString(),
        'mode': 'lines',
        'name': day.toString(),
        'line': {
          // 'color': '#b0b0b0', // gray
          'color': '#add8e6', // light blue
        },
        'showlegend': false,
      });
    }

    /// append the last trace to use for highlighting!
    traces.add(Map<String, dynamic>.from(traces.last));
    return traces;
  }

  /// Calculate the median of each hour's demand, say 24 values.  Then calculate
  /// the weights from that list of 24 values.  (It does not calculate the
  /// weights first for each day and then takes the median of each weight for
  /// each hour)
  ///
  /// Note:
  ///  - Because this is a summary statistic over many days, ignore the 25 hour
  ///    in Nov.  Just skip it.
  ///
  static List<Map<String, dynamic>> _getTracesMedianByYear(
      DayFilter dayFilter) {
    var traces = <Map<String, dynamic>>[];

    var aux = dayFilter.getDays(Term.fromInterval(
        term.interval.withTimeZone(_dailyGroupsDemand.keys.first.location)));
    var days = _dailyGroupsDemand.keys.toSet().intersection(aux.toSet());

    /// split the days by year,
    var byYear = groupBy(days, (e) => e.year);
    for (var year in byYear.keys) {
      var summary = <num>[];
      var ws = byYear[year]!.map((day) => _dailyGroupsDemand[day]!).toList();

      for (var hour = 0; hour < 24; hour++) {
        var xs = <num>[];
        for (var i = 0; i < ws.length; i++) {
          if (ws[i].length > hour) {
            xs.add(ws[i][hour]);
          }
        }
        var quantile = Quantile(xs);
        summary.add(quantile.median());
      }
      var meanSummary = mean(summary);
      var summaryWeight = summary.map((e) => e / meanSummary).toList();

      traces.add({
        'x': List.generate(summaryWeight.length, (index) => index),
        'y': summaryWeight,
        'mode': 'lines',
        'name': '$year',
      });
    }

    return traces;
  }

  /// calculate the size of the duck curve as a timeseries
  static List<Map<String, dynamic>> _getTracesDuckSize(DayFilter dayFilter) {
    var aux = dayFilter.getDays(Term.fromInterval(
        term.interval.withTimeZone(_dailyGroupsDemand.keys.first.location)));
    var days = _dailyGroupsDemand.keys.toSet().intersection(aux.toSet());

    var x = <String>[];
    var y = <num>[];
    for (var day in days) {
      x.add(day.toString());
      var v = _dailyGroupsDemand[day]!;
      var avg = v.mean();
      var weights = v.map((e) => e / avg).toList();
      y.add(weights.skip(7).take(10).sum);
      // even better, calculate the lenght of the curve between hour 7 and 18!
    }

    return [{
      'x': x,
      'y': y, 
      'mode': 'markers',
      'type': 'scatter',
    }];
  }

  static final layout = {
    'width': 900,
    'height': 600,
    'title': '',
    'xaxis': {
      'showgrid': true,
      'gridcolor': '#d3d3d3',
      'title': 'Hour beginning',
    },
    'yaxis': {
      'showgrid': true,
      'gridcolor': '#d3d3d3',
      'zeroline': false,
      'title': 'Hourly weight',
    },
    // 'margin': {
    //   't': 40,
    // },
    'showlegend': true,
    'hovermode': 'closest',
  };
}
