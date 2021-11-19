library screens.monthly_asset_ncpc.monthly_asset_ncpc_ui;

import 'dart:io';

import 'package:elec/risk_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quiver/models/common/load_zone_model.dart';
import 'package:flutter_quiver/models/common/term_model.dart';
import 'package:flutter_quiver/models/monthly_asset_ncpc.dart';
import 'package:flutter_quiver/screens/common/load_zone.dart';
import 'package:flutter_quiver/screens/common/term.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:table/table_base.dart' as table;
import 'package:flutter_quiver/utils/empty_download.dart'
    if (dart.library.html) '../../utils/download.dart';

class MonthlyAssetNcpcUi extends StatefulWidget {
  const MonthlyAssetNcpcUi({Key? key}) : super(key: key);

  @override
  _MonthlyAssetNcpcUiState createState() => _MonthlyAssetNcpcUiState();
}

class _MonthlyAssetNcpcUiState extends State<MonthlyAssetNcpcUi> {
  var fmt = NumberFormat.currency(decimalDigits: 0, symbol: '\$');
  late ScrollController _controller;

  @override
  void initState() {
    _controller = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final termModel = context.watch<TermModel>();
    final zoneModel = context.watch<LoadZoneModel>();
    final tableModel = context.watch<MonthlyAssetNcpcModel>();

    PaginatedDataTable _makePaginatedTable() {
      final names = tableModel.tableData.first.keys.toSet();
      var columns = [
        if (names.contains('zone')) const DataColumn(label: Text('Zone Id')),
        if (names.contains('market')) const DataColumn(label: Text('Market')),
        if (names.contains('name')) const DataColumn(label: Text('Asset Name')),
        if (names.contains('month')) const DataColumn(label: Text('Month')),
        if (names.contains('value'))
          DataColumn(
              label: const Text('NCPC'),
              tooltip: '\$ Credits',
              numeric: true,
              onSort: (index, sortAscending) {
                setState(() {
                  print('sortAscending: $sortAscending');
                  tableModel.sortAscending = sortAscending;
                  tableModel.sortByColumn(
                      name: 'value', sortAscending: sortAscending);
                });
              }),
      ];

      return PaginatedDataTable(
        // dataRowHeight: 20,
        columns: columns,
        source: _DataTableSource(tableModel),
        rowsPerPage: 20,
        sortColumnIndex: 1,
        sortAscending: tableModel.sortAscending,
        header: Row(
          children: [
            const SizedBox(
              width: 150,
            ),
            //   IconButton(
            //       tooltip: 'Download',
            //       onPressed: () {},
            //       icon: const Icon(Icons.download_outlined))
            //
          ],
        ),
        actions: [
          IconButton(
              onPressed: () {
                downloadTableToCsv(tableModel.tableData);
              },
              tooltip: 'Download',
              icon: const Icon(Icons.download_outlined))
        ],
      );
    }

    return Padding(
        padding: const EdgeInsets.only(left: 48),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Historical monthly NCPC by asset'),
            actions: [
              IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const SimpleDialog(
                          children: [
                            Text(
                                'ISO publishes the data every month, with a 4 month lag '
                                'beginning in Jan19.'),
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
              controller: _controller,
              isAlwaysShown: true,
              // child: ListView.builder(
              //     // primary: true,  // works by itself, but not with the app
              //     // itemCount: 600,
              //     controller: _controller,
              //     itemBuilder: _itemBuilder),
              child: ListView(
                controller: _controller,
                children: [
                  Row(
                    children: const [
                      SizedBox(width: 140, child: TermUi()),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                          value: tableModel.byZone,
                          onChanged: (bool? value) {
                            setState(() {
                              tableModel.byZone = value!;
                            });
                          }),
                      const SizedBox(
                        width: 20,
                      ),
                      const SizedBox(
                        width: 80,
                        child: Text('Zone', style: TextStyle(fontSize: 16)),
                      ),
                      const LoadZone(),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                          value: tableModel.byMarket,
                          onChanged: (bool? value) {
                            setState(() {
                              tableModel.byMarket = value!;
                            });
                          }),
                      const SizedBox(
                        width: 20,
                      ),
                      const SizedBox(
                        width: 80,
                        child: Text('Market', style: TextStyle(fontSize: 16)),
                      ),
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField(
                          value: tableModel.market,
                          icon: const Icon(Icons.expand_more),
                          hint: const Text('Filter'),
                          decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor))),
                          elevation: 16,
                          onChanged: (String? newValue) {
                            setState(() {
                              tableModel.market = newValue!;
                            });
                          },
                          items: ['(All)', 'DA', 'RT']
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Checkbox(
                          value: tableModel.byAsset,
                          onChanged: (bool? value) {
                            setState(() {
                              tableModel.byAsset = value!;
                            });
                          }),
                      const SizedBox(
                        width: 20,
                      ),
                      const SizedBox(
                        width: 80,
                        child: Text('Asset', style: TextStyle(fontSize: 16)),
                      ),
                      SizedBox(
                        width: 150,
                        child: DropdownButtonFormField(
                          value: tableModel.assetName,
                          icon: const Icon(Icons.expand_more),
                          hint: const Text('Filter'),
                          decoration: InputDecoration(
                              enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Theme.of(context).primaryColor))),
                          elevation: 16,
                          onChanged: (String? newValue) {
                            setState(() {
                              tableModel.assetName = newValue!;
                            });
                          },
                          items: [
                            '(All)',
                            'DA',
                            'RT'
                          ] // FIXME: replace with the correct list of assets!
                              .map((e) =>
                                  DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 150,
                    child: CheckboxListTile(
                      title: const Text('Month'),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: const EdgeInsets.all(0),
                      value: tableModel.byMonth,
                      onChanged: (bool? value) {
                        setState(() {
                          tableModel.byMonth = value!;
                        });
                      },
                    ),
                  ),

                  FutureBuilder(
                    future: tableModel.getData(termModel.term),
                    builder: (context, snapshot) {
                      List<Widget> children;
                      if (snapshot.hasData) {
                        // aggregate the data first
                        // children = [_makeDataTable(aggData)];
                        tableModel.aggregateData(zoneId: zoneModel.zoneId);
                        children = [Flexible(child: _makePaginatedTable())];
                      } else if (snapshot.hasError) {
                        children = [
                          const Icon(Icons.error_outline, color: Colors.red),
                          Text(
                            snapshot.error.toString(),
                            style: const TextStyle(fontSize: 16),
                          )
                        ];
                      } else {
                        children = [
                          const SizedBox(
                              height: 40,
                              width: 40,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ))
                        ];
                      }
                      return Row(children: children);
                    },
                  ),

                  const SizedBox(
                    height: 24,
                  ),
                  // Text('Selected: ${getSelection(market, bucket)}'),
                ],
              ),
            ),
          ),
        ));
  }

  /// The data table with a download/copy to clipboard widget.
  /// Table is sortable by value column
  DataTable _makeDataTable(Iterable<Map<String, dynamic>> data) {
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

Future<void> downloadTableToCsv(List<Map<String, dynamic>> data) async {
  var tbl = table.Table.from(data);
  download(tbl.toCsv().codeUnits, downloadName: 'monthly_asset_ncpc_data.csv');
}

class _DataTableSource extends DataTableSource {
  _DataTableSource(this.model);

  final MonthlyAssetNcpcModel model;
  final _fmt = NumberFormat.currency(decimalDigits: 0, symbol: '\$');

  @override
  DataRow? getRow(int index) {
    return _makeDataRow(model.tableData[index]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => model.tableData.length;

  @override
  int get selectedRowCount => 0;

  DataRow _makeDataRow(Map<String, dynamic> x) {
    var names = x.keys.toSet();
    return DataRow(cells: [
      if (names.contains('zone')) DataCell(Text(x['zone'].toString())),
      if (names.contains('market'))
        DataCell(Text((x['market'] as Market).name)),
      if (names.contains('name')) DataCell(Text(x['name'])),
      if (names.contains('month')) DataCell(Text(x['month'])),
      DataCell(Text(_fmt.format(x['value']))),
    ]);
  }
}
