import 'package:elec/elec.dart';
import 'package:elec/risk_system.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_quiver/models/ftr_path/ftr_path_model.dart';
import 'package:flutter_quiver/models/historical_lmp_model.dart'
    show LocationRow;
import 'package:flutter_quiver/screens/common/signal/autocomplete2.dart';
import 'package:flutter_quiver/screens/common/signal/dropdown2.dart';
import 'package:flutter_quiver/screens/common/signal/term2.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:timeseries/timeseries.dart';

class FtrPath extends StatefulWidget {
  const FtrPath({super.key});

  static const String route = '/ftr_path_analysis';

  @override
  State<FtrPath> createState() => _FtrPathState();
}

class _FtrPathState extends State<FtrPath> {
  late Plotly plotly;
  final scrollControllerV = ScrollController();
  final scrollControllerH = ScrollController();

  @override
  void initState() {
    super.initState();

    var aux = DateTime.now().hashCode;
    plotly = Plotly(
      viewId: 'plotly-hist-lmp-$aux',
      traces: const [],
      layout: model.value.layout,
    );
  }

  @override
  void dispose() {
    scrollControllerV.dispose();
    scrollControllerH.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('FTR path analysis'),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const SimpleDialog(
                        contentPadding: EdgeInsets.all(12),
                        children: [
                          Text('Visualize the congestion associated with an '
                              'FTR path, display the clearing prices and the settled prices '
                              'for a recent set of auctions, and the relevant binding constraints.\n'),
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
          child: SizedBox(
            width: 3000.0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                  padding: const EdgeInsets.only(top: 12.0, left: 12.0),
                  child: SignalBuilder(
                    builder: (context) => Column(
                      spacing: 6,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// labels row
                        const Row(
                          spacing: 12,
                          children: [
                            SizedBox(
                              width: 100,
                              child: Text(
                                'Region',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            SizedBox(
                              width: 300,
                              child: Text(
                                'Source/From',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            SizedBox(
                              width: 300,
                              child: Text(
                                'Sink/To',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                'Bucket',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                            // SizedBox(
                            //   width: 80,
                            //   child: Text(
                            //     'Market',
                            //     style: TextStyle(fontSize: 14),
                            //   ),
                            // ),
                            SizedBox(
                              width: 150,
                              child: Text(
                                'Historical Term',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),

                        /// inputs row
                        Row(
                          spacing: 12,
                          children: [
                            /// Region
                            Container(
                                width: 100,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: DropdownUi2<FtrPathAnalysisModel>(
                                    model: model,
                                    width: 70,
                                    choices: FtrPathAnalysisModel
                                        .regionDefaults.keys
                                        .toSet(),
                                    getSelection:
                                        (FtrPathAnalysisModel model) =>
                                            model.iso.name,
                                    setSelection: (String value) {
                                      final current = model.value;
                                      model.value = FtrPathAnalysisModel(
                                        iso: FtrPathAnalysisModel
                                            .regionDefaults[value]!.iso,
                                        sourceLocation: current.sourceLocation,
                                        sinkLocation: current.sinkLocation,
                                        bucket: current.bucket,
                                        market: current.market,
                                        term: current.term,
                                      );
                                    })),

                            ///
                            /// Source location
                            ///
                            Container(
                              width: 300,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: SignalBuilder(builder: (_) => switch (locations.value) {
                                    AsyncData<List<String>>() => AutocompleteUi(
                                        model: model,
                                        getSelection:
                                            (FtrPathAnalysisModel model) =>
                                                model.sourceLocation,
                                        setSelection: (String value) {
                                          final current = model.value;
                                          model.value = FtrPathAnalysisModel(
                                            iso: current.iso,
                                            sourceLocation: value,
                                            sinkLocation: current.sinkLocation,
                                            bucket: current.bucket,
                                            market: current.market,
                                            term: current.term,
                                          );
                                        },
                                        choices: LocationRow
                                            .ptidCache[model.value.iso.name]!
                                            .toSet(),
                                        width: 300,
                                        key: ValueKey(model.value
                                            .sourceLocation), // needed to wipe the textfield on icon clear
                                      ),
                                    AsyncError<List<String>>() =>
                                      Row(children: [
                                        const Icon(Icons.error_outline,
                                            color: Colors.red),
                                        Text(
                                          'Error getting location data for region ${model.value.iso.name}',
                                          style: const TextStyle(fontSize: 16),
                                        )
                                      ]),
                                    AsyncLoading<List<String>>() =>
                                      const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                  }),
                            ),

                            ///
                            /// Sink location
                            ///
                            Container(
                              width: 300,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: SignalBuilder(builder: (_) => switch (locations.value) {
                                    AsyncData<List<String>>() => AutocompleteUi(
                                        model: model,
                                        getSelection:
                                            (FtrPathAnalysisModel model) =>
                                                model.sinkLocation,
                                        setSelection: (String value) {
                                          final current = model.value;
                                          model.value = FtrPathAnalysisModel(
                                            iso: current.iso,
                                            sourceLocation:
                                                current.sourceLocation,
                                            sinkLocation: value,
                                            bucket: current.bucket,
                                            market: current.market,
                                            term: current.term,
                                          );
                                        },
                                        choices: LocationRow
                                            .ptidCache[model.value.iso.name]!
                                            .toSet(),
                                        width: 300,
                                        key: ValueKey(model.value
                                            .sourceLocation), // needed to wipe the textfield on icon clear
                                      ),
                                    AsyncError<List<String>>() =>
                                      Row(children: [
                                        const Icon(Icons.error_outline,
                                            color: Colors.red),
                                        Text(
                                          'Error getting location data for region ${model.value.iso.name}',
                                          style: const TextStyle(fontSize: 16),
                                        )
                                      ]),
                                    AsyncLoading<List<String>>() =>
                                      const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                  }),
                            ),

                            /// Bucket
                            Container(
                                width: 100,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade100,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: DropdownUi2<FtrPathAnalysisModel>(
                                    model: model,
                                    width: 100,
                                    choices: {'5x16', 'Offpeak'},
                                    getSelection:
                                        (FtrPathAnalysisModel model) =>
                                            model.bucket.name,
                                    setSelection: (String value) {
                                      final current = model.value;
                                      model.value = FtrPathAnalysisModel(
                                        iso: current.iso,
                                        sourceLocation: current.sourceLocation,
                                        sinkLocation: current.sinkLocation,
                                        bucket: Bucket.parse(value),
                                        market: current.market,
                                        term: current.term,
                                      );
                                    })),

                            // /// Market
                            // Container(
                            //     width: 80,
                            //     height: 36,
                            //     decoration: BoxDecoration(
                            //       color: Colors.amber.shade100,
                            //       borderRadius: BorderRadius.circular(4.0),
                            //     ),
                            //     child: DropdownUi2<FtrPathAnalysisModel>(
                            //         model: model,
                            //         width: 80,
                            //         choices: {'DA', 'RT'},
                            //         getSelection:
                            //             (FtrPathAnalysisModel model) =>
                            //                 model.market.name,
                            //         setSelection: (String value) {
                            //           final current = model.value;
                            //           model.value = FtrPathAnalysisModel(
                            //             iso: current.iso,
                            //             sourceLocation: current.sourceLocation,
                            //             sinkLocation: current.sinkLocation,
                            //             bucket: current.bucket,
                            //             market: Market.parse(value),
                            //             term: current.term,
                            //           );
                            //         })),

                            /// Historical term
                            Container(
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.amber.shade100,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: TermUi(
                                model: model,
                                setTerm: (term) {
                                  final current = model.value;
                                  model.value = FtrPathAnalysisModel(
                                    iso: current.iso,
                                    sourceLocation: current.sourceLocation,
                                    sinkLocation: current.sinkLocation,
                                    bucket: current.bucket,
                                    market: current.market,
                                    term: term,
                                  );
                                },
                                getTerm: (model) => model.term,
                              ),
                            ),
                          ],
                        ),

                        /// plot
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 12,
                            ),
                            SignalBuilder(builder: (context) {
                              switch (dailyLmp.value) {
                                // ignore: unused_local_variable
                                case AsyncData<TimeSeries<num>> data:
                                  return updatePlotAndTable(data.value);
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                          height: 24,
                        ),
                      ],
                    ),
                  )),
            ),
          ),
        ));
  }

  Widget updatePlotAndTable(TimeSeries<num> dailyTs) {
    // var xs = model.value.aggregateData(ts);
    // var tables = state.value.makeTables(xs);

    var traces = <Map<String, dynamic>>[
      {
        'x': dailyTs.intervals.map((e) => e.start.toString()).toList(),
        'y': dailyTs.values.toList(),
        'type': 'bar',
      }
    ];
    plotly.react(traces, model.value.layout, plotly.config);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 1000, height: 600, child: plotly),
        const SizedBox(
          height: 16,
        ),
        // ...[
        //   for (var e in tables.entries)
        //     _makeTable(e.value, e.key, fmt, state.value)
        // ],
      ],
    );
  }
}
