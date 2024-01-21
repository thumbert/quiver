library models.polygraph.transforms.time_filter;

import 'package:date/date.dart';
import 'package:elec/time.dart';
import 'package:flutter_quiver/models/polygraph/transforms/transform.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeseries/timeseries.dart';

class TimeFilter extends Object with Transform {
  TimeFilter({
    required this.years,
    required this.months,
    required this.days,
    required this.hours,
    required this.bucket,
    required this.daysOfWeek,
    required this.holidays,
  }) {
    _constructFilterFunction();
  }

  /// The empty filter
  TimeFilter.empty()
      : years = <int>{},
        months = <int>{},
        days = <int>{},
        hours = <int>{},
        bucket = Bucket.atc,
        daysOfWeek = <int>{},
        holidays = <Holiday>{} {
    _f = (Interval x) => true;
  }

  final Set<int> years;

  /// Months of year, 1-12
  final Set<int> months;

  /// Days of month
  final Set<int> days;

  /// Hours of day, 0-23
  final Set<int> hours;
  final Bucket bucket;

  /// Days of week, Mon=1, Sun=7
  final Set<int> daysOfWeek;
  final Set<Holiday> holidays;

  /// Check if this time filter is empty (doesn't have to do anything)
  bool isEmpty() =>
      years.isEmpty &&
      months.isEmpty &&
      days.isEmpty &&
      hours.isEmpty &&
      bucket == Bucket.atc &&
      holidays.isEmpty;

  bool isNotEmpty() => !isEmpty();

  bool isHourly() => hours.isNotEmpty || bucket != Bucket.atc;
  bool isDaily() => !isHourly() && (days.isNotEmpty || holidays.isNotEmpty);
  bool isMonthly() => !isDaily() && months.isNotEmpty;
  bool isYearly() => !isMonthly() && years.isNotEmpty;

  /// Construct a time filter from the minimal description only.
  static TimeFilter fromJson(Map<String, dynamic> x) {
    var years = x['years'] ?? <int>{};
    var months = x['months'] ?? <int>{};
    var days = x['days'] ?? <int>{};
    var hours = x['hours'] ?? <int>{};
    Bucket bucket = Bucket.atc;
    if (x['bucket'] != null) {
      bucket = Bucket.parse(x['bucket']);
    }
    var dayOfWeek = x['dayOfWeek'] ?? <int>{};
    var holidays = <Holiday>{};
    if (x['holidays'] != null) {
      for (var holidayName in x['holidays']) {
        holidays.add(Holiday.parse(holidayName));
      }
    }
    return TimeFilter(
        years: years.toSet().cast<int>(),
        months: months.toSet().cast<int>(),
        days: days.toSet().cast<int>(),
        hours: hours.toSet().cast<int>(),
        bucket: bucket,
        daysOfWeek: dayOfWeek.toSet().cast<int>(),
        holidays: holidays);
  }

  /// Filtering function, created only the first time
  late bool Function(Interval) _f;

  /// No care is made to ensure that the filter granularity matches
  /// the granularity of the input intervals.  If the input [ts] does not match
  /// the time granularity of the filter, the filtered results will be wrong.
  ///
  /// For example, for a filter with non-empty [days], a monthly timeseries
  /// used as an input will return wrong data.
  @override
  Iterable<IntervalTuple<num>> apply(Iterable<IntervalTuple<num>> ts) {
    return ts.where((e) => _f(e.interval));
  }

  void _constructFilterFunction() {
    _f = (Interval x) {
      var res = true;
      if (years.isNotEmpty) {
        res = res && years.contains(x.start.year);
      }
      if (months.isNotEmpty) {
        res = res && months.contains(x.start.month);
      }
      if (days.isNotEmpty) {
        res = res && days.contains(x.start.day);
      }
      if (hours.isNotEmpty) {
        res = res && hours.contains(x.start.hour);
      }
      if (bucket != Bucket.atc) {
        res = res && bucket.containsHour(Hour.beginning(x.start));
      }
      if (daysOfWeek.isNotEmpty) {
        res = res && daysOfWeek.contains(x.start.weekday);
      }
      if (holidays.isNotEmpty) {
        res = res &&
            holidays.any((holiday) =>
                holiday.isDate3(x.start.year, x.start.month, x.start.day));
      }

      return res;
    };
  }

  /// The empty filter
  static TimeFilter getDefault() => TimeFilter.empty();

  TimeFilter copyWith({
    Set<int>? years,
    Set<int>? months,
    Set<int>? days,
    Set<int>? hours,
    Bucket? bucket,
    Set<int>? daysOfWeek,
    Set<Holiday>? holidays,
  }) =>
      TimeFilter(
          years: years ?? this.years,
          months: months ?? this.months,
          days: days ?? this.days,
          hours: hours ?? this.hours,
          bucket: bucket ?? this.bucket,
          daysOfWeek: daysOfWeek ?? this.daysOfWeek,
          holidays: holidays ?? this.holidays);

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (years.isNotEmpty) 'years': years,
      if (months.isNotEmpty) 'months': months,
      if (days.isNotEmpty) 'days': days,
      if (bucket != Bucket.atc) 'bucket': bucket.name,
      if (daysOfWeek.isNotEmpty) 'daysOfWeek': daysOfWeek,
      if (holidays.isNotEmpty)
        'holidays': holidays.map((e) => e.holidayType.name).toSet(),
    };
  }
}

class TimeFilterNotifier extends StateNotifier<TimeFilter> {
  TimeFilterNotifier(this.ref) : super(TimeFilter.empty());

  final Ref ref;

  set years(Set<int> values) {
    state = state.copyWith(years: values);
  }

  set months(Set<int> values) {
    state = state.copyWith(months: values);
  }

  set days(Set<int> values) {
    state = state.copyWith(days: values);
  }

  set hours(Set<int> values) {
    state = state.copyWith(hours: values);
  }

  set daysOfWeek(Set<int> values) {
    state = state.copyWith(daysOfWeek: values);
  }

  set bucket(Bucket value) {
    state = state.copyWith(bucket: value);
  }
}
