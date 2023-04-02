library test.models.polygraph_test;

import 'dart:io';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/models/polygraph/transforms/fill_transform.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_filter.dart';
import 'package:flutter_quiver/models/polygraph/variables/slope_intercept_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_selection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

Future<void> tests(String rootUrl) async {
  group('Variable selection test', () {
    test('get categories', () {
      var vs = VariableSelection();
      var cat0 = vs.getCategoriesForNextLevel();
      expect(cat0.length, cat0.toSet().length); // should be unique
      expect(cat0.contains('Time'), true);
      expect(cat0.contains('Electricity'), true);
      expect(cat0.contains('Gas'), true);
      expect(vs.isSelectionDone(), false);

      // add one
      vs.selectCategory('Electricity');
      var cat1 = vs.getCategoriesForNextLevel();
      expect(cat1, ['Realized', 'Forward']);
      expect(vs.isSelectionDone(), false);

      // and another
      vs.selectCategory('Realized');
      var cat2 = vs.getCategoriesForNextLevel();
      expect(cat2.isEmpty, true);
      expect(vs.isSelectionDone(), true);

      // remove level 1
      vs.removeFromLevel(1);
      expect(vs.categories, ['Electricity']);

      // add another one, remove from level 0
      vs.selectCategory('Forward');
      vs.removeFromLevel(0);
      expect(vs.isSelectionDone(), false);
      expect(vs.getCategoriesForNextLevel().contains('Time'), true);
    });
    test('get categories level 1', () {
      var vs = VariableSelection();
      expect(vs.getCategoriesForNextLevel().contains('Time'), true);
      vs.selectCategory('Grid Line');
      expect(vs.getCategoriesForNextLevel(), ['Horizontal', 'Vertical']);
    });
  });

  group('horizontal line variable', () {
    var term = Term.parse('Jan22-Dec22', IsoNewEngland.location);
    var yVariable = SlopeInterceptVariable(slope: 0.0, intercept: 1);

    // test('check various transforms', () {
    //   var ts = yVariable.timeSeries(term);
    //   expect(ts.length, 1);
    //
    //   // add a fill hourly transform
    //   yVariable.transforms.add(FillTransform(timeFrequency: 'hourly'));
    //   var ts1 = yVariable.timeSeries(term);
    //   expect(ts1.length, 8760);
    //
    //   // filter by bucket 5x16, aggregate by month
    //   yVariable.transforms
    //       .add(TimeFilter.empty()..copyWith(bucket: Bucket.b5x16));
    //   yVariable.transforms
    //       .add(TimeAggregation(frequency: 'monthly', function: 'sum'));
    //   var ts2 = yVariable.timeSeries(term);
    //   expect(ts2.length, 12);
    //   expect(
    //       ts2.first,
    //       IntervalTuple<num>(
    //           Month(2022, 1, location: IsoNewEngland.location), 336));
    // });

    // var state = PolygraphState(term: term,
    //     xVariable: TimeVariable(),
    //     yVariables: [yVariable]);
    //
    // var traces = state.makeTraces();
    // expect(traces.length, 1);
    // var t0 = traces.first;
    // print(t0);
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;
  await tests(rootUrl);
}
