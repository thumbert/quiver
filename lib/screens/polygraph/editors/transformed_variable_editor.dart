library screens.polygraph.editors.transformed_variable_editor;

import 'package:flutter/material.dart' hide Interval, Transform;
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/transformed_variable.dart';
import 'package:flutter_quiver/screens/polygraph/other/variable_selection_ui.dart';
import 'package:flutter_quiver/screens/polygraph/polygraph.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  int activeTab = 0;

  @override
  void initState() {
    super.initState();

    controllerExpression.text = '';
    controllerLabel.text = '';

    focusLabel.addListener(() {
      if (!focusLabel.hasFocus) {
        setState(() {
          validateLabel(ref.read(providerOfTransformedVariable));
        });
      }
    });
    focusExpression.addListener(() {
      if (!focusExpression.hasFocus) {
        setState(() {
          validateExpression();
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
              Column(
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
                            enabledBorder: state.hasInvalidLabel()
                                ? const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red))
                                : InputBorder.none,
                          ),
                          onEditingComplete: () {
                            setState(() {
                              validateLabel(state);
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
                        child: TextField(
                          controller: controllerExpression,
                          focusNode: focusExpression,
                          style: const TextStyle(fontSize: 14),
                          maxLines: null,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.all(8),
                            enabledBorder: (state.hasInvalidExpression() ||
                                    state.hasParsingError())
                                ? const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red))
                                : InputBorder.none,
                          ),
                          onEditingComplete: () {
                            setState(() {
                              validateExpression();
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
                  for (var error in state.getErrors())
                    Row(
                      children: [
                        Container(
                          width: 100,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 8),
                          child: const Text(''),
                        ),
                        Text(
                          error,
                          style: const TextStyle(
                              color: Colors.red, fontSize: 10),
                        ),
                      ],
                    ),
                ],
              ),
            if (activeTab == 1)
              const Placeholder(
                fallbackHeight: 150,
                fallbackWidth: 900,
              ),

            Padding(
              padding: const EdgeInsets.only(top: 36.0),
              child: SizedBox(
                width: 500,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    TextButton(
                      child: const Text('CANCEL'),
                      onPressed: () {
                        context.pop();
                        setState(() {
                          ref.read(providerOfTransformedVariable.notifier).reset();
                          ref.read(providerOfVariableSelection.notifier).categories = <String>[];
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      child: const Text('OK'),
                      onPressed: () async {
                        if (state.getErrors().isEmpty) {
                          context.pop(state);
                          setState(() {
                            ref.read(providerOfTransformedVariable.notifier).reset();
                            ref.read(providerOfVariableSelection.notifier).categories = <String>[];
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void validateLabel(TransformedVariable state) {
    ref.read(providerOfTransformedVariable.notifier).label =
        controllerLabel.text;
  }

  void validateExpression() {
    ref.read(providerOfTransformedVariable.notifier).expression =
        controllerExpression.text;
    var poly = ref.read(providerOfPolygraph);
    var tab = poly.tabs[poly.activeTabIndex];
    var window = tab.windows[tab.activeWindowIndex];
    var state = ref.read(providerOfTransformedVariable);
    state.eval(window.cache);
    ref.read(providerOfTransformedVariable.notifier).error = state.error;
  }
}
