library models.polygraph.parser.custom_functions_arity2;

import 'dart:math' as math;

import 'package:elec/elec.dart';
import 'package:flutter_quiver/models/polygraph/parser/common.dart';
import 'package:petitparser/petitparser.dart';
import 'package:timeseries/timeseries.dart';

// /// Calculates the max of two arguments
// dynamic max(dynamic left, dynamic right) {
//   var res = switch ((left, right)) {
//     ((num left, num right)) => math.max<num>(left, right),
//     ((TimeSeries<num> left, num right)) => TimeSeries.fromIterable(
//         left.map((e) => IntervalTuple(e.interval, math.max(e.value, right)))),
//     ((num left, TimeSeries<num> right)) => TimeSeries.fromIterable(
//         right.map((e) => IntervalTuple(e.interval, math.max(e.value, left)))),
//     ((TimeSeries<num> left, TimeSeries<num> right)) =>
//       left.merge(right, f: (x, y) => math.max(x!, y!)),
//     _ => throw StateError('Don\'t know how to calculate the max for these inputs'),
//   };
//   return res;
// }
//
// /// Calculates the min of two arguments
// dynamic min(dynamic left, dynamic right) {
//   var res = switch ((left, right)) {
//     ((num left, num right)) => math.min<num>(left, right),
//     ((TimeSeries<num> left, num right)) => TimeSeries.fromIterable(
//         left.map((e) => IntervalTuple(e.interval, math.min(e.value, right)))),
//     ((num left, TimeSeries<num> right)) => TimeSeries.fromIterable(
//         right.map((e) => IntervalTuple(e.interval, math.min(e.value, left)))),
//     ((TimeSeries<num> left, TimeSeries<num> right)) =>
//       left.merge(right, f: (x, y) => math.min(x!, y!)),
//     _ => throw StateError('Don\'t know how to calculate the min for these inputs'),
//   };
//   return res;
// }

// TimeSeries<num> toMonthly(TimeSeries<num> ts, String functionName) {
//   if (!baseFunctions.containsKey(functionName)) {
//     throw StateError('Unsupported aggregation function: $functionName');
//   }
//   return TimeSeries<num>();
// }



// Result min(dynamic ts, dynamic value) {
//   if (ts is! TimeSeries) {
//     return const Failure('', 0, 'First argument needs to be a timeseries');
//   }
//   if (value is! num) {
//     return const Failure('', 0, 'Second argument needs to be a number');
//   }
//   return Success(
//       '',
//       0,
//       TimeSeries.fromIterable(ts.observations.map(
//           (e) => IntervalTuple(e.interval, math.min<num>(e.value, value)))));
// }

// Result toMonthly(dynamic ts, dynamic functionName) {
//   if (ts is! TimeSeries) {
//     return const Failure('', 0, 'First argument needs to be a timeseries');
//   }
//   if (baseFunctions.containsKey(functionName)) {
//     return Success(
//         '', 0, toMonthly(ts as TimeSeries<num>, baseFunctions[functionName]!));
//   } else {
//     return Failure('', 0, 'Unsupported aggregation function: $functionName');
//   }
// }
