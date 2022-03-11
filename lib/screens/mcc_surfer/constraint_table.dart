library screens.constraint_table;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/region_load_zone_model.dart';
import 'package:flutter_quiver/models/common/term_model.dart';
import 'package:flutter_quiver/models/mcc_surfer/constraint_table_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ConstraintTable extends StatefulWidget {
  const ConstraintTable({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ConstraintTable();
}

class _ConstraintTable extends State<ConstraintTable> {
  @override
  Widget build(BuildContext context) {
    final termModel = context.watch<TermModel>();
    final zoneModel = context.watch<RegionLoadZoneModel>();
    final constraintModel = context.watch<ConstraintTableModel>();

    return FutureBuilder(
        future: constraintModel.getTopConstraints(termModel.term,
            region: zoneModel.region),
        builder: (context, snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            var xs = snapshot.data! as List;
            children = [];
            if (xs.isNotEmpty) {
              children.add(
                SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          'Top constraints for ${termModel.term}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        LimitedBox(
                          maxWidth: 800,
                          child: PaginatedDataTable(
                            columnSpacing: 14,
                            rowsPerPage: min(16, constraintModel.table.length),
                            columns: const [
                              DataColumn(
                                  label: Text(
                                'Constraint\nName',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )),
                              DataColumn(
                                  label: Text('Contingency\nName',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  numeric: true),
                              DataColumn(
                                  label: Text('Marginal\nValue',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  numeric: true),
                              DataColumn(
                                  label: Text('Hours\nCount',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  numeric: true),
                            ],
                            source: _DataTableSource(constraintModel),

                            // rows: rows
                          ),
                        )
                      ],
                    )),
              );
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
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ))
            ];
          }
          return Row(children: children);
        });
  }
}

class _DataTableSource extends DataTableSource {
  _DataTableSource(this.model);

  final ConstraintTableModel model;
  final _fmt = NumberFormat.currency(decimalDigits: 0, symbol: '\$');

  @override
  DataRow? getRow(int index) {
    var x = model.table[index];
    return DataRow(
        cells: [
          DataCell(Text(x['Constraint Name'])),
          DataCell(Text(x['Contingency Name'])),
          DataCell(Text(_fmt.format(x['Marginal Value']))),
          DataCell(Text(x['Hours Count'].toString())),
        ],
        selected: model.selected.isNotEmpty ? model.selected[index] : false,
        onSelectChanged: (bool? value) {
          model.clickConstraint(index);
        });
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => model.table.length;

  @override
  int get selectedRowCount => 0;
}
