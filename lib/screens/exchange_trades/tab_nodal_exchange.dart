import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_quiver/screens/common/signal/autocomplete.dart';
import 'package:table/table_base.dart' as table;
import 'package:flutter_quiver/models/exchange_trades/nodal_model.dart'
    as nodal;
import 'package:flutter_quiver/screens/common/signal/date_field.dart';
import 'package:signals_flutter/signals_flutter.dart';

class TabNodalExchange extends StatefulWidget {
  const TabNodalExchange({super.key});
  @override
  State<TabNodalExchange> createState() => _State();
}

class _State extends State<TabNodalExchange> {
  @override
  Widget build(BuildContext context) {
    return Watch(
      (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///
          /// Trade date start & end
          ///
          Row(
            children: [
              const Text(
                'Trade date start',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(
                width: 8,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.amber.shade50,
                    child: DateFieldUi(
                        date: nodal.startDate, error: nodal.startError),
                  ),
                  if (nodal.startError.value != null)
                    Text(
                      nodal.startError.value!,
                      style: const TextStyle(color: Colors.red, fontSize: 11),
                    )
                ],
              ),
              const SizedBox(
                width: 36,
              ),
              const Text(
                'end',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(
                width: 8,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: Colors.amber.shade50,
                    child:
                        DateFieldUi(date: nodal.endDate, error: nodal.endError),
                  ),
                  if (nodal.endError.value != null)
                    Text(
                      nodal.endError.value!,
                      style: const TextStyle(color: Colors.red, fontSize: 11),
                    )
                ],
              ),
              const SizedBox(
                width: 36,
              ),
              SegmentedButton(
                segments: const [
                  ButtonSegment(value: 'Outright', label: Text('Outright')),
                  ButtonSegment(value: 'Spread', label: Text('Spread')),
                  ButtonSegment(value: 'Option', label: Text('Option')),
                ],
                selected: {nodal.tradeKind.value},
                onSelectionChanged: (Set<String> newSelection) {
                  nodal.tradeKind.value = newSelection.first;
                },
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),

          ///
          /// Second row
          ///
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///
              /// ISO
              ///
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        alignment: Alignment.centerRight,
                        child: const Text(
                          'ISO',
                          style: TextStyle(fontSize: 14),
                        ),
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
                        child: Watch((context) {
                          var allIsos = switch (nodal.getAllIsos.value) {
                            AsyncData<Set<String>> data => data.value,
                            _ => <String>{},
                          };
                          return AutocompleteUi(
                            selection: signal(''),
                            choices: allIsos,
                            accumulatedSelection: nodal.isos,
                            width: 150,
                            key: UniqueKey(),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 60,
                      ),
                      SizedBox(
                        width: 150,
                        child: Watch((context) {
                          return Wrap(
                              direction: Axis.vertical,
                              spacing: 5.0,
                              children: List.generate(nodal.isos.value.length,
                                  (index) {
                                return InputChip(
                                  label: Text(nodal.isos.value[index]),
                                  backgroundColor: Colors.purple.shade50,
                                  side: BorderSide.none,
                                  onDeleted: () {
                                    var aux = [...nodal.isos.value];
                                    aux.removeAt(index);
                                    nodal.isos.value = aux;
                                  },
                                );
                              }));
                        }),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                width: 36,
              ),

              ///
              /// Location
              ///
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 60,
                        alignment: Alignment.centerRight,
                        child: const Text(
                          'Location',
                          style: TextStyle(fontSize: 14),
                        ),
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
                        child: Watch((context) {
                          var allLocations =
                              switch (nodal.getAllLocations.value) {
                            AsyncData<Set<String>> data => data.value,
                            _ => <String>{},
                          };
                          return AutocompleteUi(
                            selection: signal(''),
                            choices: allLocations,
                            accumulatedSelection: nodal.locations,
                            width: 150,
                            key: UniqueKey(),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 60,
                      ),
                      SizedBox(
                        width: 150,
                        child: Watch((context) {
                          return Wrap(
                              direction: Axis.vertical,
                              spacing: 5.0,
                              children: List.generate(
                                  nodal.locations.value.length, (index) {
                                return InputChip(
                                  label: Text(nodal.locations.value[index]),
                                  backgroundColor: Colors.purple.shade50,
                                  side: BorderSide.none,
                                  onDeleted: () {
                                    var aux = [...nodal.locations.value];
                                    aux.removeAt(index);
                                    nodal.locations.value = aux;
                                  },
                                );
                              }));
                        }),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                width: 36,
              ),

              ///
              /// Strip
              ///
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        alignment: Alignment.centerRight,
                        child: const Text(
                          'Strip',
                          style: TextStyle(fontSize: 14),
                        ),
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
                        child: Watch((context) {
                          var allStrips = switch (nodal.getAllStrips.value) {
                            AsyncData<Set<String>> data => data.value,
                            _ => <String>{},
                          };
                          return AutocompleteUi(
                            selection: signal(''),
                            choices: allStrips,
                            accumulatedSelection: nodal.strips,
                            width: 150,
                            key: UniqueKey(),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 40,
                      ),
                      SizedBox(
                        width: 150,
                        child: Watch((context) {
                          return Wrap(
                              direction: Axis.vertical,
                              spacing: 5.0,
                              children: List.generate(nodal.strips.value.length,
                                  (index) {
                                return InputChip(
                                  label: Text(nodal.strips.value[index]),
                                  backgroundColor: Colors.purple.shade50,
                                  side: BorderSide.none,
                                  onDeleted: () {
                                    var aux = [...nodal.strips.value];
                                    aux.removeAt(index);
                                    nodal.strips.value = aux;
                                  },
                                );
                              }));
                        }),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                width: 36,
              ),

              ///
              /// Bucket
              ///
              Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        alignment: Alignment.centerRight,
                        child: const Text(
                          'Bucket',
                          style: TextStyle(fontSize: 14),
                        ),
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
                        child: Watch((context) {
                          var allBuckets = switch (nodal.getAllBuckets.value) {
                            AsyncData<Set<String>> data => data.value,
                            _ => <String>{},
                          };
                          return AutocompleteUi(
                            selection: signal(''),
                            choices: allBuckets,
                            accumulatedSelection: nodal.buckets,
                            width: 150,
                            key: UniqueKey(),
                          );
                        }),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: 50,
                      ),
                      SizedBox(
                        width: 150,
                        child: Watch((context) {
                          return Wrap(
                              direction: Axis.vertical,
                              spacing: 5.0,
                              children: List.generate(
                                  nodal.buckets.value.length, (index) {
                                return InputChip(
                                  label: Text(nodal.buckets.value[index]),
                                  backgroundColor: Colors.purple.shade50,
                                  side: BorderSide.none,
                                  onDeleted: () {
                                    var aux = [...nodal.buckets.value];
                                    aux.removeAt(index);
                                    nodal.buckets.value = aux;
                                  },
                                );
                              }));
                        }),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                width: 36,
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),

          const SizedBox(
            height: 24,
          ),

          ///
          /// Table
          ///
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Watch((context) {
                switch (nodal.rows.value) {
                  // ignore: unused_local_variable
                  case AsyncData<List<Map<String, dynamic>>> data:
                    return updateTable();
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

  Widget updateTable() {
    var xs = nodal.filterRows(
      tradeKind: nodal.tradeKind.value,
      isos: nodal.isos.value.toSet(),
      locations: nodal.locations.value.toSet(),
      strips: nodal.strips.value.toSet(),
      buckets: nodal.buckets.value.toSet(),
    );
    const pageSize = 12;
    var indStart = nodal.pageNumber.value * pageSize;
    var indEnd = min((nodal.pageNumber.value + 1) * pageSize, xs.length);

    var summary = 'Found ${xs.length} trade';
    if (xs.length != 1) {
      summary += 's';
    }
    if (xs.isNotEmpty) {
      summary += '. Showing trades ${indStart + 1}-$indEnd.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Tooltip(
              message: 'Copy to clipboard',
              child: IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.content_copy,
                    color: Color.fromRGBO(103, 80, 164, 1.0),
                  )),
            ),
          ],
        ),
        Text(
          // contents,
          table.Table.from(xs.sublist(indStart, indEnd),
              options: {'columnSeparation': '  '}).toString(),
          style: const TextStyle(fontSize: 14, fontFamily: 'UbuntuMono'),
          maxLines: 30,
        ),
        Row(
          children: [
            Text(
              summary,
              style: const TextStyle(
                  fontStyle: FontStyle.italic,
                  color: Color.fromRGBO(103, 80, 164, 0.9)),
            ),
            IconButton(
                onPressed: () {
                  setState(() {
                    nodal.pageNumber.value = 0;
                  });
                },
                icon: const Icon(
                  Icons.skip_previous,
                  color: Color.fromRGBO(103, 80, 164, 0.9),
                )),
            IconButton(
                onPressed: () {
                  setState(() {
                    nodal.pageNumber.value = max(0, nodal.pageNumber.value - 1);
                  });
                },
                icon: const Icon(
                  Icons.navigate_before,
                  color: Color.fromRGBO(103, 80, 164, 0.9),
                )),
            IconButton(
                onPressed: () {
                  setState(() {
                    nodal.pageNumber.value =
                        min(xs.length ~/ 30, nodal.pageNumber.value + 1);
                  });
                },
                icon: const Icon(
                  Icons.navigate_next,
                  color: Color.fromRGBO(103, 80, 164, 0.9),
                )),
            IconButton(
                onPressed: () {
                  setState(() {
                    nodal.pageNumber.value = xs.length ~/ 30;
                  });
                },
                icon: const Icon(
                  Icons.skip_next,
                  color: Color.fromRGBO(103, 80, 164, 0.9),
                )),
          ],
        ),
      ],
    );
  }
}
