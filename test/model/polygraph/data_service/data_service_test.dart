library test.models.polygraph.data_service.data_service_test;

import 'dart:io';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec/risk_system.dart';
import 'package:elec/time.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service_local.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/models/polygraph/transforms/fill_transform.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_filter.dart';
import 'package:flutter_quiver/models/polygraph/variables/slope_intercept_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_lmp.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_selection.dart';
import 'package:flutter_quiver/models/polygraph/variables/temperature_variable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

Future<void> tests(String rootUrl) async {
  // var service = DataServiceLocal(rootUrl: rootUrl);
  var service = PolygraphState.service;
  group('Data Service test', () {
    var term = Term.parse('Jan20-Dec21', UTC);
    test('get min and max temperatures Boston', () async {
      var minVariable = TemperatureVariable(
        airportCode: 'BOS',
        variable: 'min',
        frequency: 'daily',
        isForecast: false,
        dataSource: 'NOAA',
        label: 'bos_min',
      );
      var minData = await service.getTemperature(minVariable, term);
      expect(minData.length, 366 + 365);
      expect(minData.first.interval, Date.utc(2020, 1, 1));
      expect(minData.first.value, 36);

      var maxVariable = minVariable.copyWith(variable: 'max');
      var maxData = await service.getTemperature(maxVariable, term);
      expect(maxData.first.interval, Date.utc(2020, 1, 1));
      expect(maxData.first.value, 43);
    });
    test('get isone lmp data', () async {
      var v4000 = VariableLmp(
          iso: Iso.newEngland,
          market: Market.da,
          ptid: 4000,
          lmpComponent: LmpComponent.lmp);
      var term = Term.parse('Cal21', Iso.newEngland.preferredTimeZoneLocation);
      var data4000 = await service.getLmp(v4000, term);
      expect(data4000.length, 8760);
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  var rootUrl = 'http://localhost:8080';
  await tests(rootUrl);
}
