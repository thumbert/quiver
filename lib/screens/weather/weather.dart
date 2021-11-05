library screens.weather.weather;

import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/widgets.dart' hide Interval;
import 'package:flutter_quiver/models/weather/airport_model.dart';
import 'package:flutter_quiver/models/weather/instrument_model.dart';
import 'package:flutter_quiver/models/weather/month_range_model.dart';
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

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(
          create: (context) => AirportModel(airportCode: airportCode)),
      ChangeNotifierProvider(
          create: (context) => MonthRangeModel(monthRange: monthRange)),
      ChangeNotifierProvider(
          create: (context) =>
              InstrumentModel(instrument: InstrumentModel.instruments.first)),
      ChangeNotifierProvider(create: (context) => WeatherModel()),
    ], child: const WeatherUi());
  }
}
