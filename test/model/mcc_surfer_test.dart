import 'dart:io';

import 'package:date/date.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/mcc_surfer/congestion_chart_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

Future<void> tests(String rootUrl, String rustServer) async {
  group('MCC surfer model test', () {
    final model =
        CongestionChartModel(rootUrl: rootUrl, rustServer: rustServer);
    late Term term;
    late List<Map<String, dynamic>> traces;

    setUp(() async {
      term = Term.parse('Sep25', UTC);
    });
    test('make traces for ISONE', () async {
      traces = await model.makeHourlyTraces(term,
          region: 'ISONE', projectionCount: 100);
      var rTraces = model.reduceTraces(traces, 100);
      expect(rTraces.length, 100);
      expect((rTraces[0]['y'] as List).length, 720);
    });
    test('make traces for NYISO', () async {
      traces = await model.makeHourlyTraces(term,
          region: 'NYISO', projectionCount: 100);
      var rTraces = model.reduceTraces(traces, 100);
      expect(rTraces.length, 100);
      expect((rTraces[0]['y'] as List).length, 720);
    });
    // test('make traces for IESO', () async {
    //   traces = await model.makeHourlyTraces(term,
    //       region: 'IESO', projectionCount: 100);
    //   var rTraces = model.reduceTraces(traces, 100);
    //   expect(rTraces.length, 100);
    //   expect((rTraces[0]['y'] as List).length, 720);
    // });
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;
  final rustServer = dotenv.env['RUST_SERVER'] as String;

  await tests(rootUrl, rustServer);
}
