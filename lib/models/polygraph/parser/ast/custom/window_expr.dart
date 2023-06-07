library ast.custom.window_expr;

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_quiver/models/polygraph/parser/ast.dart';
import 'package:timeseries/timeseries.dart';

import '../expression.dart';

/// The window expression associated with the window function.
class WindowExpr extends Expression {
  WindowExpr({required this.x, this.bucket, required this.months,
    required this.hours});

  final Variable x;
  final Bucket? bucket;
  final List<int> months;
  final List<int> hours;

  @override
  dynamic eval(Map<String, dynamic> variables) {
    var ts = x.eval(variables) as TimeSeries<num>;
    if (months.isNotEmpty) {
      var monthsS = months.toSet();
      ts = ts.where((e) => monthsS.contains(e.interval.start.month)).toTimeSeries();
    }

    if (hours.isNotEmpty) {
      var hoursS = hours.toSet();
      ts = ts.where((e) => hoursS.contains(e.interval.start.hour)).toTimeSeries();
    }

    if (bucket != null) {
      if (ts.first.interval is! Hour) {
        throw StateError('The bucket argument is only allowed for hourly timeseries!'
            'Your timeseries is not hourly.');
      }
      ts = ts.where((e) => bucket!.containsHour(e.interval as Hour)).toTimeSeries();
    }

    return ts;
  }

  @override
  String toString() => 'window(${x.name}, bla-bla)';  /// TODO:
}
