library test.models.polygraph_test;

import 'dart:io';

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/models/polygraph/transforms/fill_transform.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_filter.dart';
import 'package:flutter_quiver/models/polygraph/variables/slope_intercept_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_selection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

Future<void> tests(String rootUrl) async {
  group('Polygraph toMongo/fromMongo tests', () {
    test('Serialize default', () {
      var poly = PolygraphState.getDefault();
      var out = poly.toMongo();
      expect(out, {
        'settings': {
          'canvasSize': [1200, 800],
        },
        'tabs': [
          {
            'tab': 0,
            'grid': {
              'rows': 1,
              'cols': 1,
            },
            'windows': [
              {
                'term': '',
                'xVariable': 'time',
                'yVariables': [
                  {
                    'label': '',
                  },
                  {
                    'label',
                    '',
                  },
                ],
                'layout': {
                  'width': 900.0,
                  'height': 600.0,
                  'xaxis': {
                    'showgrid': true,
                    'gridcolor': '#bdbdbd',
                  },
                  'yaxis': {
                    'showgrid': true,
                    'gridcolor': '#bdbdbd',
                  },
                },
              },
            ]
          },
        ],
      });
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;
  await tests(rootUrl);
}
