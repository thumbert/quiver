library test.models.historical_option_pricing_test;

import 'dart:io';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec/risk_system.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/historical_option_pricing_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart' as tz;

Future<void> tests(String rootUrl) async {
  group('Historical option pricing test', () {
    test('get historicalTerms', () {
      final forwardTerm = Term.parse('Dec23-Feb24', IsoNewEngland.location);
      final historicalTerm = Term.parse('Jan18-Nov23', IsoNewEngland.location);
      final terms = getHistoricalTerms(forwardTerm, historicalTerm);
      expect(terms.length, 5);
      expect(terms.first, Term.parse('Dec18-Feb19', IsoNewEngland.location));
      expect(terms.last, Term.parse('Dec22-Feb23', IsoNewEngland.location));
    });

    // test('get ISONE data', () async {
    //   final term = Term.parse('Jan18-Dec23', IsoNewEngland.location);
    //   final ts = await getData(term, Location.massHub, Market.da);
    //   expect(ts.length > 100, true);
    // });

    /// check that historicalTerm < forwardTerm
    ///
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;

  await tests(rootUrl);
}
