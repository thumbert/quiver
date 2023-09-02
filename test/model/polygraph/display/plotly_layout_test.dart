library test.models.polygraph.display.layout_test;

import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/polygraph/display/plotly_layout.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart';

Future<void> tests(String rootUrl) async {
  group('Plotly x axis tests', () {
    test('Default axis', () {
      var axis = PlotlyXAxis();
      expect(axis.toJson(), {});
    });
    test('with show grid', () {
      var axis = PlotlyXAxis()..showGrid = false;
      expect(axis.toJson(), {'showgrid': false});
    });
  });

  group('Plotly layout tests', () {
    test('Simplest layout', () async {
      var layout = PlotlyLayout();
      expect(layout.toJson(), {});
    });
    test('Default layout', () async {
      var layout = PlotlyLayout()
        ..xAxis = (PlotlyXAxis()
          ..showGrid = true
          ..gridColor = '#f5f5f5')
        ..yAxis = (PlotlyYAxis()
          ..showGrid = true
          ..gridColor = '#f5f5f5')
        ..legend = (PlotlyLegend()..orientation = LegendOrientation.horizontal);
      expect(layout.toJson(), {
        'legend': {'orientation': 'h'},
        'xaxis': {'gridcolor': '#f5f5f5'},
        'yaxis': {'gridcolor': '#f5f5f5'},
      });
    });

    test('with legend', () {
      var x = {
        'legend': {'orientation': 'h'}
      };
      var layout = PlotlyLayout.fromJson(x);
      expect(layout.legend?.orientation.toString(), 'h');
    });
  });
}

Future<void> main() async {
  initializeTimeZones();
  dotenv.testLoad(fileInput: File('.env').readAsStringSync());
  final rootUrl = dotenv.env['ROOT_URL'] as String;
  await tests(rootUrl);
}
