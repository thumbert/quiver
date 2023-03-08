library models.polygraph.editors.horizontal_line;

import 'package:date/date.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_filter.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';

class HorizontalLine extends Object with PolygraphVariable {
  HorizontalLine({
    required this.yIntercept,
    required this.timeFilter,
    required this.timeAggregation,
  });

  final num yIntercept;
  final TimeFilter timeFilter;
  final TimeAggregation timeAggregation;

  static getDefault() => HorizontalLine(
      yIntercept: 0.0,
      timeFilter: TimeFilter.empty(),
      timeAggregation: TimeAggregation.empty());

  @override
  String label() {
    return 'h=$yIntercept';
  }

  @override
  TimeSeries<num> timeSeries(Term term) {
    late TimeSeries<num> ts, aux;
    if (timeFilter.isNotEmpty()) {
      if (timeFilter.isMonthly()) {
        var months = Month.fromTZDateTime(term.interval.start).upTo(Month.fromTZDateTime(term.interval.end));
        aux = TimeSeries.fill(months, yIntercept);
      } else if (timeFilter.isDaily()) {
        aux = TimeSeries.fill(term.days(), yIntercept);
      } else if (timeFilter.isYearly()) {
        var years = term.interval.splitLeft((dt) => Interval(TZDateTime(dt.location, dt.year), TZDateTime(dt.location, dt.year+1)));
        aux = TimeSeries.fill(years, yIntercept);
      } else {
        aux = TimeSeries.fill(term.hours(), yIntercept);
      }
      ts = TimeSeries.fromIterable(timeFilter.apply(aux));

    }
    if (timeAggregation.isNotEmpty()) {
      ts = TimeSeries.fromIterable(timeAggregation.apply(ts));
    }

    return ts;
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}
