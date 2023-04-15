library screens.polygraph.editors.transformed_variable_editor;

import 'dart:ui';

import 'package:flutter/material.dart' hide Interval, Transform;
import 'package:flutter/scheduler.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/polygraph/variables/transformed_variable.dart';
import 'package:flutter_quiver/models/polygraph/transforms/transform.dart';
import 'package:flutter_quiver/screens/polygraph/editors/editor_time_aggregation.dart';
import 'package:flutter_quiver/screens/polygraph/editors/editor_time_filter.dart';
import 'package:flutter_quiver/screens/polygraph/polygraph_window_ui.dart';
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

  String _errorMessage = '';
  bool pressedOk = false;
  int activeTab = 0;

  @override
  void initState() {
    super.initState();
    controllerExpression.text = '';
    controllerLabel.text = '';

    focusLabel.addListener(() {
      if (!focusLabel.hasFocus) {
        setState(() {
          ref.read(providerOfTransformedVariable.notifier).label =
              controllerLabel.text;
          if (controllerLabel.text == '') {
            _errorMessage =
                'Label can\'t be empty.  Please provide a variable name';
          }
        });
      }
    });
    focusExpression.addListener(() {
      if (!focusExpression.hasFocus) {
        var state = ref.read(providerOfTransformedVariable);
        var window = ref.read(providerOfPolygraphWindow);
        setState(() {
          ref.read(providerOfTransformedVariable.notifier).expression =
              controllerExpression.text;
          state.eval(window.cache);
          _errorMessage = state.error;
        });
      }
    });
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
    _errorMessage = state.error;
    // print('_errorMessage: $_errorMessage');

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
                    ///
                    /// Label row
                    ///
                    Row(
                      children: [
                        Container(
                          width: 100,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 8),
                          child: const Text(
                            'Label',
                          ),
                        ),
                        Container(
                          color: MyApp.background,
                          width: 180,
                          child: TextField(
                            style: const TextStyle(fontSize: 14),
                            controller: controllerLabel,
                            focusNode: focusLabel,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(8),
                              enabledBorder: (pressedOk &&
                                      controllerLabel.text == '')
                                  ? const OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red))
                                  : InputBorder.none,
                            ),
                            onEditingComplete: () {
                              setState(() {
                                ref
                                    .read(
                                        providerOfTransformedVariable.notifier)
                                    .label = controllerLabel.text;
                                // pressedOk = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),

                    ///
                    /// Expression row
                    ///
                    Row(
                      children: [
                        Container(
                          width: 100,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 8),
                          child: const Text(
                            'Expression',
                          ),
                        ),
                        Container(
                          color: MyApp.background,
                          width: 400,
                          // height: 32,
                          child: TextField(
                            controller: controllerExpression,
                            focusNode: focusExpression,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(8),
                              enabledBorder: state.error != ''
                                  ? const OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red))
                                  : InputBorder.none,
                            ),
                            onEditingComplete: () {
                              var window = ref.read(providerOfPolygraphWindow);
                              setState(() {
                                ref
                                    .read(
                                        providerOfTransformedVariable.notifier)
                                    .expression = controllerExpression.text;
                                state.eval(window.cache);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),

                    ///
                    /// Error row
                    ///
                    Row(
                      children: [
                        Container(
                          width: 80,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 8),
                          child: const Text(''),
                        ),
                        Text(
                          _errorMessage != '' ? 'Error: $_errorMessage' : '',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
        // ElevatedButton(
        //   onPressed: () {
        //     var window = ref.read(providerOfPolygraphWindow);
        //     setState(() {
        //       pressedOk = true;
        //       if (controllerLabel.text == '') {
        //         state.error =
        //             'Label can\'t be empty.  Please provide a variable name';
        //         return;
        //       }
        //       state.eval(window.cache);
        //       var yVariables = [...window.yVariables, state];
        //       ref.read(providerOfPolygraphWindow.notifier).yVariables = yVariables;
        //       // Navigator.of(context).pop(result);
        //     });
        //   },
        //   child: const Text('OK'),
        // ),
      ],
    );
  }
}
