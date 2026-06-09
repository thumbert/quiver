import 'dart:io';

import 'package:date/date.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/mcc_surfer/mcc_surfer_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

Future<void> tests() async {
  group('MCC surfer model test', () {
    test('make traces for ISONE', () async {
      region.value = 'ISONE';
      zones.value = getAllZoneNames();
      term.value = Term.parse('Sep25', UTC);
      var traces = await makeTraces();
      var rTraces = reduceTraces(traces, 100);
      expect(rTraces.length, 100);
      expect((rTraces[0]['y'] as List).length, 720);
    });
    test('make traces for NYISO', () async {
      region.value = 'NYISO';
      term.value = Term.parse('Sep25', UTC);
      zones.value = getAllZoneNames();
      var traces = await makeTraces();
      var rTraces = reduceTraces(traces, 100);
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
  await tests();
}
