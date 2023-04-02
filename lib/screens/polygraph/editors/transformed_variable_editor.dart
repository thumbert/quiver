library screens.polygraph.editors.transformed_variable_editor;

import 'package:flutter/material.dart' hide Interval, Transform;
import 'package:flutter/scheduler.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/polygraph/variables/transformed_variable.dart';
import 'package:flutter_quiver/models/polygraph/transforms/transform.dart';
import 'package:flutter_quiver/screens/polygraph/editors/editor_time_aggregation.dart';
import 'package:flutter_quiver/screens/polygraph/editors/editor_time_filter.dart';
import 'package:flutter_quiver/screens/polygraph/utils/autocomplete_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final providerOfTransformedVariable =
    StateNotifierProvider<TransformedVariableNotifier, TransformedVariable>(
        (ref) => TransformedVariableNotifier(ref));

class TransformedVariableEditor extends ConsumerStatefulWidget {
  const TransformedVariableEditor({Key? key}) : super(key: key);

  @override
  ConsumerState<TransformedVariableEditor> createState() =>
      _TransformedVariableEditorState();
}

class _TransformedVariableEditorState
    extends ConsumerState<TransformedVariableEditor> {
  final controllerLabel = TextEditingController();
  final controllerExpression = TextEditingController();

  final focusLabel = FocusNode();
  final focusExpression = FocusNode();

  String? _errorExpression;
  int activeTab = 0;

  @override
  void initState() {
    super.initState();
    controllerExpression.text = '';
    controllerLabel.text = '';

    // focusExpression.addListener(() {
    //   if (!focusExpression.hasFocus) {
    //     setState(() {
    //       try {
    //         var value = num.parse(controllerExpression.text);
    //         ref.read(providerOfTransformedVariable.notifier).yIntercept = value;
    //         ref.read(providerOfHorizontalLine.notifier).label = 'h=$value';
    //       } catch (_) {
    //         _errorYValue = 'Field needs to be a number';
    //         ref.read(providerOfHorizontalLine.notifier).yIntercept = 0.0;
    //       }
    //     });
    //   }
    // });
    // focusLabel.addListener(() {
    //   if (!focusLabel.hasFocus) {
    //     setState(() {
    //       ref.read(providerOfHorizontalLine.notifier).label = controllerLabel.text;
    //     });
    //   }
    // });
  }

  @override
  void dispose() {
    controllerExpression.dispose();
    controllerLabel.dispose();

    focusExpression.dispose();
    focusLabel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(providerOfTransformedVariable);
    controllerExpression.text = state.expression;
    controllerLabel.text = state.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///
            /// Tabs
            ///
            Wrap(
              children: [
                TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () {
                      setState(() {
                        activeTab = 0;
                      });
                    },
                    child: Container(
                        width: 140,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 2,
                                color: activeTab == 0
                                    ? Colors.blueGrey[700]!
                                    : Colors.grey[300]!),
                          ),
                        ),
                        child: const Center(child: Text('Main')))),

                ///
                ///
                TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () {
                      setState(() {
                        activeTab = 1;
                      });
                    },
                    child: Container(
                        width: 140,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 2,
                                color: activeTab == 1
                                    ? Colors.blueGrey[700]!
                                    : Colors.grey[300]!),
                          ),
                        ),
                        child: const Center(child: Text('Display')))),

              ],
            ),
            const SizedBox(
              height: 16,
            ),
            if (activeTab == 0)
              SizedBox(
                height: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 80,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 8),
                          child: const Text(
                            'Label',
                          ),
                        ),
                        Container(
                          color: MyApp.background,
                          width: 120,
                          child: TextField(
                            style: const TextStyle(fontSize: 14),
                            controller: controllerLabel,
                            focusNode: focusLabel,
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.all(8),
                              enabledBorder: InputBorder.none,
                            ),
                            onEditingComplete: () {
                              setState(() {
                                ref
                                    .read(
                                        providerOfTransformedVariable.notifier)
                                    .label = controllerLabel.text;
                              });
                            },
                          ),
                        ),
                        Text(
                          _errorExpression ?? '',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    Row(
                      children: [
                        Container(
                          width: 80,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 8),
                          child: const Text(
                            'Expression',
                          ),
                        ),
                        Container(
                          color: MyApp.background,
                          width: 300,
                          // height: 32,
                          child: TextField(
                            controller: controllerExpression,
                            focusNode: focusExpression,
                            style: const TextStyle(fontSize: 14),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.all(8),
                              enabledBorder: InputBorder.none,
                            ),
                            onEditingComplete: () {
                              setState(() {
                                try {
                                  ref
                                      .read(providerOfTransformedVariable
                                          .notifier)
                                      .expression = controllerExpression.text;
                                } catch (_) {
                                  _errorExpression = 'Wrong expression';
                                }
                              });
                            },
                          ),
                        ),
                        Text(
                          _errorExpression ?? '',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              /// blah
            });
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
