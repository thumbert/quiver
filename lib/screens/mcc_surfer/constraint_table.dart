import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/mcc_surfer/mcc_surfer_model.dart';
import 'package:intl/intl.dart';
import 'package:signals_flutter/signals_flutter.dart';

class ConstraintTable extends StatefulWidget {
  const ConstraintTable({super.key});

  @override
  State<StatefulWidget> createState() => _ConstraintTable();
}

class _ConstraintTable extends State<ConstraintTable> {
  @override
  Widget build(BuildContext context) {
    return Watch((_) {
      switch (topConstraintsTable.value) {
        case AsyncData<List<Map<String, dynamic>>>():
          var tbl = topConstraintsTable.requireValue;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                'Top 15 constraints for ${term.value}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              LimitedBox(
                maxWidth: 800,
                child: PaginatedDataTable(
                  columnSpacing: 10,
                  rowsPerPage: min(20, tbl.length),
                  columns: const [
                    DataColumn(
                        label: Text(
                      'Constraint\nName',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )),
                    DataColumn(
                        label: Text('Contingency\nName',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        numeric: true),
                    DataColumn(
                        label: Text('Marginal\nValue',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        numeric: true),
                    DataColumn(
                        label: Text('Hours\nCount',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        numeric: true),
                  ],
                  source: _DataTableSource(tbl),
                  dividerThickness: 0.0,
                ),
              )
            ],
          );
        case AsyncError<List<Map<String, dynamic>>>():
          return Row(children: [
            const Icon(Icons.error_outline, color: Colors.red),
            Text(
              'Error loading the DA binding constraints',
              style: const TextStyle(fontSize: 16),
            )
          ]);
        case AsyncLoading<List<Map<String, dynamic>>>():
          return const SizedBox(
            width: 400,
            height: 600,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              CircularProgressIndicator(),
              Text('    Loading ...'),
            ]),
          );
      }
    });
  }
}

class _DataTableSource extends DataTableSource {
  _DataTableSource(this.model);

  final List<Map<String, dynamic>> model;
  final _fmt = NumberFormat.currency(decimalDigits: 0, symbol: '\$');

  @override
  DataRow? getRow(int index) {
    var x = model[index];
    final constraintName = x['Constraint Name'] as String;
    return DataRow(
        selected: selectedConstraints.value.contains(x['Constraint Name']),
        cells: [
          DataCell(Text(x['Constraint Name'])),
          DataCell(Text(x['Contingency Name'])),
          DataCell(Text(_fmt.format(x['Marginal Value']))),
          DataCell(Text(x['Hours Count'].toString())),
        ],
        onSelectChanged: (bool? value) {
          if (value == true) {
            selectedConstraints.value = {...selectedConstraints.value, constraintName};
          } else {
            selectedConstraints.value = {...selectedConstraints.value}..remove(constraintName);
          }
          notifyListeners();
        });
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => model.length;

  @override
  int get selectedRowCount => selectedConstraints.value.length;
}
