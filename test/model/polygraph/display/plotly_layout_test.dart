library test.models.polygraph.display.layout_test;

import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/models/polygraph/display/plotly_layout.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart';

Future<void> tests(String rootUrl) async {
  group('Plotly x axis tests', () {
    test('Default axis', (){
      var axis = PlotlyXAxis();
      expect(axis.toMap(), {});
    });
    test('with show grid', (){
      var axis = PlotlyXAxis()..showGrid = false;
      expect(axis.toMap(), {'showgrid': false});
    });

  });


  group('Plotly layout tests', () {
    test('Simplest layout', () async {
      var layout = PlotlyLayout(width: 900, height: 600);
      expect(layout.toMap(), {
        'width': 900,
        'height': 600,
        'displaylogo': false,
      });
    });
    test('Default layout', () async {
      var layout = PlotlyLayout(width: 900, height: 600)
        ..xAxis = (PlotlyXAxis()
          ..showGrid = true
          ..gridColor = '#f5f5f5')
        ..yAxis = (PlotlyYAxis()
          ..showGrid = true
          ..gridColor = '#f5f5f5')
        ..legend = (PlotlyLegend()..orientation = LegendOrientation.horizontal);
      expect(layout.toMap(), {
        'width': 900,
        'height': 600,
        'legend': {'orientation': 'h'},
        'xaxis': {'gridcolor': '#f5f5f5'},
        'yaxis': {'gridcolor': '#f5f5f5'},
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
