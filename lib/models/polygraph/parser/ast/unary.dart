library ast.unary;

import 'dart:async';
import 'expression.dart';

/// An unary expression.
class Unary extends Expression {
  Unary(this.name, this.value, this.function);

  final String name;
  final Expression value;
  final dynamic Function(dynamic) function;

  @override
  dynamic eval(Map<String, dynamic> variables) {
    var res = function(value.eval(variables));
    return res;
  }

  @override
  String toString() => 'Unary{$name}';
}
