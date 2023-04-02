library test.models.polygraph_window_test;

import 'dart:io';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_tab.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_window.dart';
import 'package:flutter_quiver/models/polygraph/transforms/fill_transform.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_filter.dart';
import 'package:flutter_quiver/models/polygraph/variables/slope_intercept_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/time_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_selection.dart';
import 'package:flutter_quiver/models/polygraph/variables/temperature_variable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

Future<void> tests(String rootUrl) async {
  group('Polygraph window', () {
    test('Window with temperature data', () async {
      var window = PolygraphWindow.getDefault();
      await window.updateCache();
      var traces = window.makeTraces();
      expect(traces.length, 1);
      expect(traces.first['x'].first, TZDateTime(UTC, 2020));
      expect(traces.first['y'].first, 39.5);
    });
    test('Window with temperature data, local time', () async {
      var location = getLocation('America/New_York');
      var window = PolygraphWindow(
          term: Term.parse('Jan20-Dec21', location),
          tzLocation: location,
          xVariable: TimeVariable(),
          yVariables: [
            TemperatureVariable(
              airportCode: 'BOS',
              variable: 'min',
              frequency: 'daily',
              isForecast: false,
              dataSource: 'NOAA',
              id: 'bos_min',
            )
          ]);
      await window.updateCache();
      var traces = window.makeTraces();
      expect(traces.length, 1);
      expect(traces.first['x'].first, TZDateTime(location, 2020));
      expect(traces.first['y'].first, 36);
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;
  await tests(rootUrl);
}
