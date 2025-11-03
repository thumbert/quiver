import 'dart:convert';

import 'package:dama/stat/descriptive/summary.dart';
import 'package:date/date.dart';
import 'package:elec/analysis.dart' as seasonal;
import 'package:elec/elec.dart';
import 'package:elec/time.dart';
import 'package:elec_server/client/lmp.dart';
import 'package:elec_server/client/other/ptids.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:signals/signals_flutter.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';
import 'package:elec/risk_system.dart';
import 'package:http/http.dart';

final class LocationRow {
  LocationRow({
    required this.region,
    required this.location,
    required this.market,
  });

  final String? region;
  final String? location;
  final Market? market;

  static List<String> locations(String? region) {
    if (region == null) {
      return [];
    }
    return ptidCache[region] ?? [];
  }

  static final ptidClient =
      PtidsApi(Client(), rootUrl: dotenv.env['ROOT_URL']!);

  /// Map from region -> List of locations,
  /// e.g. for 'ISONE' : ['.H.INTERNAL HUB, ptid: 4000', ...]
  static Map<String, List<String>> ptidCache = <String, List<String>>{
    'IESO': [],
    'ISONE': ['.H.INTERNAL_HUB, ptid: 4000'],
    'NYISO': ['Zone G, ptid: 61758'],
    'PJM': ['WESTERN HUB, ptid: 51288'],
  };

  bool isValid() {
    return region != null && location != null && market != null;
  }

  // For ISONE, location is like ".H.INTERNAL_HUB, ptid: 4000"
  static int getPtid(String location) {
    final parts = location.split(', ptid: ');
    if (parts.length != 2) {
      throw ArgumentError('Location string is malformed: $location');
    }
    final ptidStr = parts[1].trim();
    return int.parse(ptidStr);
  }

  static Future<void> populatePtidCache(String region) async {
    if (ptidCache[region]!.length == 1) {
      var xs = <String>[];
      if (region == 'IESO') {
        var res = await get(
            Uri.parse('${dotenv.env['RUST_SERVER']}/ieso/node_table/all'));
        var aux = (json.decode(res.body) as List).cast<Map<String, dynamic>>();
        ptidCache[region] = aux.map((e) => e['name'] as String).toList();
        return;
      }

      Iterable<Map> aux =
          await ptidClient.getPtidTable(region: region.toLowerCase());
      if (region == 'NYISO') {
        /// add the zones first, in a spoken form
        var zones = aux.where((e) => e['type'] == 'zone');
        for (var zone in zones) {
          if (zone.containsKey('spokenName')) {
            var label = '${zone['spokenName']}, ptid: ${zone['ptid']}';
            xs.add(label);
          }
        }
      }
      if (region == 'ISONE') {
        aux = aux.where((e) => e['ptid'] < 7000 || e['ptid'] >= 8000);
      }
      xs.addAll(aux.map((e) => '${e['name']}, ptid: ${e['ptid']}'));
      ptidCache[region] = xs;
      // print('Populated ${xs.length} locations for region $region');
    }
  }
}

class HistoricalLmpModel {
  HistoricalLmpModel({
    required this.sink,
    required this.source,
    required this.bucketNames,
    required this.lmpComponent,
    required this.historicalTerm,
    required this.timeAggregation,
  });

  final LocationRow sink;
  final LocationRow? source;
  final String bucketNames;
  final String lmpComponent;
  final Term historicalTerm;
  final String timeAggregation;

  /// Store the historical data.
  /// The key is (region, location, market, lmpComponent)
  static Map<
      ({String lmpComponent, String location, Market market, String region}),
      TimeSeries<num>> cache = <({
    String region,
    String location,
    Market market,
    String lmpComponent
  }),
      TimeSeries<num>>{};

  static final allBuckets = {
    'ATC': [Bucket.atc],
    'Peak, Offpeak': [Bucket.b5x16, Bucket.offpeak],
    '5x16, 2x16H, 7x8': [Bucket.b5x16, Bucket.b2x16H, Bucket.b7x8],
    '2x16H / 5x16': [Bucket.b5x16, Bucket.b2x16H],
    '7x8 / 7x24': [Bucket.b7x8, Bucket.atc],
    '5xHE10-17 / 5x16': [Bucket.b5xHE1017, Bucket.b5x16],
    '5xHE10-15, 5xHE18-22': [Bucket.b5xHE1017, Bucket.b5xHE1822],
    '7xHE10-17 / 7x16': [Bucket.b7xHE1017, Bucket.b7x16],
    '7xHE18-22, 7xHE18-22': [Bucket.b7xHE1822, Bucket.b7xHE1822],
  };

  static const allLmpComponents = {
    'LMP': LmpComponent.lmp,
    'Congestion': LmpComponent.congestion,
    'Loss': LmpComponent.loss,
    'Loss%': LmpComponent.lossPercent,
    'Energy': LmpComponent.energy
  };

  static const allDart = ['DA', 'RT'];

  static const allTimeAggregations = ['Monthly', 'Daily', 'Hourly'];

  static final regionDefaults = <String, Map<String, String>>{
    // 'IESO': {
    //   'location': 'ONTARIO',
    //   'dart': 'DA',
    // },
    'ISONE': {
      'location': '.H.INTERNAL_HUB, ptid: 4000',
      'dart': 'DA',
    },
    'NYISO': {
      'location': 'Zone G, ptid: 61758',
      'dart': 'DA',
    },
    'PJM': {
      'location': 'WESTERN HUB, ptid: 51288',
      'dart': 'RT',
    },
  };

  ///
  ///
  List<Map<String, dynamic>> makeTraces(Map<Bucket, TimeSeries<num>> xs) {
    var traces = <Map<String, dynamic>>[];
    if (bucketNames.contains(' / ')) {
      if (timeAggregation == 'Monthly') {
        final data = xs[allBuckets[bucketNames]!.first]! /
            xs[allBuckets[bucketNames]!.last]!;
        traces.add({
          'x': data.map((e) => e.interval.start.toString().substring(0, 7)),
          'y': data.map((e) => e.value),
          'mode': 'lines',
          'name': bucketNames,
        });
      } else if (timeAggregation == 'Daily') {
        var data = dailyFormat(xs);
        traces.add({
          'x': data.map((e) => e['Date']).toList(),
          'y': data.map((e) => e[bucketNames]).toList(),
          'mode': 'lines+markers',
          'name': bucketNames,
        });
      }
    } else {
      if (timeAggregation == 'Monthly') {
        for (var bucket in xs.keys) {
          var data = xs[bucket]!;
          traces.add({
            'x': data.map((e) => e.interval.start.toString().substring(0, 7)),
            'y': data.map((e) => e.value),
            'mode': 'lines',
            'name': bucket.name,
          });
        }
      } else if (timeAggregation == 'Daily') {
        var data = mergeAll(xs);
        for (var bucket in allBuckets[bucketNames]!) {
          traces.add({
            'x': data.map((e) => e.interval.start.toString().substring(0, 10)),
            'y': data.map((e) => e.value[bucket]),
            'mode': 'lines+markers',
            'name': bucket.name,
          });
        }
      } else if (timeAggregation == 'Hourly') {
        var data = xs[Bucket.atc]!;
        traces.add({
          'x': data.map((e) => e.interval.start.toIso8601String()),
          'y': data.map((e) => e.value),
          'mode': 'lines',
          'name': '',
        });
      }
    }
    return traces;
  }

  /// Aggregate by time the input hourly timeseries [ts]
  Map<Bucket, TimeSeries<num>> aggregateData(TimeSeries<num> ts) {
    if (lmpComponent == 'Loss%') {
      ts = TimeSeries.fromIterable(ts.where((e) => e.value.isFinite));
    }

    if (timeAggregation == 'Monthly') {
      return monthlyPrice(ts, buckets: allBuckets[bucketNames]!);
      //
      //
    } else if (timeAggregation == 'Daily') {
      var data = splitByBucket(ts, allBuckets[bucketNames]!);
      var out = <Bucket, TimeSeries<num>>{};
      for (var bucket in data.keys) {
        out[bucket] =
            toDaily(TimeSeries<num>.fromIterable(data[bucket]!), mean);
      }
      return out;
      //
      //
    } else if (timeAggregation == 'Hourly') {
      return {Bucket.atc: ts};
    } else {
      throw StateError('Unsupported time aggregation $timeAggregation');
    }
  }

  /// Calculate the monthly price by bucket.
  ///
  /// [x] can be a daily, hourly, or sub-hourly timeseries.
  ///
  /// If [buckets] are not specified, get the 5x16, 2x16H, 7x8 buckets.
  ///
  /// If [f] is not specified, mean average price is calculated.
  Map<Bucket, TimeSeries<num>> monthlyPrice(TimeSeries<num> x,
      {List<Bucket>? buckets, num Function(Iterable<num>)? f}) {
    f ??= mean;
    buckets ??= <Bucket>[
      IsoNewEngland.bucket5x16,
      IsoNewEngland.bucket2x16H,
      IsoNewEngland.bucket7x8
    ];
    var data = splitByBucket(x, buckets);

    var out = <Bucket, TimeSeries<num>>{};
    for (var bucket in data.keys) {
      out[bucket] = toMonthly(TimeSeries<num>.fromIterable(data[bucket]!), f);
    }

    return out;
  }

  /// For example for '5xHE10-17 / 5x16', return a table with rows:
  ///   {'date': '2022-01-03', '5xHE10-17': 79.225, '5x16': 90.345, '5xHE10-17 / 5x16': 0.87},
  ///
  /// For 'Peak, Offpeak', return a table with rows:
  ///   {'date': '2022-01-01', 'Peak': 321.16, 'Offpeak': 275.12},
  ///
  List<Map<String, dynamic>> dailyFormat(Map<Bucket, TimeSeries<num>> xs) {
    var aux = mergeAll(xs);
    final isRatio = bucketNames.contains(' / ');
    var res = <Map<String, dynamic>>[];
    for (var e in aux) {
      var one = {
        'Date': e.interval.start.toIso8601String().substring(0, 10),
        ...e.value.map((key, value) => MapEntry(key.toString(), value)),
      };
      if (isRatio && e.value.length == 2) {
        // can calculate the ratio as both buckets exist for this day
        one[bucketNames] = e.value[allBuckets[bucketNames]!.first]! /
            e.value[allBuckets[bucketNames]!.last]!;
      }
      res.add(one);
    }
    return res;
  }

  /// Calculate the tables to display.
  /// If [buckets] contains a list of buckets separated by, return one table
  ///   for each bucket.
  /// If [buckets] contains a ratio of buckets, return one table for the ratio.
  /// 
  Map<String, List<Map<String, dynamic>>> makeTables(
      Map<Bucket, TimeSeries<num>> xs) {
    var out = <String, List<Map<String, dynamic>>>{};
    if (bucketNames.contains(' / ')) {
      final ratio = xs[allBuckets[bucketNames]!.first]! /
          xs[allBuckets[bucketNames]!.last]!;
      if (timeAggregation == 'Monthly') {
        var data = seasonal.formatYearMonth(ratio);
        // Add the Calendar year value
        var calPrice = toYearly(ratio, mean);
        var cpMap = {for (var e in calPrice) e.interval.start.year: e.value};
        for (var row in data) {
          row['Cal'] = cpMap[row['Year'] as int]!;
        }
        out[bucketNames] = data;
      } else if (timeAggregation == 'Daily') {
        out['Daily'] = dailyFormat(xs);
      }
      //
      //
      //
    } else {
      if (timeAggregation == 'Monthly') {
        ///
        for (var bucket in xs.keys) {
          var data = seasonal.formatYearMonth(xs[bucket]!);
          // Add the Calendar year value if you have all the months
          var calPrice = toYearly(xs[bucket]!, mean);
          var cpMap = {for (var e in calPrice) e.interval.start.year: e.value};
          for (var row in data) {
            row['Cal'] = cpMap[row['Year'] as int]!;
          }
          out[bucket.toString()] = data;
        }
      } else if (timeAggregation == 'Daily') {
        out['Daily'] = dailyFormat(xs);
      } else if (timeAggregation == 'Hourly') {
        out['Hourly'] = xs.entries.first.value
            .map((e) => {
                  'HourBeginning': e.interval.start.toIso8601String(),
                  'Value': e.value,
                })
            .toList();
      }
    }

    /// Don't do anything for hourly data, use the plot for that
    return out;
  }

  /// For the table
  List<String> getColumns() {
    if (timeAggregation == 'Monthly') {
      return [
        'Year',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
        'Cal'
      ];
    } else if (timeAggregation == 'Daily') {
      return ['Date', ...allBuckets[bucketNames]!.map((e) => e.toString())];
    } else if (timeAggregation == 'Hourly') {
      return [
        'HourBeginning',
        ...allBuckets[bucketNames]!.map((e) => e.toString())
      ];
    } else {
      throw StateError('Unsupported time aggregation $timeAggregation');
    }
  }

  Map<String, dynamic> layout() => {
        'width': 1000,
        'height': 600,
        'title': '',
        'xaxis': {
          'title': '',
          'showgrid': true,
        },
        'yaxis': {
          'showgrid': true,
          'zeroline': false,
          'title': lmpComponent == 'Loss%' ? 'Loss%' : '\$/MWh',
        },
        'showlegend': true,
        'hovermode': 'closest',
      };
}

final state = signal(getDefaultHistoricalLmpModel());

final locationsSink = futureSignal(() async {
  final region = state.value.sink.region!;
  await LocationRow.populatePtidCache(region);
  return LocationRow.ptidCache[region]!;
}, dependencies: [state]);

final locationsSource = futureSignal(() async {
  final region = state.value.source?.region;
  if (region == null) return <String>[];
  await LocationRow.populatePtidCache(region);
  return LocationRow.ptidCache[region]!;
}, dependencies: [state]);

/// What to plot
final hourlyLmp = futureSignal(() async {
  try {
    return await getLmpData(state.value);
  } catch (e) {
    rethrow;
  }
}, dependencies: [state]);

Future<TimeSeries<num>> getLmpData(HistoricalLmpModel state) async {
  final lmp = Lmp(Client(), rustServer: dotenv.env['RUST_SERVER']!);
  final hTerm = Term.fromInterval(
      state.historicalTerm.interval.withTimeZone(IsoNewEngland.location));

  var sink = (
    region: state.sink.region!,
    location: state.sink.location!,
    market: state.sink.market!,
    lmpComponent: state.lmpComponent
  );
  if (!HistoricalLmpModel.cache.containsKey(sink)) {
    // print('getting data for $sink');
    var ts = await lmp.getHourlyLmp(
        iso: Iso.newEngland,
        ptid: LocationRow.getPtid(state.sink.location!),
        component: LmpComponent.parse(state.lmpComponent),
        term: hTerm,
        market: state.sink.market!);
    HistoricalLmpModel.cache[sink] = ts;
  }
  var ts = HistoricalLmpModel.cache[sink]!;

  if (state.source != null && state.source!.isValid()) {
    var source = (
      region: state.source!.region!,
      location: state.source!.location!,
      market: state.source!.market!,
      lmpComponent: state.lmpComponent
    );
    late TimeSeries<num> tsSource;
    if (!HistoricalLmpModel.cache.containsKey(source)) {
      // print('getting data for $source');
      tsSource = await lmp.getHourlyLmp(
          iso: Iso.newEngland,
          ptid: LocationRow.getPtid(state.source!.location!),
          component: LmpComponent.parse(state.lmpComponent),
          term: hTerm,
          market: state.source!.market!);
      HistoricalLmpModel.cache[source] = tsSource;
    }
    tsSource = HistoricalLmpModel.cache[source]!;
    ts = ts - tsSource;
  }

  /// Treat this as a special case.  NYISO congestion is negative!
  if (state.sink.region == 'NYISO' &&
      state.source!.region == 'NYISO' &&
      state.lmpComponent == 'Congestion') {
    ts = TimeSeries.fromIterable(
        ts.map((e) => IntervalTuple(e.interval, -e.value)));
  }

  /// Filter to the desired historical term
  var defaultTerm = getDefaultHistoricalLmpModel().historicalTerm;
  if (state.historicalTerm.startDate.isAfter(defaultTerm.startDate) ||
      state.historicalTerm.endDate.isBefore(defaultTerm.endDate)) {
    /// TODO: make this more robust, not to assume America/New_York
    ts = TimeSeries.fromIterable(ts.window(
        state.historicalTerm.interval.withTimeZone(IsoNewEngland.location)));
  }

  return ts;
}

HistoricalLmpModel getDefaultHistoricalLmpModel() {
  final start = Date.utc(2021, 1, 1);
  final end = Date.today(location: UTC);
  return HistoricalLmpModel(
    sink: LocationRow(
      region: 'ISONE',
      location: '.H.INTERNAL_HUB, ptid: 4000',
      market: Market.da,
    ),
    source: LocationRow(region: null, location: null, market: null),
    bucketNames: 'ATC',
    lmpComponent: 'LMP',
    historicalTerm: Term(start, end),
    timeAggregation: 'Monthly',
  );
}
