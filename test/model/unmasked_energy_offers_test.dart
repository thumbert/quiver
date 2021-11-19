library test.models.unmasked_energy_offers_test;

import 'dart:io';

import 'package:date/date.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/unmasked_energy_offers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/data/latest.dart';

Future<void> tests(String rootUrl) async {
  final location = getLocation('America/New_York');
  group('Unmasked energy offers test', () {
    var model = UnmaskedEnergyOffersModel();
    var term = Term.parse('Apr18', location);
    setUp(() async => await model.getMaskedAssetIds());
    test('get traces one asset', () async {
      var ind = model.assetData.indexWhere((e) => e['ptid'] == 14614);
      model.clickCheckbox(ind);
      var traces = await model.makeTraces(term);
      expect(traces.length, 4);
      var t0 = traces.first;
      expect(t0.keys.toSet(), {'x', 'y', 'text', 'name', 'mode', 'line'});
      expect((t0['x'] as List).first, TZDateTime(location, 2018, 4, 1));
      expect((t0['y'] as List).first, 25.71);
      expect(t0['name'], 'price 0');
      expect(t0['mode'], 'lines');
    });
    test('get traces several asset', () async {
      model.deselectAll();
      model
          .clickCheckbox(model.assetData.indexWhere((e) => e['ptid'] == 14614));
      model.clickCheckbox(model.assetData.indexWhere((e) => e['ptid'] == 642));

      var traces = await model.makeTraces(term);
      expect(traces.length, 2);
      var t0 = traces.first;
      expect(t0.keys.toSet(), {'x', 'y', 'text', 'name', 'mode', 'line'});
      expect((t0['x'] as List).first, TZDateTime(location, 2018, 4, 1));
      expect((t0['y'] as List).first, 25.71);
      expect(t0['name'], 'YARMOUTH 4');
      expect(t0['mode'], 'lines');
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['rootUrl'] as String;

  await tests(rootUrl);
}
