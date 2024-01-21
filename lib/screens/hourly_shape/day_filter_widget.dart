library screens.hourly_shape.time_filter_widget;

import 'package:date/date.dart';
import 'package:elec/time.dart';
import 'package:elec_server/utils.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/hourly_shape/day_filter.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:timezone/timezone.dart';

class DayFilterWidget extends StatefulWidget {
  const DayFilterWidget(this.model, {super.key});

  final Signal<DayFilter> model;

  @override
  State<DayFilterWidget> createState() => _DayFilterEditorState();
}

class _DayFilterEditorState extends State<DayFilterWidget> {
  final controllerYears = TextEditingController();
  final controllerMonths = TextEditingController();
  final controllerDays = TextEditingController();
  final controllerDaysOfWeek = TextEditingController();
  final controllerSpecialDays = TextEditingController();

  final focusYears = FocusNode();
  final focusMonths = FocusNode();
  final focusDays = FocusNode();
  final focusDaysOfWeek = FocusNode();
  final focusSpecialDays = FocusNode();

  String? _errorYears,
      _errorMonths,
      _errorDays,
      _errorDaysOfWeeek,
      _errorSpecialDays;

  @override
  void initState() {
    super.initState();
    _setControllers();

    focusYears.addListener(() {
      if (!focusYears.hasFocus) {
        validateYears();
      }
    });
    focusMonths.addListener(() {
      if (!focusMonths.hasFocus) {
        validateMonths();
      }
    });
    focusDays.addListener(() {
      if (!focusDays.hasFocus) {
        validateDays();
      }
    });
    focusDaysOfWeek.addListener(() {
      if (!focusDaysOfWeek.hasFocus) {
        validateDaysOfWeek();
      }
    });
    focusSpecialDays.addListener(() {
      if (!focusSpecialDays.hasFocus) {
        validateSpecialDays();
      }
    });
  }

  @override
  void dispose() {
    controllerYears.dispose();
    controllerMonths.dispose();
    controllerDays.dispose();
    controllerDaysOfWeek.dispose();
    controllerSpecialDays.dispose();
    focusYears.dispose();
    focusMonths.dispose();
    focusDays.dispose();
    focusDaysOfWeek.dispose();
    focusSpecialDays.dispose();

    super.dispose();
  }

  void _setControllers() {
    controllerYears.text = widget.model.value.years.isEmpty
        ? ''
        : packIntegerList(widget.model.value.years.toList());
    controllerMonths.text = widget.model.value.months.isEmpty
        ? ''
        : packIntegerList(widget.model.value.months.toList(),
            minValue: 1, maxValue: 12);
    controllerDays.text = widget.model.value.days.isEmpty
        ? ''
        : packIntegerList(widget.model.value.days.toList(),
            minValue: 1, maxValue: 31);
    controllerDaysOfWeek.text = widget.model.value.daysOfWeek.isEmpty
        ? ''
        : packIntegerList(widget.model.value.daysOfWeek.toList(),
            minValue: 1, maxValue: 7);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ///
        /// Years
        ///
        Row(
          children: [
            Container(
              width: 140,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 8),
              child: const Tooltip(
                message: 'A year or a year range, e.g. 2018,2020-2023',
                child: Text(
                  'Years',
                ),
              ),
            ),
            Container(
              color: MyApp.background,
              width: 120,
              child: TextField(
                controller: controllerYears,
                focusNode: focusYears,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: InputBorder.none,
                ),
                onEditingComplete: () => validateYears(),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 4,
        ),

        ///
        /// Months
        ///
        Row(
          children: [
            Container(
              width: 140,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 8),
              child: const Tooltip(
                message: 'A number from 1 to 12, or a range e.g. 1-3,12',
                child: Text(
                  'Months',
                ),
              ),
            ),
            Container(
              color: MyApp.background,
              width: 120,
              child: TextField(
                controller: controllerMonths,
                focusNode: focusMonths,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: InputBorder.none,
                ),
                onEditingComplete: () => validateMonths(),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 4,
        ),

        ///
        /// Days of month
        ///
        Row(
          children: [
            Container(
              width: 140,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 8),
              child: const Tooltip(
                message: 'A number from 1 to 31, or a range e.g. 5-10,15,20-23',
                child: Text(
                  'Days of month',
                ),
              ),
            ),
            Container(
              color: MyApp.background,
              width: 120,
              child: TextField(
                controller: controllerDays,
                focusNode: focusDays,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: InputBorder.none,
                ),
                onEditingComplete: () => validateDays(),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 4,
        ),

        ///
        /// Days of week
        ///
        Row(
          children: [
            Container(
              width: 140,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 8),
              child: const Tooltip(
                message:
                    'A number from 1 (Mon) to 7 (Sun), or a range e.g. 3,6-7.',
                child: Text(
                  'Days of week',
                ),
              ),
            ),
            Container(
              color: MyApp.background,
              width: 120,
              child: TextField(
                controller: controllerDaysOfWeek,
                focusNode: focusDaysOfWeek,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: InputBorder.none,
                ),
                onEditingComplete: () => validateDaysOfWeek(),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 4,
        ),

        ///
        /// Special days
        ///
        Row(
          children: [
            Container(
              width: 140,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 8),
              child: const Tooltip(
                message: 'Enter one date per row',
                child: Text(
                  'Special days',
                ),
              ),
            ),
            Container(
              color: MyApp.background,
              width: 120,
              child: TextField(
                maxLines: null, // can accept multiple rows
                controller: controllerSpecialDays,
                focusNode: focusSpecialDays,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: InputBorder.none,
                ),
                onEditingComplete: () => validateSpecialDays(),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),

        ///
        /// Federal holidays
        ///
        Row(
          children: [
            const SizedBox(
              width: 15,
            ),
            SizedBox(
              width: 150,
              child: Watch((context) {
                return ListTileTheme(
                  // tileColor: Colors.pink,
                  horizontalTitleGap: 0.0,
                  child: Tooltip(
                    message: 'Include Federal holidays?',
                    child: CheckboxListTile(
                      visualDensity:
                          const VisualDensity(vertical: -4, horizontal: -4),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Transform.translate(
                        offset: const Offset(6, 0),
                        child: const Text(
                          'Federal holidays',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                      value: widget.model.value.holidays.isNotEmpty,
                      onChanged: (bool? value) {
                        var holidays = value!
                            ? Calendar.federalHolidays.holidays
                            : <Holiday>{};
                        widget.model.value =
                            widget.model.value.copyWith(holidays: holidays);
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),

        ///
        /// Error message
        ///
        if (_errorYears != null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              _errorYears!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        if (_errorMonths != null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              _errorMonths!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        if (_errorDays != null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Text(
              _errorDays!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        if (_errorDaysOfWeeek != null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Text(
              _errorDaysOfWeeek!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        if (_errorSpecialDays != null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Text(
              _errorSpecialDays!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }

  void validateYears() {
    setState(() {
      _errorYears = null;
      try {
        var years = unpackIntegerList(controllerYears.text);
        widget.model.value = widget.model.value.copyWith(years: years.toSet());
      } catch (_) {
        _errorYears = 'Incorrect list of years';
      }
    });
  }

  void validateMonths() {
    setState(() {
      _errorMonths = null;
      try {
        var months =
            unpackIntegerList(controllerMonths.text, minValue: 1, maxValue: 12);
        if (months.any((e) => e < 1 || e > 12)) {
          throw 'Wrong month value';
        }
        widget.model.value =
            widget.model.value.copyWith(months: months.toSet());
      } catch (_) {
        _errorMonths = 'Month values must be between 1 and 12';
      }
    });
  }

  void validateDays() {
    setState(() {
      _errorDays = null;
      try {
        var days = unpackIntegerList(controllerDays.text);
        if (days.any((e) => e < 1 || e > 31)) {
          throw 'Wrong value';
        }
        widget.model.value = widget.model.value.copyWith(days: days.toSet());
      } catch (_) {
        _errorDays = 'Day of month must be between 1 and 31';
      }
    });
  }

  void validateDaysOfWeek() {
    setState(() {
      _errorDaysOfWeeek = null;
      try {
        var dow = unpackIntegerList(controllerDaysOfWeek.text);
        if (dow.any((e) => e < 1 || e > 7)) {
          throw 'Wrong value';
        }
        widget.model.value =
            widget.model.value.copyWith(daysOfWeek: dow.toSet());
      } catch (_) {
        _errorDaysOfWeeek = 'Day of week must be between 1 (Mon) and 7 (Sun)';
      }
    });
  }

  void validateSpecialDays() {
    setState(() {
      _errorSpecialDays = null;
      try {
        var days = controllerSpecialDays.text
            .split('\n')
            .where((e) => !e.startsWith('//'))
            .map((e) => Date.parse(e, location: UTC))
            .toSet();
        widget.model.value =
            widget.model.value.copyWith(specialDays: days.toSet());
      } catch (_) {
        _errorSpecialDays = 'Enter one date per row in format yyyy-mm-dd';
      }
    });
  }
}
