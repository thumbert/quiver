library ast.binary;

import 'dart:async';
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
      return function(left.eval(variables), right.toString().replaceFirst('Variable ', ''));
    }

    return function(left.eval(variables), right.eval(variables));
  }

  @override
  String toString() => 'Binary{$name}';
}