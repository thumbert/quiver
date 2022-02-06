library screens.ftr_path.congestion_chart;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/ftr_path/region_source_sink_model.dart';
import 'package:flutter_quiver/models/ftr_path/data_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';

class CongestionChart extends StatefulWidget {
  const CongestionChart({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CongestionChartState();
}

class _CongestionChartState extends State<CongestionChart> {
  late Plotly plotly;

  @override
  void initState() {
    final chartModel = context.read<DataModel>();
    plotly = Plotly(
      viewId: 'ftr-path-div',
      data: const [],
      layout: chartModel.layout,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final path = context.watch<RegionSourceSinkModel>();
    final dataModel = context.watch<DataModel>();

    return FutureBuilder(
        future: dataModel.makeHourlyTrace(path.ftrPath!),
        builder: (context, snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            var traces = snapshot.data! as List;
            plotly.plot.react(traces, dataModel.layout);
            children = [
              SizedBox(
                  width: dataModel.layout['width'] as double,
                  height: dataModel.layout['height'] as double,
                  child: plotly),
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
