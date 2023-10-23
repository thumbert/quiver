library test.models.ct_suppliers_backlog_test;

import 'dart:io';

import 'package:date/date.dart';
import 'package:elec_server/client/utilities/ct_supplier_backlog_rates.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/ct_suppliers_backlog/ct_suppliers_backlog_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart';
import 'package:timezone/data/latest.dart';

Future<void> tests(String rootUrl) async {
  group('CT suppliers backlog tests:', () {
    var model = CtSuppliersBacklogModel.getDefault();
    var term = Term.parse('Jan22-Jul23', UTC);
    setUp(() async => await CtSuppliersBacklogModel.getData(term, Utility.eversource));
    test('get traces one asset', () async {
      var traces = await model.makeTraces();
      expect(traces.length, 35);
      var t0 = traces.first;
      expect(t0.keys.toSet(), {'x', 'y', 'name', 'mode'});
      expect((t0['y'] as List).first, 19053);
      expect(t0['name'], 'AMBIT ENERGY  LLC');
      expect(t0['mode'], 'lines+markers');
    });
    // test('change term', () async {
    //   model = model.copyWith(
    //       term: Term.parse('May23', IsoNewEngland.location),
    //       selectedAssets: ['KLEEN ENERGY', 'YARMOUTH 4']);
    //   var traces = await model.makeTraces();
    //   expect(traces.length, 2);
    //   var t0 = traces.first;
    //   expect(t0.keys.toSet(), {'x', 'y', 'text', 'name', 'mode', 'line'});
    //   expect((t0['x'] as List).first, TZDateTime(location, 2018, 4, 1));
    //   expect((t0['y'] as List).first, 27.098096774193547); // volume weighted
    //   expect(t0['name'], 'KLEEN ENERGY');
    //   expect(t0['mode'], 'lines');
    // });
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;

  await tests(rootUrl);
}
