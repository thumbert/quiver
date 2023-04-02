import 'expression.dart';


/// A value expression.
class Value extends Expression {
  Value(this.value);

  final num value;

  @override
  num eval(Map<String, dynamic> variables) => value;

  @override
  String toString() => 'Value{$value}';
}
