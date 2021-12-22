library models.congestion_chart;

import 'package:date/date.dart';
import 'package:elec_server/client/isoexpress/dacongestion_compact.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CongestionChartModel extends ChangeNotifier {
  final String rootUrl;
  late final DaCongestion client;

  CongestionChartModel({this.rootUrl = 'http://127.0.0.1:8080'}) {
    client = DaCongestion(http.Client(), rootUrl: rootUrl);
  }

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
  };

  Term? _term;
  List<Map<String, dynamic>>? _traces;

  /// Get the data and make the Plotly hourly traces.
  /// For reference, getting one full month takes less than 800 ms, the first
  /// time.  The second time (from the cache) it only takes 70 ms.
  /// This method also gets called when different constraints from the table are
  /// selected/unselected.  Don't make a call to the client unless the term
  /// changes.
  Future<List<Map<String, dynamic>>> makeHourlyTraces(Date start, Date end,
      {List<int>? ptids}) async {
    var currentTerm = Term(start, end);
    _term ??= currentTerm;
    if (_term != currentTerm || _traces == null) {
      print('getting hourly traces ...');
      var traces = await client.getHourlyTraces(start, end, ptids: ptids);
      // do other things to the traces
      for (var e in traces) {
        e['mode'] = 'lines';
        e['text'] = '${e['ptid']}, zone:?, subZone:?';
      }
      _traces = traces;
    }
    return _traces!;
  }

  // /// Get the data and make the Plotly daily traces
  // Future<List<Map<String, dynamic>>> makeDailyTraces(Date start, Date end,
  //     {List<int>? ptids}) async {
  //   var traces = await client.getDailyTraces(start, end, ptids: ptids);
  //   // do other things to the traces
  //   for (var e in traces) {
  //     e['mode'] = 'lines';
  //     e['text'] = '${e['name']}, zone:?, subZone:?';
  //   }
  //   return traces;
  // }
}
