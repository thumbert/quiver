import 'dart:io';

import 'package:elec/risk_system.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/historical_lmp_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/data/latest.dart';

Future<void> tests(String rootUrl) async {
  group('Historical LMP model test', () {
    var model = getDefaultHistoricalLmpModel();
    test('get monthly LMP MassHub', () async {
      var lmp = await getLmpData(model);
      expect(lmp.length > 10000, true);
    });
    test('get monthly LMP Zone G', () async {
      final zoneG = LocationRow(
          region: 'NYISO', location: 'Zone G, ptid: 61758', market: Market.da);
      model = model.copyWith(sink: zoneG);
      final key = (
        region: 'NYISO',
        location: 'Zone G, ptid: 61758',
        market: Market.da,
        lmpComponent: 'LMP'
      );
      HistoricalLmpModel.cache[key] = TimeSeries<num>();
      var lmp = await getLmpData(model);
      expect(lmp.length > 10000, true);
      final aggregated = model.aggregateData(lmp);
      expect(model.makeTraces(aggregated).single['y'], isNotEmpty);
      expect(model.makeTables(aggregated).values.single, isNotEmpty);
      expect(HistoricalLmpModel.cache[key], same(lmp));
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;

  await tests(rootUrl);
}
