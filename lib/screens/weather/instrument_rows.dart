library screens.weather.instrument_rows;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quiver/models/weather/weather_model.dart';
import 'package:flutter_quiver/screens/common/buy_sell.dart';
import 'package:flutter_quiver/screens/weather/airport.dart';
import 'package:flutter_quiver/screens/weather/instrument.dart';
import 'package:flutter_quiver/screens/weather/max_payoff.dart';
import 'package:flutter_quiver/screens/weather/month_range.dart';
import 'package:flutter_quiver/screens/weather/notional.dart';
import 'package:flutter_quiver/screens/weather/strike.dart';

class InstrumentRows extends StatefulWidget {
  const InstrumentRows({Key? key}) : super(key: key);

  @override
  _InstrumentRowsState createState() => _InstrumentRowsState();
}

class _InstrumentRowsState extends State<InstrumentRows> {
  final _columnSpace = 12.0;
  final _background = Colors.orange[100]!;

  late List<BuySell> _buySell;

  @override
  void initState() {
    final weatherModel = context.read<WeatherModel>();
    for (var row = 0; row < weatherModel.deals.length; row++) {
      _buySell.add(const BuySell());
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final weatherModel = context.watch<WeatherModel>();

    return Table(
      children: [
        TableRow(children: header()),
        // TODO: generate them
        TableRow(children: instrumentRow(0)),
        _rowSpacer,
      ],
      // defaultColumnWidth: const IntrinsicColumnWidth(),
      columnWidths: const {
        0: FixedColumnWidth(90),
        1: FixedColumnWidth(140),
        2: FixedColumnWidth(140),
        3: FixedColumnWidth(90),
        4: IntrinsicColumnWidth(),
        5: IntrinsicColumnWidth(),
        6: IntrinsicColumnWidth(),
        7: FixedColumnWidth(30),
      },
    );
  }

  List<Widget> instrumentRow(int row) {
    return [
      Container(
          margin: EdgeInsetsDirectional.only(end: _columnSpace),
          color: _background,
          child: _buySell[row]),
      Container(
          margin: EdgeInsetsDirectional.only(end: _columnSpace),
          color: _background,
          child: const MonthRange()),
      Container(
          margin: EdgeInsetsDirectional.only(end: _columnSpace),
          color: _background,
          child: const Instrument()),
      Container(
          margin: EdgeInsetsDirectional.only(end: _columnSpace),
          color: _background,
          child: const Airport()),
      Container(
          margin: EdgeInsetsDirectional.only(end: _columnSpace),
          color: _background,
          child: const Strike()),
      Container(
          margin: EdgeInsetsDirectional.only(end: _columnSpace),
          color: _background,
          child: const Notional()),
      Container(
          margin: EdgeInsetsDirectional.only(end: _columnSpace),
          color: _background,
          child: const MaxPayoff()),
      Container(
        // height: 36,
        alignment: Alignment.centerLeft,
        child: PopupMenuButton<int>(
          onSelected: (result) {
            if (result == 0) {
              addRow(row);
            } else if (result == 1) {
              removeRow(row);
            } else if (result == 2) {
              clearRow(row);
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 0,
              child: Text('Add row'),
            ),
            const PopupMenuItem(
              value: 2,
              child: Text('Clear row'),
            ),
            const PopupMenuItem(
              value: 1,
              child: Text('Delete row'),
            ),
          ],
        ),
      ),
    ];
  }

  void addRow(int row) {}
  void removeRow(int row) {}
  void clearRow(int row) {}

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
              child: Text('Term', style: _style))),
      TableCell(
          verticalAlignment: TableCellVerticalAlignment.bottom,
          child: Container(
              margin: EdgeInsetsDirectional.only(end: _columnSpace),
              padding: const EdgeInsetsDirectional.only(bottom: 4),
              child: Text('Instrument', style: _style))),
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
      children: List.generate(8, (index) => const SizedBox(height: 4)));
}
