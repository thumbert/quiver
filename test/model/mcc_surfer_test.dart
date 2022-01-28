library test.models.weather_model_test;

import 'dart:io';

import 'package:date/date.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/mcc_surfer/congestion_chart_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart';

Future<void> tests(String rootUrl) async {
  group('MCC surfer model test', () {
    var model = CongestionChartModel(rootUrl: rootUrl);
    late List<Map<String, dynamic>> traces;

    setUp(() async {
      traces = await model.makeHourlyTraces(
          Date.utc(2021, 11, 1), Date.utc(2021, 11, 30),
          projectionCount: 100);
    });
    test('reduce traces', () {
      //
      var rTraces = model.reduceTraces(traces, 100);
      expect(rTraces.length, 100);
      expect(rTraces.first['ptid'], 69257);
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['rootUrl'] as String;

  await tests(rootUrl);
}
