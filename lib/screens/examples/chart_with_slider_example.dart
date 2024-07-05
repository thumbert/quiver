library screens.examples.chart_with_slider_example;

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:signals/signals_flutter.dart';

final minmaxRange = signal<(double, double)>((0, 1));
final selectedRange = signal<(double, double)>((0, 1));

final getData = futureSignal(() async {
  await Future.delayed(const Duration(seconds: 2));
  final y = <double>[1, -2, 0, 2, 5, 3, 7, 5, 3, 1];
  minmaxRange.value = (y.min, y.max);
  selectedRange.value = minmaxRange.value;
  return <String, List<num>>{
    'x': [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
    'y': y,
  };
});

Map<String, dynamic> makeTrace(List<num> x, List<num> y, List<String> color) =>
    {
      'x': x,
      'y': y,
      'mode': 'markers',
      'marker': {
        'color': color,
      }
    };

final layout = {
  'width': 600,
  'height': 400,
  'hovermode': 'closest',
};

class ChartWithSliderExample extends StatefulWidget {
  const ChartWithSliderExample({super.key});
  static const route = '/chart_with_slider';
  @override
  State<ChartWithSliderExample> createState() => _DropdownExampleState();
}

class _DropdownExampleState extends State<ChartWithSliderExample> {
  late Plotly plotly;

  @override
  void initState() {
    super.initState();
    setState(() {
      var aux = DateTime.now().hashCode;
      plotly = Plotly(
          viewId: 'plotly-chart-slider-$aux', data: const [], layout: layout);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green,
        ),
        home: Scaffold(
          body: SafeArea(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                  'The points in chart change color depending on slider value'),
              const SizedBox(
                height: 32,
              ),
              SizedBox(
                width: 200,
                child: Watch((_) => RangeSlider(
                    values: RangeValues(selectedRange.value.$1.toDouble(),
                        selectedRange.value.$2.toDouble()),
                    min: minmaxRange.value.$1.toDouble(),
                    max: minmaxRange.value.$2.toDouble(),
                    divisions: 100,
                    labels: RangeLabels(
                        selectedRange.value.$1.toStringAsFixed(1),
                        selectedRange.value.$2.toStringAsFixed(1)),
                    onChanged: (RangeValues newRange) {
                      selectedRange.value = (newRange.start, newRange.end);
                    })),
              ),
              SizedBox(
                  width: 900,
                  child: Row(children: [
                    /// Add slider here ...
                    const SizedBox(
                      width: 24,
                    ),
                    Watch((context) {
                      late Widget out;
                      switch (getData.value) {
                        case AsyncData<Map<String, List<num>>> data:
                          var color =
                              List.filled(data.value['x']!.length, '#1f77b4');
                          final y = data.value['y']!;
                          for (var i = 0; i < color.length; i++) {
                            if (y[i] < selectedRange.value.$1 ||
                                y[i] > selectedRange.value.$2) {
                              color[i] = '#d2691e';
                            }
                          }
                          var trace = makeTrace(
                              data.value['x']!, data.value['y']!, color);
                          plotly.plot
                              .react([trace], layout, displaylogo: false);
                          out = SizedBox(
                            width: 600,
                            height: 400,
                            child: plotly,
                          );

                        case AsyncError<Map<String, List<num>>>():
                          out = const Text('Error getting data');

                        case AsyncLoading<Map<String, List<num>>>():
                          out = const Row(
                            children: [
                              CircularProgressIndicator(),
                              Text('   Loading data ...'),
                            ],
                          );
                      }

                      return out;
                    })
                  ])),
            ],
          )),
        ));
  }
}
