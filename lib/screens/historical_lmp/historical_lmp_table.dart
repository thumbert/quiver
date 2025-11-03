// import 'dart:math';

// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_quiver/models/historical_lmp_model.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_web_plotly/flutter_web_plotly.dart';
// import 'package:intl/intl.dart';
// import 'package:table/table_base.dart' as table;
// import 'package:flutter_quiver/utils/empty_download.dart'
//     if (dart.library.html) '../../utils/download.dart';
// import 'package:timeseries/timeseries.dart';

// class HistoricalLmpTable extends ConsumerStatefulWidget {
//   const HistoricalLmpTable({super.key});

//   @override
//   ConsumerState<HistoricalLmpTable> createState() => _HistoricalLmpTableState();
// }

// class _HistoricalLmpTableState extends ConsumerState<HistoricalLmpTable> {
//   late Plotly plotly;

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (hourlyLmp.isNotEmpty)
//           SizedBox(width: 1000, height: 600, child: plotly),
//         const SizedBox(
//           height: 16,
//         ),
//         ...[
//           for (var e in tables.entries) _makeTable(e.value, e.key, fmt, model)
//         ],
//       ],
//     );
//   }

//   Widget _makeTable(List<Map<String, dynamic>> data, String bucketName,
//       NumberFormat fmt, HistoricalLmpModel state) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Row(
//           children: [
//             Text(
//               bucketName,
//               style:
//                   const TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
//             ),
//             const SizedBox(
//               width: 48,
//             ),
//             Row(
//               children: [
//                 IconButton(
//                     onPressed: () {
//                       Clipboard.setData(
//                           ClipboardData(text: table.Table.from(data).toCsv()));
//                     },
//                     tooltip: 'Copy',
//                     icon: const Icon(
//                       Icons.content_copy,
//                       color: Colors.grey,
//                     )),
//                 IconButton(
//                     onPressed: () {
//                       downloadTableToCsv(data, bucketName);
//                     },
//                     tooltip: 'Download',
//                     icon: const Icon(
//                       Icons.download_outlined,
//                       color: Colors.grey,
//                     ))
//               ],
//             )
//           ],
//         ),
//         state.timeAggregation == 'Monthly'
//             ? DataTable(
//                 columnSpacing: 18,
//                 columns: _makeColumns(state),
//                 rows: _makeRows(data, fmt, state),
//               )
//             : LimitedBox(
//                 maxWidth: 400,
//                 child: PaginatedDataTable(
//                   columnSpacing: 18,
//                   columns: _makeColumns(state),
//                   rowsPerPage: min(31, data.length),
//                   showFirstLastButtons: true,
//                   source: _DataTableSource(data, state.getColumns(), state),
//                 ),
//               ),
//         const SizedBox(
//           height: 12,
//         ),
//       ],
//     );
//   }

//   List<DataColumn> _makeColumns(HistoricalLmpModel state) {
//     var out = <DataColumn>[];
//     var columns = state.getColumns();
//     if (state.timeAggregation == 'Monthly') {
//       for (var column in columns) {
//         out.add(DataColumn(
//             numeric: true,
//             label: Text(column,
//                 style: const TextStyle(fontWeight: FontWeight.bold))));
//       }
//     } else if (state.timeAggregation == 'Daily') {
//       out.add(DataColumn(
//           label: Text(columns.first,
//               style: const TextStyle(fontWeight: FontWeight.bold))));
//       for (var column in columns.skip(1)) {
//         out.add(DataColumn(
//             numeric: true,
//             label: Text(column,
//                 style: const TextStyle(fontWeight: FontWeight.bold))));
//       }
//     } else if (state.timeAggregation == 'Hourly') {
//       out.add(DataColumn(
//           label: Text(columns.first,
//               style: const TextStyle(fontWeight: FontWeight.bold))));
//       for (var column in columns.skip(1)) {
//         out.add(DataColumn(
//             numeric: true,
//             label: Text(column,
//                 style: const TextStyle(fontWeight: FontWeight.bold))));
//       }
//     }
//     return out;
//   }

//   List<DataRow> _makeRows(List<Map<String, dynamic>> data, NumberFormat fmt,
//       HistoricalLmpModel state) {
//     var out = <DataRow>[];
//     var columns = state.getColumns();
//     if (state.timeAggregation == 'Monthly') {
//       for (var row in data) {
//         var cells = <DataCell>[DataCell(Text(row['Year'].toString()))];
//         for (var col in columns.skip(1)) {
//           if (row.containsKey(col)) {
//             cells.add(DataCell(Text(fmt.format(row[col]))));
//           } else {
//             cells.add(const DataCell(Text('')));
//           }
//         }
//         out.add(DataRow(cells: cells));
//       }
//       //
//       //
//     } else if (state.timeAggregation == 'Daily') {
//       for (var row in data) {
//         var cells = <DataCell>[DataCell(Text(row['Date'].toString()))];
//         for (var col in columns.skip(1)) {
//           if (row.containsKey(col)) {
//             cells.add(DataCell(Text(fmt.format(row[col]))));
//           } else {
//             cells.add(const DataCell(Text('')));
//           }
//         }
//         out.add(DataRow(cells: cells));
//       }
//     }
//     return out;
//   }

//   final _fmt2 = NumberFormat.currency(decimalDigits: 2, symbol: '');
//   final _fmtPercent = NumberFormat.decimalPercentPattern(decimalDigits: 2);
// }

// Future<void> downloadTableToCsv(
//     List<Map<String, dynamic>> data, String bucketName) async {
//   var tbl = table.Table.from(data);
//   download(tbl.toCsv().codeUnits,
//       downloadName: 'historical_lmp_$bucketName.csv');
// }

// /// Daily data is paginated
// class _DataTableSource extends DataTableSource {
//   _DataTableSource(this.data, this.columns, this.state);

//   final List<Map<String, dynamic>> data;
//   final List<String> columns;
//   final HistoricalLmpModel state;
//   final _fmt2 = NumberFormat.currency(decimalDigits: 2, symbol: '');

//   @override
//   DataRow? getRow(int index) {
//     var x = data[index];
//     if (state.timeAggregation == 'Hourly') {
//       return DataRow(cells: [
//         DataCell(Text(x['HourBeginning'].toString())),
//         DataCell(Text(_fmt2.format(x['Value'])))
//       ]);
//     }
//     return DataRow(cells: [
//       DataCell(Text(x['Date'].toString())),
//       ...[
//         for (var col in columns.skip(1))
//           x.containsKey(col)
//               ? DataCell(Text(_fmt2.format(x[col])))
//               : const DataCell(Text(''))
//       ]
//     ]);
//   }

//   @override
//   bool get isRowCountApproximate => false;

//   @override
//   int get rowCount => data.length;

//   @override
//   int get selectedRowCount => 0;
// }
