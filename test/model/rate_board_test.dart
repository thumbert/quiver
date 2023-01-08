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
      await RateBoardState.getOffers('ISONE', 'CT');
    });
    test('make CT Eversource table as of 2022-12-14', () async {
      var xs = state.makeOfferTable(asOfDate: Date.utc(2022, 12, 14));
      // All offers are Residential, per the default state
      expect(xs.map((e) => e.accountType).toSet(), {'Residential'});
      // there are several offers by this supplier
      var x0 = xs.firstWhere((e) => e.supplierName == 'Constellation NewEnergy, Inc.');
      // offers are returned sorted by # months by default
      expect(x0.countOfBillingCycles, 24);
      expect(x0.rate, 169.9);
    });
    test('dropdowns for default state', () {
      expect(state.getAllUtilities(), ['Eversource', 'United Illuminating']);
    });
    test('make table for MA NEMA NGrid', () async {
      state = state.copyWith(stateName: 'MA', loadZone: 'NEMA',
        utility: 'NGrid', accountType: 'Residential', billingCycles: '(All)');
      await RateBoardState.getOffers('ISONE', 'MA');
      var xs = state.makeOfferTable(asOfDate: Date.utc(2022, 12, 14));
      expect(xs.length, 16);
    });

  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;

  await tests(rootUrl);
}
