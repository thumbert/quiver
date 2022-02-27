// library screens.weather.summary_table;
//
// import 'dart:math';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_quiver/models/ftr_path/data_model.dart';
// import 'package:flutter_quiver/models/ftr_path/region_source_sink_model.dart';
// import 'package:flutter_quiver/models/weather/weather_model.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// import 'package:table/table_base.dart' as table;
// import 'package:flutter_quiver/utils/empty_download.dart'
// if (dart.library.html) '../../utils/download.dart';
//
// class SummaryTable extends StatefulWidget {
//   const SummaryTable({Key? key}) : super(key: key);
//
//   @override
//   State<StatefulWidget> createState() => _SummaryTableState();
// }
//
// class _SummaryTableState extends State<SummaryTable> {
//   @override
//   Widget build(BuildContext context) {
//     final model = context.watch<WeatherModel>();
//
//     return FutureBuilder(
//       future: model.getSummaryData(row: 0),
//       builder: (context, snapshot) {
//         List<Widget> children;
//         if (snapshot.hasData) {
//           if (model.tableConstraintCost.isEmpty) {
//             /// if source == sink for example
//             children = [];
//           } else {
//             /// if you have data to show in the table
//             var columns = _makeColumns(model);
//             children = [
//               LimitedBox(
//                   maxWidth: 560,
//                   child: PaginatedDataTable(
//                     columnSpacing: 24,
//                     columns: columns,
//                     source: _DataTableSource(model),
//                     rowsPerPage: min(10, model.tableConstraintCost.length),
//                     showFirstLastButtons: true,
//                   ))
//             ];
//           }
//         } else if (snapshot.hasError) {
//           children = [
//             const Icon(Icons.error_outline, color: Colors.red),
//             Text(
//               snapshot.error.toString(),
//               style: const TextStyle(fontSize: 16),
//             )
//           ];
//         } else {
//           children = [
//             const SizedBox(
//                 height: 40,
//                 width: 40,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                 ))
//           ];
//         }
//         return Row(children: children);
//       },
//     );
//   }
//
//   List<DataColumn> _makeColumns(DataModel dataModel) {
//     return <DataColumn>[
//       const DataColumn(
//           label: Text(
//             'Constraint Name',
//             style: TextStyle(fontWeight: FontWeight.bold),
//           )),
//       DataColumn(
//         // tooltip: 'Mean value of the spread when this constraint bound',
//           label: TextButton(
//               onPressed: () {
//                 setState(() {
//                   dataModel.sortAscendingBc = !dataModel.sortAscendingBc;
//                   dataModel.sortColumnBc = 'hours';
//                 });
//               },
//               child: Row(
//                 children: [
//                   const Text(
//                     'Hours',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   if (dataModel.sortColumnBc == 'hours')
//                     dataModel.sortAscendingBc
//                         ? const Icon(Icons.arrow_upward)
//                         : const Icon(Icons.arrow_downward),
//                 ],
//               ))),
//       DataColumn(
//         // tooltip: 'Mean value of the spread when this constraint bound',
//           label: TextButton(
//               onPressed: () {
//                 setState(() {
//                   dataModel.sortAscendingBc = !dataModel.sortAscendingBc;
//                   dataModel.sortColumnBc = 'Mean Spread';
//                 });
//               },
//               child: Row(
//                 children: [
//                   const Text(
//                     'Mean\nSpread',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   if (dataModel.sortColumnBc == 'Mean Spread')
//                     dataModel.sortAscendingBc
//                         ? const Icon(Icons.arrow_upward)
//                         : const Icon(Icons.arrow_downward),
//                 ],
//               ))),
//       DataColumn(
//           label: TextButton(
//               onPressed: () {
//                 setState(() {
//                   dataModel.sortAscendingBc = !dataModel.sortAscendingBc;
//                   dataModel.sortColumnBc = 'Cumulative Spread';
//                 });
//               },
//               child: Row(
//                 children: [
//                   const Text(
//                     'Cumulative\nSpread',
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   if (dataModel.sortColumnBc == 'Cumulative Spread')
//                     dataModel.sortAscendingBc
//                         ? const Icon(Icons.arrow_upward)
//                         : const Icon(Icons.arrow_downward),
//                 ],
//               ))),
//     ];
//   }
// }
//
// class _DataTableSource extends DataTableSource {
//   _DataTableSource(this.model);
//
//   final DataModel model;
//   final _fmt0 = NumberFormat.currency(decimalDigits: 0, symbol: '\$');
//   final _fmt2 = NumberFormat.currency(decimalDigits: 2, symbol: '\$');
//
//   @override
//   DataRow? getRow(int index) {
//     var x = model.tableConstraintCost[index];
//     return DataRow(cells: [
//       DataCell(Text(x['name'])),
//       DataCell(Text(x['hours'].toString())),
//       DataCell(Text(_fmt2.format(x['Mean Spread']))),
//       DataCell(Text(_fmt0.format(x['Cumulative Spread']))),
//     ]);
//   }
//
//   @override
//   bool get isRowCountApproximate => false;
//
//   @override
//   int get rowCount => model.tableConstraintCost.length;
//
//   @override
//   int get selectedRowCount => 0;
// }
