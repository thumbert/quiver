library screens.ftr_path.table_binding_constraints;

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

class TableBindingConstraints extends StatefulWidget {
  const TableBindingConstraints({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TableBindingConstraintsState();
}

class _TableBindingConstraintsState extends State<TableBindingConstraints> {
  @override
  Widget build(BuildContext context) {
    final pathModel = context.watch<RegionSourceSinkModel>();
    final dataModel = context.watch<DataModel>();

    return FutureBuilder(
      future: dataModel.getRelevantBindingConstraints(
          ftrPath: pathModel.ftrPath),
      builder: (context, snapshot) {
        List<Widget> children;
        if (snapshot.hasData) {
          if (dataModel.tableConstraintCost.isEmpty) {
            /// if source == sink for example
            children = [];
          } else {
            /// if you have data to show in the table
            var columns = _makeColumns(dataModel);
            children = [
              LimitedBox(
                  maxWidth: 500,
                  child: PaginatedDataTable(
                    columns: columns,
                    source: _DataTableSource(dataModel),
                    rowsPerPage: min(10, dataModel.tableConstraintCost.length),
                    showFirstLastButtons: true,
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
          label: Text(
        'Constraint Name',
        style: TextStyle(fontWeight: FontWeight.bold),
      )),
      const DataColumn(
          label: Text(
        'Cost',
        style: TextStyle(fontWeight: FontWeight.bold),
      )),
    ];
  }
}

class _DataTableSource extends DataTableSource {
  _DataTableSource(this.model);

  final DataModel model;
  final _fmt = NumberFormat.currency(decimalDigits: 0, symbol: '\$');

  @override
  DataRow? getRow(int index) {
    var x = model.tableConstraintCost[index];
    return DataRow(cells: [
      DataCell(Text(x['constraintName'])),
      DataCell(Text(_fmt.format(x['cost']))),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => model.tableConstraintCost.length;

  @override
  int get selectedRowCount => 0;
}
