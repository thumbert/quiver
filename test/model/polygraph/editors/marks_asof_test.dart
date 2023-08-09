library test.models.polygraph.editors.marks_asof_test;

import 'dart:io';
import 'dart:ui';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec/time.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
import 'package:flutter_quiver/models/polygraph/variables/variable_marks_asofdate.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_selection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

Future<void> tests() async {
  group('MarksAsOf test', () {
    test('get forward curve as of 2023-07-27', () async {
      var variable = VariableMarksAsOfDate(
          asOfDate: Date.utc(2023, 7, 27), curveName: 'NG_HENRY_HUB_CME');
      var term = Term.parse('Aug23-Dec27', UTC);
      var data = await variable.get(PolygraphState.service, term);
      expect(data.length, 53);
      expect(data.observationAt(Month.utc(2024, 1)).value, 3.765);
    });

    test('Window with VariableMarksAsOf', () async {
      var tabLayout = TabLayout.getDefault();
      var poly = PolygraphState(
          tabs: [
            PolygraphTab(
                name: 'Tab1',
                layout: tabLayout,
                windows: [
                  PolygraphWindow(
                    term: Term.parse('Aug23-Dec27', IsoNewEngland.location),
                    xVariable: TimeVariable(),
                    yVariables: [
                      VariableMarksAsOfDate(
                        asOfDate: Date.utc(2023, 7, 27),
                        curveName: 'NG_HENRY_HUB_CME',
                        label: 'hh',
                      )
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
      expect(traces.first['y'].length, 53 * 2);
      expect(traces.first['y'].first, 2.492); // for Aug23
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  await tests();
}
