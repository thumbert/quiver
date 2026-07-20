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
      term.value = Term.parse('1Jun26-10Jun26', UTC);
      var traces = await makeTracesMcc();
      var rTraces = reduceTraces(traces, 100);
      expect(rTraces.length, 100);
      expect((rTraces[0]['y'] as List).length, 240);

      // set a focus node
      focusNodeMcc.value = 'UN.WESTBRK 18.0WE1A, ptid: 14177';
      traces = await makeTracesMcc();
      expect(traces.length, 101);

      // get top constraints
      var constraints = await getTopConstraints();
      expect(constraints.length, 14);
      expect(constraints.first.keys.toSet(), {
        'Constraint Name',
        'Contingency Name',
        'Marginal Value',
        'Hours Count'
      });
    });
    test('make traces for NYISO', () async {
      region.value = 'NYISO';
      term.value = Term.parse('1Jun26-10Jun26', UTC);
      zones.value = getAllZoneNames();
      var traces = await makeTracesMcc();
      var rTraces = reduceTraces(traces, 100);
      expect(rTraces.length, 100);
      expect((rTraces[0]['y'] as List).length, 240);

      // set a focus node
      focusNodeMcc.value = 'NINE_MILE_1, ptid: 23575';
      traces = await makeTracesMcc();
      expect(traces.length, 101);
      expect(traces.last['keyName'], 'NINE_MILE_1, ptid: 23575');

      // get top constraints
      var constraints = await getTopConstraints();
      expect(constraints.length, 15);

      // make trace for lower plot (mcc vs. constraint cost)
      focusNodeConstraint.value = 'NINE_MILE_1, ptid: 23575';
      focusConstraint.value = 'MEYER    230 MEYER      1 1';
      var constraintCostTraces = makeTracesConstraintCost();
      expect(constraintCostTraces.length, 1);

    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  await tests();
}
