library test.models.rate_board_test;

import 'dart:io';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec/ftr.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/ftr_path/data_model.dart';
import 'package:flutter_quiver/models/pool_load_stats/pool_load_stats_model.dart';
import 'package:flutter_quiver/models/rate_board/rate_board_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

Future<void> tests(String rootUrl) async {
  var state = RateBoardState.getDefault();
  // state = state.copyWith(term: Term.parse('1Jan18-31Aug22', UTC));
  group('Rate board tests', () {
    setUp(() async {
      await RateBoardState.getOffers('ISONE');
    });
    test('make table as of 2022-11-29', () async {
      var xs = state.makeOfferTable();
      expect(xs.length, 6);  // all Residential offers
      expect(xs.map((e) => e['Account Type']).toSet(), {'Residential'});
      var x0 = xs.first;
      expect(x0['Supplier'], 'Constellation NewEnergy, Inc.');
      expect(x0['Supplier'], 165.9);
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;

  await tests(rootUrl);
}
