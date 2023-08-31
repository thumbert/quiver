library ast.unary;

import 'package:timeseries/timeseries.dart';

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

class UnaryNegation extends Expression {
  UnaryNegation(this.value);

  final Expression value;

  @override
  dynamic eval(Map<String, dynamic> variables) {
    var x = value.eval(variables);
    return switch (x) {
      (num x) => -x,
      (TimeSeries<num> x) => x.apply((e) => -e),
      _ => throw StateError('Don\'t know how to negate $x'),
    };
  }

  @override
  String toString() => 'UnaryNegation';
}


