library models.hourly_shape.day_filter;

import 'package:date/date.dart';
import 'package:elec/time.dart';
import 'package:more/collection.dart';

class DayFilter {
  /// All the arguments specify what days to keep in the filter.
  /// If empty don't apply the respective filter at all.
  DayFilter({
    required this.years,
    required this.months,
    required this.days,
    required this.daysOfWeek,
    required this.specialDays,
    required this.holidays,
  });

  /// The empty filter
  DayFilter.empty()
      : years = <int>{},
        months = <int>{},
        days = <int>{},
        daysOfWeek = <int>{},
        specialDays = <Date>{},
        holidays = <Holiday>{};

  static DayFilter getDefault() {
    var yearEnd = DateTime.now().year;
    var yearStart = yearEnd - 4;
    var years = IntegerRange(yearStart, yearEnd + 1).toSet();
    return DayFilter(
        years: years,
        months: <int>{3},
        days: <int>{},
        daysOfWeek: <int>{1, 2, 3, 4, 5},
        specialDays: <Date>{},
        holidays: <Holiday>{});
  }

  final Set<int> years;

  /// Months of year, 1-12
  final Set<int> months;

  /// Days of month
  final Set<int> days;

  /// Days of week, Mon=1, Sun=7
  final Set<int> daysOfWeek;

  /// Hand-picked days (UTC)
  final Set<Date> specialDays;

  /// Holidays to keep in the filter
  final Set<Holiday> holidays;

  /// Return all the days in term that satisfy this filter
  List<Date> getDays(Term term) {
    var candidates = term.days();
    var out = <Date>[];
    for (var day in candidates) {
      if (years.isNotEmpty && !years.contains(day.year)) continue;
      if (months.isNotEmpty && !months.contains(day.month)) continue;
      if (days.isNotEmpty && !days.contains(day.day)) continue;
      if (daysOfWeek.isNotEmpty && !daysOfWeek.contains(day.weekday)) continue;
      if (holidays.isNotEmpty &&
          holidays.every((e) => !e.isDate3(day.year, day.month, day.day))) {
        continue;
      }
      out.add(day);
    }
    if (specialDays.isNotEmpty) {
      var aux = specialDays
          .map((e) => Date(e.year, e.month, e.day, location: term.location))
          .toSet();
      out.addAll(aux.intersection(candidates.toSet()));
      out = out.toSet().toList();
    }

    return out;
  }

  /// Check if this time filter is empty (doesn't have to do anything)
  bool isEmpty() =>
      years.isEmpty && months.isEmpty && days.isEmpty && holidays.isEmpty;

  bool isNotEmpty() => !isEmpty();

  /// Construct a time filter from the minimal description only.
  static DayFilter fromJson(Map<String, dynamic> x) {
    var years = x['years'] ?? <int>{};
    var months = x['months'] ?? <int>{};
    var days = x['days'] ?? <int>{};
    var dayOfWeek = x['dayOfWeek'] ?? <int>{};
    var holidays = <Holiday>{};
    if (x['holidays'] != null) {
      for (var holidayName in x['holidays']) {
        holidays.add(Holiday.parse(holidayName));
      }
    }
    return DayFilter(
        years: years.toSet().cast<int>(),
        months: months.toSet().cast<int>(),
        days: days.toSet().cast<int>(),
        daysOfWeek: dayOfWeek.toSet().cast<int>(),
        specialDays: <Date>{},
        holidays: holidays);
  }

  DayFilter copyWith({
    Set<int>? years,
    Set<int>? months,
    Set<int>? days,
    Set<int>? daysOfWeek,
    Set<Date>? specialDays,
    Set<Holiday>? holidays,
  }) =>
      DayFilter(
          years: years ?? this.years,
          months: months ?? this.months,
          days: days ?? this.days,
          daysOfWeek: daysOfWeek ?? this.daysOfWeek,
          specialDays: specialDays ?? this.specialDays,
          holidays: holidays ?? this.holidays);

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (years.isNotEmpty) 'years': years,
      if (months.isNotEmpty) 'months': months,
      if (days.isNotEmpty) 'days': days,
      if (daysOfWeek.isNotEmpty) 'daysOfWeek': daysOfWeek,
      if (holidays.isNotEmpty)
        'holidays': holidays.map((e) => e.holidayType.name).toSet(),
    };
  }
}
