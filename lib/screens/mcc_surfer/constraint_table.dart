library screens.constraint_table;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/term_model.dart';
import 'package:flutter_quiver/models/mcc_surfer/constraint_table_model.dart';
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
    final constraintModel = context.watch<ConstraintTableModel>();

    return FutureBuilder(
        future: constraintModel.getTopConstraints(termModel.term),
        builder: (context, snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            var xs = snapshot.data! as List;
            // print(xs.take(5));

            // create the DataRows
            var rows = <DataRow>[];
            for (var i = 0; i < xs.length; i++) {
              rows.add(DataRow(
                  cells: [
                    DataCell(Text(xs[i]['Constraint Name'])),
                    DataCell(Text(xs[i]['Contingency Name'].toString())),
                    DataCell(Text(
                        (xs[i]['Marginal Value'] as num).toStringAsFixed(1))),
                    DataCell(Text(xs[i]['Hours Count'].toString())),
                  ],
                  selected: constraintModel.selected.isNotEmpty
                      ? constraintModel.selected[i]
                      : false,
                  onSelectChanged: (bool? value) {
                    setState(() {
                      constraintModel.clickConstraint(i);
                    });
                  }));
            }

            children = [
              SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Top 40 constraints for ${termModel.term}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      DataTable(
                          columnSpacing: 14,
                          columns: const [
                            DataColumn(
                                label: Text(
                              'Constraint Name',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                            DataColumn(
                                label: Text('Contingency Name',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                numeric: true),
                            DataColumn(
                                label: Text('Marginal Value',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                numeric: true),
                            DataColumn(
                                label: Text('Hours Count',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                numeric: true),
                          ],
                          rows: rows)
                    ],
                  )),
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
