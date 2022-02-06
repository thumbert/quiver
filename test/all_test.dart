import 'dart:io';

import 'package:timezone/data/latest.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'model/mcc_surfer_test.dart' as mcc_surfer;
import 'model/monthly_asset_ncpc_test.dart' as monthly_asset_ncpc;
import 'model/unmasked_energy_offers_test.dart' as unmasked_energy_offers;
import 'model/weather_model_test.dart' as weather_model;

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;

  mcc_surfer.tests(rootUrl);
  unmasked_energy_offers.tests(rootUrl);
  weather_model.tests(rootUrl);
}
