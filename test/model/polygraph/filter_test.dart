library test.models.polygraph.filter_test;

import 'dart:io';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec/time.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/models/polygraph/transforms/fill_transform.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_filter.dart';
import 'package:flutter_quiver/models/polygraph/variables/slope_intercept_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_selection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

Future<void> tests() async {
  group('Time Filter test', () {
    var term = Term.parse('Jan20-Dec23', UTC);
    test('a monthly filter', () {
      var filter = TimeFilter.empty().copyWith(months: {1, 2});
      var months = term.interval.splitLeft((dt) => Month.fromTZDateTime(dt));
      var ts = TimeSeries.fill(months, 1.0);
      expect(filter.apply(ts).toList().length, 8);
      expect(filter.toMongo(), {
        'months': {1, 2}
      });
      var filter2 = TimeFilter.fromMongo({
        'months': {1, 2}
      });
      expect(filter2.apply(ts).toList().length, 8);
      expect(filter.isHourly(), false);
      expect(filter.isDaily(), false);
      expect(filter.isMonthly(), true);
    });
    test('a bucket filter', () {
      var filter = TimeFilter.empty().copyWith(bucket: Bucket.b5x16);
      var ts = TimeSeries.fill(
          Term.parse('Jan20', IsoNewEngland.location).hours(), 1.0);
      expect(filter.apply(ts).toList().length, 352);
      expect(filter.isHourly(), true);
      expect(filter.isDaily(), false);
      expect(filter.isMonthly(), false);
    });
    test('a holiday filter', () {
      var filter = TimeFilter.empty()
          .copyWith(holidays: {Holiday.memorialDay, Holiday.laborDay});
      var ts = TimeSeries.fill(term.days(), 1.0);
      expect(filter.apply(ts).toList().length, 8);
      expect(filter.isHourly(), false);
      expect(filter.isDaily(), true);
      expect(filter.isMonthly(), false);
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  await tests();
}
