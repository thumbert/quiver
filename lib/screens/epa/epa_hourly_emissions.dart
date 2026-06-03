import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/epa/epa_hourly_emissions.dart';
import 'package:flutter_quiver/utils/clipboard.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:quiver_core/quiver_core.dart';
import 'package:signals_flutter/signals_flutter.dart';

class EpaHourlyEmissions extends StatefulWidget {
  const EpaHourlyEmissions({super.key});
  static const route = '/epa_hourly_emissions_ui';
  @override
  State<EpaHourlyEmissions> createState() => _EpaHourlyEmissionsState();
}

class _EpaHourlyEmissionsState extends State<EpaHourlyEmissions> {
  late Plotly plotly;
  late EffectCleanup _termEffect;
  final scrollControllerV = ScrollController();
  final scrollControllerH = ScrollController();

  @override
  void initState() {
    var aux = DateTime.now().hashCode;
    plotly = Plotly(
      viewId: 'plotly-epa-hourly-$aux',
      traces: const [],
      layout: layout,
    );
    _termEffect = effect(() {
      term.value; // subscribe
      cacheTs.clear();
    });
    super.initState();
  }

  @override
  void dispose() {
    _termEffect();
    scrollControllerV.dispose();
    scrollControllerH.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('EPA emissions data'),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const SimpleDialog(
                        contentPadding: EdgeInsets.all(12),
                        children: [
                          Text(
                              'Analyze data from EPA hourly emissions datasets.'),
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.info_outline),
              tooltip: 'Info',
            )
          ],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: scrollControllerV,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
                padding: const EdgeInsets.only(top: 12.0, left: 12.0),
                child: Watch(
                  (context) => Column(
                    spacing: 6,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Term',
                            style: TextStyle(
                                fontSize: 14, color: Colors.blueGrey.shade600),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Container(
                            width: 150,
                            color: Colors.amber.shade50,
                            child: Center(
                                child: TermUi(
                              model: term,
                              setTerm: (Term? value) {
                                term.value = value!;
                              },
                              getTerm: (model) => term.value,
                            )),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),
                      ...rowUserView(),
                      const SizedBox(
                        height: 24,
                      ),
                      Watch((context) {
                        switch (traces.value) {
                          // ignore: unused_local_variable
                          case AsyncData data:
                            plotly.react(
                                traces.requireValue, layout, plotly.config);
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                IconButton(
                                  onPressed: () => copyToClipboard(toCsv()),
                                  icon: const Icon(Icons.copy),
                                  tooltip: 'Copy',
                                ),
                                Row(children: [
                                  SizedBox(
                                      width: 900, height: 600, child: plotly),
                                ]),
                              ],
                            );
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
                )),
          ),
        ));
  }

  List<Widget> rowUserView() {
    final out = <Widget>[
      /// column header
      Row(
        children: [
          SizedBox(
            width: 84,
            child: Text(
              'State',
              style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600),
            ),
          ),
          SizedBox(
            width: 324,
            child: Text(
              'Facility name',
              style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600),
            ),
          ),
          SizedBox(
            width: 120,
            child: Text(
              'Variable',
              style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600),
            ),
          ),
        ],
      ),
    ];
    for (var (i, _) in rows.value.indexed) {
      out.add(Row2(index: i));
    }
    return out;
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
        padding: const EdgeInsets.only(bottom: 1.0),
        child: SizedBox(
            // I use this to increase the MouseRegion
            width: 825,
            child: Watch(
              (context) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///
                  /// State
                  ///
                  Container(
                    width: 72,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: DropdownUi(
                      model: rows,
                      setSelection: (value) {
                        final rs = rows.value;
                        rs[widget.index] = rs[widget.index]
                            .copyWith(state: value, facilityName: '');
                        rows.value = [...rs];
                      },
                      getSelection: (model) => rows.value[widget.index].state,
                      choices: allStatesTz.keys.toSet(),
                      width: 72,
                      // padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),

                  ///
                  /// Facility name
                  ///
                  Container(
                    width: 312,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: switch (FacilityRow.allFacilities.value) {
                      AsyncData<int>() => AutocompleteUi(
                          model: rows,
                          setSelection: (value) {
                            final rs = rows.value;
                            rs[widget.index] =
                                rs[widget.index].copyWith(facilityName: value);
                            rows.value = [...rs];
                          },
                          getSelection: (model) =>
                              rows.value[widget.index].facilityName,
                          clearSelection: () {
                            final rs = rows.value;
                            rs[widget.index] =
                                rs[widget.index].copyWith(facilityName: '');
                            rows.value = [...rs];
                          },
                          choices:
                              cacheFacilities[rows.value[widget.index].state]!,
                          width: 312,
                          style: const TextStyle(fontSize: 14),
                        ),
                      AsyncError<int>() => Text(
                          'Error loading locations for ${rows.value[widget.index].state}',
                        ),
                      AsyncLoading<int>() => Center(
                          child: CircularProgressIndicator(),
                        ),
                    },
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  ///
                  /// Variable name
                  ///
                  Container(
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: DropdownUi(
                      model: rows,
                      setSelection: (value) {
                        final rs = rows.value;
                        rs[widget.index] =
                            rs[widget.index].copyWith(variableName: value);
                        rows.value = [...rs];
                      },
                      getSelection: (model) =>
                          rows.value[widget.index].variableName,
                      choices: allVariables.keys.toSet(),
                      width: 300,
                    ),
                  ),

                  ///
                  /// Checkbox to aggregate units or not.
                  ///
                  SizedBox(
                    height: 32,
                    child: Center(
                      child: Tooltip(
                        message: 'Aggregate units?',
                        child: Checkbox(
                          value: rows.value[widget.index].aggregateUnits,
                          onChanged: (value) {
                            final rs = rows.value;
                            rs[widget.index] = rs[widget.index]
                                .copyWith(aggregateUnits: value ?? false);
                            rows.value = [...rs];
                          },
                        ),
                      ),
                    ),
                  ),

                  /// The pop-up menu on the side ...
                  if (isMouseOver)
                    Container(
                      height: 32,
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          /// Remove
                          IconButton(
                            tooltip: 'Remove',
                            onPressed: () {
                              setState(() {
                                if (rows.value.length > 1) {
                                  var rs = rows.value;
                                  rs.removeAt(widget.index);
                                  rows.value = [...rs];
                                }
                              });
                            },
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
                                var rs = rows.value;
                                var row = FacilityRow(
                                  state: rs[widget.index].state,
                                  facilityName: rs[widget.index].facilityName,
                                  variableName: rs[widget.index].variableName,
                                  aggregateUnits:
                                      rs[widget.index].aggregateUnits,
                                );
                                rs.insert(widget.index, row);
                                rows.value = [...rs];
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
    // if (!tab1.allLocations().contains(locationController.text)) {
    //   locationError.value = 'Invalid location';
    // } else {
    //   locationError.value = '';
    // }
  }
}
