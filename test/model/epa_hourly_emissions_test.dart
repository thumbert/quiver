import 'dart:io';

import 'package:date/date.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/epa/epa_hourly_emissions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

Future<void> tests() async {
  group('EPA hourly emissions tests', () {
    test('get data', () async {
      final row = rows.value.first;
      final term = Term.parse('Jan25', UTC);
      final data = await row.getData(term);
      expect(data.keys.toSet(), {'11', '12'});
    });
    test('make traces', () async {
      final tracesData = await makeTraces();
      expect(tracesData.length, 2); 
    });
  });
}

void main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  await tests();
}
