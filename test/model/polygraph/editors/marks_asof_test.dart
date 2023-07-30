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
import 'package:flutter_quiver/models/polygraph/variables/variable_selection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

Future<void> tests() async {
  group('MarksAsof test', () {
    test('get curve names on 2023-07-23', () {
      var ts = TimeSeries();
      expect(ts.length, 0);
    });
    // test('Window with horizontal variable', () async {
    //   var tabLayout = TabLayout.getDefault();
    //   var poly = PolygraphState(
    //       config: PolygraphConfig.getDefault(),
    //       tabs: [
    //         PolygraphTab(
    //             name: 'Tab1',
    //             layout: tabLayout,
    //             windows: [
    //               PolygraphWindow(
    //                 term: Term.parse('Jan21-Dec21',
    //                     Iso.newEngland.preferredTimeZoneLocation),
    //                 xVariable: TimeVariable(),
    //                 yVariables: [
    //                   HorizontalLine(
    //                       yIntercept: 1.0,
    //                       timeFilter: TimeFilter.empty()
    //                           .copyWith(bucket: Bucket.b5x16),
    //                       timeAggregation: TimeAggregation(
    //                           frequency: 'month', function: 'count')),
    //                 ],
    //                 layout: PlotlyLayout(width: tabLayout.canvasSize.width, height: tabLayout.canvasSize.height),
    //               ),
    //             ],
    //             activeWindowIndex: 0),
    //       ],
    //       activeTabIndex: 0);
    //   var window = poly.tabs.first.windows.first;
    //   await window.updateCache();
    //   var traces = window.makeTraces();
    //   expect(traces.length, 1);
    //   expect(traces.first['y'].length, 24);
    // });
  });
}

Future<void> main() async {
  initializeTimeZones();
  await tests();
}
