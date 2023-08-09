library models.polygraph.editors.shooju_expression;

import 'package:date/date.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_filter.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';

enum PeriodConvention {
  beginning('beginning'),
  ending('ending');

  const PeriodConvention(this.value);

  final String value;
  
  PeriodConvention parse(String value) {
    if (value == 'beginning') {
      return PeriodConvention.beginning;
    } else if (value == 'ending') {
      return PeriodConvention.ending;
    } else {
      throw 'Don\'t know how to parse $value as PeriodConvention';
    }
  }
}

class ShoojuExpression extends PolygraphVariable {
  ShoojuExpression({
    required this.expression,
    // required this.periodConvention,
    String? label,
    required this.timeFilter,
    required this.timeAggregation,
  }) {
    this.label = label ?? expression;
  }

  /// For example, 'tsdbid=WTHR_KBOS_TMIN_DLY_HIST'
  final String expression;
  // final PeriodConvention periodConvention;
  final TimeFilter timeFilter;
  final TimeAggregation timeAggregation;

  ///

  static getDefault() => ShoojuExpression(
      expression: '',
      // periodConvention: PeriodConvention.ending,
      timeFilter: TimeFilter.empty(),
      timeAggregation: TimeAggregation.empty());

  @override
  TimeSeries<num> timeSeries(Term term) {
    TimeSeries<num> ts, aux;

    // dataProvider.spec =

    // if (timeFilter.isNotEmpty()) {
    //   if (timeFilter.isMonthly()) {
    //     var months = Month.fromTZDateTime(term.interval.start)
    //         .upTo(Month.fromTZDateTime(term.interval.end));
    //     aux = TimeSeries.fill(months, yIntercept);
    //   } else if (timeFilter.isDaily()) {
    //     aux = TimeSeries.fill(term.days(), yIntercept);
    //   } else if (timeFilter.isYearly()) {
    //     var years = term.interval.splitLeft((dt) => Interval(
    //         TZDateTime(dt.location, dt.year),
    //         TZDateTime(dt.location, dt.year + 1)));
    //     aux = TimeSeries.fill(years, yIntercept);
    //   } else {
    //     aux = TimeSeries.fill(term.hours(), yIntercept);
    //   }
    //   ts = TimeSeries.fromIterable(timeFilter.apply(aux));
    // }
    // if (timeAggregation.isNotEmpty()) {
    //   ts = TimeSeries.fromIterable(timeAggregation.apply(ts));
    // }

    return TimeSeries<num>();
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  ShoojuExpression copyWith(
      {String? expression,
        String? label,
        // PeriodConvention? periodConvention,
        TimeFilter? timeFilter,
        TimeAggregation? timeAggregation}) =>
      ShoojuExpression(
        expression: expression ?? this.expression,
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

class ShoojuExpressionNotifier extends StateNotifier<ShoojuExpression> {
  ShoojuExpressionNotifier(this.ref) : super(ShoojuExpression.getDefault());

  final Ref ref;

  set expression(String value) {
    state = state.copyWith(expression: value);
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
