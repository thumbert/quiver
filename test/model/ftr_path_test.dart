library test.models.ftr_path_test;

import 'dart:io';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec/ftr.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/ftr_path/data_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart';

Future<void> tests(String rootUrl) async {
  group('FTR path model test', () {
    var model = DataModel();
    test('get relevant constraints NYISO', () async {
      var path = FtrPath(
          sourcePtid: 23598, // Fitz
          sinkPtid: 61754, // C
          bucket: Bucket.atc,
          iso: Iso.newYork);
      var term =
          Term.parse('Jan21-Dec21', Iso.newYork.preferredTimeZoneLocation);
      model.focusTerm = term;
      var bc = await model.getRelevantBindingConstraints(ftrPath: path);
      expect(bc.length, 19);
      expect(bc.first, {
        'constraintName': 'CENTRAL EAST - VC',
        'cost': 15223.26000000001,
      });
    });
    test('get relevant constraints ISONE', () async {
      var path = FtrPath(
          sourcePtid: 4000,
          sinkPtid: 4001,
          bucket: Bucket.b5x16,
          iso: Iso.newEngland);
      var term =
          Term.parse('Jan21-Dec21', Iso.newYork.preferredTimeZoneLocation);
      model.focusTerm = term;
      var bc = await model.getRelevantBindingConstraints(ftrPath: path);
      expect(bc.length, 9);
      expect(bc.first, {
        'constraintName': 'MIS',
        'cost': -276.02000000000004,
      });
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;

  await tests(rootUrl);
}
