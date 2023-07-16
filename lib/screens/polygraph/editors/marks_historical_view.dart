library screens.polygraph.editors.marks_historical_strip;

import 'package:date/date.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/scheduler.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/polygraph/editors/marks_historical_view.dart' as model;
import 'package:flutter_quiver/screens/polygraph/utils/autocomplete_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart';

final providerOfMarksHistoricalView =
StateNotifierProvider<model.MarksHistoricalViewNotifier, model.MarksHistoricalView>(
        (ref) => model.MarksHistoricalViewNotifier(ref));

class MarksHistoricalView extends ConsumerStatefulWidget {
  const MarksHistoricalView({Key? key}) : super(key: key);

  static bool isValid = true;

  @override
  ConsumerState<MarksHistoricalView> createState() => _MarksHistoricalViewState();
}

class _MarksHistoricalViewState extends ConsumerState<MarksHistoricalView> {
  final controllerCurveName = TextEditingController();
  final controllerForwardStrip = TextEditingController();
  final controllerHistoricalTerm = TextEditingController();
  final controllerLabel = TextEditingController();

  final focusCurveName = FocusNode();
  final focusForwardStrip = FocusNode();
  final focusHistoricalTerm = FocusNode();
  final focusLabel = FocusNode();

  int activeTab = 0;

  String? _errorCurveName, _errorForwardStrip, _errorHistoricalTerm, _errorLabel;

  @override
  void initState() {
    super.initState();
    // get this as soon as possible
    model.MarksHistoricalView.getAllCurveNames();
    var state = ref.read(providerOfMarksHistoricalView);
    _setControllers(state);

    focusCurveName.addListener(() {
      if (!focusCurveName.hasFocus) {
        setState(() {
          validateCurveName(ref.read(providerOfMarksHistoricalView));
        });
      }
    });
    focusForwardStrip.addListener(() {
      if (!focusForwardStrip.hasFocus) {
        setState(() {
          validateForwardStrip(ref.read(providerOfMarksHistoricalView));
        });
      }
    });
    focusHistoricalTerm.addListener(() {
      if (!focusHistoricalTerm.hasFocus) {
        setState(() {
          validateHistoricalTerm(ref.read(providerOfMarksHistoricalView));
        });
      }
    });
    focusLabel.addListener(() {
      if (!focusLabel.hasFocus) {
        setState(() {
          validateLabel(ref.read(providerOfMarksHistoricalView));
        });
      }
    });
  }

  @override
  void dispose() {
    controllerCurveName.dispose();
    controllerForwardStrip.dispose();
    controllerHistoricalTerm.dispose();
    controllerLabel.dispose();

    focusCurveName.dispose();
    focusForwardStrip.dispose();
    focusHistoricalTerm.dispose();
    focusLabel.dispose();

    super.dispose();
  }

  void _setControllers(model.MarksHistoricalView state) {
    controllerCurveName.text = state.curveName;
    controllerForwardStrip.text = state.forwardStrip.toString();
    controllerHistoricalTerm.text = state.historicalTerm.toString();
    controllerLabel.text = state.label;
  }

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(providerOfMarksHistoricalView);
    // var curvesProvider = ref.watch(model.providerOfPolygraphCurveNames);

    return Column(
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
              /// Curve name
              ///
              Row(
                children: [
                  Container(
                    width: 140,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 8),
                    child: const Text(
                      'Curve name',
                    ),
                  ),
                  Container(
                    color: MyApp.background,
                    width: 240,
                    child: RawAutocomplete(
                        focusNode: focusCurveName,
                        textEditingController: controllerCurveName,
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
                                enabledBorder: _errorCurveName != null  ?
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
                          var aux = (await model.MarksHistoricalView.getAllCurveNames()).where((e) => e
                              .toUpperCase()
                              .contains(textEditingValue.text.toUpperCase())).toList();
                          return aux;
                        },
                        onSelected: (String selection) {
                          setState(() {
                            validateCurveName(state);
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
                    _errorCurveName ?? '',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),

              ///
              /// Forward strip
              ///
              Row(
                children: [
                  Container(
                    width: 140,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 8),
                    child: const Tooltip(
                      message: 'The forward term of interest, a month, a month range, a year, etc.',
                      child: Text(
                        'Forward strip',
                      ),
                    ),
                  ),
                  Container(
                    color: MyApp.background,
                    width: 150,
                    height: 32,
                    child: TextField(
                      controller: controllerForwardStrip,
                      focusNode: focusForwardStrip,
                      style: const TextStyle(fontSize: 13.0),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.all(8),
                        enabledBorder: InputBorder.none,
                      ),
                      onEditingComplete: () {
                        setState(() {
                          validateForwardStrip(state);
                        });
                      },
                    ),
                  ),
                  Text(
                    _errorForwardStrip ?? '',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(
                height: 8,
              ),

              ///
              /// Historical term
              ///
              Row(
                children: [
                  Container(
                    width: 140,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 8),
                    child: const Tooltip(
                      message: 'A date range for the historical period of interest',
                      child: Text(
                        'Historical period',
                      ),
                    ),
                  ),
                  Container(
                    color: MyApp.background,
                    width: 150,
                    height: 32,
                    child: TextField(
                      controller: controllerHistoricalTerm,
                      focusNode: focusHistoricalTerm,
                      style: const TextStyle(fontSize: 13.0),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.all(8),
                        enabledBorder: InputBorder.none,
                      ),
                      onEditingComplete: () {
                        setState(() {
                          validateHistoricalTerm(state);
                        });
                      },
                    ),
                  ),
                  Text(
                    _errorHistoricalTerm ?? '',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(
                height: 24,
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
                          validateLabel(state);
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

      ],
    );
  }

  void validateCurveName(model.MarksHistoricalView state) {
    _errorCurveName = null;
    if (controllerCurveName.text != '') {
      ref
          .read(providerOfMarksHistoricalView.notifier)
          .curveName = controllerCurveName.text;
    } else {
      _errorLabel = 'Curve name can\'t be empty';
    }
  }

  void validateForwardStrip(model.MarksHistoricalView state) {
    _errorForwardStrip = null;
    try {
      var term = Term.parse(controllerForwardStrip.text, UTC);
      if (!term.isOneMonth() && !term.isMonthRange()) {
        throw 'Forward strip needs to be a month or a month range\n'
            ', for example: K27, Jul28, Nov26-Mar27, Cal28';
      }
      ref.read(providerOfMarksHistoricalView.notifier).forwardStrip = term;
      MarksHistoricalView.isValid = true;
    } catch (e) {
      MarksHistoricalView.isValid = false;
      if (e is ArgumentError) {
        _errorForwardStrip = 'Don\'t know how to parse ${controllerForwardStrip.text}'
            '\nValid examples are: K27, Nov26-Mar27, Cal28, Q2,28, etc.';
      } else {
        _errorForwardStrip = e.toString();
      }
    }
  }

  void validateHistoricalTerm(model.MarksHistoricalView state) {
    _errorHistoricalTerm = null;
    try {
      var term = Term.parse(controllerHistoricalTerm.text, UTC);
      ref.read(providerOfMarksHistoricalView.notifier).historicalTerm = term;
      MarksHistoricalView.isValid = true;
    } catch (e) {
      MarksHistoricalView.isValid = false;
      if (e is ArgumentError) {
        _errorHistoricalTerm = 'Don\'t know how to parse ${controllerHistoricalTerm.text}'
            '\nEnter a date range: 15Jan21-31Jul21, or a relative date: -10d';
      } else {
        _errorHistoricalTerm = e.toString();
      }
    }
  }


  void validateLabel(model.MarksHistoricalView state) {
    _errorLabel = null;
    if (controllerLabel.text != '') {
      ref
          .read(providerOfMarksHistoricalView.notifier)
          .label = controllerLabel.text;
      MarksHistoricalView.isValid = true;
    } else {
      MarksHistoricalView.isValid = false;
      _errorLabel = 'Label can\'t be empty';
    }
  }
}


