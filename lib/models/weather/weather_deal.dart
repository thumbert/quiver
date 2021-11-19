library models.weather.weather_deal;

import 'package:elec/risk_system.dart';

class WeatherDeal {
  WeatherDeal(
      {required String buySell,
      required this.monthRange,
      required this.instrumentType,
      required this.airport,
      required this.strike,
      required this.notional,
      required this.maxPayoff}) {
    this.buySell = BuySell.parse(buySell);
  }

  late BuySell buySell;
  String monthRange;
  String instrumentType;
  String airport;
  num strike;
  num notional;
  num maxPayoff;
}
