library ast.variable;

import 'dart:async';
import 'expression.dart';

/// A variable expression.
class Variable extends Expression {
  Variable(this.name);

  final String name;

  @override
  dynamic eval(Map<String, dynamic> variables) => variables.containsKey(name)
      ? variables[name]!
      : throw 'Unknown variable $name';

  @override
  String toString() => 'Variable $name';
}
