library test.models.polygraph.parser.parser_test;

import 'dart:io';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service_local.dart';
import 'package:flutter_quiver/models/polygraph/parser/parser.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_tab.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_window.dart';
import 'package:flutter_quiver/models/polygraph/transforms/fill_transform.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_filter.dart';
import 'package:flutter_quiver/models/polygraph/variables/slope_intercept_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/time_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/transformed_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_selection.dart';
import 'package:flutter_quiver/models/polygraph/variables/temperature_variable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

Future<void> tests(String rootUrl) async {
  // var service = DataServiceLocal(rootUrl: rootUrl);
  group('Polygraph parser test', () {
    // test('parser functions', () {
    //   var res = parser.parse('sum2(2,3)');
    //   print(res.isSuccess);
    //   print(res.value.eval({}));
    //   expect(true, true);
    // });

    test('parse toMonthly(bos_daily_temp, mean)', () async {
      var location = getLocation('America/New_York');
      var term = Term.parse('Jan20-Dec21', location);
      var window = PolygraphWindow(
          term: term,
          xVariable: TimeVariable(),
          yVariables: [
            TemperatureVariable(
              airportCode: 'BOS',
              variable: 'mean',
              frequency: 'daily',
              isForecast: false,
              dataSource: 'NOAA',
              id: 'bos_daily_temp',
            ),
            TransformedVariable(
                expression: 'toMonthly(bos_daily_temp, mean)',
                id: 'bos_monthly_temp'),
          ]);
      await window.updateCache();
      expect(window.cache.keys.toSet(), {'bos_daily_temp', 'bos_monthly_temp'});
      var ts = window.cache['bos_monthly_temp'] as TimeSeries<num>;
      expect(ts.observationAt(Month(2020, 4, location: location)).value, 44.55);
      //
      // generate an error on a transformed variable, unknown function
      window.yVariables[1] = TransformedVariable(
          expression: 'toMonthly(bos_daily_temp, mix)',
          id: 'bos_monthly_temp');
      await window.updateCache();
      expect(window.cache.keys.toSet(), {'bos_daily_temp'});
      var tv = window.yVariables[1] as TransformedVariable;
      expect(tv.error, 'Unsupported aggregation function: mix');
      //
      // generate an error on a transformed variable, wrong arity
      window.yVariables[1] = TransformedVariable(
          expression: 'toMonthly(bos_daily_temp)',
          id: 'bos_monthly_temp');
      await window.updateCache();
      expect(window.cache.keys.toSet(), {'bos_daily_temp'});
      tv = window.yVariables[1] as TransformedVariable;
      expect(tv.error, 'Bad state: Can\'t find function toMonthly among '
          'list of functions with one argument.');
      //
      // generate an error on a transformed variable, wrong syntax
      window.yVariables[1] = TransformedVariable(
          expression: 'toMonthly(bos_daily_temp',
          id: 'bos_monthly_temp');
      await window.updateCache();
      expect(window.cache.keys.toSet(), {'bos_daily_temp'});
      tv = window.yVariables[1] as TransformedVariable;
      expect(tv.error, '")" expected');
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;
  await tests(rootUrl);
}
