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
  group('Polygraph Tab tests', () {
    test('Empty tab', () {
      var tab = PolygraphTab.empty(name: 'Tab 1');
      expect(tab.windows.length, 1);
      expect(tab.activeWindowIndex, 0);
      expect(tab.rootNode.width(), 900);
      expect(tab.rootNode.height(), 600);
    });

    test('get valid tab name', (){
      var poly = PolygraphState.getDefault();
      poly.deleteTab(2);
      poly.deleteTab(1);

      expect(poly.tabs.length, 1);
      expect(poly.getValidTabName(tabIndex: 0, suggestedName: 'Tab 1'), 'Tab 1');
      // 'Tab 2' is a valid name for tab index 0
      expect(poly.getValidTabName(tabIndex: 0, suggestedName: 'Tab 2'), 'Tab 2');
      poly = poly.copyWith(tabs: [poly.tabs.first.copyWith(name: 'Boo')]);
      expect(poly.getValidTabName(tabIndex: 0, suggestedName: 'Tab 1'), 'Tab 1');
      expect(poly.getValidTabName(tabIndex: 0, suggestedName: ''), 'Tab 1');
      /// add another tab
      poly.addTab();
      expect(poly.tabs.map((e) => e.name).toList(), ['Boo', 'Tab 1']);
      // can't rename tab index 0 to 'Tab 1', but you can to 'Tab 2'
      expect(poly.getValidTabName(tabIndex: 0, suggestedName: 'Tab 1'), 'Tab 2');

      /// Rename tab to existing tab name, maintains name
      poly = PolygraphState.getDefault();
      poly.addTab();
      expect(poly.tabs.map((e) => e.name).toList(), ['Tab 1', 'Tab 2', 'Tab 3', 'Tab 4']);
      // can't rename tab index 1 to 'Tab 1', but you stay at 'Tab 2'
      expect(poly.getValidTabName(tabIndex: 1, suggestedName: 'Tab 1'), 'Tab 2');

      /// Delete tabs
      poly = PolygraphState.getDefault();
      expect(poly.tabs.map((e) => e.name).toList(), ['Tab 1', 'Tab 2', 'Tab 3']);
      poly.deleteTab(1);
      poly.addTab();
      expect(poly.tabs.map((e) => e.name).toList(), ['Tab 1', 'Tab 3', 'Tab 2']);
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
      expect(poly.tabs.first.rootNode.width(), 900);
      expect(poly.tabs.first.rootNode.height(), 600);

      var tab = poly.tabs[1];
      expect(tab.windows.length, 1);

      // split main window horizontally
      var tab2 = tab.splitWindowHorizontally(0);
      var nodes = tab2.rootNode.flatten();
      expect(tab2.windows.length, 2);
      expect(nodes[0].width(), 900.0);
      expect(nodes[0].height(), 300.0);
      expect(nodes[1].width(), 900.0);
      expect(nodes[1].height(), 300.0);

      // split the top window vertically
      var tab3 = tab2.splitWindowVertically(0);
      nodes = tab3.rootNode.flatten();
      expect(tab3.windows.length, 3);
      expect(nodes[0].width(), 450.0);
      expect(nodes[0].height(), 300.0);
      expect(nodes[1].width(), 450.0);
      expect(nodes[1].height(), 300.0);
      expect(nodes[2].width(), 900.0);
      expect(nodes[2].height(), 300.0);

      // add another window
      var tab4 = tab3.splitWindowVertically(2);
      nodes = tab3.rootNode.flatten();
      expect(tab4.windows.length, 4);
      expect(nodes[3].width(), 450.0);
      expect(nodes[3].height(), 300.0);
    });

    test('Remove windows from a tab', () {
      var tab = PolygraphTab.empty(name: 'Tab 1');
      var nodes = tab.rootNode.flatten();
      expect(tab.windows.length, 1);
      expect(nodes.first.width(), 900);
      expect(nodes.first.height(), 600);

      /// make a column with 4 windows
      tab = tab.splitWindowHorizontally(0);
      tab = tab.splitWindowHorizontally(0);
      tab = tab.splitWindowHorizontally(2);
      nodes = tab.rootNode.flatten();
      expect(tab.windows.length, 4);
      expect(nodes[3].width(), 900.0);
      expect(nodes[3].height(), 150.0);

      /// remove one window
      tab = tab.removeWindow(3);
      nodes = tab.rootNode.flatten();
      expect(tab.windows.length, 3);
      expect(nodes[0].width(), 900.0);
      expect(nodes[0].height(), 150.0);
      expect(nodes[2].width(), 900.0);
      expect(nodes[2].height(), 300.0);

      /// remove another window
      tab = tab.removeWindow(2);
      nodes = tab.rootNode.flatten();
      expect(tab.windows.length, 2);
      expect(nodes[0].width(), 900.0);
      expect(nodes[0].height(), 300.0);
    });


    test('Add window to tab with temperature data', () {
      var location = getLocation('America/New_York');
      var poly = PolygraphState(
          tabs: [PolygraphTab.empty(name: 'Tab 1')],
          activeTabIndex: 0,
      );
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
              label: 'bos_min',
            )
          ],
          layout: PlotlyLayout.getDefault(),
      );
      /// TO BE CONTINUED ...
      /// when I add a window to this tab, the existing variable in disappear

    });

    test('Hide/Unhide variable', () async {
      var poly = PolygraphState(
          tabs: [
            PolygraphTab(
                name: 'Tab1',
                rootNode: SingleNode(900, 600),
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
                          ..label = 'hub_da_lmp',
                        TransformedVariable(
                            expression: 'toMonthly(hub_da_lmp, mean)',
                            label: 'monthly_mean'),
                      ],
                    layout: PlotlyLayout.getDefault(),
                  ),
                ],
              activeWindowIndex: 0,
            ),
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
