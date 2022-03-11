library models.congestion_chart;

import 'package:dama/dama.dart';
import 'package:date/date.dart';
import 'package:elec_server/client/dacongestion.dart';
import 'package:elec_server/client/other/ptids.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/region_load_zone_model.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CongestionChartModel extends ChangeNotifier {
  late final PtidsApi ptidClient;
  final _client = http.Client();

  CongestionChartModel() {
    _currentRegion = 'NYISO';
    ptidClient = PtidsApi(_client, rootUrl: dotenv.env['ROOT_URL']!);
    getPtidMap(_currentRegion);
  }

  Term? _term;
  late String _currentRegion;
  List<Map<String, dynamic>>? traces;

  /// A cache with Region -> ptid -> data
  final _ptidMapCache = <String, Map<int, Map<String, dynamic>>>{};
  late int traceCount;

  /// How precise is the series resolution for the selected interval
  int resolution = 0;

  /// How many curves are currently displayed
  int displayedCurvesCount = 0;

  ///
  DaCongestion get mccClient => DaCongestion(_client,
      iso: RegionLoadZoneModel.allowedRegions[_currentRegion]!,
      rootUrl: dotenv.env['ROOT_URL']!);

  final layout = <String, dynamic>{
    'width': 900.0,
    'height': 600.0,
    'margin': {
      't': 10,
      'l': 50,
      'r': 20,
      'pad': 4,
    },
    'yaxis': {
      'title': 'Congestion price, \$/MWh',
    },
    'showlegend': false,
    'hovermode': 'closest',
    'shapes': [],
    'displaylogo': false,
  };

  ///
  Future<Map<int, Map<String, dynamic>>> getPtidMap(String region) async {
    if (!_ptidMapCache.containsKey(region)) {
      var aux = await ptidClient.getPtidTable(region: region.toLowerCase());
      var _ptidMap = {for (var e in aux) e['ptid'] as int: e};
      _ptidMapCache[region] = _ptidMap;
    }
    return _ptidMapCache[region]!;
  }

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
  Future<List<Map<String, dynamic>>> makeHourlyTraces(Term term,
      {required String region,
      int? loadZonePtid,
      required int projectionCount}) async {
    var ptidMap = await getPtidMap(region);

    var currentTerm = term;
    _term ??= currentTerm;
    if (_term != currentTerm || traces == null || region != _currentRegion) {
      /// Don't make a call to the client unless the term changes, etc.
      _currentRegion = region;
      var rawTraces =
          await mccClient.getHourlyTraces(term.startDate, term.endDate);
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
        }
        e['mode'] = 'lines';
      }
      traces = rawTraces;
    }

    var filteredTraces = List<Map<String, dynamic>>.from(traces!);
    if (loadZonePtid != null) {
      // get only the ptids in this zone
      filteredTraces =
          filteredTraces.where((e) => e['zonePtid'] == loadZonePtid).toList();
    }
    traceCount = filteredTraces.length;
    return reduceTraces(filteredTraces, projectionCount);
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
    resolution = 0; // reset it
    displayedCurvesCount = traces.length;
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
    resolution = (diff[i]['diff'] as num).round();
    displayedCurvesCount = out.length;
    return out;
  }
}
