library screens.monthly_asset_ncpc.monthly_asset_ncpc_ui;

import 'dart:math';
import 'package:flutter/services.dart';

import 'package:elec/risk_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/load_zone_model.dart';
import 'package:flutter_quiver/models/common/term_model.dart';
import 'package:flutter_quiver/models/monthly_asset_ncpc/asset_autocomplete_model.dart';
import 'package:flutter_quiver/models/monthly_asset_ncpc/monthly_asset_ncpc.dart';
import 'package:flutter_quiver/screens/common/load_zone.dart';
import 'package:flutter_quiver/screens/common/term.dart';
import 'package:flutter_quiver/screens/monthly_asset_ncpc/asset_autocomplete.dart';
import 'package:intl/intl.dart';
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
    final assetModel = context.watch<AssetAutocompleteModel>();
    final tableModel = context.watch<MonthlyAssetNcpcModel>();
    tableModel.zoneId = zoneModel.zoneId;
    tableModel.assetName = assetModel.assetName;

    return Scaffold(
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
                            'beginning in Jan19.\nData has monthly granularity.'),
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
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
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
                  const SizedBox(
                    width: 150,
                    child: AssetAutocomplete(),
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

              // table with costs
              //
              FutureBuilder(
                future: tableModel.getData(termModel.term),
                builder: (context, snapshot) {
                  List<Widget> children;
                  if (snapshot.hasData) {
                    AssetAutocompleteModel.assetNames = tableModel.assetNames;
                    var columns = _makeColumns(tableModel);
                    children = [
                      Flexible(
                          child: PaginatedDataTable(
                        columns: columns,
                        source: _DataTableSource(tableModel),
                        rowsPerPage: min(20, tableModel.data.length),
                        showFirstLastButtons: true,
                        header: const Text(''),
                        actions: [
                          IconButton(
                              onPressed: () {
                                Clipboard.setData(ClipboardData(
                                    text: table.Table.from(tableModel.data)
                                        .toCsv()));
                              },
                              tooltip: 'Copy',
                              icon: const Icon(Icons.content_copy)),
                          IconButton(
                              onPressed: () {
                                downloadTableToCsv(tableModel.data);
                              },
                              tooltip: 'Download',
                              icon: const Icon(Icons.download_outlined))
                        ],
                      ))
                    ];
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
    );
  }

  List<DataColumn> _makeColumns(MonthlyAssetNcpcModel tableModel) {
    final names = tableModel.data.first.keys.toList();
    return <DataColumn>[
      if (names.contains('zone')) const DataColumn(label: Text('Zone Id')),
      if (names.contains('market'))
        DataColumn(
            label: TextButton(
                onPressed: () {
                  setState(() {
                    tableModel.sortAscending = !tableModel.sortAscending;
                    tableModel.sortColumn = 'market';
                  });
                },
                child: Row(
                  children: [
                    if (tableModel.sortColumn == 'market')
                      tableModel.sortAscending
                          ? const Icon(Icons.arrow_upward)
                          : const Icon(Icons.arrow_downward),
                    const Text('Market'),
                  ],
                ))),
      if (names.contains('name')) const DataColumn(label: Text('Asset Name')),
      if (names.contains('month'))
        DataColumn(
            label: TextButton(
                onPressed: () {
                  setState(() {
                    tableModel.sortAscending = !tableModel.sortAscending;
                    tableModel.sortColumn = 'month';
                  });
                },
                child: Row(
                  children: [
                    if (tableModel.sortColumn == 'month')
                      tableModel.sortAscending
                          ? const Icon(Icons.arrow_upward)
                          : const Icon(Icons.arrow_downward),
                    const Text('Month'),
                  ],
                ))),
      if (names.contains('value'))
        DataColumn(
          label: TextButton(
              onPressed: () {
                setState(() {
                  tableModel.sortAscending = !tableModel.sortAscending;
                  tableModel.sortColumn = 'value';
                });
              },
              child: Row(
                children: [
                  if (tableModel.sortColumn == 'value')
                    tableModel.sortAscending
                        ? const Icon(Icons.arrow_upward)
                        : const Icon(Icons.arrow_downward),
                  const Text('NCPC'),
                ],
              )),
          tooltip: '\$ Credits',
          numeric: true,
        ),
    ];
  }
}

class _DataTableSource extends DataTableSource {
  _DataTableSource(this.model);

  final MonthlyAssetNcpcModel model;
  final _fmt = NumberFormat.currency(decimalDigits: 0, symbol: '\$');

  @override
  DataRow? getRow(int index) {
    var x = model.data[index];
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

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => model.data.length;

  @override
  int get selectedRowCount => 0;
}

Future<void> downloadTableToCsv(List<Map<String, dynamic>> data) async {
  var tbl = table.Table.from(data);
  download(tbl.toCsv().codeUnits, downloadName: 'monthly_asset_ncpc_data.csv');
}
