import 'expression.dart';


/// An int list expression.
class IntListExpr extends Expression {
  IntListExpr(this.value);

  final List<int> value;

  @override
  List<int> eval(Map<String, dynamic> variables) => value;

  @override
  String toString() => 'List<int>{$value}';
}


class MonthsListExpr extends Expression {
  MonthsListExpr(this.value);

  final List<int> value;

  @override
  List<int> eval(Map<String, dynamic> variables) => value;

  @override
  String toString() => 'MonthsList{$value}';
}

class HoursListExpr extends Expression {
  HoursListExpr(this.value);

  final List<int> value;

  @override
  List<int> eval(Map<String, dynamic> variables) => value;

  @override
  String toString() => 'HoursList{$value}';
}

