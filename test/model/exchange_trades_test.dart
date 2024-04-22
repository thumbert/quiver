library test.models.exchange_trades_test;

import 'dart:io';

import 'package:date/date.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/exchange_trades/nodal_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signals/signals.dart';
import 'package:timezone/data/latest.dart';

final update = effect(() {
  print('in updateFilters... -----------------------');
  selectedLocations.value = {...allLocations.value};
});

Future<void> tests(String rootUrl) async {
  group('Nodal test', () {
    setUp(() async {
      final term = Term(Date.utc(2024, 4, 1), Date.utc(2024, 4, 22));
      await getTrades(term);
    });
    tearDown(() {
      // updateFilters();
    });
    test('default', () {
      expect(allIsos.value, {'PJM', 'ISONE', 'NYISO'});
      expect(labelIsos.value, 'PJM');
      expect(selectedIsos.value, {'PJM'});
      expect(labelLocations.value, '(All)');
      expect(allLocations.value, {'WH', 'BGE'});
      expect(selectedLocations.value, {'WH', 'BGE'});
      expect(labelBuckets.value, '(All)');
      expect(labelStrips.value, '(All)');
    });

    test('modify filter ISO', () async {
      print('set iso to ISONE');
      selectedIsos.value = {'ISONE'};
      print('selectedLocations: ${selectedLocations.value}');
      expect(labelIsos.value, 'ISONE');
      expect(allLocations.value, {'MH'});
      expect(selectedLocations.value, {'MH'});  // <-- NEED TO USE AN EFFECT!


      // await rows.future;
      // switch (rows.value) {
      //   case AsyncData<List<Map<String, dynamic>>> data:
      //     print('on the branch... ---------------');
      //     print(data.value);
      //   default:
      //     throw StateError('Wrong state!');
      // }
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;

  await tests(rootUrl);
}
