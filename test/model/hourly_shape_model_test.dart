library test.models.mcc_surfer_test;

import 'dart:io';

import 'package:date/date.dart';
import 'package:elec/time.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/hourly_shape/hourly_shape_model.dart';
import 'package:flutter_quiver/models/hourly_shape/day_filter.dart';
import 'package:flutter_quiver/models/hourly_shape/settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

Future<void> tests(String rootUrl) async {
  group('Hourly shape model test', () {
    setUp(() async {
      await HourlyShapeModel.getData(HourlyShapeModel.allNames.first);
    });
    test('day filter with years', () {
      final dayFilter = DayFilter.empty().copyWith(years: {2021, 2023});
      final term = Term.parse('1Jan20-31Dec23', UTC);
      final days = dayFilter.getDays(term);
      expect(days.map((e) => e.year).toSet(), {2021, 2023});
    });
    test('day filter with years, months', () {
      final dayFilter =
          DayFilter.empty().copyWith(years: {2021, 2023}, months: {1, 2});
      final term = Term.parse('1Jan20-31Dec23', UTC);
      final days = dayFilter.getDays(term);
      expect(days.map((e) => e.year).toSet(), {2021, 2023});
      expect(days.map((e) => e.month).toSet(), {1, 2});
      expect(days.length, 118);
    });
    test('day filter with years, months, day of month', () {
      final dayFilter = DayFilter.empty()
          .copyWith(years: {2021, 2023}, months: {1, 2}, days: {10, 11, 12});
      final term = Term.parse('1Jan20-31Dec23', UTC);
      final days = dayFilter.getDays(term);
      expect(days.map((e) => e.year).toSet(), {2021, 2023});
      expect(days.map((e) => e.month).toSet(), {1, 2});
      expect(days.map((e) => e.day).toSet(), {10, 11, 12});
      expect(days.length, 12);
    });
    test('day filter with years, NERC holidays', () {
      final dayFilter = DayFilter.empty()
          .copyWith(years: {2021, 2023}, holidays: Calendar.nerc.holidays);
      final term = Term.parse('1Jan20-31Dec23', UTC);
      final days = dayFilter.getDays(term);
      expect(days.map((e) => e.year).toSet(), {2021, 2023});
      expect(days.length, 12); // 6 NERC holidays / year
    });
    test('day filter with years, months, NERC holidays', () {
      final dayFilter = DayFilter.empty().copyWith(
          years: {2021, 2023}, months: {4}, holidays: Calendar.nerc.holidays);
      final term = Term.parse('1Jan20-31Dec23', UTC);
      final days = dayFilter.getDays(term);
      expect(days.isEmpty, true); // no NERC holidays in April
    });
    test('traces for median by year', () {
      final dayFilter = DayFilter.empty()
          .copyWith(years: {2021}, months: {3}, days: {10, 11, 12, 14, 15});
      var traces =
          HourlyShapeModel.getTraces(dayFilter, SettingsForMedianByYear());
      expect(traces.length, 1); // one year
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;

  await tests(rootUrl);
}
