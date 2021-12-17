library models.weather.weather_deal;

import 'package:date/date.dart';
import 'package:elec/risk_system.dart';
import 'package:elec/calculators/weather.dart';
import 'package:elec/src/weather/lib_weather_utils.dart';
import 'package:flutter_quiver/models/weather/month_range_model.dart';
import 'package:timeseries/timeseries.dart';

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
    weatherInstrument = _setup();
  }

  late final BuySell buySell;
  final String monthRange; // e.g. 'Jan-Feb'

  /// Allowed instrumentTypes come from models/weather/instrument_model.dart
  final String instrumentType;
  final String airport;
  final num strike;
  final num notional;
  final num maxPayoff;
  late WeatherInstrument weatherInstrument;

  /// Calculate the value of this deal for the given term
  num cappedValue(Interval interval) {
    weatherInstrument.term = interval;
    weatherInstrument.strike =
        TimeSeries.fromIterable([IntervalTuple(interval, strike)]);
    var value = weatherInstrument.value();
    return weatherInstrument.cappedValue(value);
  }

  /// Create the weather instrument associated with this row in the UI.
  /// Set the term to last available.
  WeatherInstrument _setup() {
    var _monthRange = MonthRangeModel.ranges[monthRange]!;
    var term = makeHistoricalTerm(_monthRange[0], _monthRange[1], n: 1).first;

    late WeatherInstrument weatherInstrument;
    if (instrumentType.contains('swap')) {
      /// it's either an 'HDD swap' or a 'CDD swap'
      if (instrumentType.contains('HDD')) {
        weatherInstrument = HddSwap(
          buySell: buySell,
          term: term,
          quantity: notional,
          strike: TimeSeries.fromIterable([IntervalTuple(term, strike)]),
          maxPayoff: maxPayoff,
        );
      } else if (instrumentType.contains('CDD')) {
        weatherInstrument = CddSwap(
          buySell: buySell,
          term: term,
          quantity: notional,
          strike: TimeSeries.fromIterable([IntervalTuple(term, strike)]),
          maxPayoff: maxPayoff,
        );
      }
    } else {
      /// it's an option
      var callPut =
          instrumentType.contains('call') ? CallPut.call : CallPut.put;
      if (instrumentType == 'HDD call' || instrumentType == 'HDD put') {
        weatherInstrument = HddOption(
            buySell: buySell,
            term: term,
            quantity: notional,
            strike: TimeSeries.fromIterable([IntervalTuple(term, strike)]),
            callPut: callPut);
      } else if (instrumentType == 'CDD call' || instrumentType == 'CDD put') {
        weatherInstrument = CddOption(
            buySell: buySell,
            term: term,
            quantity: notional,
            strike: TimeSeries.fromIterable([IntervalTuple(term, strike)]),
            callPut: callPut);
      } else if (instrumentType.contains('Daily T')) {
        /// 'Daily T call' or 'Daily T put'
        weatherInstrument = DailyTemperatureOption(
            buySell: buySell,
            term: term,
            quantity: notional,
            strike: TimeSeries.fromIterable([IntervalTuple(term, strike)]),
            callPut: callPut);
      }
    }

    return weatherInstrument;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'buySell': buySell.toString(),
      'monthRange': monthRange,
      'instrumentType': instrumentType,
      'airport': airport,
      'strike': strike,
      'notional': notional,
      'maxPayoff': maxPayoff,
    };
  }
}
