library parser.ast.custom.ma_expr;

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_quiver/models/polygraph/parser/ast.dart';
import 'package:timeseries/timeseries.dart';

import '../expression.dart';

/// The expression associated with the ma function.
///
class MaExpr extends Expression {
  MaExpr({required this.x, required this.n});

  final Expression x;
  final int n;

  @override
  dynamic eval(Map<String, dynamic> variables) {
    var ts = x.eval(variables) as TimeSeries<num>;

    return ts;
  }

  @override
  String toString() => 'ma(${x.toString()}, n)';
}
