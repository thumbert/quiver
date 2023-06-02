library test.models.polygraph.parser.parser_test;

import 'dart:io';
import 'dart:math';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service_local.dart';
import 'package:flutter_quiver/models/polygraph/display/plotly_layout.dart';
import 'package:flutter_quiver/models/polygraph/parser/parser.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_tab.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_window.dart';
import 'package:flutter_quiver/models/polygraph/transforms/fill_transform.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_filter.dart';
import 'package:flutter_quiver/models/polygraph/variables/slope_intercept_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/time_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/transformed_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_selection.dart';
import 'package:flutter_quiver/models/polygraph/variables/temperature_variable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petitparser/debug.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

Future<void> tests(String rootUrl) async {
  group('Parse chain', () {
    test('x => toMonthly(sum)', () {
      var res = chain.parse('x => toMonthly(sum)');
      expect(res.isSuccess, true);
    });
  });
  group('Polygraph parser test (basic): ', () {
    test('arithmetic', () {
      var res = parser.parse('2 + 2');
      expect(res.isSuccess, true);
      var value = res.value.eval({});
      expect(value, 4);
    });
    test('arithmetic with parentheses and integers', () {
      var res = parser.parse('2 + 2 * (3 - 1)');
      expect(res.isSuccess, true);
      var value = res.value.eval({});
      expect(value, 6);
    });
    test('arithmetic with variables', () {
      var res = parser.parse('x + 2 * y');
      expect(res.isSuccess, true);
      var value = res.value.eval({'x': 1, 'y': 2});
      expect(value, 5);
    });
    test('sin function', () {
      // trace(parser).parse('sin(0.0)');
      expect(parser.parse('sin(0.0)').isSuccess, true);
      expect(parser.parse('sin(0.0)').value.eval({}), 0.0);
      expect(parser.parse('sin(pi/4)').value.eval({}), 1 / sqrt2);
      var x = TimeSeries<num>.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 1), 0.0),
        IntervalTuple(Date.utc(2022, 1, 2), pi/6),
        IntervalTuple(Date.utc(2022, 1, 3), pi/2),
      ]);
      expect(parser.parse('sin(x)').value.eval({'x': x}),
          x.apply((e) => sin(e))
      );
    });
    test('linear transform of sin function ', () {
      // trace(parser).parse('sin(0.0)');
      expect(parser.parse('3 + 2*sin(x)').isSuccess, true);
      expect(parser.parse('3 + 2*sin(x)').value.eval({'x': pi / 6}), 4.0);
    });
  });
  group('Polygraph parser test (basic timeseries operations)', () {
    test('addition with one timeseries', () {
      var ts = TimeSeries.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 1), 1.0),
        IntervalTuple(Date.utc(2022, 1, 2), 2.0),
        IntervalTuple(Date.utc(2022, 1, 3), 3.0),
      ]);
      expect(parser.parse('ts + 1').value.eval({'ts': ts}),
          ts.apply((e) => e + 1));
      expect(parser.parse('2 + ts').value.eval({'ts': ts}),
          ts.apply((e) => e + 2));
      expect(parser.parse('ts + ts').value.eval({'ts': ts}),
          ts.apply((e) => e + e));
    });
    test('subtraction with one timeseries', () {
      var ts = TimeSeries.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 1), 1.0),
        IntervalTuple(Date.utc(2022, 1, 2), 2.0),
        IntervalTuple(Date.utc(2022, 1, 3), 3.0),
      ]);
      expect(parser.parse('ts - 1').value.eval({'ts': ts}),
          ts.apply((e) => e - 1));
      expect(parser.parse('2 - ts').value.eval({'ts': ts}),
          ts.apply((e) => 2 - e));
      expect(parser.parse('ts - ts').value.eval({'ts': ts}),
          ts.apply((e) => e - e));
    });
    test('multiplication with one timeseries', () {
      var ts = TimeSeries.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 1), 1.0),
        IntervalTuple(Date.utc(2022, 1, 2), 2.0),
        IntervalTuple(Date.utc(2022, 1, 3), 3.0),
      ]);
      expect(parser.parse('ts * 2').value.eval({'ts': ts}),
          ts.apply((e) => e * 2));
      expect(parser.parse('2 * ts').value.eval({'ts': ts}),
          ts.apply((e) => e * 2));
      expect(parser.parse('ts * ts').value.eval({'ts': ts}),
          ts.apply((e) => e * e));
    });
    test('division with one timeseries', () {
      var ts = TimeSeries.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 1), 1.0),
        IntervalTuple(Date.utc(2022, 1, 2), 2.0),
        IntervalTuple(Date.utc(2022, 1, 3), 3.0),
      ]);
      expect(parser.parse('ts / 2').value.eval({'ts': ts}),
          ts.apply((e) => e / 2));
      expect(parser.parse('2 / ts').value.eval({'ts': ts}),
          ts.apply((e) => 2 / e));
      expect(parser.parse('ts / ts').value.eval({'ts': ts}),
          ts.apply((e) => 1));
    });
    test('more complicated arithmetic with timeseries', () {
      var x = TimeSeries.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 1), 1.0),
        IntervalTuple(Date.utc(2022, 1, 2), 2.0),
        IntervalTuple(Date.utc(2022, 1, 3), 3.0),
      ]);
      var y = TimeSeries.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 2), 2.0),
        IntervalTuple(Date.utc(2022, 1, 3), 3.0),
        IntervalTuple(Date.utc(2022, 1, 5), 5.0),
      ]);
      expect(parser.parse('x + 2*(y - 1)').value.eval({'x': x, 'y': y}),
          TimeSeries<num>.fromIterable([
            IntervalTuple(Date.utc(2022, 1, 2), 4.0),
            IntervalTuple(Date.utc(2022, 1, 3), 7.0),
          ]));
    });
  });
  group('Polygraph parser test (custom functions arity 2)', () {
    test('max', (){
      var x = TimeSeries<num>.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 1), 1.0),
        IntervalTuple(Date.utc(2022, 1, 2), 2.0),
        IntervalTuple(Date.utc(2022, 1, 3), 3.0),
      ]);
      var y = TimeSeries<num>.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 2), 3.0),
        IntervalTuple(Date.utc(2022, 1, 3), 5.0),
        IntervalTuple(Date.utc(2022, 1, 4), 4.0),
      ]);
      expect(parser.parse('max(ts, 1.5)').value.eval({'ts': x}),
          x.apply((e) => max(e, 1.5)));
      expect(parser.parse('max(1.5, ts)').value.eval({'ts': x}),
          x.apply((e) => max(e, 1.5)));
      expect(parser.parse('max(x, y)').value.eval({'x': x, 'y': y}),
          x.merge(y, f: (x,y) => max<num>(x!, y!)));
    });
    test('min', (){
      var x = TimeSeries<num>.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 1), 1.0),
        IntervalTuple(Date.utc(2022, 1, 2), 2.0),
        IntervalTuple(Date.utc(2022, 1, 3), 3.0),
      ]);
      var y = TimeSeries<num>.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 2), 3.0),
        IntervalTuple(Date.utc(2022, 1, 3), 5.0),
        IntervalTuple(Date.utc(2022, 1, 4), 4.0),
      ]);
      expect(parser.parse('min(ts, 1.5)').value.eval({'ts': x}),
          x.apply((e) => min(e, 1.5)));
      expect(parser.parse('min(1.5, ts)').value.eval({'ts': x}),
          x.apply((e) => min(e, 1.5)));
      expect(parser.parse('min(x, y)').value.eval({'x': x, 'y': y}),
          x.merge(y, f: (x,y) => min<num>(x!, y!)));
    });
    test('toMonthly', (){
      var x = TimeSeries<num>.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 1), 1.0),
        IntervalTuple(Date.utc(2022, 1, 2), 2.0),
        IntervalTuple(Date.utc(2022, 2, 1), 3.0),
        IntervalTuple(Date.utc(2022, 2, 4), 8.0),
      ]);
      expect(parser.parse('toMonthly(x, sum)').value.eval({'x': x}),
          TimeSeries<num>.fromIterable([
            IntervalTuple(Month.utc(2022, 1), 3.0),
            IntervalTuple(Month.utc(2022, 2), 11.0),
          ]));
    });
  });

  // group('Polygraph parser test (custom functions arity 3)', () {
  //   test('toMonthly', (){
  //     var x = TimeSeries<num>.fromIterable([
  //       IntervalTuple(Date.utc(2022, 1, 1), 1.0),
  //       IntervalTuple(Date.utc(2022, 1, 2), 2.0),
  //       IntervalTuple(Date.utc(2022, 2, 1), 3.0),
  //       IntervalTuple(Date.utc(2022, 2, 4), 8.0),
  //     ]);
  //     expect(parser.parse('toMonthly(x, sum)').value.eval({'x': x}),
  //         TimeSeries<num>.fromIterable([
  //           IntervalTuple(Month.utc(2022, 1), 3.0),
  //           IntervalTuple(Month.utc(2022, 2), 11.0),
  //         ]));
  //   });
  // });

  /// toMonthly(filterBucket(x, 5x16), sum)
  ///
  ///
  /// filter(x, {bucket: 5x16})
  ///
  /// toMonthly(x, sum, 5x16)
  ///
  /// x => filter(bucket: 5x16) => to_monthly(mean)
  /// x.filter(months: [1,2,3], bucket: offpeak).to_monthly(mean)
  /// x.filter(hours: [7, 9, 13-20]).to_daily(max)
  ///

}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;
  await tests(rootUrl);
}


// test('parse toMonthly(bos_daily_temp, mean)', () async {
//   var location = getLocation('America/New_York');
//   var term = Term.parse('Jan20-Dec21', location);
//   var window = PolygraphWindow(
//       term: term,
//       xVariable: TimeVariable(),
//       yVariables: [
//         TemperatureVariable(
//           airportCode: 'BOS',
//           variable: 'mean',
//           frequency: 'daily',
//           isForecast: false,
//           dataSource: 'NOAA',
//           id: 'bos_daily_temp',
//         ),
//         TransformedVariable(
//             expression: 'toMonthly(bos_daily_temp, mean)',
//             id: 'bos_monthly_temp'),
//       ],
//       layout: PlotlyLayout.getDefault(width: 900, height: 600),
//   );
//   await window.updateCache();
//   expect(window.cache.keys.toSet(), {'bos_daily_temp', 'bos_monthly_temp'});
//   var ts = window.cache['bos_monthly_temp'] as TimeSeries<num>;
//   expect(ts.observationAt(Month(2020, 4, location: location)).value, 44.55);
//   //
//   // generate an error on a transformed variable, unknown function
//   window.yVariables[1] = TransformedVariable(
//       expression: 'toMonthly(bos_daily_temp, mix)',
//       id: 'bos_monthly_temp');
//   await window.updateCache();
//   expect(window.cache.keys.toSet(), {'bos_daily_temp'});
//   var tv = window.yVariables[1] as TransformedVariable;
//   expect(tv.error, 'Unsupported aggregation function: mix');
//   //
//   // generate an error on a transformed variable, wrong arity
//   window.yVariables[1] = TransformedVariable(
//       expression: 'toMonthly(bos_daily_temp)',
//       id: 'bos_monthly_temp');
//   await window.updateCache();
//   expect(window.cache.keys.toSet(), {'bos_daily_temp'});
//   tv = window.yVariables[1] as TransformedVariable;
//   expect(tv.error, 'Bad state: Can\'t find function toMonthly among '
//       'list of functions with one argument.');
//   //
//   // generate an error on a transformed variable, wrong syntax
//   // (missing end parenthesis)
//   window.yVariables[1] = TransformedVariable(
//       expression: 'toMonthly(bos_daily_temp',
//       id: 'bos_monthly_temp');
//   await window.updateCache();
//   expect(window.cache.keys.toSet(), {'bos_daily_temp'});
//   tv = window.yVariables[1] as TransformedVariable;
//   expect(tv.error, '")" expected');
// });
