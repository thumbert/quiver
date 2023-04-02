import 'dart:async';
import 'dart:math';

import 'package:petitparser/petitparser.dart';
import 'package:timeseries/timeseries.dart';
import 'package:dama/dama.dart';

/// Common mathematical constants.
final constants = {
  'e': e,
  'pi': pi,
};

final baseFunctions = <String, num Function(Iterable<num>)>{
  'count': (xs) => xs.length,
  'first': (xs) => xs.first,
  'last': (xs) => xs.last,
  'mean': (xs) => mean(xs),
  // 'median': (xs) => median(xs), // TODO: implement median and quantile
  'min': (xs) => min(xs),
  'max': (xs) => max(xs),
};


/// Functions of arity 1.
final functions1 = <String, FutureOr<dynamic> Function(dynamic)>{
  'exp': (x) => exp(x),
  'log': (x) => log(x),
  'sin': (x) => sin(x),
  'asin': (x) => asin(x),
  'cos': (x) => cos(x),
  'acos': (x) => acos(x),
  'tan': (x) => tan(x),
  'atan': (x) => atan(x),
  'sqrt': (x) => sqrt(x),

  /// custom functions
  'get': (x) => x,
  'sum': (x) => x,
};

/// Functions of arity 2
final functions2 = <String, dynamic Function(dynamic, dynamic)> {
  'sd': (ts, window) => ts,
  //
  //
  'toDaily': (ts, functionName) {
    if (ts is! TimeSeries) {
      return const Failure('', 0, 'First argument needs to be a timeseries');
    }
    if (baseFunctions.containsKey(functionName)) {
      return Success('', 0, toDaily(ts as TimeSeries<num>, baseFunctions[functionName]!));
    } else {
      return Failure('', 0, 'Unsupported function: $functionName');
    }
  },
  //
  //
  'toMonthly': (ts, functionName) {
    if (ts is! TimeSeries) {
      return const Failure('', 0, 'First argument needs to be a timeseries');
    }
    if (baseFunctions.containsKey(functionName)) {
      return Success('', 0, toMonthly(ts as TimeSeries<num>, baseFunctions[functionName]!));
    } else {
      return Failure('', 0, 'Unsupported function: $functionName');
    }
  },
};

