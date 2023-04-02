library test.models.polygraph_test;

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
  group('Tabs', () {
    test('Add/Remove tabs', () {
      var poly = PolygraphState.getDefault();
      poly.addTab();
      poly.addTab();
      expect(poly.tabs.length, 3);
      expect(
          poly.tabs.map((e) => e.name).toList(), ['Tab 1', 'Tab 2', 'Tab 3']);

      // delete tab
      poly.deleteTab(1);
      expect(poly.tabs.map((e) => e.name).toList(), ['Tab 1', 'Tab 3']);

      // add another tab, tabs get added at the end
      poly.addTab();
      expect(
          poly.tabs.map((e) => e.name).toList(), ['Tab 1', 'Tab 3', 'Tab 4']);
    });

    test('Simple tab with temperature data', () {
      var location = getLocation('America/New_York');
      var poly = PolygraphState(
          config: PolygraphConfig.getDefault(), tabs: [PolygraphTab.empty()]);
      poly.tabs.first.windows.first = PolygraphWindow(
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
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;
  await tests(rootUrl);
}
