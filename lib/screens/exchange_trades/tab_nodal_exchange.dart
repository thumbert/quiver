library screens.exchange_trades.tab_nodal_exchange;

import 'package:flutter/material.dart';
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
  late void Function() updateLocations;
  late void Function() updateStrips;
  late void Function() updateBuckets;

  @override
  void initState() {
    super.initState();
    var aux = DateTime.now().hashCode;
    plotly = Plotly(
      viewId: 'plotly-nodal-exchange-$aux',
      data: const [],
      layout: nodal.layout,
    );

    /// NOTE: Need to register this effect here!
    /// After [allLocations] change, reset [selectedLocations] and [tempSelectionLocation]
    updateLocations = effect(() {
      nodal.selectedLocations.value = {...nodal.allLocations.value};
      nodal.tempSelectionLocation.value = {...nodal.allLocations.value};
      // Need to setState below to update the location dropdown!
      setState(() {});
    });
    updateStrips = effect(() {
      nodal.selectedStrips.value = {...nodal.allStrips.value};
      nodal.tempSelectionStrip.value = {...nodal.allStrips.value};
      // Need to setState below to update the strip dropdown!
      setState(() {});
    });
    updateBuckets = effect(() {
      nodal.selectedBuckets.value = {...nodal.allBuckets.value};
      nodal.tempSelectionBucket.value = {...nodal.allBuckets.value};
      // Need to setState below to update the strip dropdown!
      setState(() {});
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
    var xs = nodal.filterRows(nodal.rows.requireValue);
    var contents = [for (var row in xs) row.toString()].join('\n');
    return Text(contents);
  }
}
