library screens.weather.instrument_rows;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/multiple/buysell_model.dart';
import 'package:flutter_quiver/models/common/multiple/maxpayoff_model.dart';
import 'package:flutter_quiver/models/common/multiple/notional_model.dart';
import 'package:flutter_quiver/models/common/multiple/strike_model.dart';
import 'package:flutter_quiver/models/weather/airport_model.dart';
import 'package:flutter_quiver/models/weather/instrument_model.dart';
import 'package:flutter_quiver/models/weather/month_range_model.dart';
import 'package:flutter_quiver/models/weather/weather_deal.dart';
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
  _InstrumentRowsState();

  final _columnSpace = 12.0;
  final _background = Colors.orange[100]!;

  @override
  void initState() {
    final weatherModel = context.read<WeatherModel>();
    final buySellModel = context.read<BuySellModel>();
    final monthRangeModel = context.read<MonthRangeModel>();
    final instrumentModel = context.read<InstrumentModel>();
    final airportModel = context.read<AirportModel>();
    final strikeModel = context.read<StrikeModel>();
    final notionalModel = context.read<NotionalModel>();
    final maxPayoffModel = context.read<MaxPayoffModel>();

    for (var i = 0; i < weatherModel.deals.length; i++) {
      var deal = weatherModel.deals[i];
      buySellModel.insert(i, deal.buySell.toString());
      monthRangeModel.insert(i, deal.monthRange);
      instrumentModel.insert(i, deal.instrumentType);
      airportModel.insert(i, deal.airport);
      strikeModel.insert(i, deal.strike);
      notionalModel.insert(i, deal.notional);
      maxPayoffModel.insert(i, deal.maxPayoff);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final weatherModel = context.watch<WeatherModel>();
    final buySellModel = context.watch<BuySellModel>();
    final monthRangeModel = context.watch<MonthRangeModel>();
    final instrumentModel = context.watch<InstrumentModel>();
    final airportModel = context.watch<AirportModel>();
    final strikeModel = context.watch<StrikeModel>();
    final notionalModel = context.watch<NotionalModel>();
    final maxPayoffModel = context.watch<MaxPayoffModel>();

    // recreate the deals correctly from the inputs
    for (var i = 0; i < weatherModel.deals.length; i++) {
      weatherModel.deals[i] = WeatherDeal(
          buySell: buySellModel[i],
          monthRange: monthRangeModel[i],
          instrumentType: instrumentModel[i],
          airport: airportModel[i],
          strike: strikeModel[i],
          notional: notionalModel[i],
          maxPayoff: maxPayoffModel[i]);
    }

    List<Widget> instrumentRow(int row) {
      return [
        Container(
            margin: EdgeInsetsDirectional.only(end: _columnSpace),
            color: _background,
            child: BuySell(
              index: row,
            )),
        Container(
            margin: EdgeInsetsDirectional.only(end: _columnSpace),
            color: _background,
            child: MonthRange(
              index: row,
            )),
        Container(
            margin: EdgeInsetsDirectional.only(end: _columnSpace),
            color: _background,
            child: Instrument(
              index: row,
            )),
        Container(
            margin: EdgeInsetsDirectional.only(end: _columnSpace),
            color: _background,
            child: Airport(
              index: row,
              key: UniqueKey(),
            )),
        Container(
            margin: EdgeInsetsDirectional.only(end: _columnSpace),
            color: _background,
            child: Strike(
              index: row,
              key: UniqueKey(),
            )),
        Container(
            margin: EdgeInsetsDirectional.only(end: _columnSpace),
            color: _background,
            child: Notional(
              index: row,
              key: UniqueKey(),
            )),
        Container(
            margin: EdgeInsetsDirectional.only(end: _columnSpace),
            color: _background,
            child: MaxPayoff(
              index: row,
              key: UniqueKey(),
            )),
        Container(
          // height: 36,
          alignment: Alignment.centerLeft,
          child: PopupMenuButton<int>(
            offset: const Offset(150, 0),
            onSelected: (result) {
              setState(() {
                if (result == 0) {
                  // add row
                  var deal = weatherModel.deals[row];
                  buySellModel.insert(row, deal.buySell.toString());
                  monthRangeModel.insert(row, deal.monthRange);
                  instrumentModel.insert(row, deal.instrumentType);
                  airportModel.insert(row, deal.airport);
                  strikeModel.insert(row, deal.strike);
                  notionalModel.insert(row, deal.notional);
                  maxPayoffModel.insert(row, deal.maxPayoff);
                  weatherModel.copyRow(row);
                } else if (result == 1) {
                  // delete row
                  weatherModel.removeAt(row);
                  buySellModel.removeAt(row);
                  monthRangeModel.removeAt(row);
                  instrumentModel.removeAt(row);
                  airportModel.removeAt(row);
                  strikeModel.removeAt(row);
                  notionalModel.removeAt(row);
                  maxPayoffModel.removeAt(row);
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 0,
                child: Text('Add row'),
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

    return Table(
      children: [
        TableRow(children: header()),
        for (var i = 0; i < weatherModel.deals.length; i++)
          TableRow(children: instrumentRow(i)),
        _rowSpacer,
      ],
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
