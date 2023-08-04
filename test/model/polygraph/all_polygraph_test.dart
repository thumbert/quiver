library test.models.polygraph_test;

import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service_local.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart';

import 'data_service/data_service_test.dart' as data_service;
import 'parser/parser_test.dart' as parser;
import 'polygraph_tab_test.dart' as tab;
import 'polygraph_window_test.dart' as window;

import 'editors/marks_asof_test.dart' as marks_asof;
import 'editors/marks_historical_view_test.dart' as marks_historical_view;


Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;
  PolygraphState.service = DataServiceLocal(rootUrl: rootUrl);


  await data_service.tests(rootUrl);
  await parser.tests(rootUrl);

  await tab.tests(rootUrl);
  await window.tests(rootUrl);

  await marks_asof.tests();
  await marks_historical_view.tests();
}
