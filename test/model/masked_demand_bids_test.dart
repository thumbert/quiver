import 'dart:io';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/masked_demand_bids/masked_demand_bids.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/data/latest.dart';

Future<void> tests() async {
  group('Masked demand bids tests', () {
    test('get data all zones in aggregate', () async {
      term.value = Term.parse('Jan26', IsoNewEngland.location);
      final data = await getAggDataByParticipant(term.value);
      final ts0 = data[(maskedParticipantId: 212494, zoneName: '(All)')]!;
      expect(
          ts0.first,
          IntervalTuple<num>(
              Date.parse('2026-01-01', location: IsoNewEngland.location),
              2490.5));
      expect(data.length, 120);
    });

    test('get data for all zones, one participant', () async {
      term.value = Term.parse('Jan26', IsoNewEngland.location);
      final data = await getZonalDataByParticipant(term.value, 212494);
      final ts0 = data[(maskedParticipantId: 212494, zoneName: 'NEMA')]!;
      expect(
          ts0.first,
          IntervalTuple<num>(
              Date.parse('2026-01-01', location: IsoNewEngland.location),
              542.7));
      expect(data.length, 3);
    });

    test('get allParticipants', () async {
      term.value = Term.parse('Jan26', IsoNewEngland.location);
      var participants = await allParticipants.future;
      expect(participants.length, 121);
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  await tests();
}
