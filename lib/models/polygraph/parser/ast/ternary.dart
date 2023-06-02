library ast.binary;

import 'dart:async';
import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_quiver/models/polygraph/parser/common.dart';
import 'package:timeseries/timeseries.dart';

import 'expression.dart';

/// A ternary expression.
class Ternary extends Expression {
  Ternary(this.name, this.x0, this.x1, this.x2, this.function);

  final String name;
  final Expression x0;
  final Expression x1;
  final Expression x2;
  final dynamic Function(dynamic, dynamic, dynamic) function;

  @override
  dynamic eval(Map<String, dynamic> variables) {
    return function(x0.eval(variables), x1.eval(variables), x2.eval(variables));
  }

  @override
  String toString() => 'Ternary{$name}';
}


class ToMonthly3 extends Expression {
  ToMonthly3(this.x, this.function, this.bucketName);

  final Expression x;
  final String function;
  final String bucketName;

  @override
  dynamic eval(Map<String, dynamic> variables) {
    var bucket = Bucket.parse(bucketName);
    var ts = x.eval(variables);
    if (ts is! TimeSeries<num>) {
      throw StateError('First argument to function toMonthly needs to be a timeseries');
    }
    if (!baseFunctions.containsKey(function)) {
      throw StateError('Can\'t find $function in the pre-defined aggregation functions list');
    }
    return toMonthly(ts.where((e) => bucket.containsHour(e.interval as Hour)), baseFunctions[function]!);
  }

  @override
  String toString() => 'toMonthly';
}