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

  /// Get the data and make the Plotly hourly traces
  Future<List<Map<String, dynamic>>> makeHourlyTraces(Date start, Date end,
      {List<int>? ptids}) async {
    var traces = await client.getHourlyTraces(start, end, ptids: ptids);
    // do other things to the traces
    traces.forEach((e) {
      e['mode'] = 'lines';
      e['text'] = '${e['name']}, zone:?, subZone:?';
    });
    return traces;
  }

  /// Get the data and make the Plotly daily traces
  Future<List<Map<String, dynamic>>> makeDailyTraces(Date start, Date end,
      {List<int>? ptids}) async {
    var traces = await client.getDailyTraces(start, end, ptids: ptids);
    // do other things to the traces
    traces.forEach((e) {
      e['mode'] = 'lines';
      e['text'] = '${e['name']}, zone:?, subZone:?';
    });
    return traces;
  }
}
