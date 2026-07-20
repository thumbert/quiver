import 'dart:io';

import 'package:date/date.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/masked_monthly_capacity/masked_monthly_capacity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart';

Future<void> tests() async {
  group('Masked monthly capacity test, ISONE', () {
    test('make traces for ISONE, all zones', () async {
      region.value = 'ISONE';
      zoneName.value = '(All)';
      month.value = Month.utc(2025, 12);
      await isoneClearingPrices.future;
      await isoneBidsOffers.future;

      var traces =
          isoneMakeTracesForZone(month.value, allZonesIsone[zoneName.value]);
      expect(traces.length, 2);
      expect((traces[0]['y'] as List).length, 279);
    });

    test('make traces for ISONE, Maine zone', () async {
      region.value = 'ISONE';
      zoneName.value = 'Maine';
      month.value = Month.utc(2025, 12);
      await isoneClearingPrices.future;
      await isoneBidsOffers.future;

      var traces =
          isoneMakeTracesForZone(month.value, allZonesIsone[zoneName.value]);
      expect(traces.length, 3);
      expect((traces[0]['y'] as List).length, 33);
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  await tests();
}
