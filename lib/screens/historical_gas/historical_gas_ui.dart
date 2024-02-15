library screens.historical_lmp.historical_gas_ui;

import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/historical_gas_model.dart';
import 'package:flutter_quiver/screens/common/signal/dropdown.dart';
import 'package:flutter_quiver/screens/common/signal/multiselect.dart';
import 'package:flutter_quiver/screens/common/signal/term.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:signals_flutter/signals_flutter.dart';

class HistoricalGas extends StatefulWidget {
  const HistoricalGas({super.key});

  static const route = '/historical_gas';

  @override
  State<HistoricalGas> createState() => _State();
}

class _State extends State<HistoricalGas> {
  final scrollControllerV = ScrollController();
  final scrollControllerH = ScrollController();
  late Plotly plotly;

  static late Signal<Term> termSignal;
  late Signal<String?> termErrorSignal;
  final Signal<String> timeAggregation = signal('Daily');
  final timeAggregationController = TextEditingController();

  final SelectionModel region = SelectionModel(
      selection: setSignal(<String>{}),
      choices: HistoricalGasModel.regions().toSet());

  final DropdownModel timeAggregationModel =
      DropdownModel(selection: signal('Daily'), choices: {'Daily', 'Monthly'});

  static late Signal<HistoricalGasModel> model;

  ListSignal<bool> regions =
      listSignal(List.filled(HistoricalGasModel.mappedLocations.length, false));

  late final traces = futureSignal(() async {
    // print('in traces ...');
    // print('model location: ${model.value.locations}');
    // print('model indices: ${model.value.indices}');
    // print('term: ${termSignal.value}');
    if (!HistoricalGasModel.cacheTerm.interval
        .containsInterval(termSignal.value.interval)) {
      HistoricalGasModel.cache.clear();
      HistoricalGasModel.cacheTerm = termSignal.value;
    }
    try {
      await HistoricalGasModel.getData(
          termSignal.value, model.value.locations, model.value.indices);
    } catch (e) {
      rethrow;
    }
    return model.value.makeTraces(termSignal.value);
  }, dependencies: [
    termSignal,
    model,
  ]);

  @override
  void initState() {
    model = signal(HistoricalGasModel.getDefault());
    termSignal = signal(HistoricalGasModel.getDefaultTerm());
    termErrorSignal = signal(null);
    timeAggregationController.text = timeAggregation.value;

    var aux = DateTime.now().hashCode;
    plotly = Plotly(
      viewId: 'plotly-hist-gas-$aux',
      data: const [],
      layout: HistoricalGasModel.layout,
    );

    super.initState();
  }

  @override
  void dispose() {
    scrollControllerV.dispose();
    scrollControllerH.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allRegions = HistoricalGasModel.regions();

    return Scaffold(
        body: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      controller: scrollControllerV,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 12.0),
            child: Watch(
              (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Term',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Container(
                        width: 150,
                        color: Colors.amber.shade50,
                        child: Center(
                            child: TermUi(
                          term: termSignal,
                          error: termErrorSignal,
                        )),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      if (termErrorSignal.value != null)
                        Text(
                          termErrorSignal.value!,
                          style: const TextStyle(
                              color: Colors.red,
                              fontFamily: 'Italic',
                              fontSize: 11),
                        ),
                      const SizedBox(
                        width: 36,
                      ),

                      ///
                      /// Aggregation
                      ///
                      const Text(
                        'Time Aggregation',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      DropdownMenu<String>(
                        width: 120.0,
                        menuHeight: 600.0,
                        trailingIcon: const Icon(
                          Icons.keyboard_arrow_down,
                        ),
                        selectedTrailingIcon: const Icon(
                          Icons.keyboard_arrow_up,
                        ),
                        controller: timeAggregationController,
                        textStyle: const TextStyle(fontSize: 14),
                        dropdownMenuEntries: const [
                          DropdownMenuEntry(value: 'Daily', label: 'Daily'),
                          DropdownMenuEntry(value: 'Monthly', label: 'Monthly'),
                        ],
                        inputDecorationTheme: InputDecorationTheme(
                          isDense: true,
                          isCollapsed: true,
                          filled: true,
                          fillColor: Colors.blueGrey.shade50,
                          contentPadding: const EdgeInsets.only(left: 8.0),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide.none),
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide.none),
                          constraints: const BoxConstraints(maxHeight: 36),
                        ),
                        onSelected: (String? name) {
                          timeAggregation.value =
                              timeAggregationController.text;
                        },
                      ),
                      const SizedBox(
                        width: 36,
                      ),

                      ///
                      /// Time aggregation
                      ///
                      Container(
                          width: 226,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade50,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          // color: Colors.blueGrey.shade50,
                          child: DropdownUi(model: timeAggregationModel)),
                      const SizedBox(
                        width: 36,
                      ),

                      ///
                      /// Region
                      ///
                      const Text(
                        'Region',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Container(
                          width: 226,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade50,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          // color: Colors.blueGrey.shade50,
                          child: MultiselectUi(model: region)),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  // Row(
                  //   children: [
                  //     const Text(
                  //       'Region',
                  //       style: TextStyle(fontSize: 14),
                  //     ),
                  //     const SizedBox(
                  //       width: 8,
                  //     ),
                  //     ...[
                  //       for (var i = 0; i < allRegions.length; i++)
                  //         Padding(
                  //             padding: const EdgeInsets.only(right: 4.0),
                  //             child: ElevatedButton(
                  //                 style: ElevatedButton.styleFrom(
                  //                   backgroundColor: regions.value[i]
                  //                       ? Colors.purple.shade100
                  //                       : Colors.blueGrey.shade50,
                  //                 ),
                  //                 onPressed: () {
                  //                   regions.value[i] = !regions.value[i];
                  //                   setState(() {});
                  //                 },
                  //                 child: Text(allRegions[i]))),
                  //     ]
                  //   ],
                  // ),
                  // const SizedBox(
                  //   height: 12,
                  // ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          ...[
                            for (var i = 0;
                                i < model.value.locations.length;
                                i++)
                              Row2(
                                index: i,
                                key: UniqueKey(), // need this
                              )
                          ],
                        ],
                      ),
                      Watch((context) {
                        switch (traces.value) {
                          // ignore: unused_local_variable
                          case AsyncData data:
                            return updatePlot();
                          case AsyncError error:
                            return Row(children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red),
                              Text(
                                error.error.toString(),
                                style: const TextStyle(fontSize: 16),
                              )
                            ]);
                          case AsyncLoading():
                            return const SizedBox(
                              width: 900,
                              height: 600,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    Text('    Loading ...'),
                                  ]),
                            );
                        }
                      }),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                    width: 1500,
                  ),
                ],
              ),
            )),
      ),
    ));
  }

  Widget updatePlot() {
    plotly.plot.react(traces.requireValue, HistoricalGasModel.layout,
        displaylogo: false);
    return Row(children: [
      SizedBox(width: 900, height: 600, child: plotly),
    ]);
  }
}

class Row2 extends StatefulWidget {
  const Row2({required this.index, super.key});

  final int index;

  @override
  State<Row2> createState() => _Row2State();
}

class _Row2State extends State<Row2> {
  bool isMouseOver = false;

  final locationController = TextEditingController();
  final gasIndexController = TextEditingController();

  Signal<String> locationError = signal('');
  Signal<String> gasIndexError = signal('');

  @override
  void initState() {
    super.initState();
    locationController.text = _State.model.value.locations[widget.index];
    gasIndexController.text = _State.model.value.indices[widget.index];
  }

  @override
  void dispose() {
    gasIndexController.dispose();
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    checkErrorLocation();
    checkErrorGasIndex();

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          isMouseOver = true;
        });
      },
      onExit: (_) {
        setState(() {
          isMouseOver = false;
        });
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: SizedBox(
            // I use this to increase the MouseRegion
            width: 525,
            child: Watch(
              (context) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///
                  /// Gas location
                  ///
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownMenu<String>(
                        width: 300.0,
                        menuHeight: 600.0,
                        trailingIcon: const Icon(
                          Icons.keyboard_arrow_down,
                          size: 0,
                        ),
                        selectedTrailingIcon: const Icon(
                          Icons.keyboard_arrow_up,
                          size: 0,
                        ),
                        controller: locationController,
                        enableFilter: true,
                        leadingIcon: const Icon(Icons.search),
                        textStyle: const TextStyle(fontSize: 14),
                        dropdownMenuEntries: [
                          for (var asset in HistoricalGasModel.allLocations())
                            DropdownMenuEntry(
                                value: asset,
                                label: asset,
                                style: const ButtonStyle(
                                    padding: MaterialStatePropertyAll(
                                        EdgeInsets.only(left: 8)),
                                    visualDensity: VisualDensity.compact))
                        ],
                        inputDecorationTheme: InputDecorationTheme(
                          isDense: true,
                          isCollapsed: true,
                          filled: true,
                          fillColor: Colors.blueGrey.shade50,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 4.0),
                          border: const OutlineInputBorder(
                              borderSide: BorderSide.none),
                          enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide.none),
                          constraints: const BoxConstraints(maxHeight: 36),
                        ),
                        onSelected: (String? name) {
                          var locations = [..._State.model.value.locations];
                          locations[widget.index] = name!;
                          _State.model.value =
                              _State.model.value.copyWith(locations: locations);
                          locationError.value = '';
                        },
                      ),
                      if (locationError.value != '')
                        Watch((context) => Text(
                              locationError.value,
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontFamily: 'Italic',
                                  fontSize: 11),
                            )),
                    ],
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  ///
                  /// Gas index
                  ///
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownMenu(
                        controller: gasIndexController,
                        onSelected: (value) {
                          _State.model.value.indices[widget.index] = value!;
                          gasIndexError.value = '';
                        },
                        trailingIcon: const Icon(
                          Icons.keyboard_arrow_down_outlined,
                        ),
                        selectedTrailingIcon: const Icon(
                          Icons.keyboard_arrow_up_outlined,
                        ),
                        textStyle: const TextStyle(fontSize: 14),
                        dropdownMenuEntries: const [
                          DropdownMenuEntry(
                              value: 'Gas Daily', label: 'Gas Daily'),
                          DropdownMenuEntry(value: 'IFerc', label: 'IFerc'),
                        ],
                        inputDecorationTheme: InputDecorationTheme(
                          contentPadding: const EdgeInsets.only(left: 8),
                          border: InputBorder.none,
                          outlineBorder: BorderSide.none,
                          disabledBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          isDense: true,
                          fillColor: Colors.blueGrey.shade50,
                          filled: true,
                          constraints: const BoxConstraints(maxHeight: 36),
                        ),
                      ),
                      if (gasIndexError.value != '')
                        Watch((context) => Text(
                              gasIndexError.value,
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontFamily: 'Italic',
                                  fontSize: 11),
                            )),
                    ],
                  ),

                  /// The pop-up menu on the side ...
                  if (isMouseOver)
                    Container(
                      height: 36,
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          /// Remove
                          IconButton(
                            tooltip: 'Remove',
                            onPressed: () {
                              _State.model.value =
                                  _State.model.value.removeRowAt(widget.index);
                            }, // delete the sucker
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.only(left: 0, right: 0),
                            icon: Icon(
                              Icons.delete_forever,
                              color: Colors.blueGrey[300],
                              size: 28,
                            ),
                          ),

                          /// Add
                          IconButton(
                            tooltip: 'Add',
                            onPressed: () {
                              setState(() {
                                _State.model.value =
                                    _State.model.value.addRowAt(widget.index);
                              });
                            },
                            visualDensity: VisualDensity.compact,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.only(left: 0, right: 0),
                            icon: const Icon(
                              Icons.add,
                              color: Colors.purple,
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            )),
      ),
    );
  }

  void checkErrorGasIndex() {
    if (!HistoricalGasModel.allGasIndices.contains(gasIndexController.text)) {
      gasIndexError.value = 'Invalid gas index';
    } else {
      gasIndexError.value = '';
    }
  }

  void checkErrorLocation() {
    if (!HistoricalGasModel.allLocations().contains(locationController.text)) {
      locationError.value = 'Invalid location';
    } else {
      locationError.value = '';
    }
  }
}
