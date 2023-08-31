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
  'median': (xs) {
    var q = Quantile(xs.toList());
    return q.median();
  },
  'min': (xs) => min(xs),
  'max': (xs) => max(xs),
  'sum': (xs) => sum(xs),
};


/// Functions of arity 1.
final functions1 = <String, dynamic Function(dynamic)>{
  'exp': (x) {
    return switch (x) {
      (num x) => exp(x),
      (TimeSeries<num> x) => x.apply((e) => exp(e)),
      _ => throw StateError('Don\'t know how to calculate the exp for this input'),
    };
  },
  'log': (x) {
    return switch (x) {
      (num x) => log(x),
      (TimeSeries<num> x) => x.apply((e) => log(e)),
      _ => throw StateError('Don\'t know how to calculate the log for this input'),
    };
  },
  'sin': (x) {
    return switch (x) {
      (num x) => sin(x),
      (TimeSeries<num> x) => x.apply((e) => sin(e)),
      _ => throw StateError('Don\'t know how to calculate the sin for this input'),
    };
  },
  'asin': (x) => asin(x),
  'cos': (x) {
    return switch (x) {
      (num x) => cos(x),
      (TimeSeries<num> x) => x.apply((e) => cos(e)),
      _ => throw StateError('Don\'t know how to calculate the cos for this input'),
    };
  },
  'acos': (x) => acos(x),
  'tan': (x) => tan(x),
  'atan': (x) => atan(x),
  'sqrt': (x) => sqrt(x),

  /// custom functions
  'get': (x) => x,
  'sum': (x) {
    return switch (x) {
      (num x) => x,
      (TimeSeries<List<num>> x) => TimeSeries.fromIterable(x.map((e) =>
          IntervalTuple(e.interval, sum(e.value)))),
      _ => throw StateError('Don\'t know how to calculate the cos for this input'),
    };
  },

  // 'toMonthly(mean)': (x) {
  //   return switch (x) {
  //     (TimeSeries<num> x) => x.groupByIndex((interval) => Month.fromTZDateTime(interval.start)),
  //     _ => throw StateError('Input is not a numeric timeseries.  Don\'t know how to aggregate toMonthly for this input'),
  //   };
  // },

};

/// Functions of arity 2.  First argument is a timeseries.
final functions2 = <String, dynamic Function(dynamic, dynamic)> {
  // 'max': arity2.max,
  // 'min': arity2.min,

  // TODO: implement moving average and standard deviation for Bollinger bands
  // TODO: implement append/prepend of two timeseries
  
  
  // 'sd': (ts, window) => ts,
  //
  //
  'toDaily': (ts, functionName) {
    if (ts is! TimeSeries) {
      return const Failure('', 0, 'First argument needs to be a timeseries');
    }
    if (baseFunctions.containsKey(functionName)) {
      return Success('', 0, toDaily(ts as TimeSeries<num>, baseFunctions[functionName]!));
    } else {
      return Failure('', 0, 'Unsupported aggregation function: $functionName');
    }
  },
  //
  //
  // 'toMonthly': arity2.toMonthly,
};

