library test.models.polygraph_test;

import 'dart:io';
import 'dart:ui';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec/risk_system.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/polygraph/display/plotly_layout.dart';
import 'package:flutter_quiver/models/polygraph/display/variable_display_config.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_tab.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_variable.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_window.dart';
import 'package:flutter_quiver/models/polygraph/variables/time_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_lmp.dart';
import 'package:flutter_quiver/models/polygraph/variables/temperature_variable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

Future<void> tests(String rootUrl) async {
  group('Tab tests', () {
    test('Empty tab', () {
      var tab = PolygraphTab.empty(name: 'Tab 1');
      expect(tab.windows.length, 1);
      expect(tab.activeWindowIndex, 0);
      expect(tab.layout.rows, 1);
      expect(tab.layout.cols, 1);
      expect(tab.layout.canvasSize, const Size(900.0, 600.0));
    });

    test('Tab layout, add windows', () {
      var layout = TabLayout(rows: 1, cols: 1, canvasSize: const Size(900.0, 600.0));
      layout = layout.addWindow();
      expect(layout.rows, 2);
      expect(layout.cols, 1);

      layout = layout.addWindow();
      expect(layout.rows, 3);
      expect(layout.cols, 1);

      layout = layout.addWindow();
      expect(layout.rows, 2);
      expect(layout.cols, 2);

      layout = layout.addWindow();
      expect(layout.rows, 5);
      expect(layout.cols, 1);

      layout = layout.addWindow();
      expect(layout.rows, 3);
      expect(layout.cols, 2);

      layout = layout.addWindow();
      expect(layout.rows, 7);
      expect(layout.cols, 1);

      layout = layout.addWindow();
      expect(layout.rows, 4);
      expect(layout.cols, 2);

      layout = layout.addWindow();
      expect(layout.rows, 4);
      expect(layout.cols, 2);
    });

    test('Tab layout, remove windows', () {
      var layout = TabLayout(rows: 1, cols: 1, canvasSize: const Size(900.0, 600.0));
      layout = layout.addWindow();
      layout = layout.addWindow();
      layout = layout.addWindow();
      layout = layout.addWindow();
      layout = layout.addWindow();
      layout = layout.addWindow();
      layout = layout.addWindow();
      expect(layout.rows, 4);
      expect(layout.cols, 2);

      layout = layout.removeWindow();
      expect(layout.rows, 7);
      expect(layout.cols, 1);

      layout = layout.removeWindow();
      expect(layout.rows, 3);
      expect(layout.cols, 2);

      layout = layout.removeWindow();
      expect(layout.rows, 5);
      expect(layout.cols, 1);

      layout = layout.removeWindow();
      expect(layout.rows, 2);
      expect(layout.cols, 2);

      layout = layout.removeWindow();
      expect(layout.rows, 3);
      expect(layout.cols, 1);

      layout = layout.removeWindow();
      expect(layout.rows, 2);
      expect(layout.cols, 1);

      layout = layout.removeWindow();
      expect(layout.rows, 1);
      expect(layout.cols, 1);

      layout = layout.removeWindow();
      expect(layout.rows, 1);
      expect(layout.cols, 1);
    });

    test('Add/Remove tabs', () {
      var poly = PolygraphState.getDefault();
      expect(
          poly.tabs.map((e) => e.name).toList(), ['Tab 1', 'Tab 2', 'Tab 3']);
      poly.addTab();
      poly.addTab();
      expect(poly.tabs.length, 5);
      expect(poly.tabs.map((e) => e.name).toList(),
          ['Tab 1', 'Tab 2', 'Tab 3', 'Tab 4', 'Tab 5']);

      // delete tab
      poly.deleteTab(1);
      expect(poly.tabs.map((e) => e.name).toList(),
          ['Tab 1', 'Tab 3', 'Tab 4', 'Tab 5']);

      // add another tab, tabs get added at the end
      poly.addTab();
      expect(poly.tabs.map((e) => e.name).toList(),
          ['Tab 1', 'Tab 3', 'Tab 4', 'Tab 5', 'Tab 2']);
    });

    test('Add windows to a tab', () {
      var poly = PolygraphState.getDefault();
      expect(poly.tabs.first.layout.canvasSize, const Size(900.0, 600.0));

      var tab = poly.tabs[1];
      expect(tab.windows.length, 1);

      var tab2 = tab.addWindow();
      expect(tab2.windows.length, 2);
      expect(tab2.layout.rows, 2);
      expect(tab2.layout.cols, 1);
      expect(tab2.windows[0].layout.width, 900.0);
      expect(tab2.windows[0].layout.height, 300.0);
      expect(tab2.windows[1].layout.width, 900.0);
      expect(tab2.windows[1].layout.height, 300.0);

      // add another window
      var tab3 = tab2.addWindow();
      expect(tab3.windows.length, 3);
      expect(tab3.layout.rows, 3);
      expect(tab3.layout.cols, 1);
      expect(tab3.windows[0].layout.width, 900.0);
      expect(tab3.windows[0].layout.height, 200.0);

      // add another window
      var tab4 = tab3.addWindow();
      expect(tab4.windows.length, 4);
      expect(tab4.layout.rows, 2);
      expect(tab4.layout.cols, 2);
      expect(tab4.windows[0].layout.width, 450.0);
      expect(tab4.windows[0].layout.height, 300.0);
    });

    test('Remove windows from a tab', () {
      var tab = PolygraphTab.empty(name: 'Tab 1');
      tab = tab.copyWith(layout: tab.layout.copyWith(canvasSize: const Size(900.0, 600.0)));
      expect(tab.windows.length, 1);
      tab = tab.addWindow();
      tab = tab.addWindow();
      tab = tab.addWindow();
      tab = tab.addWindow();
      tab = tab.addWindow();
      tab = tab.addWindow();
      tab = tab.addWindow();
      expect(tab.windows.length, 8);
      expect(tab.layout.rows, 4);
      expect(tab.layout.cols, 2);

      tab = tab.removeWindow(7);
      expect(tab.windows.length, 7);
      expect(tab.layout.rows, 7);
      expect(tab.layout.cols, 1);
      expect(tab.windows.first.layout.width, 900.0);
      expect(tab.windows.first.layout.height, 600.0/7);

      tab = tab.removeWindow(6);
      expect(tab.windows.length, 6);
      expect(tab.layout.rows, 3);
      expect(tab.layout.cols, 2);
      expect(tab.windows.first.layout.width, 450.0);
      expect(tab.windows.first.layout.height, 200.0);

      tab = tab.removeWindow(5);
      expect(tab.windows.length, 5);
      expect(tab.layout.rows, 5);
      expect(tab.layout.cols, 1);
      expect(tab.windows.first.layout.width, 900.0);
      expect(tab.windows.first.layout.height, 120.0);

      tab = tab.removeWindow(4);
      tab = tab.removeWindow(3);
      tab = tab.removeWindow(2);
      expect(tab.windows.length, 2);
      expect(tab.layout.rows, 2);
      expect(tab.layout.cols, 1);
      expect(tab.windows.first.layout.width, 900.0);
      expect(tab.windows.first.layout.height, 300.0);

      tab = tab.removeWindow(1);
      tab = tab.removeWindow(0);
      expect(tab.windows.length, 1);
      expect(tab.layout.rows, 1);
      expect(tab.layout.cols, 1);
      expect(tab.windows.first.layout.width, 900.0);
      expect(tab.windows.first.layout.height, 600.0);
    });

    test('Add window to tab with temperature data', () {
      var location = getLocation('America/New_York');
      var poly = PolygraphState(
          config: PolygraphConfig.getDefault(),
          tabs: [PolygraphTab.empty(name: 'Tab 1')],
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
          ],
          layout: PlotlyLayout.getDefault(width: 900, height: 600),
      );
      /// TO BE CONTINUED ...
      /// when I add a window to this tab, the existing variable in disappear

    });

    test('Hide/Unhide variable', () async {
      var poly = PolygraphState(
          config: PolygraphConfig.getDefault(),
          tabs: [
            PolygraphTab(
                name: 'Tab1',
                layout: TabLayout.getDefault(),
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
                      ],
                    layout: PlotlyLayout.getDefault(width: 900, height: 600),
                  ),
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
