library screens.mcc_surfer.congestion_chart;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/load_zone_model.dart';
import 'package:flutter_quiver/models/common/region_load_zone_model.dart';
import 'package:flutter_quiver/models/common/term_model.dart';
import 'package:flutter_quiver/models/mcc_surfer/congestion_chart_model.dart';
import 'package:flutter_quiver/models/mcc_surfer/constraint_table_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:timezone/timezone.dart';

class CongestionChart extends StatefulWidget {
  const CongestionChart({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CongestionChartState();
}

class _CongestionChartState extends State<CongestionChart> {
  bool initialPlot = true;
  late Plotly plotly;
  bool showHighlights = true;

  @override
  void initState() {
    final chartModel = context.read<CongestionChartModel>();
    var aux = DateTime.now().hashCode;
    plotly = Plotly(
      viewId: 'mcc-surfer-div-$aux',
      data: const [],
      layout: chartModel.layout,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final termModel = context.watch<TermModel>();
    final zoneModel = context.watch<RegionLoadZoneModel>();
    final chartModel = context.watch<CongestionChartModel>();
    final constraintTableModel = context.watch<ConstraintTableModel>();

    return FutureBuilder(
        future: chartModel.makeHourlyTraces(termModel.term,
            region: zoneModel.region,
            loadZonePtid: zoneModel.zoneId,
            projectionCount: 100),
        builder: (context, snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            var traces = snapshot.data! as List;
            // highlight the selected constraints
            var aux = constraintTableModel.getHighlightedBlocks();
            chartModel.layout['shapes'] = [
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
            // if (constraintTableModel.hasChangedHighlight) {
            //   plotly.relayout(chartModel.layout);
            // } else {
            plotly.plot.react(traces, chartModel.layout, displaylogo: false);
            // }
            children = [
              SizedBox(
                  width: chartModel.layout['width'] as double,
                  height: chartModel.layout['height'] as double,
                  child: plotly),
              Text('Curve resolution: \$${chartModel.resolution}.  '
                  'Curves displayed: ${chartModel.displayedCurvesCount} '
                  'out of ${chartModel.traceCount}.'),
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
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: children);
        });
  }
}
