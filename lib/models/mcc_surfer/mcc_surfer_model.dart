import 'package:collection/collection.dart';
import 'package:dama/stat/descriptive/summary.dart';
import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec_server/client/dacongestion.dart';
import 'package:elec_server/client/other/ptids.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:signals_flutter/signals_flutter.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';
import 'package:elec_server/client/nyiso/binding_constraints.dart' as ny_bc;

final term = signal(getDefaultTerm(), debugLabel: 'term');
final region = signal('NYISO', debugLabel: 'region');
final zones = signal<List<String>>(getAllZoneNames(), debugLabel: 'zones');
final selectedConstraints =
    signal<Set<String>>({}, debugLabel: 'selectedConstraints');
final focusNodeMcc = signal<String?>(null, debugLabel: 'focusNodeMcc');

/// For the lower plot of MCC vs. constraint cost
final focusNodeConstraint = signal<String?>('NINE_MILE_1, ptid: 23575',
    debugLabel: 'focusNodeConstraint');
final focusConstraint = signal<String?>('SCRIBA   345 VOLNEY   345 1',
    debugLabel: 'focusConstraint');

/// How precise is the series resolution for the selected interval.
/// Value is in $ lost over the term.  Less is better.
final resolution = signal(0, debugLabel: 'resolution');

/// How many curves are currently displayed
final displayedCurvesCount = signal(0, debugLabel: 'displayedCurvesCount');

///
final projectionCount = signal(100, debugLabel: 'projectionCount');

///
final filteredTracesCount = signal(0, debugLabel: 'filteredTracesCount');

final traces = FutureSignal<List<Map<String, dynamic>>>(makeTracesMcc,
    dependencies: [region, term, zones, focusNodeMcc], debugLabel: 'traces');

final topConstraintsTable = FutureSignal<List<Map<String, dynamic>>>(
  () async => getTopConstraints(),
  dependencies: [region, term],
  debugLabel: 'topConstraintsTable',
);

/// The set of all node key-name strings for the current region.
/// Derived from [traces]: once traces resolves, makeTraces() has already
/// populated [cachePtidMap], so no second network call is needed.
final nodeNameChoices = computed<Set<String>>(() {
  if (traces.value is AsyncData) {
    return cachePtidMap[region.value]
            ?.values
            .map<String>((e) => e['keyName'] as String)
            .toSet() ??
        {};
  }
  return {};
}, debugLabel: 'nodeNameChoices');

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
Future<List<Map<String, dynamic>>> makeTracesMcc() async {
  var ptidMap = await getPtidMap(region.value);

  late List<Map<String, dynamic>> rawTraces;
  if (cacheTraces.isNotEmpty) {
    rawTraces = cacheTraces;
  } else {
    rawTraces = await mccClient.value
        .getHourlyTraces(term.value.startDate, term.value.endDate);
    // customize the display on hover
    for (var e in rawTraces) {
      var ptid = e['ptid'] as int;
      if (ptidMap.containsKey(ptid)) {
        var entry = ptidMap[ptid]!;
        e['name'] = entry['name'];
        e['text'] = entry['keyName'] ?? entry['name'];
        if (entry.containsKey('zonePtid')) {
          e['zonePtid'] = entry['zonePtid']; // need it for the zone filter
        }
        if (entry.containsKey('rspArea')) {
          e['text'] += ', subzone: ${entry['rspArea']}';
        }
      } else {
        e['text'] = 'ptid: ${e['ptid']}';
      }
      e['mode'] = 'lines';
    }
    cacheTraces.clear();
    cacheTraces.addAll(rawTraces);
  }

  var filteredTraces = List<Map<String, dynamic>>.from(rawTraces);
  if (zones.value.length != getAllZoneNames().length) {
    // get only the ptids in the selected zones
    final zonalPtids = zones.value
        .map((zoneName) => Iso.parse(region.value).loadZones[zoneName]!)
        .toSet();
    filteredTraces = filteredTraces
        .where((e) =>
            e['zonePtid'] != null && zonalPtids.contains(e['zonePtid'] as int))
        .toList();
  }
  filteredTracesCount.value = filteredTraces.length;

  // if you have a focus location
  var focusTrace =
      rawTraces.firstWhereOrNull((e) => e['text'] == focusNodeMcc.value);
  if (focusTrace != null) {
    focusTrace['line'] = {
      'color': 'black',
      'size': 3,
    };
  }

  return [
    ...reduceTraces(filteredTraces, projectionCount.value),
    if (focusTrace != null) focusTrace
  ];
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

/// Get the constraints for the [term] from the database.
/// Show the top constraints in the focusTerm.
/// [focusTerm] can be a sub-interval of the [term] that you get from
/// zooming into the plot.
///
Future<List<Map<String, dynamic>>> getTopConstraints() async {
  var xs = await getDaConstraints();

  var groups = groupBy(xs, (e) => (e.limitingFacility, e.contingency));
  var table = <Map<String, dynamic>>[
    for (var group in groups.entries)
      {
        'Constraint Name': group.key.$1,
        'Contingency Name': group.key.$2,
        'Marginal Value': group.value.map((e) => e.constraintCost).sum,
        'Hours Count': group.value.length,
      }
  ];

  /// sort descending by absolute Marginal Value
  table.sort((a, b) =>
      -(a['Marginal Value'].abs()).compareTo(b['Marginal Value'].abs()));

  // if (selected.isEmpty) {
  //   selected = List.filled(_table.length, false);
  // }
  table = table.take(15).toList();

  return table;
}

Future<List<ny_bc.Record>> getDaConstraints() async {
  if (cacheConstraints.isEmpty) {
    if (region.value == 'NYISO') {
      var aux = await ny_bc.queryRecords(
        filter: ny_bc.QueryFilter(
          hourBeginningGte: term.value.start,
          hourBeginningLt: term.value.end,
        ),
        rootUrl: dotenv.env['RUST_SERVER']!,
      );
      cacheConstraints.addAll(aux);
    }
  }
  return cacheConstraints;
}

///
Future<Map<int, Map<String, dynamic>>> getPtidMap(String region) async {
  if (!cachePtidMap.containsKey(region)) {
    var aux = await ptidClient.getPtidTable(region: region.toLowerCase());
    if (region == 'NYISO') {
      for (var e in aux) {
        var keyName = '${e['spokenName'] ?? e['name']}, ptid: ${e['ptid']}';
        e['keyName'] = keyName;
      }
    } else if (region == 'ISONE') {
      aux = aux.where((e) => e['ptid'] < 7000 || e['ptid'] >= 8000).map((e) {
        e['keyName'] = '${e['name']}, ptid: ${e['ptid']}';
        return e;
      }).toList();
    }
    var ptidMap = {for (var e in aux) e['ptid'] as int: e};
    cachePtidMap[region] = ptidMap;
  }
  return cachePtidMap[region]!;
}

/// A utility function to get all locations for a given ISO.
/// For ISONE, the returned location names are like:
///    ".H.INTERNAL_HUB, ptid: 4000"
///
Set<String> getLocations(List<Map<String, dynamic>> ptidMap, String region) {
  var xs = <String>{};
  if (region == 'NYISO') {
    xs.addAll(ptidMap
        .where((e) => e['type'] == 'zone')
        .map((e) => '${e['spokenName']}, ptid: ${e['ptid']}'));
    xs.addAll(ptidMap.map((e) => '${e['name']}, ptid: ${e['ptid']}'));
  } else if (region == 'ISONE') {
    xs.addAll(ptidMap
        .where((e) => e['ptid'] < 7000 || e['ptid'] >= 8000)
        .map((e) => '${e['name']}, ptid: ${e['ptid']}'));
  }
  return xs;
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

/// Cache clears when term or region changes.
final cacheTraces = <Map<String, dynamic>>[];

/// Cache clears when term or region changes.  Pulls all the DA constraints.
final cacheConstraints = <ny_bc.Record>[];

/// A cache with Region -> ptid -> data
final cachePtidMap = <String, Map<int, Map<String, dynamic>>>{};

/// in UTC
Term getDefaultTerm() {
  final today = Date.today(location: UTC);
  return Term.fromInterval(Month.utc(today.year, today.month));
}

final highlightedBlocks = computed(() {
  if (selectedConstraints.value.isEmpty) {
    return <Interval>[];
  }
  var xs = cacheConstraints
      .where((e) => selectedConstraints.value.contains(e.limitingFacility))
      .map((e) => (e.limitingFacility, e.hourBeginning))
      .toList();
  var groups = groupBy(xs, (e) => e.$1);
  var blocks = <Interval>[];
  for (var group in groups.entries) {
    var hours = group.value.map((e) => e.$2).toList()..sort();
    var intervals = <Interval>[];
    for (var i = 0; i < hours.length; i++) {
      if (intervals.isEmpty) {
        intervals
            .add(Interval(hours[i], hours[i].add(const Duration(hours: 1))));
      } else {
        var last = intervals.last;
        if (hours[i].difference(last.end) == const Duration(hours: 0)) {
          // extend the last interval
          intervals[intervals.length - 1] =
              Interval(last.start, hours[i].add(const Duration(hours: 1)));
        } else {
          // start a new interval
          intervals
              .add(Interval(hours[i], hours[i].add(const Duration(hours: 1))));
        }
      }
    }
    blocks.addAll(intervals);
  }
  return blocks;
}, debugLabel: 'highlightedBlocks');

/// Make the layout for the plot.  It depends on the highlighted constraints,
/// so it will update when the user selects/unselects constraints from the
/// table.
final layoutMcc = computed(() {
  return <String, dynamic>{
    'width': 1100,
    'height': 700,
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
    'shapes': highlightedBlocks.value
        .map((block) => {
              'type': 'rect',
              'xref': 'x',
              'yref': 'paper',
              'x0': block.start.millisecondsSinceEpoch,
              'x1': block.end.millisecondsSinceEpoch,
              'y0': 0,
              'y1': 1,
              'fillcolor': '#800000',
              'opacity': 0.2,
              'line': {'width': 0},
            })
        .toList(),
    'displaylogo': false,
  };
}, debugLabel: 'layout');

List<Map<String, dynamic>> makeTracesConstraintCost() {
  if (focusNodeConstraint.value == null || focusConstraint.value == null) {
    return [
      {
        'x': [],
        'y': [],
        'text': [],
        'mode': 'markers',
        'type': 'scatter',
      }
    ];
  }
  var aux = cacheTraces
      .firstWhereOrNull((e) => e['text'] == focusNodeConstraint.value);
  var mcc = TimeSeries.from(
    (aux?['x'] as List).map(
        (e) => Hour.beginning(TZDateTime.parse(IsoNewEngland.location, e))),
    (aux?['y'] as List).cast<num>(),
  );

  // sum up the constraint costs by hour for all limiting facilities.
  var bc = cacheConstraints
      .where((e) => e.limitingFacility == focusConstraint.value);
  var groups = groupBy(bc, (e) => e.hourBeginning);
  var bux = groups.entries
      .map((e) => IntervalTuple(
          Hour.beginning(e.key), e.value.map((e) => e.constraintCost).sum))
      .toList()
    ..sort((a, b) => a.interval.start.compareTo(b.interval.start));
  var constraintCost = TimeSeries.fromIterable(bux);

  var data = constraintCost.merge(mcc, f: (x, y) => [x, y]);
  // print(data);

  return [
    {
      'x': data.values.map((e) => e[0]),
      'y': data.values.map((e) => e[1]),
      'text': data.intervals.map((e) => e.start.toIso8601String()),
      'mode': 'markers',
      'type': 'scatter',
    }
  ];
}

final layoutConstraint = <String, dynamic>{
  'width': 1100,
  'height': 700,
  'margin': {
    't': 10,
    'l': 50,
    'r': 20,
    'pad': 4,
  },
  'xaxis': {
    'title': {'text': 'Constraint Price, \$/MWh'},
  },
  'yaxis': {
    'title': {'text': 'Congestion Price, \$/MWh'},
  },
  'showlegend': false,
  'hovermode': 'closest',
  'displaylogo': false,
};
