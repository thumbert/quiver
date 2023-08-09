library test.models.polygraph.editors.marks_historical_view_test;

import 'dart:io';
import 'dart:ui';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec/time.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service_local.dart';
import 'package:flutter_quiver/models/polygraph/display/plotly_layout.dart';
import 'package:flutter_quiver/models/polygraph/editors/horizontal_line.dart';
import 'package:flutter_quiver/models/polygraph/editors/marks_asof.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_tab.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_window.dart';
import 'package:flutter_quiver/models/polygraph/transforms/fill_transform.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_filter.dart';
import 'package:flutter_quiver/models/polygraph/variables/slope_intercept_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/time_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_marks_historical_view.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_selection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

Future<void> tests() async {
  group('MarksHistoricalView test', () {
    test('get HH prices for Jan24 contract', () async {
      var variable = VariableMarksHistoricalView(
          curveName: 'NG_HENRY_HUB_CME',
          forwardStrip: Term.parse('Jan24-Feb24', UTC));
      var term = Term.parse('1Jan23-27Jul23', UTC);
      var data = await variable.get(PolygraphState.service, term);
      expect(data.length, 49);
      expect(data.first.value, 3.82915);
    });

    test('Window with VariableMarksHistoricalView', () async {
      var tabLayout = TabLayout.getDefault();
      var poly = PolygraphState(
          tabs: [
            PolygraphTab(
                name: 'Tab1',
                layout: tabLayout,
                windows: [
                  PolygraphWindow(
                    term: Term.parse('1Jan23-27Jul23', IsoNewEngland.location),
                    xVariable: TimeVariable(),
                    yVariables: [
                      VariableMarksHistoricalView(
                          curveName: 'NG_HENRY_HUB_CME',
                          label: 'hh',
                          forwardStrip: Term.parse('Jan24-Feb24', UTC))
                    ],
                    layout: PlotlyLayout(
                        width: tabLayout.canvasSize.width,
                        height: tabLayout.canvasSize.height),
                  ),
                ],
                activeWindowIndex: 0),
          ],
          activeTabIndex: 0);
      var window = poly.tabs.first.windows.first;
      await window.updateCache();
      var traces = window.makeTraces();
      expect(traces.length, 1);
      expect(traces.first['y'].length, 49*2);
      expect(traces.first['y'].first, 3.82915);
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  await tests();
}
