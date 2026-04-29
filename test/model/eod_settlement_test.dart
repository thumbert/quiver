import 'dart:io';

import 'package:elec_server/client/ui/eod_settlements/views_asof_date.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart';

Future<void> tests() async {
  group('EOD settlement tests', () {
    test('get records', () async {
      final result = await queryRecords(
          filter: QueryFilter(), rootUrl: dotenv.env['RUST_SERVER']!);
      print('returned ${result.length} records from database');    
      expect(result, isA<List<Record>>());
    });
  });
}

void main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  await tests();
}
