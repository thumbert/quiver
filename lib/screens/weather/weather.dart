library screens.weather.weather;

import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/widgets.dart' hide Interval;
import 'package:flutter_quiver/models/common/buysell_model.dart';
import 'package:flutter_quiver/models/weather/airport_model.dart';
import 'package:flutter_quiver/models/weather/instrument_model.dart';
import 'package:flutter_quiver/models/weather/maxpayoff_model.dart';
import 'package:flutter_quiver/models/weather/month_range_model.dart';
import 'package:flutter_quiver/models/weather/notional_model.dart';
import 'package:flutter_quiver/models/weather/strike_model.dart';
import 'package:flutter_quiver/models/weather/weather_deal.dart';
import 'package:flutter_quiver/models/weather/weather_model.dart';
import 'package:flutter_quiver/screens/weather/weather_ui.dart';
import 'package:provider/provider.dart';

class Weather extends StatefulWidget {
  const Weather({Key? key}) : super(key: key);

  @override
  _WeatherState createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  final airportCode = 'BOS';
  final monthRange = 'Jan-Feb';
  final strike = 1250;
  final notional = 10000;
  final maxPayoff = 3000000;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => BuySellModel(buySell: 'Buy')),
      ChangeNotifierProvider(
          create: (context) => MonthRangeModel(monthRange: monthRange)),
      ChangeNotifierProvider(
          create: (context) =>
              InstrumentModel(instrument: InstrumentModel.instruments.first)),
      ChangeNotifierProvider(
          create: (context) => AirportModel(airportCode: airportCode)),
      ChangeNotifierProvider(create: (context) => StrikeModel(strike: strike)),
      ChangeNotifierProvider(
          create: (context) => NotionalModel(notional: notional)),
      ChangeNotifierProvider(
          create: (context) => MaxPayoffModel(maxPayoff: maxPayoff)),
      ChangeNotifierProvider(
          create: (context) => WeatherModel()
            ..deals = [
              WeatherDeal(
                  buySell: 'Buy',
                  monthRange: 'Jan-Feb',
                  instrumentType: 'HDD swap',
                  airport: 'BOS',
                  strike: 1250,
                  notional: 10000,
                  maxPayoff: 3000000)
            ]),
    ], child: const WeatherUi());
  }
}
