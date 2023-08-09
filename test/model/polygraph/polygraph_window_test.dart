library test.models.polygraph_window_test;

import 'dart:io';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service_local.dart';
import 'package:flutter_quiver/models/polygraph/display/plotly_layout.dart';
import 'package:flutter_quiver/models/polygraph/parser/parser.dart';
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
import 'package:flutter_quiver/models/polygraph/variables/variable_selection.dart';
import 'package:flutter_quiver/models/polygraph/variables/temperature_variable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

Future<void> tests(String rootUrl) async {
  group('Polygraph window, temperature data', () {
    var window = PolygraphWindow(
      term: Term.parse('Jan20-Dec21', UTC),
      xVariable: TimeVariable(),
      yVariables: [
        TemperatureVariable(
          airportCode: 'BOS',
          variable: 'mean',
          frequency: 'daily',
          isForecast: false,
          dataSource: 'NOAA',
          label: 'bos_daily_temp',
        )
      ],
      layout: PlotlyLayout.getDefault(width: 900, height: 600),
    );
    setUp(() async {
      await window.updateCache();
    });
    test('toMap()', () {
      var res = window.toJson();
      expect(
          res.keys.toSet(), {'term', 'tzLocation', 'xVariable', 'yVariables'});
    });

    test('Window with temperature data, UTC', () async {
      var traces = window.makeTraces();
      expect(traces.length, 1);
      expect(traces.first['x'].first, TZDateTime(UTC, 2020));
      expect(traces.first['y'].first, 39.5);
    });
    test('Get monthly average using a TransformedVariable', () async {
      var mTemp = TransformedVariable(
          expression: 'toMonthly(bos_daily_temp, mean)',
          label: 'bos_monthly_temp');
      mTemp.eval(window.cache);
      expect(window.cache.keys.contains('bos_monthly_temp'), true);

      window.yVariables.add(mTemp);
      var traces = window.makeTraces();
      expect(traces.length, 2);
      expect(traces.last['x'].length, 48);
      expect(traces.last['x'].first, TZDateTime(UTC, 2020));
      expect(traces.last['y'].first, 37.98387096774193);

      /// what if it's a parsing error
      mTemp = TransformedVariable(
          expression: 'toMonthly(bos_daily_temp)', // has no average function
          label: 'bos_monthly_temp');
      mTemp.eval(window.cache);
    });

    // test('Window with transformed variable', () async {
    //   var window = PolygraphWindow(
    //     term: Term.parse('Jan20-Mar20', IsoNewEngland.location),
    //     xVariable: TimeVariable(),
    //     yVariables: [
    //       TransformedVariable(
    //           label: 'shape', expression: "hourly_schedule(50, bucket='Peak')"),
    //     ],
    //     layout: PlotlyLayout.getDefault(width: 900, height: 600),
    //   );
    //   await window.updateCache();
    //   var traces = window.makeTraces();
    //   expect(traces.length, 1);
    //   expect(traces.first['x'].first, TZDateTime(IsoNewEngland.location, 2020));
    //   expect(traces.first['y'].first, 36);
    // });

    test('Window with temperature data, local time', () async {
      var location = getLocation('America/New_York');
      var window = PolygraphWindow(
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
        layout: PlotlyLayout.getDefault(width: 900, height: 600),
      );
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
