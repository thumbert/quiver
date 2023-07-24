library parser.ast.custom.hourly_schedule_expr;

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec/time.dart';
import 'package:flutter_quiver/models/polygraph/parser/ast.dart';
import 'package:timeseries/timeseries.dart';

import '../expression.dart';

class HourlyScheduleExpr extends Expression {
  HourlyScheduleExpr(this.x, {this.bucket, required this.months});

  final num x;
  final Bucket? bucket;
  final List<int> months;

  @override
  dynamic eval(Map<String, dynamic> variables) {
    if (!variables.containsKey('_domain')) {
      throw StateError('hourly_schedule needs a _domain!');
    }
    var hs = HourlyScheduleFilled(x);
    var ts = hs.toHourly(variables['_domain'] as Interval);

    if (months.isNotEmpty) {
      var monthsS = months.toSet();
      ts = ts.where((e) => monthsS.contains(e.interval.start.month)).toTimeSeries();
    }

    if (bucket != null) {
      ts = ts.where((e) => bucket!.containsHour(e.interval as Hour)).toTimeSeries();
    }

    return ts;
  }

  @override
  String toString() => 'hourly_schedule($x, bla-bla)';  /// TODO:
}