library test.models.polygraph.editors.horizontal_line_test;

import 'dart:io';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec/time.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/polygraph/editors/horizontal_line.dart';
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
import 'package:flutter_test/flutter_test.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

Future<void> tests() async {
  group('Horizontal line test', () {
    var term = Term.parse('Jan20-Dec21', UTC);
    test('count number of onpeak hours by month', () {
      var yVariable = HorizontalLine(
          yIntercept: 1.0,
          timeFilter: TimeFilter.empty().copyWith(bucket: Bucket.b5x16),
          timeAggregation:
              TimeAggregation(frequency: 'month', function: 'count'));
      var ts = yVariable.timeSeries(term);
      expect(ts.length, 24);
    });
    test('Window with horizontal variable', () async {
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
                        HorizontalLine(
                            yIntercept: 1.0,
                            timeFilter: TimeFilter.empty()
                                .copyWith(bucket: Bucket.b5x16),
                            timeAggregation: TimeAggregation(
                                frequency: 'month', function: 'count')),
                      ]),
                ],
                activeWindowIndex: 0),
          ],
          activeTabIndex: 0);
      var window = poly.tabs.first.windows.first;
      await window.updateCache();
      var traces = window.makeTraces();
      expect(traces.length, 1);
      expect(traces.first['y'].length, 24);
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  await tests();
}
