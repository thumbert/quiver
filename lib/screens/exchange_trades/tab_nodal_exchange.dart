library screens.exchange_trades.tab_nodal_exchange;

import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:table/table_base.dart' as table;
import 'package:flutter_quiver/models/exchange_trades/nodal_model.dart'
    as nodal;
import 'package:flutter_quiver/screens/common/signal/date_field.dart';
import 'package:flutter_quiver/screens/common/signal/multiselect3.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:signals_flutter/signals_flutter.dart';

class TabNodalExchange extends StatefulWidget {
  const TabNodalExchange({super.key});
  @override
  State<TabNodalExchange> createState() => _State();
}

class _State extends State<TabNodalExchange> {
  late Plotly plotly;
  late void Function() updateIsos;
  late void Function() updateLocations;
  late void Function() updateStrips;
  late void Function() updateBuckets;

  late Set<String> previousIsos,
      previousLocations,
      previousStrips,
      previousBuckets;
  final equality = const SetEquality();

  @override
  void initState() {
    super.initState();
    previousIsos = nodal.selectedIsos.value;
    previousLocations = nodal.selectedLocations.value;
    previousStrips = nodal.selectedStrips.value;
    previousBuckets = nodal.selectedBuckets.value;

    updateIsos = effect(() {
      nodal.selectedIsos.value = {...nodal.allIsos.value};
      nodal.tempSelectionIso.value = {...nodal.allIsos.value};
      setState(() {});
    });

    /// NOTE: Need to register this effect here!
    /// After [allLocations] change, reset [selectedLocations] and [tempSelectionLocation]
    updateLocations = effect(() {
      // only update the locations if the isos actually change
      if (!equality.equals(previousIsos, nodal.selectedIsos.value)) {
        nodal.selectedLocations.value = {...nodal.allLocations.value};
        nodal.tempSelectionLocation.value = {...nodal.allLocations.value};
        setState(() {
          previousIsos = nodal.selectedIsos.value;
        });
      }
    });
    updateStrips = effect(() {
      // only update the strips if the locations actually change
      if (!equality.equals(previousLocations, nodal.selectedLocations.value)) {
        nodal.selectedStrips.value = {...nodal.allStrips.value};
        nodal.tempSelectionStrip.value = {...nodal.allStrips.value};
        // Need to setState below to update the strip dropdown!
        setState(() {
          previousLocations = nodal.selectedLocations.value;
        });
      }
    });
    updateBuckets = effect(() {
      // only update the buckets if the strips actually change
      if (!equality.equals(previousStrips, nodal.selectedStrips.value)) {
        nodal.selectedBuckets.value = {...nodal.allBuckets.value};
        nodal.tempSelectionBucket.value = {...nodal.allBuckets.value};
        // Need to setState below to update the strip dropdown!
        setState(() {
          previousStrips = nodal.selectedStrips.value;
        });
      }
    });
  }

  @override
  void dispose() {
    updateLocations();
    updateStrips();
    updateBuckets();
    super.dispose();
  }

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
            ],
          ),
          const SizedBox(
            height: 16,
          ),

          ///
          /// Second row
          ///
          Row(
            children: [
              const Text(
                'ISO',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(
                width: 8,
              ),
              Container(
                width: 160,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Watch((context) => MultiselectUi(
                    allValues: nodal.allIsos,
                    selectedValues: nodal.selectedIsos,
                    label: nodal.labelIsos,
                    temporarySelection: nodal.tempSelectionIso,
                    width: 160)),
              ),
              const SizedBox(
                width: 36,
              ),

              ///
              /// Location
              ///
              const Text(
                'Location',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(
                width: 8,
              ),
              Container(
                width: 250,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Watch((context) => MultiselectUi(
                    allValues: nodal.allLocations,
                    selectedValues: nodal.selectedLocations,
                    label: nodal.labelLocations,
                    temporarySelection: nodal.tempSelectionLocation,
                    width: 250)),
              ),
              const SizedBox(
                width: 36,
              ),

              ///
              /// Strip
              ///
              const Text(
                'Strip',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(
                width: 8,
              ),
              Container(
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Watch((context) => MultiselectUi(
                    allValues: nodal.allStrips,
                    selectedValues: nodal.selectedStrips,
                    label: nodal.labelStrips,
                    temporarySelection: nodal.tempSelectionStrip,
                    width: 200)),
              ),
              const SizedBox(
                width: 36,
              ),

              ///
              /// Bucket
              ///
              const Text(
                'Bucket',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(
                width: 8,
              ),
              Container(
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Watch((context) => MultiselectUi(
                    allValues: nodal.allBuckets,
                    selectedValues: nodal.selectedBuckets,
                    label: nodal.labelBuckets,
                    temporarySelection: nodal.tempSelectionBucket,
                    width: 200)),
              ),
              const SizedBox(
                width: 36,
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),

          ///
          /// TradeKind
          ///
          Row(
            children: [
              //
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
      isos: nodal.selectedIsos.value,
      locations: nodal.selectedLocations.value,
      strips: nodal.selectedStrips.value,
      buckets: nodal.selectedBuckets.value,
    );
    const pageSize = 6;
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
