library screens.common.time_filter;

import 'package:collection/collection.dart';
import 'package:elec/elec.dart';
import 'package:elec_server/utils.dart';
import 'package:flutter_quiver/screens/common/maybe_bucket.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

final providerOfTimeFilter =
    StateNotifierProvider<TimeFilterNotifier, TimeFilter>((ref) {
  var maybeBucket = ref.watch(providerOfMaybeBucket);
  var bucketName = maybeBucket == null ? '' : maybeBucket.toString();
  return TimeFilterNotifier(ref)..bucket = bucketName;
});

class TimeFilter {
  TimeFilter({
    this.bucket,
    this.hoursOfDay,
    this.monthsOfYear,
    this.monthsOfYearAsPackage = false,
    this.daysOfWeek,
    this.holiday,
  });

  final Bucket? bucket;
  final List<int>? hoursOfDay;

  /// A list to filter by month.  For example, [7,8] selects Jul and Aug and
  /// [11, 12, 1, 2, 3] selects Nov-Mar.  Note that order is important for
  /// defining a range.
  final List<int>? monthsOfYear;
  final bool monthsOfYearAsPackage;
  final List<int>? daysOfWeek;

  /// A [String] representing the holiday.  For example 'NERC' to capture all
  /// NERC holidays, or other ones like 'Juneteenth'.  [Null] value
  /// represents no holiday filter.
  final String? holiday;

  static TimeFilter fromJson(Map<String, dynamic> json) {
    Bucket? bucket;
    if (json.containsKey('bucket')) {
      bucket = Bucket.parse(json['bucket']);
    }
    List<int>? hoursOfDay;
    if (json.containsKey('hoursOfDay')) {
      hoursOfDay = unpackIntegerList(json['hoursOfDay']);
    }
    List<int>? monthsOfYear;
    if (json.containsKey('monthsOfYear')) {
      monthsOfYear = unpackIntegerList(json['monthsOfYear']);
    }
    bool monthsOfYearAsPackage = json['monthsOfYearAsPackage'] ?? false;
    List<int>? daysOfWeek;
    if (json.containsKey('daysOfWeek')) {
      hoursOfDay = unpackIntegerList(json['daysOfWeek']);
    }
    var holiday = json['holiday'];

    return TimeFilter(
        bucket: bucket,
        hoursOfDay: hoursOfDay,
        monthsOfYear: monthsOfYear,
        monthsOfYearAsPackage: monthsOfYearAsPackage,
        daysOfWeek: daysOfWeek,
        holiday: holiday);
  }

  TimeFilter copyWith({
    Bucket? bucket,
    List<int>? hoursOfDay,
    List<int>? monthsOfYear,
    bool monthsOfYearAsPackage = false,
    List<int>? daysOfWeek,
    String? holiday,
  }) {
    return TimeFilter(
      bucket: bucket ?? this.bucket,
      hoursOfDay: hoursOfDay ?? this.hoursOfDay,
      monthsOfYear: monthsOfYear ?? this.monthsOfYear,
      monthsOfYearAsPackage: monthsOfYearAsPackage,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
      holiday: holiday ?? this.holiday,
    );
  }

  @override
  String toString() {
    var out = <String>[];
    if (bucket != null) {
      out.add('Bucket: $bucket');
    }
    if (hoursOfDay != null) {
      out.add('Hours of day: $hoursOfDay');
    }
    if (monthsOfYear != null) {
      out.add('Months of year: $monthsOfYear');
    }
    if (monthsOfYearAsPackage) {
      out.add('Months of year as package: $monthsOfYearAsPackage');
    }
    if (daysOfWeek != null) {
      out.add('Days of week: $daysOfWeek');
    }
    if (holiday != null) {
      out.add('Holiday: $holiday');
    }
    return out.join(', ');
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (bucket != null) 'bucket': bucket.toString(),
      if (hoursOfDay != null) 'hoursOfDay': packIntegerList(hoursOfDay!),
      if (monthsOfYear != null) 'monthsOfYear': monthsOfYear!.join(','),
      'monthsOfYearAsPackage': monthsOfYearAsPackage,
      if (daysOfWeek != null) 'daysOfWeek': packIntegerList(daysOfWeek!),
      if (holiday != null) 'holiday': holiday,
    };
  }
}

class TimeFilterNotifier extends StateNotifier<TimeFilter> {
  TimeFilterNotifier(this.ref) : super(TimeFilter());
  final Ref ref;

  set bucket(String value) {
    state = state.copyWith(bucket: value == '' ? null : Bucket.parse(value));
  }

  set hoursOfDay(String value) {
    var aux = unpackIntegerList(value);
    if (aux.isNotEmpty) {
      if (!aux.isSorted((a, b) => a.compareTo(b))) {
        throw StateError('Hours in list should be sorted');
      }
      if (aux.first < 0 || aux.last > 23) {
        throw StateError('Invalid hours (not between 0 and 23)');
      }
    }
    state = state.copyWith(hoursOfDay: aux);
  }

  set monthsOfYear(String value) {
    var aux = unpackIntegerList(value, minValue: 1, maxValue: 12);
    if (aux.isNotEmpty) {
      if (aux.min < 1 || aux.max > 12) {
        throw StateError('Invalid months (not between 1 and 12)');
      }
    }
    state = state.copyWith(monthsOfYear: aux);
  }

  set monthsOfYearAsPackage(bool value) {
    state = state.copyWith(monthsOfYearAsPackage: value);
  }

  set daysOfWeek(String value) {
    var aux = unpackIntegerList(value);
    if (aux.isNotEmpty) {
      if (!aux.isSorted((a, b) => a.compareTo(b))) {
        throw StateError('Hours in list should be sorted');
      }
      if (aux.first < 1 || aux.last > 7) {
        throw StateError('Invalid weekday (not between 1 and 7)');
      }
    }
    state = state.copyWith(daysOfWeek: aux);
  }
}

class TimeFilterUi extends ConsumerStatefulWidget {
  const TimeFilterUi({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TimeFilterUiState();
}

class _TimeFilterUiState extends ConsumerState<TimeFilterUi> {
  final _background = Colors.orange[100]!;
  final maxOptionsHeight = 350.0;

  final focusNode = FocusNode();
  final focusNodeDow = FocusNode();
  final focusNodeMoy = FocusNode();
  final focusNodeHoliday = FocusNode();
  final controller = TextEditingController();
  final controllerDow = TextEditingController();
  final controllerMoy = TextEditingController();
  final controllerHoliday = TextEditingController();
  String? _error;
  String? _errorDow;
  String? _errorMoy;
  late List<bool> hasValue = [
    false, // Bucket
    false, // Hours of day
    false, // Months of year
    false, // Days of week
    false, // Holiday
  ];

  @override
  void initState() {
    MaybeBucketNotifier.allowedValues = Bucket.buckets.keys.toList();
    // final mabyeBucket = ref.read(providerOfMaybeBucket);

    final timeFilter = ref.read(providerOfTimeFilter);
    controller.text = packIntegerList(timeFilter.hoursOfDay ?? <int>[]);
    controllerDow.text = packIntegerList(timeFilter.daysOfWeek ?? <int>[]);
    controllerMoy.text = packIntegerList(timeFilter.monthsOfYear ?? <int>[]);
    controllerHoliday.text = '';
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        /// validate when you lose focus (Tab out of the field)
        setState(() {
          if (controller.text == '') {
            hasValue[1] = false;
          } else {
            hasValue[1] = true;
          }
          validateHoursOfDay();
        });
      }
    });
    focusNodeMoy.addListener(() {
      if (!focusNodeMoy.hasFocus) {
        /// validate when you lose focus (Tab out of the field)
        setState(() {
          if (controllerMoy.text == '') {
            hasValue[2] = false;
          } else {
            hasValue[2] = true;
          }
          validateMonthsOfYear();
        });
      }
    });
    focusNodeDow.addListener(() {
      if (!focusNodeDow.hasFocus) {
        /// validate when you lose focus (Tab out of the field)
        setState(() {
          if (controllerDow.text == '') {
            hasValue[3] = false;
          } else {
            hasValue[3] = true;
          }
          validateDaysOfWeek();
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    controllerDow.dispose();
    controllerMoy.dispose();
    focusNode.dispose();
    focusNodeDow.dispose();
    focusNodeMoy.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(providerOfTimeFilter);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8.0, top: 8.0),
          child: Row(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: SizedBox(
                    width: 70,
                    child: Text(
                      'Bucket',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
                Container(
                    color: _background,
                    width: 100,
                    child: const Tooltip(
                        message: 'Filter for hours in this bucket.',
                        child: MaybeBucketUi())),
              ]),
        ),
        // Hour of day
        //
        Padding(
          padding: const EdgeInsets.only(right: 8.0, top: 8.0),
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SizedBox(
                width: 120,
                child: Text(
                  'Hours of day',
                  style: TextStyle(
                      fontSize: 16,
                      color: hasValue[1] ? Colors.black : Colors.grey),
                ),
              ),
            ),
            Container(
                color: _background,
                width: 100,
                child: Tooltip(
                  message: 'Filter for hours of day\n'
                      'in hour beginning convention\n'
                      'e.g. 6-10, 12, 14-18.',
                  child: TextField(
                    focusNode: focusNode,
                    controller: controller,
                    onEditingComplete: () {
                      setState(() {
                        if (controller.text == '') {
                          hasValue[1] = false;
                        } else {
                          hasValue[1] = true;
                        }
                        validateHoursOfDay();
                      });
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      errorText: _error,
                      enabledBorder: InputBorder.none,
                      // hintText: 'e.g. 6-10, 12, 14-18',
                    ),
                  ),
                )),
          ]),
        ),
        // Months of year
        //
        Padding(
          padding: const EdgeInsets.only(right: 8.0, top: 8.0),
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SizedBox(
                width: 120,
                child: Text(
                  'Months of year',
                  style: TextStyle(
                      fontSize: 16,
                      color: hasValue[2] ? Colors.black : Colors.grey),
                ),
              ),
            ),
            Container(
                color: _background,
                width: 100,
                child: Tooltip(
                  message: 'Filter for months of year\n'
                      'in range e.g. 11-3, 5, 7-8.',
                  child: TextField(
                    focusNode: focusNodeMoy,
                    controller: controllerMoy,
                    onEditingComplete: () {
                      setState(() {
                        if (controllerMoy.text == '') {
                          hasValue[2] = false;
                        } else {
                          hasValue[2] = true;
                        }
                        validateMonthsOfYear();
                      });
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(12),
                      errorText: _errorMoy,
                      enabledBorder: InputBorder.none,
                      // hintText: 'e.g. 6-10, 12, 14-18',
                    ),
                  ),
                )),
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Tooltip(
                message: 'Treat all months as a package',
                child: Checkbox(
                    value: model.monthsOfYearAsPackage,
                    onChanged: (value) {
                      setState(() {
                        ref
                            .read(providerOfTimeFilter.notifier)
                            .monthsOfYearAsPackage = value!;
                      });
                    }),
              ),
            ),
          ]),
        ),
        // Day of week
        //
        Padding(
          padding: const EdgeInsets.only(right: 8.0, top: 8.0),
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: SizedBox(
                width: 120,
                child: Text(
                  'Days of week',
                  style: TextStyle(
                      fontSize: 16,
                      color: hasValue[3] ? Colors.black : Colors.grey),
                ),
              ),
            ),
            Container(
              color: _background,
              width: 100,
              child: Tooltip(
                message:
                    'Filter for day of week\nMon=1, ... Sun=7, e.g. 1-3, 6.',
                child: TextField(
                  focusNode: focusNodeDow,
                  controller: controllerDow,
                  onEditingComplete: () {
                    setState(() {
                      if (controller.text == '') {
                        hasValue[3] = false;
                      } else {
                        hasValue[3] = true;
                      }
                      validateDaysOfWeek();
                    });
                  },
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.all(12),
                    errorText: _errorDow,
                    enabledBorder: InputBorder.none,
                  ),
                ),
              ),
            ),
          ]),
        ),
      ],
    );
  }

  void validateHoursOfDay() {
    try {
      ref.read(providerOfTimeFilter.notifier).hoursOfDay = controller.text;
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
  }

  void validateMonthsOfYear() {
    try {
      ref.read(providerOfTimeFilter.notifier).monthsOfYear = controllerMoy.text;
      _errorMoy = null;
    } catch (e) {
      _errorMoy = e.toString();
    }
  }

  void validateDaysOfWeek() {
    try {
      ref.read(providerOfTimeFilter.notifier).daysOfWeek = controllerDow.text;
      _errorDow = null;
    } catch (e) {
      _errorDow = e.toString();
    }
  }
}
