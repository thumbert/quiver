library test.models.polygraph.display.layout_test;

import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/polygraph/display/plotly_layout.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart';

Future<void> tests(String rootUrl) async {
  group('Layout tests', () {
    test('Simplest layout', () async {
      var layout = PlotlyLayout(width: 900.0, height: 600.0);
      expect(layout.toMap(), {
        'width': 900.0,
        'height': 600.0,
        'displaylogo': false,
      });
    });
    test('Default layout', () async {
      var layout = PlotlyLayout(width: 900.0, height: 600.0)
        ..xAxis = (PlotlyXAxis()
          ..showGrid = true
          ..gridColor = '#f5f5f5')
        ..yAxis = (PlotlyYAxis()
          ..showGrid = true
          ..gridColor = '#f5f5f5')
        ..legend = (PlotlyLegend()..orientation = LegendOrientation.horizontal);
      expect(layout.toMap(), {
        'width': 900.0,
        'height': 600.0,
        'legend': {'orientation': 'h'},
        'xaxis': {'showgrid': true, 'gridcolor': '#f5f5f5', 'zeroline': false},
        'yaxis': {'showgrid': true, 'gridcolor': '#f5f5f5'},
        'displaylogo': false,
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
