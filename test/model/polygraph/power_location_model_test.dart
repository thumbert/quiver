library test.models.ftr_path_test;

import 'dart:io';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart';

Future<void> tests(String rootUrl) async {
  group('Power location model test', () {
    // var model = PowerLocationModel(
    //     region: 'ISONE',
    //     deliveryPoint: 'Mass Hub',
    //     market: 'DA',
    //     lmpComponent: 'LMP');
    // test('test fields', () {
    //   expect(model.region, 'ISONE');
    //   expect(model.deliveryPointName, 'Mass Hub');
    //   expect(model.market, 'DA');
    //   expect(model.lmpComponent, 'LMP');
    // });
  });
}

Future<void> main() async {
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;
  await tests(rootUrl);
}
