library screens.congestion_chart;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/term_model.dart';
import 'package:flutter_quiver/models/mcc_surfer/congestion_chart_model.dart';
import 'package:flutter_quiver/models/mcc_surfer/constraint_table_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:timezone/browser.dart';

class CongestionChart extends StatefulWidget {
  const CongestionChart({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CongestionChartState();
}

class _CongestionChartState extends State<CongestionChart> {
  final layout = {
    'height': 700,
    'width': 1000,
    'margin': {
      't': 10,
      'l': 50,
      'r': 20,
      'pad': 4,
    },
    'yaxis': {
      'title': 'Congestion price, \$/MWh',
    },
    'showlegend': false,
    'hovermode': 'closest',
    'shapes': [],
  };

  @override
  Widget build(BuildContext context) {
    final termModel = context.watch<TermModel>();
    final chartModel = context.watch<CongestionChartModel>();
    final constraintTableModel = context.watch<ConstraintTableModel>();

    return FutureBuilder(
        future: chartModel.makeHourlyTraces(
            termModel.term.startDate, termModel.term.endDate),
        builder: (context, snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            var traces = snapshot.data! as List;
            // highlight the selected constraints
            var aux = constraintTableModel.getHighlightedBlocks();
            // print(aux);
            layout['shapes'] = [
              for (var x in aux)
                {
                  'type': 'rect',
                  'xref': 'x',
                  'yref': 'paper',
                  'x0': (x['start'] as TZDateTime).millisecondsSinceEpoch,
                  'y0': 0,
                  'x1': (x['end'] as TZDateTime).millisecondsSinceEpoch,
                  'y1': 1,
                  'fillcolor': '#800000',
                  'opacity': 0.2,
                  'line': {
                    'width': 0,
                  }
                }
            ];

            children = [
              SizedBox(
                  width: 700,
                  height: 1000,
                  child: Plotly(
                    viewId: 'mydiv',
                    data: traces,
                    layout: layout,
                  )),
            ];
          } else if (snapshot.hasError) {
            children = [
              const Icon(Icons.error_outline, color: Colors.red),
              Text(
                snapshot.error.toString(),
                style: const TextStyle(fontSize: 16),
              )
            ];
          } else {
            children = [
              const SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                  )),
            ];
            // the only way I found to keep the progress indicator centered
            return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: children);
          }
          return Row(children: children);
        });
  }
}
