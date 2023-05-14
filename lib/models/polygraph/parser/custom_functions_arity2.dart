library models.polygraph.parser.custom_functions_arity2;

import 'dart:math' as math;

import 'package:flutter_quiver/models/polygraph/parser/common.dart';
import 'package:petitparser/petitparser.dart';
import 'package:timeseries/timeseries.dart';

/// Calculates the max(x, value) for each element of the timeseries.
Result max(dynamic ts, dynamic value) {
  if (ts is! TimeSeries) {
    return const Failure('', 0, 'First argument needs to be a timeseries');
  }
  if (value is! num) {
    return const Failure('', 0, 'Second argument needs to be a number');
  }
  return Success('', 0, TimeSeries.fromIterable(ts.observations.map((e) =>
      IntervalTuple(e.interval, math.max<num>(e.value, value)))));
}

/// Calculates the max(x, value) for each element of the timeseries.
Result min(dynamic ts, dynamic value) {
  if (ts is! TimeSeries) {
    return const Failure('', 0, 'First argument needs to be a timeseries');
  }
  if (value is! num) {
    return const Failure('', 0, 'Second argument needs to be a number');
  }
  return Success('', 0, TimeSeries.fromIterable(ts.observations.map((e) =>
      IntervalTuple(e.interval, math.min<num>(e.value, value)))));
}

Result toMonthly(dynamic ts, dynamic functionName) {
  if (ts is! TimeSeries) {
    return const Failure('', 0, 'First argument needs to be a timeseries');
  }
  if (baseFunctions.containsKey(functionName)) {
    return Success('', 0, toMonthly(ts as TimeSeries<num>, baseFunctions[functionName]!));
  } else {
    return Failure('', 0, 'Unsupported aggregation function: $functionName');
  }
}
