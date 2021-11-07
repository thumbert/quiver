library models.weather;

import 'package:date/date.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter/material.dart' hide Interval;
import 'package:http/http.dart';
import 'package:elec_server/client/weather/noaa_daily_summary.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';

class WeatherModel extends ChangeNotifier {
  WeatherModel({
    String airportCode = 'BOS',
    String term = 'Jan',
    String underlying = 'Temperature',
    String instrument = 'HDD swap',
    num notional = 1,
    num maxPayoff = 20000000,
    num strike = 1000,
  }) {
    // _airportCode = airportCode;
    // _term = term;
    // _underlying = underlying;
    // _instrument = instrument;
    // _notional = notional;
    // _maxPayoff = maxPayoff;
    // _strike = strike;
    client = NoaaDailySummary(Client(), rootUrl: dotenv.env['rootUrl']!);
  }

  late NoaaDailySummary client;
  // late String _airportCode;
  // late String _term;
  // late String _underlying;
  // late String _instrument;
  // late num _notional;
  // late num _maxPayoff;
  // late num _strike;

  /// airportCode -> 30 years of history
  final _cacheTemps = <String, TimeSeries<num>>{};
  // late Iterable<Map<String,dynamic>> _tableData;

  // set term(String value) {
  //   _term = value;
  //   notifyListeners();
  // }
  //
  // String get term => _term;
  //
  // set underlying(String value) {
  //   _underlying = value;
  //   notifyListeners();
  // }
  //
  // String get underlying => _underlying;
  //
  // set instrument(String value) {
  //   _instrument = value;
  //   notifyListeners();
  // }
  //
  // String get instrument => _instrument;
  //
  // set notional(num value) {
  //   _notional = value;
  //   notifyListeners();
  // }
  //
  // num get notional => _notional;
  //
  // set maxPayoff(num value) {
  //   _maxPayoff = value;
  //   notifyListeners();
  // }
  //
  // num get maxPayoff => _maxPayoff;
  //
  // set strike(num value) {
  //   _strike = value;
  //   notifyListeners();
  // }
  //
  // num get strike => _strike;

  /// Get 30 years data from the webservice.
  Future<TimeSeries<num>> getHistoricalTemperature(String airportCode) async {
    if (!_cacheTemps.containsKey(airportCode)) {
      var _current = Month.fromTZDateTime(TZDateTime.now(UTC));
      var _start = _current.subtract(30 * 12 + 1).start;
      var _end = _current.start;
      var interval = Interval(_start, _end);
      _cacheTemps[airportCode] =
          await client.getDailyHistoricalTemperature(airportCode, interval);
    }
    return _cacheTemps[airportCode]!;
  }

  /// Given an airport code and a month start, end calculate some historical
  /// stats.  For example for Nov-Mar period, the [startMonth] is 11,
  /// [endMonth] is 3.
  /// Return Term, tAvg, HDD, CDD
  List<Map<String, dynamic>> make30YearTable(
      String airportCode, int startMonth, int endMonth) {
    return [];
  }
}
