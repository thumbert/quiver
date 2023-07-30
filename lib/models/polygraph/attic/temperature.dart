// library models.polygraph.editors.temperature;
//
// import 'package:date/date.dart';
// import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
// import 'package:flutter_quiver/models/polygraph/transforms/time_filter.dart';
// import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:timeseries/timeseries.dart';
// import 'package:timezone/timezone.dart';
//
// class Temperature extends Object with PolygraphVariable {
//   Temperature({
//     required this.airportCode,
//     required this.yIntercept,
//     String? label,
//     required this.timeFilter,
//     required this.timeAggregation,
//   }) {
//     this.label = label ?? 'h=$yIntercept';
//   }
//
//   /// For example, BOS for Logan International Airport
//   final String airportCode;
//   final String frequency;
//   /// mean, min, max -- only for frequency daily
//   final String variable;
//
//   final TimeFilter timeFilter;
//   final TimeAggregation timeAggregation;
//
//   static getDefault() => Temperature(
//       yIntercept: 0.0,
//       label: 'h=0',
//       timeFilter: TimeFilter.empty(),
//       timeAggregation: TimeAggregation.empty());
//
//   @override
//   TimeSeries<num> timeSeries(Term term) {
//     late TimeSeries<num> ts, aux;
//     if (timeFilter.isNotEmpty()) {
//       if (timeFilter.isMonthly()) {
//         var months = Month.fromTZDateTime(term.interval.start)
//             .upTo(Month.fromTZDateTime(term.interval.end));
//         aux = TimeSeries.fill(months, yIntercept);
//       } else if (timeFilter.isDaily()) {
//         aux = TimeSeries.fill(term.days(), yIntercept);
//       } else if (timeFilter.isYearly()) {
//         var years = term.interval.splitLeft((dt) => Interval(
//             TZDateTime(dt.location, dt.year),
//             TZDateTime(dt.location, dt.year + 1)));
//         aux = TimeSeries.fill(years, yIntercept);
//       } else {
//         aux = TimeSeries.fill(term.hours(), yIntercept);
//       }
//       ts = TimeSeries.fromIterable(timeFilter.apply(aux));
//     }
//     if (timeAggregation.isNotEmpty()) {
//       ts = TimeSeries.fromIterable(timeAggregation.apply(ts));
//     }
//
//     return ts;
//   }
//
//   @override
//   Map<String, dynamic> toJson() {
//     // TODO: implement toJson
//     throw UnimplementedError();
//   }
//
//   Temperature copyWith(
//       {num? yIntercept,
//         String? label,
//         TimeFilter? timeFilter,
//         TimeAggregation? timeAggregation}) =>
//       Temperature(
//           yIntercept: yIntercept ?? this.yIntercept,
//           label: label ?? this.label,
//           timeFilter: timeFilter ?? this.timeFilter,
//           timeAggregation: timeAggregation ?? this.timeAggregation);
// }
//
// class HorizontalLineNotifier extends StateNotifier<Temperature> {
//   HorizontalLineNotifier(this.ref) : super(Temperature.getDefault());
//
//   final Ref ref;
//
//   set yIntercept(num value) {
//     state = state.copyWith(yIntercept: value);
//   }
//
//   set label(String value) {
//     state = state.copyWith(label: value);
//   }
//
//   set timeFilter(TimeFilter value) {
//     state = state.copyWith(timeFilter: value);
//   }
//
//   set timeAggregation(TimeAggregation value) {
//     state = state.copyWith(timeAggregation: value);
//   }
// }
