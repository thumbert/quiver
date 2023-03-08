library screens.polygraph.editors.editor_line_horizontal;

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

class EditorLineHorizontal extends ConsumerStatefulWidget {
  const EditorLineHorizontal({Key? key}) : super(key: key);

  @override
  ConsumerState<EditorLineHorizontal> createState() => _EditorLineHorizontalState();
}
/// TODO:
class _EditorLineHorizontalState extends ConsumerState<EditorLineHorizontal> {
  final controllerFrequency = TextEditingController();
  final controllerFunction = TextEditingController();

  final focusFrequency = FocusNode();
  final focusFunction = FocusNode();

  bool needsFrequency = false;
  bool needsFunction = false;
  String? _errorFrequency, _errorFunction;

  @override
  void initState() {
    super.initState();
    controllerFrequency.text = '';
    controllerFunction.text = '';

    // focusFrequency.addListener(() {
    //   if (!focusFrequency.hasFocus) {
    //     setState(() {
    //       if (needsFrequency || needsFunction) {
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
    // focusFunction.addListener(() {
    //   if (!focusFunction.hasFocus) {
    //     setState(() {
    //       if (needsFrequency || needsFunction) {
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
              color: needsFrequency ? Colors.pink[100] : MyApp.background,
              width: 120,
              child: RawAutocomplete(
                  focusNode: focusFrequency,
                  textEditingController: controllerFrequency,
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) =>
                      AutocompleteField(
                        focusNode: focusNode,
                        textEditingController: textEditingController,
                        onFieldSubmitted: onFieldSubmitted,
                        options: TimeAggregation.allFrequencies,
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
                      if (selection != '') {
                        needsFunction = state.function == '';
                      } else {
                        ref.read(providerOfTimeAggregation.notifier).function = '';
                        needsFunction = false;
                      }
                      needsFrequency = false;
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
              _errorFrequency ?? '',
              style: const TextStyle(color: Colors.red),
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
              color: needsFunction ? Colors.pink[100] : MyApp.background,
              width: 120,
              child: RawAutocomplete(
                  focusNode: focusFunction,
                  textEditingController: controllerFunction,
                  fieldViewBuilder: (BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted) =>
                      AutocompleteField(
                        focusNode: focusNode,
                        textEditingController: textEditingController,
                        onFieldSubmitted: onFieldSubmitted,
                        options: ['', ...Transform.aggregations.keys],
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
                      if (selection != '') {
                        needsFrequency = state.frequency == '';
                      } else {
                        ref.read(providerOfTimeAggregation.notifier).frequency = '';
                        needsFrequency = false;
                      }
                      needsFunction = false;
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
              _errorFunction ?? '',
              style: const TextStyle(color: Colors.red),
            ),
          ],
        ),

      ],
    );
  }
  
}


