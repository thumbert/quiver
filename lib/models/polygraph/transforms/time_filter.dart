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
  static TimeFilter fromMongo(Map<String, dynamic> x) {
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
        var date = Date.fromTZDateTime(x.start);
        res = res && holidays.any((holiday) => holiday.isDate(date));
      }

      return res;
    };
  }

  Map<String, dynamic> toMongo() {
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
    // TODO: implement toJson
    throw UnimplementedError();
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

// class TimeFilter extends Object with Transform {
//   TimeFilter() {
//     _f = (Interval x) => true;
//   }
//
//   late bool Function(Interval) _f;
//
//   // TimeFilter withYears(Set<int> years) {
//   //   var tf = TimeFilter();
//   //   tf._f = (Interval x) => _f(x) && years.contains(x.start.year);
//   //   return tf;
//   // }
//   //
//   // TimeFilter withMonths(Set<int> months) {
//   //   var tf = TimeFilter();
//   //   tf._f = (Interval x) => _f(x) && months.contains(x.start.month);
//   //   return tf;
//   // }
//
//   @override
//   Iterable<IntervalTuple<num>> apply(Iterable<IntervalTuple<num>> ts) {
//     return ts.where((e) => _f(e.interval));
//   }
//
//   /// Something like:
//   /// ```
//   /// {
//   ///   'filter': {
//   ///      'time': {
//   ///         'type': 'bucketFilter',
//   ///         'bucket': '5x16',
//   ///      },
//   ///   }
//   /// }
//   /// ```
//   /// or
//   /// ```
//   /// {
//   ///   'filter': {
//   ///      'time': {
//   ///         'type': 'monthFilter',
//   ///         'months': [12, 1, 2],
//   ///      },
//   ///   }
//   /// }
//   /// ```
//   TimeFilter fromJson(Map<String, dynamic> x) {
//     var filterType = x['filter']['time']['type'] as String?;
//     if (filterType == null) {
//       throw StateError(
//           'Format error for time filter, missing [filter][time][type]');
//     }
//
//     // if (!x.containsKey('filter')) {
//     //   throw StateError('Format error for time filter, missing key filter');
//     // }
//     // if (!(x['filter'] as Map).containsKey('time')) {
//     //   throw StateError('Format error for time filter, missing key time');
//     // }
//     // if (!(x['filter']['time'] as Map).containsKey('type')) {
//     //   throw StateError('Format error for time filter, missing key type');
//     // }
//
//     if (filterType == 'bucketFilter') {
//       var bucket = x['filter']['time']['bucket'] as String?;
//       if (bucket == null) {
//         throw StateError('Bucket not specified for time filter for bucket');
//       }
//       return TimeFilterForBucket(bucket: Bucket.parse(bucket));
//
//       ///
//       ///
//     } else if (filterType == 'monthFilter') {
//       var months = x['filter']['time']['months'] as List?;
//       if (months == null) {
//         throw StateError('Months not specified for time filter for months');
//       }
//       return TimeFilterForMonths(months: months.toSet().cast<int>());
//
//       ///
//       ///
//     } else {
//       throw StateError('Unsupported time filter type: $filterType');
//     }
//   }
//
//   @override
//   Map<String, dynamic> toJson() {
//     // TODO: implement toJson
//     throw UnimplementedError();
//   }
// }
//
// class TimeFilterForBucket extends TimeFilter {
//   TimeFilterForBucket({required this.bucket}) {
//     _f = (Interval interval) =>
//         bucket.containsHour(Hour.containing(interval.start));
//   }
//   final Bucket bucket;
//
//   @override
//   Map<String, dynamic> toJson() {
//     // TODO: implement toJson
//     throw UnimplementedError();
//   }
// }
//
// class TimeFilterForMonths extends TimeFilter {
//   TimeFilterForMonths({required this.months}) {
//     _f = (Interval interval) => months.contains(interval.start.month);
//   }
//   final Set<int> months;
//
//   @override
//   Map<String, dynamic> toJson() {
//     // TODO: implement toJson
//     throw UnimplementedError();
//   }
// }
