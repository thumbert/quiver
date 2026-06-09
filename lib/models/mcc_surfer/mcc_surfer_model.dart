import 'package:dama/stat/descriptive/summary.dart';
import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec_server/client/dacongestion.dart';
import 'package:elec_server/client/other/ptids.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
// import 'package:flutter_quiver/main.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';

final term = signal(getDefaultTerm(), debugLabel: 'term');
final region = signal('NYISO', debugLabel: 'region');
final zones = signal<List<String>>(getAllZoneNames(), debugLabel: 'zones');

/// How precise is the series resolution for the selected interval.
/// Value is in $ lost over the term.  Less is better.
final resolution = signal(0, debugLabel: 'resolution');

/// How many curves are currently displayed
final displayedCurvesCount = signal(0, debugLabel: 'displayedCurvesCount');

///
final projectionCount = signal(100, debugLabel: 'projectionCount');

final traces = FutureSignal<List<Map<String, dynamic>>>(makeTraces,
    dependencies: [region, term]);

/// Get the data and make the Plotly hourly traces.
/// For reference, getting one full month takes less than 800 ms, the first
/// time.  The second time (from the cache on the server) it only takes 70 ms.
/// This method also gets called when different constraints from the table are
/// selected/unselected.
///
/// You can specify [loadZonePtid] to return the traces for the ptids in this
/// zone only.
/// Return only the top [projectionCount] most 'dissimilar' curves.
///
Future<List<Map<String, dynamic>>> makeTraces() async {
  var ptidMap = await getPtidMap(region.value);

  var currentTerm = term.value;
  var rawTraces = await mccClient.value
      .getHourlyTraces(currentTerm.startDate, currentTerm.endDate);
  // customize the display on hover
  for (var e in rawTraces) {
    var ptid = e['ptid'] as int;
    if (ptidMap.containsKey(ptid)) {
      var entry = ptidMap[ptid]!;
      e['name'] = '';
      e['text'] = '${entry['name']}, ptid: ${e['ptid']}';
      if (entry.containsKey('zonePtid')) {
        e['zonePtid'] = entry['zonePtid']; // need it for the zone filter
        e['text'] += ', zone: ${ptidMap[entry['zonePtid']]!['name']}';
      }
      if (entry.containsKey('rspArea')) {
        e['text'] += ', subzone: ${entry['rspArea']}';
      }
    } else {
      e['text'] = 'ptid: ${e['ptid']}';
    }
    e['mode'] = 'lines';
  }

  var filteredTraces = List<Map<String, dynamic>>.from(rawTraces);
  if (zones.value.length != getAllZoneNames().length) {
    // get only the ptids in the selected zones
    final zonalPtids = zones.value
        .map((zoneName) => Iso.parse(region.value).loadZones[zoneName]!)
        .toSet();
    filteredTraces = filteredTraces
        .where((e) => zonalPtids.contains(e['zonePtid'] as int))
        .toList();
  }
  return reduceTraces(filteredTraces, projectionCount.value);
}

/// A quick and dirty algorithm for curve classification.  Ideally we should
/// use k-means or similar, but it will be slow.  This approach calculates the
/// cumulative sum of absolute value of the congestion and groups the terminal
/// values to extract/sample the top [projectionCount] curves from the groups.
///
/// For example for Nov21 the 1206 ISONE congestion curves were reduced to
/// 100 curves.  On the last curve retained after the reduction the
/// difference between it and the previous curve was $2.  Totally worth it!
List<Map<String, dynamic>> reduceTraces(
    List<Map<String, dynamic>> traces, int projectionCount) {
  resolution.value = 0; // reset it
  displayedCurvesCount.value = traces.length;
  if (projectionCount >= traces.length) {
    return traces;
  }

  var tValue = <Map<String, dynamic>>[];
  for (var i = 0; i < traces.length; i++) {
    var ys = (traces[i]['y'] as List).cast<num>();
    tValue.add({'index': i, 'value': sum(ys)});
  }

  /// sort them ascending by terminal values
  tValue.sort((a, b) => a['value']!.compareTo(b['value']!));

  /// take the difference between terminal values
  var diff = <Map<String, dynamic>>[];
  for (var i = 1; i < tValue.length; i++) {
    diff.add({
      'fromIndex': tValue[i - 1]['index'],
      'toIndex': tValue[i]['index'],
      'diff': tValue[i]['value']! - tValue[i - 1]['value']!,
    });
  }

  /// sort descending the differences
  diff.sort((a, b) => -a['diff'].compareTo(b['diff']));

  /// Select curves going down the diff vector until you have enough curves.
  /// Always have the lowest/highest variation curves.
  var iSelected = <int>{
    tValue.first['index'] as int,
    tValue.last['index'] as int,
  };
  var i = 0;
  while (iSelected.length < projectionCount) {
    iSelected.add(diff[i]['fromIndex']);
    iSelected.add(diff[i]['toIndex']);
    i++;
  }

  var out = <Map<String, dynamic>>[];
  for (var i in iSelected.take(projectionCount)) {
    out.add(traces[i]);
  }
  // on the last selected spacing, what is the 'distance' between curves
  resolution.value = (diff[i]['diff'] as num).round();
  displayedCurvesCount.value = out.length;
  return out;
}

final mccClient = computed(() {
  return DaCongestion(http.Client(),
      iso: Iso.parse(region.value),
      rootUrl: dotenv.env['ROOT_URL'] as String,
      rustServer: dotenv.env['RUST_SERVER'] as String);
}, debugLabel: 'mccClient');

///
Future<Map<int, Map<String, dynamic>>> getPtidMap(String region) async {
  if (!_cachePtidMap.containsKey(region)) {
    var aux = await ptidClient.getPtidTable(region: region.toLowerCase());
    var ptidMap = {for (var e in aux) e['ptid'] as int: e};
    _cachePtidMap[region] = ptidMap;
  }
  return _cachePtidMap[region]!;
}

final ptidClient =
    PtidsApi(http.Client(), rootUrl: dotenv.env['ROOT_URL'] as String);

final allRegions = {'ISONE', 'NYISO'};
List<String> getAllZoneNames() {
  if (region.value == 'NYISO') {
    return Iso.newYork.loadZones.keys.toList();
  } else if (region.value == 'ISONE') {
    return Iso.newEngland.loadZones.keys.toList();
  } else {
    throw ArgumentError('Unknown region: ${region.value}');
  }
}

/// (ptid -> hourly timeseries of mcc).
/// Cache clears when term or region changes.
final cacheTs = <int, TimeSeries<num>>{};

/// A cache with Region -> ptid -> data
final _cachePtidMap = <String, Map<int, Map<String, dynamic>>>{};

/// in UTC
Term getDefaultTerm() {
  final today = Date.today(location: UTC);
  return Term.fromInterval(Month.utc(today.year, today.month));
}

final Map<String, dynamic> layout = {
  'width': 900,
  'height': 600,
  'margin': {
    't': 10,
    'l': 50,
    'r': 20,
    'pad': 4,
  },
  'yaxis': {
    'title': {'text': 'Congestion Price, \$/MWh'},
  },
  'showlegend': false,
  'hovermode': 'closest',
  'shapes': [],
  'displaylogo': false,
};
