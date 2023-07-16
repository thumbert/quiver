library parser.ast.custom.ma_expr;

import 'package:dama/stat/descriptive/moving_statistic.dart';
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
    if (n <= 1) {
      throw StateError('Window length n needs to be > 1');
    }
    if (n > ts.length) {
      throw StateError('Window length n too large.');
    }
    var ms = MovingStatistics(leftWindow: n-1, rightWindow: 0);

    var aux = TimeSeries.from(ts.intervals.skip(n-1),
        ms.movingMean(ts.values.toList()).skip(n-1));

    return aux;
  }

  @override
  String toString() => 'ma(${x.toString()}, n)';
}
