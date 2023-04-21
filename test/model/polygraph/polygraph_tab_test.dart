library test.models.polygraph_test;

import 'dart:io';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec/risk_system.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/polygraph/display/variable_display_config.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_tab.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_variable.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_window.dart';
import 'package:flutter_quiver/models/polygraph/transforms/fill_transform.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_filter.dart';
import 'package:flutter_quiver/models/polygraph/variables/slope_intercept_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/time_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_lmp.dart';
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
          poly.tabs.map((e) => e.name).toList(), ['Tab 1', 'Tab 3', 'Tab 2']);
    });

    test('Simple tab with temperature data', () {
      var location = getLocation('America/New_York');
      var poly = PolygraphState(
          config: PolygraphConfig.getDefault(),
          tabs: [PolygraphTab.empty()],
          activeTabIndex: 0);
      poly.tabs.first.windows.first = PolygraphWindow(
          term: Term.parse('Jan20-Dec21', location),
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

    test('Hide/Unhide variable', () async {
      var poly = PolygraphState(
          config: PolygraphConfig.getDefault(),
          tabs: [
            PolygraphTab(
                name: 'Tab1',
                windowLayout: WindowLayout(rows: 1, cols: 1),
                windows: [
                  PolygraphWindow(
                      term: Term.parse('Jan21-Dec21',
                          Iso.newEngland.preferredTimeZoneLocation),
                      xVariable: TimeVariable(),
                      yVariables: [
                        VariableLmp(
                            iso: Iso.newEngland,
                            market: Market.da,
                            ptid: 4000,
                            lmpComponent: LmpComponent.lmp)
                          ..id = 'hub_da_lmp'
                          ..label = 'hub_da_lmp',
                        TransformedVariable(
                            expression: 'toMonthly(hub_da_lmp, mean)',
                            id: 'monthly_mean'),
                      ]),
                ],
                activeWindowIndex: 0),
          ],
          activeTabIndex: 0);
      var window = poly.tabs.first.windows.first;
      await window.updateCache();
      var traces = window.makeTraces();
      expect(traces.length, 2);
      expect(
          traces[0]['line']['color'],
          VariableDisplayConfig.colorToHex(
              VariableDisplayConfig.defaultColors[0]));
      expect(
          traces[1]['line']['color'],
          VariableDisplayConfig.colorToHex(
              VariableDisplayConfig.defaultColors[1]));
      // hide first variable
      window.yVariables.first.isHidden = true;
      traces = window.makeTraces();
      expect(traces.length, 1); // only one trace now
      expect(
          traces[0]['line']['color'],
          VariableDisplayConfig.colorToHex(VariableDisplayConfig
              .defaultColors[1])); // keep the previous color
      // show first variable again
      window.yVariables.first.isHidden = false;
      traces = window.makeTraces();
      expect(traces.length, 2); // back to two traces again
      expect(
          traces[0]['line']['color'],
          VariableDisplayConfig.colorToHex(
              VariableDisplayConfig.defaultColors[0]));
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;
  await tests(rootUrl);
}
