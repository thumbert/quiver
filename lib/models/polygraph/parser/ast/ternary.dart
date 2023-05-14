library ast.binary;

import 'dart:async';
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
    // if (name == 'toMonthly') {
    //   return function(x0.eval(variables), x1.toString().replaceFirst('Variable ', ''));
    // }
    return function(x0.eval(variables), x1.eval(variables), x2.eval(variables));
  }

  @override
  String toString() => 'Ternary{$name}';
}