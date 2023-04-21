library screens.polygraph.editors.editor_time_aggregation;

import 'package:flutter/material.dart' hide Interval, Transform;
import 'package:flutter/scheduler.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
import 'package:flutter_quiver/models/polygraph/transforms/transform.dart';
import 'package:flutter_quiver/screens/polygraph/utils/autocomplete_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final providerOfTimeAggregation =
StateNotifierProvider<TimeAggregationNotifier, TimeAggregation>(
        (ref) => TimeAggregationNotifier(ref));

class TimeAggregationEditor extends ConsumerStatefulWidget {
  const TimeAggregationEditor({Key? key}) : super(key: key);

  @override
  ConsumerState<TimeAggregationEditor> createState() => _TimeAggregationEditorState();
}

class _TimeAggregationEditorState extends ConsumerState<TimeAggregationEditor> {
  final controllerFrequency = TextEditingController();
  final controllerFunction = TextEditingController();

  final focusFrequency = FocusNode();
  final focusFunction = FocusNode();

  // bool needsFrequency = false;
  // bool needsFunction = false;
  // String? _errorFrequency, _errorFunction;

  @override
  void initState() {
    super.initState();
    controllerFrequency.text = '';
    controllerFunction.text = '';


    // focusFrequency.addListener(() {
    //   if (!focusFrequency.hasFocus) {
    //     var state = ref.read(providerOfTimeAggregation);
    //     setState(() {
    //       if (state.error != '') {
    //         // don't get yourself into a weird state
    //         ref.read(providerOfTimeAggregation.notifier).frequency = '';
    //         ref.read(providerOfTimeAggregation.notifier).function = '';
    //       } else {
    //         ref.read(providerOfTimeAggregation.notifier).frequency = controllerFrequency.text;
    //         ref.read(providerOfTimeAggregation.notifier).function = controllerFunction.text;
    //       }
    //     });
    //   }
    // });
    // focusFunction.addListener(() {
    //   if (!focusFunction.hasFocus) {
    //     var state = ref.read(providerOfTimeAggregation);
    //     setState(() {
    //       if (state.error != '') {
    //         // don't get yourself in a weird state
    //         ref.read(providerOfTimeAggregation.notifier).frequency = '';
    //         ref.read(providerOfTimeAggregation.notifier).function = '';
    //       } else {
    //         ref.read(providerOfTimeAggregation.notifier).frequency = controllerFrequency.text;
    //         ref.read(providerOfTimeAggregation.notifier).function = controllerFunction.text;
    //       }
    //     });
    //   }
    // });

  }

  @override
  void dispose() {
    controllerFrequency.dispose();
    controllerFunction.dispose();

    focusFrequency.dispose();
    focusFunction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(providerOfTimeAggregation);
    state.validate();
    controllerFrequency.text = state.frequency;
    controllerFunction.text = state.function;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ///
        /// Frequency
        ///
        Row(
          children: [
            Container(
              width: 120,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 8),
              child: const Text(
                'Frequency',
              ),
            ),
            Container(
              color: MyApp.background,
              width: 120,
              child: RawAutocomplete(
                  focusNode: focusFrequency,
                  textEditingController: controllerFrequency,
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) =>
                      TextField(
                        focusNode: focusNode,
                        controller: textEditingController,
                        onEditingComplete: onFieldSubmitted,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.all(10),
                          enabledBorder: state.error != '' && controllerFrequency.text == '' ?
                          const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red))
                              : InputBorder.none,
                          fillColor: MyApp.background,
                          filled: true,
                        ),
                      ),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue == TextEditingValue.empty) {
                      return const Iterable<String>.empty();
                    }
                    var aux = TimeAggregation.allFrequencies.where((e) => e
                        .toUpperCase()
                        .contains(textEditingValue.text.toUpperCase())).toList();
                    return aux;
                  },
                  onSelected: (String selection) {
                    setState(() {
                      ref.read(providerOfTimeAggregation.notifier).frequency = selection;
                      // state.validate();
                      // print('in editor_time_aggregation onSelected(), state.error=${state.error}');
                      // ref.read(providerOfTimeAggregation.notifier).error = state.error;
                    //   if (selection != '') {
                    //     needsFunction = state.function == '';
                    //   } else {
                    //     ref.read(providerOfTimeAggregation.notifier).function = '';
                    //     needsFunction = false;
                    //   }
                    //   needsFrequency = false;
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
            const SizedBox(
              width: 8,
            ),
            if (controllerFrequency.text == '') Text(
              state.error,
              style: const TextStyle(color: Colors.red, fontSize: 10),
            ),
          ],
        ),
        const SizedBox(
          height: 4,
        ),
        ///
        /// Function
        ///
        Row(
          children: [
            Container(
              width: 120,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 8),
              child: const Text(
                'Function',
              ),
            ),
            Container(
              color: MyApp.background,
              // color: needsFunction ? Colors.pink[100] : MyApp.background,
              width: 120,
              child: RawAutocomplete(
                  focusNode: focusFunction,
                  textEditingController: controllerFunction,
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) =>
                      TextField(
                        focusNode: focusNode,
                        controller: textEditingController,
                        onEditingComplete: onFieldSubmitted,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.all(10),
                          enabledBorder: state.error != '' && controllerFunction.text == '' ?
                          const OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.red))
                              : InputBorder.none,
                          fillColor: MyApp.background,
                          filled: true,
                        ),
                      ),
                  optionsBuilder: (TextEditingValue textEditingValue) {
                    if (textEditingValue == TextEditingValue.empty) {
                      return const Iterable<String>.empty();
                    }
                    var aux = ['', ...Transform.aggregations.keys].where((e) => e
                        .contains(textEditingValue.text.toLowerCase())).toList();
                    return aux;
                  },
                  onSelected: (String selection) {
                    setState(() {
                      ref.read(providerOfTimeAggregation.notifier).function = selection;
                      // state.validate();
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
            const SizedBox(
                width: 8,
              ),
            if (controllerFunction.text == '') Text(
              state.error,
              style: const TextStyle(color: Colors.red, fontSize: 10),
            ),
          ],
        ),
        // const SizedBox(
        //   height: 4,
        // ),
        // Text(
        //   state.error,
        //   style: const TextStyle(color: Colors.red),
        // ),
      ],
    );
  }

  // void validateFrequency(TimeAggregation state) {
  //   _errorYears = null;
  //   try {
  //     var years = unpackIntegerList(controllerYears.text);
  //     ref.read(providerOfTimeFilter.notifier).years = years.toSet();
  //   } catch (_) {
  //     _errorYears = 'Incorrect list of years';
  //     ref.read(providerOfTimeFilter.notifier).years = <int>{};
  //   }
  // }

}


