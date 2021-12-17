library screens.weather.weather;

import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/widgets.dart' hide Interval;
import 'package:flutter_quiver/models/common/multiple/buysell_model.dart';
import 'package:flutter_quiver/models/weather/airport_model.dart';
import 'package:flutter_quiver/models/weather/instrument_model.dart';
import 'package:flutter_quiver/models/common/multiple/maxpayoff_model.dart';
import 'package:flutter_quiver/models/weather/month_range_model.dart';
import 'package:flutter_quiver/models/common/multiple/notional_model.dart';
import 'package:flutter_quiver/models/common/multiple/strike_model.dart';
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
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => BuySellModel()),
      ChangeNotifierProvider(create: (context) => MonthRangeModel()),
      ChangeNotifierProvider(create: (context) => InstrumentModel()),
      ChangeNotifierProvider(create: (context) => AirportModel()),
      ChangeNotifierProvider(create: (context) => StrikeModel()),
      ChangeNotifierProvider(create: (context) => NotionalModel()),
      ChangeNotifierProvider(create: (context) => MaxPayoffModel()),
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
                  maxPayoff: 3000000),
              WeatherDeal(
                  buySell: 'Sell',
                  monthRange: 'Dec-Mar',
                  instrumentType: 'Daily T call',
                  airport: 'LGA',
                  strike: 45,
                  notional: 30000,
                  maxPayoff: 5000000),
            ]),
    ], child: const WeatherUi());
  }
}
