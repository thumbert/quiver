library screens.polygraph.editors.forward_asof;

import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_marks_asofdate.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_marks_historical_view.dart';
import 'package:flutter_quiver/screens/polygraph/polygraph.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timezone/timezone.dart';

// final providerOfMarksAsOf =
// StateNotifierProvider<VariableMarksAsOfDateNotifier, VariableMarksAsOfDate>(
//         (ref) => VariableMarksAsOfDateNotifier(ref));


class SaveProjectEditor extends ConsumerStatefulWidget {
  const SaveProjectEditor({Key? key}) : super(key: key);

  @override
  _SaveProjectEditorState createState() => _SaveProjectEditorState();
}

class _SaveProjectEditorState extends ConsumerState<SaveProjectEditor> {
  final controllerUserName = TextEditingController();
  final controllerProjectName = TextEditingController();
  final controllerLabel = TextEditingController();

  final focusCurveName = FocusNode();
  final focusAsOfDate = FocusNode();
  final focusLabel = FocusNode();

  int activeTab = 0;

  String? _errorUserName, _errorAsOfDate, _errorLabel;

  @override
  void initState() {
    super.initState();
    // get this as soon as possible
    VariableMarksHistoricalView.getAllCurveNames();
    var state = ref.read(providerOfPolygraph);
    _setControllers(state);

    focusCurveName.addListener(() {
      if (!focusCurveName.hasFocus) {
        setState(() {
          validateCurveName();
        });
      }
    });
    focusAsOfDate.addListener(() {
      if (!focusAsOfDate.hasFocus) {
        setState(() {
          validateAsOfDate();
        });
      }
    });
    focusLabel.addListener(() {
      if (!focusLabel.hasFocus) {
        setState(() {
          validateLabel();
        });
      }
    });
  }

  @override
  void dispose() {
    controllerUserName.dispose();
    controllerProjectName.dispose();
    controllerLabel.dispose();

    focusCurveName.dispose();
    focusAsOfDate.dispose();
    focusLabel.dispose();

    super.dispose();
  }

  void _setControllers(PolygraphState state) {
    controllerUserName.text = state.userId ?? '';
    controllerProjectName.text = state.projectName ?? '';
  }

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(providerOfPolygraph);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        if (activeTab == 0)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///
              /// User name
              ///
              Row(
                children: [
                  Container(
                    width: 140,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 8),
                    child: const Text(
                      'User name',
                    ),
                  ),
                  Container(
                    color: MyApp.background,
                    width: 240,
                    child: RawAutocomplete(
                        focusNode: focusCurveName,
                        textEditingController: controllerUserName,
                        fieldViewBuilder: (BuildContext context,
                            TextEditingController textEditingController,
                            FocusNode focusNode,
                            VoidCallback onFieldSubmitted) =>
                            TextField(
                              focusNode: focusNode,
                              controller: textEditingController,
                              onEditingComplete: onFieldSubmitted,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.all(10),
                                enabledBorder: _errorUserName != null  ?
                                const OutlineInputBorder(
                                    borderSide: BorderSide(color: Colors.red))
                                    : InputBorder.none,
                                fillColor: MyApp.background,
                                filled: true,
                              ),
                            ),
                        optionsBuilder: (TextEditingValue textEditingValue) async {
                          if (textEditingValue == TextEditingValue.empty) {
                            return const Iterable<String>.empty();
                          }
                          var aux = (await VariableMarksHistoricalView.getAllCurveNames()).where((e) => e
                              .toUpperCase()
                              .contains(textEditingValue.text.toUpperCase())).toList();
                          return aux;
                        },
                        onSelected: (String selection) {
                          setState(() {
                            validateCurveName();
                            // ref.read(providerOfMarksHistoricalView.notifier).curveName = selection;
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
                                const BoxConstraints(maxHeight: 300, maxWidth: 240),
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
                                              child: Text(option, style: const TextStyle(fontSize: 13),),
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
                    _errorUserName ?? '',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),
              

              ///
              /// Label
              ///
              Row(
                children: [
                  Container(
                    width: 140,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 8),
                    child: const Text(
                      'Label',
                    ),
                  ),
                  Container(
                    color: MyApp.background,
                    width: 240,
                    height: 32,
                    child: TextField(
                      controller: controllerLabel,
                      focusNode: focusLabel,
                      style: const TextStyle(fontSize: 13.0),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.all(8),
                        enabledBorder: InputBorder.none,
                      ),
                      onEditingComplete: () {
                        setState(() {
                          validateLabel();
                        });
                      },
                    ),
                  ),
                  Text(
                    _errorLabel ?? '',
                    style: const TextStyle(color: Colors.red),
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
                      ref.read(providerOfMarksAsOf.notifier).reset();
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
                        ref.read(providerOfPolygraph.notifier).refreshActiveWindow = true;
                        ref.read(providerOfMarksAsOf.notifier).reset();
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }

  void validateCurveName() {
    _errorUserName = null;
    if (controllerUserName.text != '') {
      ref
          .read(providerOfMarksAsOf.notifier)
          .curveName = controllerUserName.text;
    } else {
      _errorLabel = 'Curve name can\'t be empty';
    }
  }

  void validateAsOfDate() {
    _errorAsOfDate = null;
    try {
      var date = Date.parse(controllerProjectName.text, location: UTC);
      ref.read(providerOfMarksAsOf.notifier).asOfDate = date;
    } catch (e) {
      if (e is ArgumentError) {
        _errorAsOfDate = 'Don\'t know how to parse ${controllerProjectName.text}'
            '\nValid examples are: 7Jul23, -1b, -3d, etc.';
      } else {
        _errorAsOfDate = e.toString();
      }
    }
  }



  void validateLabel() {
    _errorLabel = null;
    if (controllerLabel.text != '') {
      ref
          .read(providerOfMarksAsOf.notifier)
          .label = controllerLabel.text;
    } else {
      _errorLabel = 'Label can\'t be empty';
    }
  }

}
