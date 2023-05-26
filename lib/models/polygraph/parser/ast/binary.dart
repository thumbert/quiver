library ast.binary;

import 'dart:async';
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
    if (name == 'toMonthly') {
      return function(
          left.eval(variables), right.toString().replaceFirst('Variable ', ''));
    }

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
