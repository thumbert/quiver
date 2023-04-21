library screens.polygraph.editors.editor_time_filter;

import 'package:elec/time.dart';
import 'package:elec_server/utils.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/scheduler.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_filter.dart';
import 'package:flutter_quiver/screens/polygraph/utils/autocomplete_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final providerOfTimeFilter =
    StateNotifierProvider<TimeFilterNotifier, TimeFilter>(
        (ref) => TimeFilterNotifier(ref));

class TimeFilterEditor extends ConsumerStatefulWidget {
  const TimeFilterEditor({Key? key}) : super(key: key);

  @override
  ConsumerState<TimeFilterEditor> createState() => _TimeFilterEditorState();
}

class _TimeFilterEditorState extends ConsumerState<TimeFilterEditor> {
  final controllerYears = TextEditingController();
  final controllerMonths = TextEditingController();
  final controllerDays = TextEditingController();
  final controllerHours = TextEditingController();
  final controllerDaysOfWeek = TextEditingController();
  final controllerBucket = TextEditingController();

  final focusYears = FocusNode();
  final focusMonths = FocusNode();
  final focusDays = FocusNode();
  final focusHours = FocusNode();
  final focusDaysOfWeek = FocusNode();
  final focusBucket = FocusNode();

  String? _errorYears, _errorMonths, _errorDays, _errorHours,
      _errorDaysOfWeeek, _errorBucket;

  @override
  void initState() {
    super.initState();
    var state = ref.read(providerOfTimeFilter);
    _setControllers(state);

    focusYears.addListener(() {
      if (!focusYears.hasFocus) {
        setState(() {
          validateYears(ref.read(providerOfTimeFilter));
        });
      }
    });
    focusMonths.addListener(() {
      if (!focusMonths.hasFocus) {
        setState(() {
          validateMonths(ref.read(providerOfTimeFilter));
        });
      }
    });
    focusDays.addListener(() {
      if (!focusDays.hasFocus) {
        setState(() {
          validateDays(ref.read(providerOfTimeFilter));
        });
      }
    });
    focusHours.addListener(() {
      if (!focusHours.hasFocus) {
        setState(() {
          validateHours(ref.read(providerOfTimeFilter));
        });
      }
    });
    focusDaysOfWeek.addListener(() {
      if (!focusDaysOfWeek.hasFocus) {
        setState(() {
          validateHours(ref.read(providerOfTimeFilter));
        });
      }
    });
  }

  @override
  void dispose() {
    controllerYears.dispose();
    controllerMonths.dispose();
    controllerDays.dispose();
    controllerHours.dispose();
    controllerDaysOfWeek.dispose();
    controllerBucket.dispose();
    focusYears.dispose();
    focusMonths.dispose();
    focusDays.dispose();
    focusHours.dispose();
    focusDaysOfWeek.dispose();
    focusBucket.dispose();

    super.dispose();
  }

  void _setControllers(TimeFilter state) {
    controllerYears.text =
        state.years.isEmpty ? '' : packIntegerList(state.years.toList());
    controllerMonths.text = state.months.isEmpty
        ? ''
        : packIntegerList(state.months.toList(), minValue: 1, maxValue: 12);
    controllerDays.text = state.days.isEmpty
        ? ''
        : packIntegerList(state.days.toList(), minValue: 1, maxValue: 31);
    controllerHours.text = state.hours.isEmpty
        ? ''
        : packIntegerList(state.hours.toList(), minValue: 0, maxValue: 23);
    controllerDaysOfWeek.text = state.daysOfWeek.isEmpty
        ? ''
        : packIntegerList(state.daysOfWeek.toList(), minValue: 1, maxValue: 7);
    controllerBucket.text = '';
  }

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(providerOfTimeFilter);

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
              child: const Text(
                'Years',
              ),
            ),
            Container(
              color: MyApp.background,
              width: 120,
              // height: 24,
              child: TextField(
                controller: controllerYears,
                focusNode: focusYears,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: InputBorder.none,
                ),
                onEditingComplete: () {
                  setState(() {
                    validateYears(state);
                  });
                },
              ),
            ),
            Text(
              _errorYears ?? '',
              style: const TextStyle(color: Colors.red),
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
                onEditingComplete: () {
                  setState(() {
                    validateMonths(state);
                  });
                },
              ),
            ),
            Text(
              _errorMonths ?? '',
              style: const TextStyle(color: Colors.red),
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
                onEditingComplete: () {
                  setState(() {
                    validateDays(state);
                  });
                },
              ),
            ),
            Text(
              _errorDays ?? '',
              style: const TextStyle(color: Colors.red),
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
                message: 'A number from 1 (Mon) to 7 (Sun), or a range e.g. 3,6-7.',
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
                onEditingComplete: () {
                  setState(() {
                    validateDaysOfWeek(state);
                  });
                },
              ),
            ),
            Text(
              _errorDaysOfWeeek ?? '',
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(
          height: 4,
        ),

        ///
        /// Hours
        ///
        Row(
          children: [
            Container(
              width: 140,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 8),
              child: const Tooltip(
                message: 'A number from 0 to 23, or a range e.g. 1-6,12',
                child: Text(
                  'Hours beginning',
                ),
              ),
            ),
            Container(
              color: MyApp.background,
              width: 120,
              child: TextField(
                controller: controllerHours,
                focusNode: focusHours,
                decoration: const InputDecoration(
                  isDense: true,
                  contentPadding: EdgeInsets.all(8),
                  enabledBorder: InputBorder.none,
                ),
                onEditingComplete: () {
                  setState(() {
                    validateHours(state);
                  });
                },
              ),
            ),
            Text(
              _errorHours ?? '',
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(
          height: 4,
        ),

        ///
        /// Bucket
        ///
        Row(
          children: [
            Container(
              width: 140,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 8),
              child: const Text(
                'Bucket',
              ),
            ),
            Container(
              color: MyApp.background,
              width: 120,
              child: RawAutocomplete(
                  focusNode: focusBucket,
                  textEditingController: controllerBucket,
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) =>
                      AutocompleteField(
                        focusNode: focusNode,
                        textEditingController: textEditingController,
                        onFieldSubmitted: onFieldSubmitted,
                        options: Bucket.buckets.keys,
                      ),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue == TextEditingValue.empty) {
                      return const Iterable<String>.empty();
                    }
                    var aux = Bucket.buckets.keys.where((e) => e
                        .toUpperCase()
                        .contains(textEditingValue.text.toUpperCase())).toList();
                    return aux;
                  },
                  onSelected: (String selection) {
                    setState(() {
                      _errorBucket = null;
                      try {
                        Bucket bucket;
                        if (selection == '') {
                          bucket = Bucket.atc;
                        } else {
                          bucket = Bucket.parse(selection);
                        }
                        ref.read(providerOfTimeFilter.notifier).bucket = bucket;
                      } catch (_) {
                        _errorBucket = 'Invalid bucket name $selection';
                      }
                    });
                  },
                  optionsViewBuilder: (BuildContext context,
                      void Function(String) onSelected,
                      Iterable<String> options) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        elevation: 4.0,
                        child: ConstrainedBox(
                          constraints:
                          const BoxConstraints(maxHeight: 300, maxWidth: 200),
                          child: ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: options.length,
                            itemBuilder:
                                (BuildContext context, int index) {
                              final option = options.elementAt(index);
                              return InkWell(
                                onTap: () {
                                  onSelected(option);
                                },
                                child: Builder(
                                    builder: (BuildContext context) {
                                      final bool highlight =
                                          AutocompleteHighlightedOption.of(
                                              context) ==
                                              index;
                                      if (highlight) {
                                        SchedulerBinding.instance
                                            .addPostFrameCallback(
                                                (Duration timeStamp) {
                                              Scrollable.ensureVisible(context,
                                                  alignment: 0.5);
                                            });
                                      }
                                      return Container(
                                        color: highlight
                                            ? Theme.of(context).focusColor
                                            : null,
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(option),
                                      );
                                    }),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  }),
            ),
            Text(
              _errorBucket ?? '',
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),
        const SizedBox(
          height: 4,
        ),

      ],
    );
  }

  void validateYears(TimeFilter state) {
    _errorYears = null;
    try {
      var years = unpackIntegerList(controllerYears.text);
      ref.read(providerOfTimeFilter.notifier).years = years.toSet();
    } catch (_) {
      _errorYears = 'Incorrect list of years';
      ref.read(providerOfTimeFilter.notifier).years = <int>{};
    }
  }

  void validateMonths(TimeFilter state) {
    _errorMonths = null;
    try {
      var months =
          unpackIntegerList(controllerMonths.text, minValue: 1, maxValue: 12);
      if (months.any((e) => e < 1 || e > 12)) {
        throw 'Wrong value';
      }
      ref.read(providerOfTimeFilter.notifier).months = months.toSet();
    } catch (_) {
      _errorMonths = 'Values must be between 1 and 12';
      ref.read(providerOfTimeFilter.notifier).months = <int>{};
    }
  }

  void validateDays(TimeFilter state) {
    _errorDays = null;
    try {
      var days = unpackIntegerList(controllerDays.text);
      if (days.any((e) => e < 1 || e > 31)) {
        throw 'Wrong value';
      }
      ref.read(providerOfTimeFilter.notifier).days = days.toSet();
    } catch (_) {
      _errorDays = 'Values must be between 1 and 31';
      ref.read(providerOfTimeFilter.notifier).days = <int>{};
    }
  }

  void validateHours(TimeFilter state) {
    _errorHours = null;
    try {
      var hours = unpackIntegerList(controllerHours.text);
      if (hours.any((e) => e < 0 || e > 23)) {
        throw 'Wrong value';
      }
      ref.read(providerOfTimeFilter.notifier).hours = hours.toSet();
    } catch (_) {
      _errorHours = 'Values must be between 0 and 23';
      ref.read(providerOfTimeFilter.notifier).hours = <int>{};
    }
  }

  void validateDaysOfWeek(TimeFilter state) {
    _errorDaysOfWeeek = null;
    try {
      var dow = unpackIntegerList(controllerDaysOfWeek.text);
      if (dow.any((e) => e < 1 || e > 7)) {
        throw 'Wrong value';
      }
      ref.read(providerOfTimeFilter.notifier).daysOfWeek = dow.toSet();
    } catch (_) {
      _errorDaysOfWeeek = 'Values must be between 1 (Mon) and 7 (Sun)';
      ref.read(providerOfTimeFilter.notifier).daysOfWeek = <int>{};
    }
  }
}


