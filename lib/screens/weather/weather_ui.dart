library screens.weather.weather_ui;

import 'package:elec/risk_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/weather/weather_model.dart';
import 'package:flutter_quiver/screens/weather/instrument_rows.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WeatherUi extends StatefulWidget {
  const WeatherUi({Key? key}) : super(key: key);

  @override
  _WeatherUiState createState() => _WeatherUiState();
}

class _WeatherUiState extends State<WeatherUi> {
  var fmt = NumberFormat.currency(decimalDigits: 0, symbol: '\$');
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<WeatherModel>();
    return Padding(
        padding: const EdgeInsets.only(left: 48),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Weather UI'),
            actions: [
              IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const SimpleDialog(
                          children: [
                            Text(
                                'Price weather instruments and get quick historical stats on weather indices.'),
                          ],
                          contentPadding: EdgeInsets.all(12),
                        );
                      });
                },
                icon: const Icon(Icons.info_outline),
                tooltip: 'Info',
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 8.0),
            child: Scrollbar(
              controller: _scrollController,
              isAlwaysShown: true,
              child: ListView(
                controller: _scrollController,
                children: [
                  Row(
                    children: const [
                      InstrumentRows(),
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  // FutureBuilder(
                  //   future: model.make30YearTable(),
                  //   builder: (context, snapshot) {
                  //     List<Widget> children;
                  //     if (snapshot.hasData) {
                  //       AssetAutocompleteModel.assetNames =
                  //           tableModel.assetNames;
                  //       var columns = _makeColumns(tableModel);
                  //       children = [
                  //         Flexible(
                  //             child: PaginatedDataTable(
                  //           columns: columns,
                  //           source: _DataTableSource(tableModel),
                  //           rowsPerPage: min(20, tableModel.data.length),
                  //           showFirstLastButtons: true,
                  //           header: const Text(''),
                  //           actions: [
                  //             IconButton(
                  //                 onPressed: () {
                  //                   Clipboard.setData(ClipboardData(
                  //                       text: table.Table.from(tableModel.data)
                  //                           .toCsv()));
                  //                 },
                  //                 tooltip: 'Copy',
                  //                 icon: const Icon(Icons.content_copy)),
                  //             IconButton(
                  //                 onPressed: () {
                  //                   downloadTableToCsv(tableModel.data);
                  //                 },
                  //                 tooltip: 'Download',
                  //                 icon: const Icon(Icons.download_outlined))
                  //           ],
                  //         ))
                  //       ];
                  //     } else if (snapshot.hasError) {
                  //       children = [
                  //         const Icon(Icons.error_outline, color: Colors.red),
                  //         Text(
                  //           snapshot.error.toString(),
                  //           style: const TextStyle(fontSize: 16),
                  //         )
                  //       ];
                  //     } else {
                  //       children = [
                  //         const SizedBox(
                  //             height: 40,
                  //             width: 40,
                  //             child: CircularProgressIndicator(
                  //               strokeWidth: 2,
                  //             ))
                  //       ];
                  //     }
                  //     return Row(children: children);
                  //   },
                  // ),
                ],
              ),
            ),
          ),
        ));
  }

  /// The data table with a download/copy to clipboard widget.
  /// Table is sortable by value column
  DataTable _makeDataTable(Iterable<Map<String, dynamic>> data) {
    // data.forEach(print);
    var names = data.first.keys.toSet();
    var columns = [
      if (names.contains('zone')) const DataColumn(label: Text('Zone Id')),
      if (names.contains('market')) const DataColumn(label: Text('Market')),
      if (names.contains('name')) const DataColumn(label: Text('Asset Name')),
      if (names.contains('month')) const DataColumn(label: Text('Month')),
      if (names.contains('value'))
        const DataColumn(
            label: Text('NCPC'), tooltip: '\$ Credits', numeric: true),
    ];
    var rows = <DataRow>[
      for (var x in data)
        DataRow(cells: [
          if (names.contains('zone')) DataCell(Text(x['zone'].toString())),
          if (names.contains('market'))
            DataCell(Text((x['market'] as Market).name)),
          if (names.contains('name')) DataCell(Text(x['name'])),
          if (names.contains('month')) DataCell(Text(x['month'])),
          DataCell(Text(fmt.format(x['value']))),
        ])
    ];

    _sortingIndex() {
      if (names.contains('month')) {
        return names.length - 2;
      }
      return 0;
    }

    return DataTable(
      sortColumnIndex: _sortingIndex(),
      columns: columns,
      rows: rows,
    );
  }
}
