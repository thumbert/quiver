library test.models.unmasked_energy_offers_test;

import 'dart:io';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/unmasked_energy_offers/unmasked_energy_offers_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/data/latest.dart';

Future<void> tests(String rootUrl) async {
  final location = getLocation('America/New_York');
  group('Unmasked energy offers test', () {
    var model = UnmaskedEnergyOffersModel.getDefault();
    setUp(() async => await UnmaskedEnergyOffersModel.getMaskedAssetIds(model.iso));
    test('get traces one asset', () async {
      var traces = await model.makeTraces();
      expect(traces.length, 4);
      var t0 = traces.first;
      expect(t0.keys.toSet(), {'x', 'y', 'text', 'name', 'mode', 'line'});
      expect((t0['x'] as List).first, TZDateTime(location, 2018, 4, 1));
      expect((t0['y'] as List).first, 25.71);
      expect(t0['name'], 'price 0');
      expect(t0['mode'], 'lines');
    });
    test('get traces for several assets', () async {
      model = model.copyWith(selectedAssets: ['KLEEN ENERGY', 'YARMOUTH 4']);
      var traces = await model.makeTraces();
      expect(traces.length, 2);
      var t0 = traces.first;
      expect(t0.keys.toSet(), {'x', 'y', 'text', 'name', 'mode', 'line'});
      expect((t0['x'] as List).first, TZDateTime(location, 2018, 4, 1));
      expect((t0['y'] as List).first, 27.098096774193547); // volume weighted
      expect(t0['name'], 'KLEEN ENERGY');
      expect(t0['mode'], 'lines');
    });
    test('change term', () async {
      model = model.copyWith(
          term: Term.parse('May23', IsoNewEngland.location),
          selectedAssets: ['KLEEN ENERGY', 'YARMOUTH 4']);
      var traces = await model.makeTraces();
      expect(traces.length, 2);
      var t0 = traces.first;
      expect(t0.keys.toSet(), {'x', 'y', 'text', 'name', 'mode', 'line'});
      expect((t0['x'] as List).first, TZDateTime(location, 2018, 4, 1));
      expect((t0['y'] as List).first, 27.098096774193547); // volume weighted
      expect(t0['name'], 'KLEEN ENERGY');
      expect(t0['mode'], 'lines');
    });
    
    
    // test('nyiso asset', () async {
    //   model.iso = Iso.newYork;
    //   await model.getMaskedAssetIds(); // selects Bethlehem
    //   // var ind = model.assetData.indexWhere((e) => e['ptid'] == 323570);
    //   // model.clickCheckbox(ind);
    //   term = Term.parse('Jan21', location);
    //   var traces = await model.makeTraces(term);
    //   print(traces);
    // });
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;

  await tests(rootUrl);
}
