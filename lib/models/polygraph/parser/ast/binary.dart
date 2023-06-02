library ast.binary;

import 'dart:async';
import 'dart:math';
import 'package:flutter_quiver/models/polygraph/parser/common.dart';
import 'package:timeseries/timeseries.dart';

import 'expression.dart';

/// A binary expression.
class Binary extends Expression {
  Binary(this.name, this.left, this.right, this.function);

  final String name;
  final Expression left;
  final Expression right;
  final dynamic Function(dynamic, dynamic) function;

  @override
  dynamic eval(Map<String, dynamic> variables) {
    return function(left.eval(variables), right.eval(variables));
  }

  @override
  String toString() => 'Binary{$name}';
}

class BinaryAdd extends Expression {
  BinaryAdd(this.left, this.right);

  final Expression left;
  final Expression right;

  @override
  dynamic eval(Map<String, dynamic> variables) {
    var x = left.eval(variables);
    var y = right.eval(variables);
    return switch ((x, y)) {
      ((num x, num y)) => x + y,
      ((num x, TimeSeries<num> y)) => y.apply((e) => e + x),
      ((TimeSeries<num> x, num y)) => x.apply((e) => e + y),
      ((TimeSeries<num> x, TimeSeries<num> y)) => x.merge(y, f: (x,y) => x! + y!),
      _ => throw StateError('Don\'t know how to add $x and $y'),
    };
  }

  @override
  String toString() => 'Add';
}

class BinarySubtract extends Expression {
  BinarySubtract(this.left, this.right);

  final Expression left;
  final Expression right;

  @override
  dynamic eval(Map<String, dynamic> variables) {
    var x = left.eval(variables);
    var y = right.eval(variables);
    return switch ((x, y)) {
      ((num x, num y)) => x - y,
      ((num x, TimeSeries<num> y)) => y.apply((e) => x - e),
      ((TimeSeries<num> x, num y)) => x.apply((e) => e - y),
      ((TimeSeries<num> x, TimeSeries<num> y)) => x.merge(y, f: (x,y) => x! - y!),
      _ => throw StateError('Don\'t know how to subtract $x and $y'),
    };
  }

  @override
  String toString() => 'Subtract';
}

class BinaryMultiply extends Expression {
  BinaryMultiply(this.left, this.right);

  final Expression left;
  final Expression right;

  @override
  dynamic eval(Map<String, dynamic> variables) {
    var x = left.eval(variables);
    var y = right.eval(variables);
    return switch ((x, y)) {
      ((num x, num y)) => x * y,
      ((num x, TimeSeries<num> y)) => y.apply((e) => e * x),
      ((TimeSeries<num> x, num y)) => x.apply((e) => e * y),
      ((TimeSeries<num> x, TimeSeries<num> y)) => x.merge(y, f: (x,y) => x! * y!),
      _ => throw StateError('Don\'t know how to multiply $x and $y'),
    };
  }

  @override
  String toString() => 'Multiply';
}

class BinaryDivide extends Expression {
  BinaryDivide(this.left, this.right);

  final Expression left;
  final Expression right;

  @override
  dynamic eval(Map<String, dynamic> variables) {
    var x = left.eval(variables);
    var y = right.eval(variables);
    return switch ((x, y)) {
      ((num x, num y)) => x / y,
      ((num x, TimeSeries<num> y)) => y.apply((e) => x / e),
      ((TimeSeries<num> x, num y)) => x.apply((e) => e / y),
      ((TimeSeries<num> x, TimeSeries<num> y)) => x.merge(y, f: (x,y) => x! / y!),
      _ => throw StateError('Don\'t know how to divide $x and $y'),
    };
  }

  @override
  String toString() => 'Divide';
}

class BinaryMax extends Expression {
  BinaryMax(this.left, this.right);

  final Expression left;
  final Expression right;

  @override
  dynamic eval(Map<String, dynamic> variables) {
    var x = left.eval(variables);
    var y = right.eval(variables);
    return switch ((x, y)) {
      ((num x, num y)) => max(x, y),
      ((num x, TimeSeries<num> y)) => y.apply((e) => max(x, e)),
      ((TimeSeries<num> x, num y)) => x.apply((e) => max(y, e)),
      ((TimeSeries<num> x, TimeSeries<num> y)) => x.merge(y, f: (x,y) => max(x!, y!)),
      _ => throw StateError('Don\'t know how to calculate the max of $x and $y'),
    };
  }

  @override
  String toString() => 'max';
}

class BinaryMin extends Expression {
  BinaryMin(this.left, this.right);

  final Expression left;
  final Expression right;

  @override
  dynamic eval(Map<String, dynamic> variables) {
    var x = left.eval(variables);
    var y = right.eval(variables);
    return switch ((x, y)) {
      ((num x, num y)) => min(x, y),
      ((num x, TimeSeries<num> y)) => y.apply((e) => min(x, e)),
      ((TimeSeries<num> x, num y)) => x.apply((e) => min(y, e)),
      ((TimeSeries<num> x, TimeSeries<num> y)) => x.merge(y, f: (x,y) => min(x!, y!)),
      _ => throw StateError('Don\'t know how to calculate the min of $x and $y'),
    };
  }

  @override
  String toString() => 'min';
}



class ToMonthly extends Expression {
  ToMonthly(this.x, this.function);

  final Expression x;
  final String function;

  @override
  dynamic eval(Map<String, dynamic> variables) {
    var ts = x.eval(variables);
    if (ts is! TimeSeries<num>) {
      throw StateError('First argument to function toMonthly needs to be a timeseries');
    }
    if (!baseFunctions.containsKey(function)) {
      throw StateError('Can\'t find $function in the pre-defined aggregation functions list');
    }
    return toMonthly(ts, baseFunctions[function]!);
  }

  @override
  String toString() => 'toMonthly';
}