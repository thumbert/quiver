library ast.assignment;

import 'dart:async';
import 'expression.dart';

/// An assignment expression.
class Assignment extends Expression {
  Assignment(this.name, this.expression);

  final String name;
  final Expression expression;

  @override
  void eval(Map<String, dynamic> variables) {
    var value = expression.eval(variables);
    variables[name] = value;
  }

  @override
  String toString() => 'Assignment $name to ${expression.toString()}';
}
