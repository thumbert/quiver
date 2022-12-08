library test.models.pool_load_stats_test;

import 'dart:io';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec/ftr.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/ftr_path/data_model.dart';
import 'package:flutter_quiver/models/pool_load_stats/pool_load_stats_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

Future<void> tests(String rootUrl) async {
  var state = PoolLoadStatsState.getDefault();
  state = state.copyWith(term: Term.parse('1Jan18-31Aug22', UTC));
  group('Pool load statistics tests', () {
    setUp(() async {
      await state.getData();
    });
    test('make traces for default data', () async {
      var traces = state.makeTraces();
      expect(traces.length, 1);
      expect(traces.first['x'].first, 6.5); // Temperature
      expect(traces.first['y'].first, 407226.122); // Energy
      expect(traces.first['text'].first, '2018-01-01');
    });
    test('make traces for default data, color = Year', () async {
      state = state.copyWith(colorBy: 'Year');
      var traces = state.makeTraces();
      expect(traces.length, 5);
      expect(traces.first['x'].first, 6.5); // Temperature
      expect(traces.first['y'].first, 407226.122); // Energy
      expect(traces.first['text'].first, '2018-01-01');
    });

  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;

  await tests(rootUrl);
}
