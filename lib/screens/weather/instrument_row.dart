library screens.weather.instrument_row;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/screens/weather/airport.dart';
import 'package:flutter_quiver/screens/weather/notional.dart';

class InstrumentRow extends StatefulWidget {
  const InstrumentRow({Key? key}) : super(key: key);

  @override
  _InstrumentRowState createState() => _InstrumentRowState();
}

class _InstrumentRowState extends State<InstrumentRow> {
  final _columnSpace = 12.0;

  @override
  Widget build(BuildContext context) {
    return Table(
      children: [
        TableRow(children: header()),
        TableRow(children: instrumentRow()),
        _rowSpacer,
      ],
      // defaultColumnWidth: const IntrinsicColumnWidth(),
      columnWidths: const {
        0: FixedColumnWidth(50),
        1: FixedColumnWidth(90),
        2: IntrinsicColumnWidth(),
        3: IntrinsicColumnWidth(),
        4: IntrinsicColumnWidth(),
        5: FixedColumnWidth(10),
      },
    );
  }

  List<Widget> instrumentRow() {
    return [
      Container(
          margin: EdgeInsetsDirectional.only(end: _columnSpace),
          color: Colors.orange[100],
          child: Text('Buy')),
      Container(
          margin: EdgeInsetsDirectional.only(end: _columnSpace),
          color: Colors.orange[100],
          child: const Airport()),
      Container(
          margin: EdgeInsetsDirectional.only(end: _columnSpace),
          color: Colors.orange[100],
          child: Notional()),
      Container(
          margin: EdgeInsetsDirectional.only(end: _columnSpace),
          color: Colors.lime,
          child: Row(
            children: [
              Expanded(child: Notional()),
            ],
          )),
      Container(
          margin: EdgeInsetsDirectional.only(end: _columnSpace),
          color: Colors.lime,
          child: Row(
            children: [
              Expanded(child: Notional()),
            ],
          )),
      Text(''),
    ];
  }

  List<Widget> header() {
    var _style = TextStyle(fontSize: 16, color: Theme.of(context).primaryColor);
    return [
      TableCell(
          verticalAlignment: TableCellVerticalAlignment.bottom,
          child: Container(
              margin: EdgeInsetsDirectional.only(end: _columnSpace),
              padding: const EdgeInsetsDirectional.only(bottom: 4),
              child: Text('Buy/Sell', style: _style))),
      TableCell(
          verticalAlignment: TableCellVerticalAlignment.bottom,
          child: Container(
              margin: EdgeInsetsDirectional.only(end: _columnSpace),
              padding: const EdgeInsetsDirectional.only(bottom: 4),
              child: Text('Airport', style: _style))),
      TableCell(
          verticalAlignment: TableCellVerticalAlignment.bottom,
          child: Container(
              margin: EdgeInsetsDirectional.only(end: _columnSpace),
              padding: const EdgeInsetsDirectional.only(bottom: 4),
              child: Text('Strike', style: _style))),
      TableCell(
          verticalAlignment: TableCellVerticalAlignment.bottom,
          child: Container(
              margin: EdgeInsetsDirectional.only(end: _columnSpace),
              padding: const EdgeInsetsDirectional.only(bottom: 4),
              child: Text('Notional', style: _style))),
      TableCell(
          verticalAlignment: TableCellVerticalAlignment.bottom,
          child: Container(
              margin: EdgeInsetsDirectional.only(end: _columnSpace),
              padding: const EdgeInsetsDirectional.only(bottom: 4),
              child: Text('Max Payoff', style: _style))),
      const Text(''),
    ];
  }

  final _rowSpacer = TableRow(
      children: List.generate(6, (index) => const SizedBox(height: 4)));
}
