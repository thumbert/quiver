library screens.polygraph.editors.transformed_variable_editor;


import 'package:flutter/material.dart' hide Interval, Transform;
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/transformed_variable.dart';
import 'package:flutter_quiver/screens/polygraph/polygraph.dart';
import 'package:flutter_quiver/screens/polygraph/polygraph_tab_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final providerOfTransformedVariable =
    StateNotifierProvider<TransformedVariableNotifier, TransformedVariable>(
        (ref) => TransformedVariableNotifier(ref));

class TransformedVariableEditor extends ConsumerStatefulWidget {
  const TransformedVariableEditor(
      {Key? key}) : super(key: key);

  static bool isValid = false;
  static String error = '';

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

  String errorLabel = '';
  String errorExpression = '';
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
          validateExpression(ref.read(providerOfTransformedVariable));
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

    /// TODO: Should do validation when the tab changes too

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
                              enabledBorder: (state.error != '' &&
                                      controllerLabel.text == '')
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
                          // height: 32,
                          child: TextField(
                            controller: controllerExpression,
                            focusNode: focusExpression,
                            style: const TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(8),
                              enabledBorder: (state.error != '' && controllerExpression.text == '')
                                  ? const OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.red))
                                  : InputBorder.none,
                            ),
                            onEditingComplete: () {
                              setState(() {
                                validateExpression(state);
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
                          width: 100,
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 8),
                          child: const Text(''),
                        ),
                        Text(state.error,
                          style: const TextStyle(color: Colors.red, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }

  void validateLabel(TransformedVariable state) {
    errorLabel = '';
    ref.read(providerOfTransformedVariable.notifier).label =
        controllerLabel.text;
    if (controllerLabel.text == '') {
      errorLabel =
      'Label can\'t be empty.  Please provide a variable name';
    }
    ref.read(providerOfTransformedVariable.notifier).error = errorLabel;
    TransformedVariableEditor.isValid = errorExpression == '' && errorLabel == '';
  }

  void validateExpression(TransformedVariable state) {
    errorExpression = '';
    if (controllerExpression.text == '') {
      errorExpression = 'Expression can\'t be empty.';
    } else {
      ref.read(providerOfTransformedVariable.notifier).expression =
          controllerExpression.text;
      var poly = ref.read(providerOfPolygraph);
      var tab = poly.tabs[poly.activeTabIndex];
      var window = tab.windows[tab.activeWindowIndex];
      state.eval(window.cache);
      errorExpression = state.error;
    }
    ref.read(providerOfTransformedVariable.notifier).error = errorExpression;
    TransformedVariableEditor.isValid = errorExpression == '' && errorLabel == '';
  }

}
