library screens.ftr_path.table_csps;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quiver/models/ftr_path/data_model.dart';
import 'package:flutter_quiver/models/ftr_path/region_source_sink_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table/table_base.dart' as table;
import 'package:flutter_quiver/utils/empty_download.dart'
    if (dart.library.html) '../../utils/download.dart';

class TableCpsp extends StatefulWidget {
  const TableCpsp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TableCpspState();
}

class _TableCpspState extends State<TableCpsp> {
  @override
  Widget build(BuildContext context) {
    final pathModel = context.watch<RegionSourceSinkModel>();
    final dataModel = context.watch<DataModel>();

    return FutureBuilder(
      future: dataModel.getCpSpTable(pathModel.ftrPath),
      builder: (context, snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          if (dataModel.tableCpSp.isEmpty) {
            /// sometimes no data is left if all checkboxes are unticked.
            children = [
              const Text(
                'No auctions found!  This can happen because: \n'
                ' \u{2022} Auction filters are too restrictive, \n'
                ' \u{2022} Source/sink node may not be participating in FTR/TCC auctions, \n'
                ' \u{2022} Database or server may be unresponsive',
                style: TextStyle(fontSize: 16),
              ),
            ];
          } else {
            /// if you have data to show in the table
            var columns = _makeColumns(dataModel);
            children = [
              LimitedBox(
                  maxWidth: 400,
                  child: PaginatedDataTable(
                    horizontalMargin: 8,
                    columnSpacing: 24,
                    columns: columns,
                    source: _DataTableSource(dataModel),
                    rowsPerPage: min(30, dataModel.tableCpSp.length),
                    showFirstLastButtons: true,
                    header: const Text(''),
                    actions: [
                      IconButton(
                          onPressed: () {
                            Clipboard.setData(ClipboardData(
                                text: table.Table.from(dataModel.tableCpSp)
                                    .toCsv()));
                          },
                          tooltip: 'Copy',
                          icon: const Icon(Icons.content_copy)),
                      IconButton(
                          onPressed: () {
                            downloadTableToCsv(dataModel.tableCpSp);
                          },
                          tooltip: 'Download',
                          icon: const Icon(Icons.download_outlined))
                    ],
                  ))
            ];
          }
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
    );
  }

  List<DataColumn> _makeColumns(DataModel dataModel) {
    return <DataColumn>[
      const DataColumn(
          label:
              Text('Auction', style: TextStyle(fontWeight: FontWeight.bold))),
      const DataColumn(
          label: Text('Clearing Price',
              style: TextStyle(fontWeight: FontWeight.bold))),
      const DataColumn(
          label: Text('Settle Price',
              style: TextStyle(fontWeight: FontWeight.bold))),
    ];
  }
}

class _DataTableSource extends DataTableSource {
  _DataTableSource(this.model);

  final DataModel model;
  final _fmt = NumberFormat.currency(decimalDigits: 2, symbol: '\$');

  @override
  DataRow? getRow(int index) {
    var x = model.tableCpSp[index];
    return DataRow(cells: [
      DataCell(Text(x['auction'].name)),
      DataCell(Text(_fmt.format(x['clearingPrice']))),
      DataCell(Text(_fmt.format(x['settlePrice']))),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => model.tableCpSp.length;

  @override
  int get selectedRowCount => 0;
}

Future<void> downloadTableToCsv(List<Map<String, dynamic>> data) async {
  var tbl = table.Table.from(data);
  download(tbl.toCsv().codeUnits, downloadName: 'cp_vs_sp.csv');
}
