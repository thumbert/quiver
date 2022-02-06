library test.models.weather_model_test;

import 'dart:io';

import 'package:date/date.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/weather/weather_deal.dart';
import 'package:flutter_quiver/models/weather/weather_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/data/latest.dart';

Future<void> tests(String rootUrl) async {
  group('Weather model test', () {
    var model = WeatherModel()
      ..deals = [
        WeatherDeal(
            buySell: 'Buy',
            monthRange: 'Jan-Feb',
            instrumentType: 'HDD swap',
            airport: 'BOS',
            strike: 2000,
            notional: 10000,
            maxPayoff: 3000000.0),
        WeatherDeal(
            buySell: 'Buy',
            monthRange: 'Dec-Mar',
            instrumentType: 'Daily T call',
            airport: 'LGA',
            strike: 45,
            notional: 30000,
            maxPayoff: 5000000),
      ];

    setUp(() async {
      await model.getHistoricalTemperature('BOS');
      await model.getHistoricalTemperature('LGA');
    });
    test('get summary data', () async {
      /// 30 years starting in Jan92-Feb92, ending in Jan21-Feb21
      var term = Term.parse('Jan92-Feb92', UTC);
      var terms = [
        term.interval,
        ...List.generate(
            29, (i) => term.withStartYear(term.startDate.year + i + 1).interval)
      ];
      var s0 = await model.getSummaryData(row: 0, terms: terms);
      var x92 = s0.firstWhere((e) => e['term'] == 'Jan92-Feb92');
      expect(x92['value'], moreOrLessEquals(5000, epsilon: 1e-6));
      var x04 = s0.firstWhere((e) => e['term'] == 'Jan04-Feb04');
      expect(x04['value'], moreOrLessEquals(3000000, epsilon: 1e-6));
      var x20 = s0.firstWhere((e) => e['term'] == 'Jan20-Feb20');
      expect(x20['value'], moreOrLessEquals(-3000000, epsilon: 1e-6));
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;

  await tests(rootUrl);
}
