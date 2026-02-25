import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/historical_lmp_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart';

Future<void> tests(String rootUrl) async {
  group('Historical LMP model test', () {
    var model = getDefaultHistoricalLmpModel();
    test('get monthly LMP MassHub', () async {
      var lmp = await getLmpData(model);
      expect(lmp.length > 10000, true);
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;

  await tests(rootUrl);
}
