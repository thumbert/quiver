library screens.historical_gas.tab1_historical_gas;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/historical_gas_model.dart' as tab1;
import 'package:flutter_quiver/screens/common/signal/dropdown.dart';
import 'package:flutter_quiver/screens/common/signal/multiselect.dart';
import 'package:flutter_quiver/screens/common/signal/term.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:signals_flutter/signals_flutter.dart';

class Tab1HistoricalGas extends StatefulWidget {
  const Tab1HistoricalGas({super.key});
  @override
  State<Tab1HistoricalGas> createState() => _State();
}

class _State extends State<Tab1HistoricalGas> {
  late Plotly plotly;

  /// update the widgets when the rows change!
  final _rows = computed(() {
    return [
      for (var i = 0; i < tab1.rows.value.length; i++)
        Row2(
          index: i,
          key: UniqueKey(), // need this
        )
    ];
  });

  @override
  void initState() {
    var aux = DateTime.now().hashCode;
    plotly = Plotly(
      viewId: 'plotly-hist-gas-tab1-$aux',
      data: const [],
      layout: tab1.layout,
    );
    super.initState();
  }

  @override
  void dispose() {
    tab1.updateRows(); // dispose of the effect
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Watch(
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
                  term: tab1.termSignal,
                  error: tab1.termErrorSignal,
                )),
              ),
              const SizedBox(
                width: 8,
              ),
              if (tab1.termErrorSignal.value != null)
                Text(
                  tab1.termErrorSignal.value!,
                  style: const TextStyle(
                      color: Colors.red, fontFamily: 'Italic', fontSize: 11),
                ),
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
                  child: MultiselectUi(
                    model: tab1.region,
                    width: 226,
                  )),
              const SizedBox(
                width: 36,
              ),

              ///
              /// Time aggregation
              ///
              const Text(
                'Time Aggregation',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(
                width: 8,
              ),
              Container(
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  // color: Colors.blueGrey.shade50,
                  child: DropdownUi(
                    model: tab1.timeAggregationModel,
                    width: 150.0,
                  )),
              const SizedBox(
                width: 36,
              ),
            ],
          ),
          const SizedBox(
            height: 24,
          ),

          /// column header
          Row(
            children: [
              SizedBox(
                width: 312,
                child: Text(
                  'Location',
                  style:
                      TextStyle(fontSize: 14, color: Colors.blueGrey.shade600),
                ),
              ),
              SizedBox(
                width: 120,
                child: Text(
                  'Index',
                  style:
                      TextStyle(fontSize: 14, color: Colors.blueGrey.shade600),
                ),
              ),
            ],
          ),

          /// rows with the locations & index
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: _rows.value,
              ),
              Watch((context) {
                switch (tab1.traces.value) {
                  // ignore: unused_local_variable
                  case AsyncData data:
                    return updatePlot();
                  case AsyncError error:
                    return Row(children: [
                      const Icon(Icons.error_outline, color: Colors.red),
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
    );
  }

  Widget updatePlot() {
    plotly.plot
        .react(tab1.traces.requireValue, tab1.layout, displaylogo: false);
    return Row(children: [
      SizedBox(width: 900, height: 600, child: plotly),
    ]);
  }
}

class Row2 extends StatefulWidget {
  const Row2({required this.index, super.key});

  final int index;
  // final Signal<({String location, String index})> row;

  @override
  State<Row2> createState() => _Row2State();
}

class _Row2State extends State<Row2> {
  bool isMouseOver = false;

  final locationController = TextEditingController();
  Signal<String> locationError = signal('');
  late final DropdownModel gasIndex;

  @override
  void initState() {
    super.initState();
    locationController.text = tab1.rows.value[widget.index].location.value;
    gasIndex = DropdownModel(
        selection: tab1.rows.value[widget.index].index,
        choices: tab1.allGasIndices.toSet());
    // tab1.registerEffects();
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    checkErrorLocation();

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
                          for (var location in tab1.allLocations())
                            DropdownMenuEntry(
                                value: location,
                                label: location,
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
                          var rs = tab1.rows.value;
                          rs[widget.index] = (
                            location: signal(name!),
                            index: rs[widget.index].index
                          );
                          tab1.rows.value = [...rs];
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
                  Container(
                      width: 120,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: DropdownUi(model: gasIndex, width: 120)),

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
                              setState(() {
                                var rs = tab1.rows.value;
                                rs.removeAt(widget.index);
                                tab1.rows.value = [...rs];
                              });
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
                                var rs = tab1.rows.value;
                                var row = (
                                  location:
                                      signal(rs[widget.index].location.value),
                                  index: signal(rs[widget.index].index.value),
                                );
                                rs.insert(widget.index, row);
                                tab1.rows.value = [...rs];
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

  void checkErrorLocation() {
    if (!tab1.allLocations().contains(locationController.text)) {
      locationError.value = 'Invalid location';
    } else {
      locationError.value = '';
    }
  }
}
