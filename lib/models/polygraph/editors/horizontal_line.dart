library models.polygraph.editors.horizontal_line;

import 'package:date/date.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_filter.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';

class HorizontalLine extends PolygraphVariable {
  HorizontalLine({
    required this.yIntercept,
    String? label,
    required this.timeFilter,
    required this.timeAggregation,
  }) {
    this.label = label ?? 'h=$yIntercept';
  }

  final num yIntercept;
  final TimeFilter timeFilter;
  final TimeAggregation timeAggregation;

  static getDefault() => HorizontalLine(
      yIntercept: 0.0,
      label: 'h=0',
      timeFilter: TimeFilter.empty(),
      timeAggregation: TimeAggregation.empty());


  TimeSeries<num> timeSeries(Term term) {
    late TimeSeries<num> ts, aux;
    if (timeFilter.isNotEmpty()) {
      if (timeFilter.isMonthly()) {
        var months = Month.containing(term.interval.start)
            .upTo(Month.containing(term.interval.end));
        aux = TimeSeries.fill(months, yIntercept);
      } else if (timeFilter.isDaily()) {
        aux = TimeSeries.fill(term.days(), yIntercept);
      } else if (timeFilter.isYearly()) {
        var years = term.interval.splitLeft((dt) => Interval(
            TZDateTime(dt.location, dt.year),
            TZDateTime(dt.location, dt.year + 1)));
        aux = TimeSeries.fill(years, yIntercept);
      } else {
        aux = TimeSeries.fill(term.hours(), yIntercept);
      }
      ts = TimeSeries.fromIterable(timeFilter.apply(aux));
    } else {
      ts = TimeSeries.from([term.interval], [yIntercept]);
    }

    /// Apply any aggregation
    if (timeAggregation.isNotEmpty()) {
      ts = TimeSeries.fromIterable(timeAggregation.apply(ts));
    }

    return ts;
  }


  void validate() {
    timeAggregation.validate();
    error = timeAggregation.error;
    print('in horizontal_line validate(), error=$error');
  }

  Map<String, dynamic> toMap() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  HorizontalLine copyWith(
          {num? yIntercept,
          String? label,
          TimeFilter? timeFilter,
          TimeAggregation? timeAggregation}) =>
      HorizontalLine(
          yIntercept: yIntercept ?? this.yIntercept,
          label: label ?? this.label,
          timeFilter: timeFilter ?? this.timeFilter,
          timeAggregation: timeAggregation ?? this.timeAggregation);

  @override
  PolygraphVariable fromMongo(Map<String,dynamic> x) {
    // TODO: implement fromMongo
    throw UnimplementedError();
  }

  @override
  Future<TimeSeries<num>> get(DataService service, Term term) {
    // TODO: implement get
    throw UnimplementedError();
  }
}

class HorizontalLineNotifier extends StateNotifier<HorizontalLine> {
  HorizontalLineNotifier(this.ref) : super(HorizontalLine.getDefault());

  final Ref ref;

  set yIntercept(num value) {
    state = state.copyWith(yIntercept: value);
  }

  set label(String value) {
    state = state.copyWith(label: value);
  }

  set timeFilter(TimeFilter value) {
    state = state.copyWith(timeFilter: value);
  }

  set timeAggregation(TimeAggregation value) {
    state = state.copyWith(timeAggregation: value);
  }
}
