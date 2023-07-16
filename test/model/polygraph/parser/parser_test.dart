library test.models.polygraph.parser.parser_test;

import 'dart:io';
import 'dart:math';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_quiver/models/polygraph/parser/parser.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petitparser/debug.dart';
import 'package:petitparser/petitparser.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/data/latest.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' hide Parser;
import 'package:timezone/timezone.dart';

Function accept(Parser p) => (input) => p.parse(input).isSuccess;

Future<void> tests(String rootUrl) async {
  var tz = Iso.newEngland.preferredTimeZoneLocation;
  group('Parser basics', () {
    test('multi-line expression', () {
      var res = parser.parse('''
    2 + 
    2''').value.eval({});
      expect(res, 4);
    });
    test('stand alone comments', () {
      var res = parser.parse('// so easy!').value.eval({});
      expect(res, 0);
    });
    test('end of line comments', () {
      expect('///', accept(comment1));
      expect('/// foo', accept(comment1));
      expect('/// \n', accept(comment1));
      expect('/// foo \n', accept(comment1));

      // var res = parser.parse('2 + 2 // so easy!').value.eval({});
      // expect(res, 4);
    });
  });
  group('Parse basic function arguments:', () {
    test('Bucket function argument', () {
      expect(bucketArg.parse("bucket = 'atc'").value, Bucket.atc);
      expect(bucketArg.parse("bucket='5x16'").value, Bucket.b5x16);
      expect(() => bucketArg.parse("bucket = '5y16'").value, throwsArgumentError);
    });
    test('Comma separated ints', () {
      // trace(intList).parse('[4, 5, 6, 13, 15, 17-19]');
      expect(() => intList.parse('[]').value.eval({}), throwsException);
      expect(intList.parse('[ 3 ]').value.eval({}), [3]);
      expect(intList.parse('[12]').value.eval({}), [12]);
      expect(intList.parse('[6-6]').value.eval({}), [6]);
      expect(intList.parse('[6-9]').value.eval({}), [6, 7, 8, 9]);
      expect(() => intList.parse('[9-6]').value.eval({}), throwsException);
      expect(intList.parse('[3, 7-9]').value.eval({}), [3, 7, 8, 9]);
      expect(intList.parse('[3, 5, 7-9]').value.eval({}), [3, 5, 7, 8, 9]);
      expect(intList.parse('[3, 5]').value.eval({}), [3, 5]);
      expect(intList.parse('[3, 5 ]').value.eval({}), [3, 5]);
      expect(intList.parse('[3, 5 ] ').value.eval({}), <int>[3, 5]);
      expect(intList.parse('[1, 4, 17]').value.eval({}), [1, 4, 17]);
      expect(intList.parse('[1, 4-6, 17, 19-20]').value.eval({}), [1, 4, 5, 6, 17, 19, 20]);
    });
    test('Months argument', () {
      expect(monthsArg.parse('months = [1-2, 7-8]').value.eval({}), [1, 2, 7, 8]);
      expect(monthsArg.parse('months=[1-2, 7-8]').value.eval({}), [1, 2, 7, 8]);
      expect(monthsArg.parse('months = [11, 3, 7-8]').value.eval({}), [3, 7, 8, 11]);
      expect(() => monthsArg.parse('months = [4, 11-14]').value.eval({}), throwsException);
      expect(() => monthsArg.parse('months = 1').value.eval({}), throwsException);
    });
  });

  group('Parse hourly_schedule function', () {
    test('basic', () {
      // var res = windowFun.parse("window(x, bucket='atc'").value;
      // trace(windowFun).parse('window(x, months=[1,2])');
      var x = TimeSeries<num>.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 1), 1.0),
        IntervalTuple(Date.utc(2022, 1, 2), 2.0),
        IntervalTuple(Date.utc(2022, 2, 1), 3.0),
        IntervalTuple(Date.utc(2022, 2, 4), 8.0),
        IntervalTuple(Date.utc(2022, 3, 3), 8.0),
        IntervalTuple(Date.utc(2022, 3, 19), 5.0),
      ]);
      expect(
          hourlyScheduleFun.parse('hourly_schedule(50)').value
              .eval({'_domain': Term.parse('Jan22', UTC)}),
          TimeSeries<num>.fromIterable([
            IntervalTuple(Date.utc(2022, 1, 1), 1.0),
            IntervalTuple(Date.utc(2022, 1, 2), 2.0),
            IntervalTuple(Date.utc(2022, 2, 1), 3.0),
            IntervalTuple(Date.utc(2022, 2, 4), 8.0),
          ]));
    });
    test('bucket filter', () {
      var x = TimeSeries<num>.fill(Date(2022, 1, 1, location: tz).hours(), 1.0);
      var ts = windowFun.parse("window(x, bucket='7x8')").value.eval({'x': x}) as TimeSeries;
      expect(ts.length, 8);
    });
    test('filter combo: bucket + months', () {
      var x = TimeSeries.fromIterable([
        ...TimeSeries<num>.fill(Date(2022, 1, 1, location: tz).hours(), 1.0),
        ...TimeSeries<num>.fill(Date(2022, 3, 1, location: tz).hours(), 3.0),
      ]);
      var ts = windowFun.parse("window(x, bucket='7x8', months=[3])").value.eval({'x': x}) as TimeSeries;
      expect(ts.length, 8);
    });


  });

  group('Parse window function', () {
    test('months filter', () {
      // var res = windowFun.parse("window(x, bucket='atc'").value;
      // trace(windowFun).parse('window(x, months=[1,2])');
      var x = TimeSeries<num>.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 1), 1.0),
        IntervalTuple(Date.utc(2022, 1, 2), 2.0),
        IntervalTuple(Date.utc(2022, 2, 1), 3.0),
        IntervalTuple(Date.utc(2022, 2, 4), 8.0),
        IntervalTuple(Date.utc(2022, 3, 3), 8.0),
        IntervalTuple(Date.utc(2022, 3, 19), 5.0),
      ]);
      expect(
          windowFun.parse('window(x, months=[1,2])').value.eval({'x': x}),
          TimeSeries<num>.fromIterable([
            IntervalTuple(Date.utc(2022, 1, 1), 1.0),
            IntervalTuple(Date.utc(2022, 1, 2), 2.0),
            IntervalTuple(Date.utc(2022, 2, 1), 3.0),
            IntervalTuple(Date.utc(2022, 2, 4), 8.0),
          ]));
    });
    test('bucket filter', () {
      var x = TimeSeries<num>.fill(Date(2022, 1, 1, location: tz).hours(), 1.0);
      var ts = windowFun.parse("window(x, bucket='7x8')").value.eval({'x': x}) as TimeSeries;
      expect(ts.length, 8);
    });
    test('filter combo: bucket + months', () {
      var x = TimeSeries.fromIterable([
        ...TimeSeries<num>.fill(Date(2022, 1, 1, location: tz).hours(), 1.0),
        ...TimeSeries<num>.fill(Date(2022, 3, 1, location: tz).hours(), 3.0),
      ]);
      var ts = windowFun.parse("window(x, bucket='7x8', months=[3])").value.eval({'x': x}) as TimeSeries;
      expect(ts.length, 8);
    });


  });

  group('Parse chains (fat-arrow operator):', () {
    test('x => toMonthly(x, mean)', () {
      var res = chain.parse('x => toMonthly(x, mean)');
      expect(res.isSuccess, true);
      var x = TimeSeries<num>.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 1), 1.0),
        IntervalTuple(Date.utc(2022, 1, 2), 2.0),
        IntervalTuple(Date.utc(2022, 2, 1), 3.0),
        IntervalTuple(Date.utc(2022, 2, 4), 8.0),
      ]);
      var value = res.value.eval({'x': x});
      expect(
          value,
          TimeSeries<num>.fromIterable([
            IntervalTuple(Month.utc(2022, 1), 1.5),
            IntervalTuple(Month.utc(2022, 2), 5.5),
          ]));
    });
    // test('window(x, months = [1]) => toMonthly(_, mean)', () {
    //   var res = chain.parse('x + 1 => toMonthly(x, mean)');
    //   expect(res.isSuccess, true);
    //       var x = TimeSeries<num>.fromIterable([
    //         IntervalTuple(Date.utc(2022, 1, 1), 1.0),
    //         IntervalTuple(Date.utc(2022, 1, 2), 2.0),
    //         IntervalTuple(Date.utc(2022, 2, 1), 3.0),
    //         IntervalTuple(Date.utc(2022, 2, 4), 8.0),
    //       ]);
    //   var value = res.value.eval({'x': x });
    //   expect(value, TimeSeries<num>.fromIterable([
    //     IntervalTuple(Month.utc(2022, 1), 2.5),
    //     IntervalTuple(Month.utc(2022, 2), 6.5),
    //   ]));
    // });
  });
  group('Parse basic arithmetic: ', () {
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
        IntervalTuple(Date.utc(2022, 1, 2), pi / 6),
        IntervalTuple(Date.utc(2022, 1, 3), pi / 2),
      ]);
      expect(parser.parse('sin(x)').value.eval({'x': x}), x.apply((e) => sin(e)));
    });
    test('linear transform of sin function ', () {
      // trace(parser).parse('sin(0.0)');
      expect(parser.parse('3 + 2*sin(x)').isSuccess, true);
      expect(parser.parse('3 + 2*sin(x)').value.eval({'x': pi / 6}), 4.0);
    });
  });
  group('Parse basic timeseries operations:', () {
    test('Unary negation', () {
      var ts = TimeSeries.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 1), 1.0),
        IntervalTuple(Date.utc(2022, 1, 2), 2.0),
        IntervalTuple(Date.utc(2022, 1, 3), 3.0),
      ]);
      expect(parser.parse('-ts').value.eval({'ts': ts}), ts.apply((e) => -e));
      expect(parser.parse('ts + (-ts)').value.eval({'ts': ts}),
          ts.apply((e) => 0.0));
    });
    test('Addition with one timeseries', () {
      var ts = TimeSeries.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 1), 1.0),
        IntervalTuple(Date.utc(2022, 1, 2), 2.0),
        IntervalTuple(Date.utc(2022, 1, 3), 3.0),
      ]);
      expect(parser.parse('ts + 1').value.eval({'ts': ts}), ts.apply((e) => e + 1));
      expect(parser.parse('2 + ts').value.eval({'ts': ts}), ts.apply((e) => e + 2));
      expect(parser.parse('ts + ts').value.eval({'ts': ts}), ts.apply((e) => e + e));
    });
    test('Subtraction with one timeseries', () {
      var ts = TimeSeries.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 1), 1.0),
        IntervalTuple(Date.utc(2022, 1, 2), 2.0),
        IntervalTuple(Date.utc(2022, 1, 3), 3.0),
      ]);
      expect(parser.parse('ts - 1').value.eval({'ts': ts}), ts.apply((e) => e - 1));
      expect(parser.parse('2 - ts').value.eval({'ts': ts}), ts.apply((e) => 2 - e));
      expect(parser.parse('ts - ts').value.eval({'ts': ts}), ts.apply((e) => e - e));
    });
    test('Multiplication with one timeseries', () {
      var ts = TimeSeries.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 1), 1.0),
        IntervalTuple(Date.utc(2022, 1, 2), 2.0),
        IntervalTuple(Date.utc(2022, 1, 3), 3.0),
      ]);
      expect(parser.parse('ts * 2').value.eval({'ts': ts}), ts.apply((e) => e * 2));
      expect(parser.parse('2 * ts').value.eval({'ts': ts}), ts.apply((e) => e * 2));
      expect(parser.parse('ts * ts').value.eval({'ts': ts}), ts.apply((e) => e * e));
    });
    test('Division with one timeseries', () {
      var ts = TimeSeries.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 1), 1.0),
        IntervalTuple(Date.utc(2022, 1, 2), 2.0),
        IntervalTuple(Date.utc(2022, 1, 3), 3.0),
      ]);
      expect(parser.parse('ts / 2').value.eval({'ts': ts}), ts.apply((e) => e / 2));
      expect(parser.parse('2 / ts').value.eval({'ts': ts}), ts.apply((e) => 2 / e));
      expect(parser.parse('ts / ts').value.eval({'ts': ts}), ts.apply((e) => 1));
    });
    test('More complicated arithmetic with timeseries', () {
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
      expect(
          parser.parse('x + 2*(y - 1)').value.eval({'x': x, 'y': y}),
          TimeSeries<num>.fromIterable([
            IntervalTuple(Date.utc(2022, 1, 2), 4.0),
            IntervalTuple(Date.utc(2022, 1, 3), 7.0),
          ]));
    });
    test('Dot addition of two timeseries', () {
      var x = TimeSeries.fromIterable([
        IntervalTuple(Month.utc(2021, 1), 10),
        IntervalTuple(Month.utc(2021, 2), 11),
        IntervalTuple(Month.utc(2021, 3), 15),
        IntervalTuple(Month.utc(2021, 4), 13),
        IntervalTuple(Month.utc(2021, 5), 12),
      ]);
      var y = TimeSeries.fromIterable([
        IntervalTuple(Month.utc(2021, 2), 5),
        IntervalTuple(Month.utc(2021, 3), 6),
        IntervalTuple(Month.utc(2021, 5), 7),
        IntervalTuple(Month.utc(2021, 8), 8),
      ]);
      expect(
          parser.parse('x .+ y').value.eval({'x': x, 'y': y}),
          TimeSeries<num>.fromIterable([
            IntervalTuple(Month.utc(2021, 1), 10),
            IntervalTuple(Month.utc(2021, 2), 16),
            IntervalTuple(Month.utc(2021, 3), 21),
            IntervalTuple(Month.utc(2021, 4), 13),
            IntervalTuple(Month.utc(2021, 5), 19),
            IntervalTuple(Month.utc(2021, 8), 8),
          ]));
    });
    test('Relational operators with timeseries', () {
      var x = TimeSeries.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 1), 1.0),
        IntervalTuple(Date.utc(2022, 1, 2), 2.0),
        IntervalTuple(Date.utc(2022, 1, 3), 3.0),
        IntervalTuple(Date.utc(2022, 1, 4), 4.0),
        IntervalTuple(Date.utc(2022, 1, 5), 3.0),
      ]);
      var y = TimeSeries.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 2), -2.0),
        IntervalTuple(Date.utc(2022, 1, 3), 3.0),
        IntervalTuple(Date.utc(2022, 1, 5), -3.0),
      ]);
      expect(
          parser.parse('x > 2').value.eval({'x': x}),
          TimeSeries<num>.fromIterable([
            IntervalTuple(Date.utc(2022, 1, 3), 3.0),
            IntervalTuple(Date.utc(2022, 1, 4), 4.0),
            IntervalTuple(Date.utc(2022, 1, 5), 3.0),
          ]));
      expect(
          parser.parse('x > y').value.eval({'x': x, 'y': y}),
          TimeSeries<num>.fromIterable([
            IntervalTuple(Date.utc(2022, 1, 2), 2.0),
            IntervalTuple(Date.utc(2022, 1, 5), 3.0),
          ]));
      expect(
          parser.parse('x < 3').value.eval({'x': x}),
          TimeSeries<num>.fromIterable([
            IntervalTuple(Date.utc(2022, 1, 1), 1.0),
            IntervalTuple(Date.utc(2022, 1, 2), 2.0),
          ]));
    });
  });


  group('Parse rolling functions', () {
    test('ma', () {
      var x = TimeSeries<num>.fromIterable([
        IntervalTuple(Month.utc(2021, 1), 10.0),
        IntervalTuple(Month.utc(2021, 2), 11.0),
        IntervalTuple(Month.utc(2021, 3), 15.0),
        IntervalTuple(Month.utc(2021, 4), 13.0),
        IntervalTuple(Month.utc(2021, 5), 12.0),
      ]);
      expect(parser.parse('ma(ts, 4)').value.eval({'ts': x}),
          TimeSeries<num>.fromIterable([
            IntervalTuple(Month.utc(2021, 4), 12.25),
            IntervalTuple(Month.utc(2021, 5), 12.75),
          ]));
    });
  });

  group('Polygraph parser test (custom functions arity 2)', () {
    test('max', () {
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
      expect(parser.parse('max(ts, 1.5)').value.eval({'ts': x}), x.apply((e) => max(e, 1.5)));
      expect(parser.parse('max(1.5, ts)').value.eval({'ts': x}), x.apply((e) => max(e, 1.5)));
      expect(parser.parse('max(x, y)').value.eval({'x': x, 'y': y}), x.merge(y, f: (x, y) => max<num>(x!, y!)));
    });
    test('min', () {
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
      expect(parser.parse('min(ts, 1.5)').value.eval({'ts': x}), x.apply((e) => min(e, 1.5)));
      expect(parser.parse('min(1.5, ts)').value.eval({'ts': x}), x.apply((e) => min(e, 1.5)));
      expect(parser.parse('min(x, y)').value.eval({'x': x, 'y': y}), x.merge(y, f: (x, y) => min<num>(x!, y!)));
    });
    test('toMonthly', () {
      var x = TimeSeries<num>.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 1), 1.0),
        IntervalTuple(Date.utc(2022, 1, 2), 2.0),
        IntervalTuple(Date.utc(2022, 2, 1), 3.0),
        IntervalTuple(Date.utc(2022, 2, 4), 8.0),
      ]);
      expect(
          parser.parse('toMonthly(x, sum)').value.eval({'x': x}),
          TimeSeries<num>.fromIterable([
            IntervalTuple(Month.utc(2022, 1), 3.0),
            IntervalTuple(Month.utc(2022, 2), 11.0),
          ]));
    });
  });

  group('Polygraph parser test (custom functions arity 3)', () {
    test('toMonthly', () {
      var x = TimeSeries<num>.fromIterable([
        IntervalTuple(Date.utc(2022, 1, 1), 1.0),
        IntervalTuple(Date.utc(2022, 1, 2), 2.0),
        IntervalTuple(Date.utc(2022, 2, 1), 3.0),
        IntervalTuple(Date.utc(2022, 2, 4), 8.0),
      ]);
      expect(
          parser.parse('toMonthly(x, sum)').value.eval({'x': x}),
          TimeSeries<num>.fromIterable([
            IntervalTuple(Month.utc(2022, 1), 3.0),
            IntervalTuple(Month.utc(2022, 2), 11.0),
          ]));
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;
  await tests(rootUrl);
}
