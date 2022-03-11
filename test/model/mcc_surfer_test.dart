library test.models.mcc_surfer_test;

import 'dart:io';

import 'package:date/date.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/mcc_surfer/congestion_chart_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

Future<void> tests(String rootUrl) async {
  group('MCC surfer model test', () {
    var model = CongestionChartModel();
    late List<Map<String, dynamic>> traces;

    setUp(() async {
      var term = Term.parse('Nov21', UTC);
      traces = await model.makeHourlyTraces(term,
          region: 'ISONE', projectionCount: 100);
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
  final rootUrl = dotenv.env['ROOT_URL'] as String;

  await tests(rootUrl);
}
