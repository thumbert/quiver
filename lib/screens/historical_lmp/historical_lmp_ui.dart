import 'dart:math';

import 'package:elec/risk_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quiver/screens/common/signal/autocomplete2.dart';
import 'package:flutter_quiver/models/historical_lmp_model.dart';
import 'package:flutter_quiver/screens/common/signal/dropdown2.dart';
import 'package:flutter_quiver/screens/common/signal/term2.dart';
import 'package:flutter_quiver/utils/empty_download.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:intl/intl.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:table/table_base.dart' as table;
import 'package:timeseries/timeseries.dart';

class HistoricalLmp extends StatefulWidget {
  const HistoricalLmp({super.key});
  static const route = '/historical_lmp_ui';
  @override
  State<HistoricalLmp> createState() => _State();
}

class _State extends State<HistoricalLmp> {
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
      layout: state.value.layout(),
    );
  }

  @override
  void dispose() {
    scrollControllerV.dispose();
    scrollControllerH.dispose();
    //     controllerLocationSink.dispose();
    // focusNodeLocationSink.dispose();
    // controllerLocationSource.dispose();
    // focusNodeLocationSource.dispose();
    // controllerTerm.dispose();
    // focusNodeTerm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Historical LMP, congestion, spreads'),
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
                              'Calculate historical monthly LMP data and spreads.'
                              'Only selected ISOs are currently supported.\n\n'
                              'To calculate a spread, populate the Source row '
                              'and the values calculated in the tables are the '
                              'monthly averages of the Sink - Source values.\n\n'
                              'The Loss% for a node is calculated relative to the '
                              'reference location in that region.  For example, '
                              'in ISONE the reference location is MassHub, in NYISO it is the ptid: 24008, '
                              'I need to find the reference location for PJM!\n\n'),
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
                  child: Watch(
                    (context) => Column(
                      spacing: 6,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// column header
                        const Row(
                          spacing: 12,
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text(''),
                            ),
                            SizedBox(
                              width: 100,
                              child: Text(
                                'Region',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.purple),
                              ),
                            ),
                            SizedBox(
                              width: 300,
                              child: Text(
                                'Location',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.purple),
                              ),
                            ),
                            SizedBox(
                              width: 70,
                              child: Text(
                                'Market',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.purple),
                              ),
                            ),
                          ],
                        ),

                        /// sink row
                        Row(
                          spacing: 12,
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text(
                                'Sink',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.purple),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const LocationRowSinkWidget(),
                          ],
                        ),

                        /// source row
                        Row(
                          spacing: 12,
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text(
                                'Source',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.purple),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            const LocationRowSourceWidget(),
                          ],
                        ),

                        /// buckets row
                        Row(
                          spacing: 12,
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text(
                                'Buckets',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.purple),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Container(
                                width: 220,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade50,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: DropdownUi2<HistoricalLmpModel>(
                                    model: state,
                                    width: 220,
                                    choices: HistoricalLmpModel.allBuckets.keys
                                        .toSet(),
                                    getSelection: (HistoricalLmpModel model) =>
                                        model.bucketNames,
                                    setSelection: (String value) {
                                      final current = state.value;
                                      state.value = HistoricalLmpModel(
                                        sink: current.sink,
                                        source: current.source,
                                        bucketNames: value,
                                        lmpComponent: current.lmpComponent,
                                        historicalTerm: current.historicalTerm,
                                        timeAggregation:
                                            current.timeAggregation,
                                      );
                                    })),
                          ],
                        ),

                        /// lmp component row
                        Row(
                          spacing: 12,
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text(
                                'LMP Component',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.purple),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Container(
                                width: 220,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade50,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: DropdownUi2<HistoricalLmpModel>(
                                    model: state,
                                    width: 220,
                                    choices: HistoricalLmpModel
                                        .allLmpComponents.keys
                                        .toSet(),
                                    getSelection: (HistoricalLmpModel model) =>
                                        model.lmpComponent,
                                    setSelection: (String value) {
                                      final current = state.value;
                                      state.value = HistoricalLmpModel(
                                        sink: current.sink,
                                        source: current.source,
                                        bucketNames: current.bucketNames,
                                        lmpComponent: value,
                                        historicalTerm: current.historicalTerm,
                                        timeAggregation:
                                            current.timeAggregation,
                                      );
                                    })),
                          ],
                        ),

                        /// historical term + time aggregation row
                        Row(
                          spacing: 12,
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text(
                                'Historical Term',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.purple),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Container(
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade50,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: TermUi(
                                model: state,
                                setTerm: (term) {
                                  final current = state.value;
                                  state.value = HistoricalLmpModel(
                                    sink: current.sink,
                                    source: current.source,
                                    bucketNames: current.bucketNames,
                                    lmpComponent: current.lmpComponent,
                                    historicalTerm: term,
                                    timeAggregation: current.timeAggregation,
                                  );
                                },
                                getTerm: (model) => model.historicalTerm,
                              ),
                            ),
                            SizedBox(
                              width: 150,
                              child: Text(
                                'Time aggregation',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.purple),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Container(
                                width: 170,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey.shade50,
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: DropdownUi2<HistoricalLmpModel>(
                                    model: state,
                                    width: 170,
                                    choices: HistoricalLmpModel
                                        .allTimeAggregations
                                        .toSet(),
                                    getSelection: (HistoricalLmpModel model) =>
                                        model.timeAggregation,
                                    setSelection: (String value) {
                                      final current = state.value;
                                      state.value = HistoricalLmpModel(
                                        sink: current.sink,
                                        source: current.source,
                                        bucketNames: current.bucketNames,
                                        lmpComponent: current.lmpComponent,
                                        historicalTerm: current.historicalTerm,
                                        timeAggregation: value,
                                      );
                                    })),
                          ],
                        ),

                        /// plot
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 12,
                            ),
                            Watch((context) {
                              switch (hourlyLmp.value) {
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

  Widget updatePlotAndTable(TimeSeries<num> ts) {
    var xs = state.value.aggregateData(ts);
    var tables = state.value.makeTables(xs);
    var fmt = state.value.lmpComponent == 'Loss%' ? _fmtPercent : _fmt2;

    var traces = state.value.makeTraces(xs);
    plotly.react(traces, state.value.layout(), plotly.config);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (traces.isNotEmpty)
          SizedBox(width: 1000, height: 600, child: plotly),
        const SizedBox(
          height: 16,
        ),
        ...[
          for (var e in tables.entries)
            _makeTable(e.value, e.key, fmt, state.value)
        ],
      ],
    );
  }

  Widget _makeTable(List<Map<String, dynamic>> data, String bucketName,
      NumberFormat fmt, HistoricalLmpModel state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              bucketName,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
            ),
            const SizedBox(
              width: 48,
            ),
            Row(
              children: [
                IconButton(
                    onPressed: () {
                      Clipboard.setData(
                          ClipboardData(text: table.Table.from(data).toCsv()));
                    },
                    tooltip: 'Copy',
                    icon: const Icon(
                      Icons.content_copy,
                      color: Colors.grey,
                    )),
                IconButton(
                    onPressed: () {
                      downloadTableToCsv(data, bucketName);
                    },
                    tooltip: 'Download',
                    icon: const Icon(
                      Icons.download_outlined,
                      color: Colors.grey,
                    ))
              ],
            )
          ],
        ),
        state.timeAggregation == 'Monthly'
            ? DataTable(
                columnSpacing: 18,
                columns: _makeColumns(state),
                rows: _makeRows(data, fmt, state),
              )
            : LimitedBox(
                maxWidth: 400,
                child: PaginatedDataTable(
                  columnSpacing: 18,
                  columns: _makeColumns(state),
                  rowsPerPage: min(31, data.length),
                  showFirstLastButtons: true,
                  source: _DataTableSource(data, state.getColumns(), state),
                ),
              ),
        const SizedBox(
          height: 12,
        ),
      ],
    );
  }

  Future<void> downloadTableToCsv(
      List<Map<String, dynamic>> data, String bucketName) async {
    var tbl = table.Table.from(data);
    download(tbl.toCsv().codeUnits,
        downloadName: 'historical_lmp_$bucketName.csv');
  }

  List<DataColumn> _makeColumns(HistoricalLmpModel state) {
    var out = <DataColumn>[];
    var columns = state.getColumns();
    if (state.timeAggregation == 'Monthly') {
      for (var column in columns) {
        out.add(DataColumn(
            numeric: true,
            label: Text(column,
                style: const TextStyle(fontWeight: FontWeight.bold))));
      }
    } else if (state.timeAggregation == 'Daily') {
      out.add(DataColumn(
          label: Text(columns.first,
              style: const TextStyle(fontWeight: FontWeight.bold))));
      for (var column in columns.skip(1)) {
        out.add(DataColumn(
            numeric: true,
            label: Text(column,
                style: const TextStyle(fontWeight: FontWeight.bold))));
      }
    } else if (state.timeAggregation == 'Hourly') {
      out.add(DataColumn(
          label: Text(columns.first,
              style: const TextStyle(fontWeight: FontWeight.bold))));
      for (var column in columns.skip(1)) {
        out.add(DataColumn(
            numeric: true,
            label: Text(column,
                style: const TextStyle(fontWeight: FontWeight.bold))));
      }
    }
    return out;
  }

  List<DataRow> _makeRows(List<Map<String, dynamic>> data, NumberFormat fmt,
      HistoricalLmpModel state) {
    var out = <DataRow>[];
    var columns = state.getColumns();
    if (state.timeAggregation == 'Monthly') {
      for (var row in data) {
        var cells = <DataCell>[DataCell(Text(row['Year'].toString()))];
        for (var col in columns.skip(1)) {
          if (row.containsKey(col)) {
            cells.add(DataCell(Text(fmt.format(row[col]))));
          } else {
            cells.add(const DataCell(Text('')));
          }
        }
        out.add(DataRow(cells: cells));
      }
      //
      //
    } else if (state.timeAggregation == 'Daily') {
      for (var row in data) {
        var cells = <DataCell>[DataCell(Text(row['Date'].toString()))];
        for (var col in columns.skip(1)) {
          if (row.containsKey(col)) {
            cells.add(DataCell(Text(fmt.format(row[col]))));
          } else {
            cells.add(const DataCell(Text('')));
          }
        }
        out.add(DataRow(cells: cells));
      }
    }
    return out;
  }

  final _fmt2 = NumberFormat.currency(decimalDigits: 2, symbol: '');
  final _fmtPercent = NumberFormat.decimalPercentPattern(decimalDigits: 2);
}

class LocationRowSinkWidget extends StatefulWidget {
  const LocationRowSinkWidget({super.key});
  @override
  State<LocationRowSinkWidget> createState() => _LocationRowSinkWidgetState();
}

class _LocationRowSinkWidgetState extends State<LocationRowSinkWidget> {
  @override
  void initState() {
    super.initState();
    // LocationRow.populatePtidCache('IESO');
  }

  @override
  Widget build(BuildContext context) {
    return Watch(
      (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                ///
                /// Region
                ///
                Container(
                    width: 100,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: DropdownUi2<HistoricalLmpModel>(
                        model: state,
                        width: 70,
                        choices: HistoricalLmpModel.regionDefaults.keys.toSet(),
                        getSelection: (HistoricalLmpModel model) =>
                            model.sink.region,
                        setSelection: (String value) {
                          final current = state.value;
                          state.value = HistoricalLmpModel(
                            sink: LocationRow(
                              region: value,
                              location: current.sink.location,
                              market: current.sink.market,
                            ),
                            source: current.source,
                            bucketNames: current.bucketNames,
                            lmpComponent: current.lmpComponent,
                            historicalTerm: current.historicalTerm,
                            timeAggregation: current.timeAggregation,
                          );
                        })),

                ///
                /// Location
                ///
                Container(
                  width: 300,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Watch((_) => switch (locationsSink.value) {
                        AsyncData<List<String>>() => AutocompleteUi(
                            model: state,
                            getSelection: (HistoricalLmpModel model) =>
                                model.sink.location,
                            setSelection: (String value) {
                              final current = state.value;
                              state.value = HistoricalLmpModel(
                                sink: LocationRow(
                                  region: current.sink.region,
                                  location: value,
                                  market: current.sink.market,
                                ),
                                source: current.source,
                                bucketNames: current.bucketNames,
                                lmpComponent: current.lmpComponent,
                                historicalTerm: current.historicalTerm,
                                timeAggregation: current.timeAggregation,
                              );
                            },
                            choices: LocationRow
                                .ptidCache[state.value.sink.region]!
                                .toSet(),
                            width: 300,
                            key: ValueKey(state.value.sink
                                .location), // needed to wipe the textfield on icon clear
                          ),
                        AsyncError<List<String>>() => Row(children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            Text(
                              'Error getting location data for region ${state.value.sink.region}',
                              style: const TextStyle(fontSize: 16),
                            )
                          ]),
                        AsyncLoading<List<String>>() => const Center(
                            child: CircularProgressIndicator(),
                          ),
                      }),
                ),

                ///
                /// Market
                ///
                Container(
                    width: 70,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: DropdownUi2<HistoricalLmpModel>(
                        model: state,
                        width: 70,
                        choices: {'DA', 'RT'},
                        getSelection: (HistoricalLmpModel model) =>
                            model.sink.market!.name,
                        setSelection: (String value) {
                          final current = state.value;
                          state.value = HistoricalLmpModel(
                            sink: LocationRow(
                              region: current.sink.region,
                              location: current.sink.location,
                              market: Market.parse(value),
                            ),
                            source: current.source,
                            bucketNames: current.bucketNames,
                            lmpComponent: current.lmpComponent,
                            historicalTerm: current.historicalTerm,
                            timeAggregation: current.timeAggregation,
                          );
                        })),
              ]),
        ],
      ),
    );
  }
}

class LocationRowSourceWidget extends StatefulWidget {
  const LocationRowSourceWidget({super.key});
  @override
  State<LocationRowSourceWidget> createState() =>
      _LocationRowSourceWidgetState();
}

class _LocationRowSourceWidgetState extends State<LocationRowSourceWidget> {
  @override
  Widget build(BuildContext context) {
    return Watch(
      (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                ///
                /// Region
                ///
                Container(
                    width: 100,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: DropdownUi2<HistoricalLmpModel>(
                        model: state,
                        width: 70,
                        choices: HistoricalLmpModel.regionDefaults.keys.toSet(),
                        getSelection: (HistoricalLmpModel model) =>
                            model.source?.region,
                        setSelection: (String value) {
                          final current = state.value;
                          state.value = HistoricalLmpModel(
                            sink: current.sink,
                            source: LocationRow(
                              region: value,
                              location: HistoricalLmpModel
                                  .regionDefaults[value]!['location'],
                              market: Market.parse(HistoricalLmpModel
                                  .regionDefaults[value]!['dart']!),
                            ),
                            bucketNames: current.bucketNames,
                            lmpComponent: current.lmpComponent,
                            historicalTerm: current.historicalTerm,
                            timeAggregation: current.timeAggregation,
                          );
                        })),

                ///
                /// Location
                ///
                Container(
                  width: 300,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Watch((_) => switch (locationsSource.value) {
                        AsyncData<List<String>>() => AutocompleteUi(
                            model: state,
                            getSelection: (HistoricalLmpModel model) =>
                                model.source?.location,
                            setSelection: (String value) {
                              final current = state.value;
                              state.value = HistoricalLmpModel(
                                sink: current.sink,
                                source: LocationRow(
                                  region: current.source?.region,
                                  location: value,
                                  market: current.sink.market,
                                ),
                                bucketNames: current.bucketNames,
                                lmpComponent: current.lmpComponent,
                                historicalTerm: current.historicalTerm,
                                timeAggregation: current.timeAggregation,
                              );
                            },
                            choices: state.value.source?.region != null
                                ? LocationRow
                                    .ptidCache[state.value.source?.region]!
                                    .toSet()
                                : <String>{},
                            width: 300,
                            key: ValueKey(state.value.source
                                ?.location), // needed to wipe the textfield on icon clear
                          ),
                        AsyncError<List<String>>() => Row(children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            Text(
                              'Error getting location data for region ${state.value.source?.region}',
                              style: const TextStyle(fontSize: 16),
                            )
                          ]),
                        AsyncLoading<List<String>>() => const Center(
                            child: CircularProgressIndicator(),
                          ),
                      }),

                  // child: Watch((_) => switch (locations.value) {
                  //       AsyncData<List<String>>() => AutocompleteUi(
                  //           model: state,
                  //           getSelection: (HistoricalLmpModel model) =>
                  //               model.sink.location,
                  //           setSelection: (String value) {
                  //             final current = state.value;
                  //             state.value = HistoricalLmpModel(
                  //               sink: current.sink,
                  //               source: LocationRow(
                  //                 region: current.source?.region,
                  //                 location: value,
                  //                 market: current.source?.market,
                  //               ),
                  //               buckets: current.buckets,
                  //               lmpComponent: current.lmpComponent,
                  //               historicalTerm: current.historicalTerm,
                  //               timeAggregation: current.timeAggregation,
                  //             );
                  //           },
                  //           choices: LocationRow
                  //               .ptidCache[state.value.source?.region]!
                  //               .toSet(),
                  //           width: 300,
                  //           key: ValueKey(state.value.source
                  //               ?.location), // needed to wipe the textfield on icon clear
                  //         ),
                  //       AsyncError<List<String>>() => Row(children: [
                  //           const Icon(Icons.error_outline, color: Colors.red),
                  //           Text(
                  //             'Error getting location data for region ${state.value.source?.region}',
                  //             style: const TextStyle(fontSize: 16),
                  //           )
                  //         ]),
                  //       AsyncLoading<List<String>>() => const Center(
                  //           child: CircularProgressIndicator(),
                  //         ),
                  //     }),
                ),

                ///
                /// Market
                ///
                Container(
                    width: 70,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: DropdownUi2<HistoricalLmpModel>(
                        model: state,
                        width: 70,
                        choices: {'DA', 'RT'},
                        getSelection: (HistoricalLmpModel model) =>
                            model.source?.market?.name,
                        setSelection: (String value) {
                          final current = state.value;
                          state.value = HistoricalLmpModel(
                            sink: current.sink,
                            source: LocationRow(
                              region: current.source?.region,
                              location: current.source?.location,
                              market: Market.parse(value),
                            ),
                            bucketNames: current.bucketNames,
                            lmpComponent: current.lmpComponent,
                            historicalTerm: current.historicalTerm,
                            timeAggregation: current.timeAggregation,
                          );
                        })),

                SizedBox(
                    height: 36,
                    child: IconButton(
                      padding: const EdgeInsets.all(0.0),
                      onPressed: () {
                        final current = state.value;
                        state.value = HistoricalLmpModel(
                          sink: current.sink,
                          source: LocationRow(
                            region: null,
                            location: null,
                            market: null,
                          ),
                          bucketNames: current.bucketNames,
                          lmpComponent: current.lmpComponent,
                          historicalTerm: current.historicalTerm,
                          timeAggregation: current.timeAggregation,
                        );
                      },
                      icon: const Icon(
                        Icons.close,
                        color: Colors.grey,
                      ),
                      tooltip: 'Clear the source row',
                    )),
              ]),
        ],
      ),
    );
  }
}

/// Daily data is paginated
class _DataTableSource extends DataTableSource {
  _DataTableSource(this.data, this.columns, this.state);

  final List<Map<String, dynamic>> data;
  final List<String> columns;
  final HistoricalLmpModel state;
  final _fmt2 = NumberFormat.currency(decimalDigits: 2, symbol: '');

  @override
  DataRow? getRow(int index) {
    var x = data[index];
    if (state.timeAggregation == 'Hourly') {
      return DataRow(cells: [
        DataCell(Text(x['HourBeginning'].toString())),
        DataCell(Text(_fmt2.format(x['Value'])))
      ]);
    }
    return DataRow(cells: [
      DataCell(Text(x['Date'].toString())),
      ...[
        for (var col in columns.skip(1))
          x.containsKey(col)
              ? DataCell(Text(_fmt2.format(x[col])))
              : const DataCell(Text(''))
      ]
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}
