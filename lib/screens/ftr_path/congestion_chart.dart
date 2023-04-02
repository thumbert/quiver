library screens.ftr_path.congestion_chart;

import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/ftr_path/region_source_sink_model.dart';
import 'package:flutter_quiver/models/ftr_path/data_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class CongestionChart extends StatefulWidget {
  const CongestionChart({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CongestionChartState();
}

class _CongestionChartState extends State<CongestionChart> {
  late Plotly plotly;

  @override
  void initState() {
    final path = context.read<RegionSourceSinkModel>();
    final dataModel = context.read<DataModel>();
    var aux = DateTime.now().hashCode;
    plotly = Plotly(
      viewId: 'ftr-path-div-$aux',
      data: const [],
      layout: dataModel.layout,
    );
    plotly.plot.onRelayout.forEach((e) {
      // print(e);
      // e is a JsObject, not a Dart Map so you need to extract contents by hand
      var keys = js.context['Object'].callMethod('keys', [e]) as List;
      if (keys.contains('xaxis.range[0]')) {
        // Pick up only the events when the axes get resized by a mouse
        // selection on the screen
        var start = e['xaxis.range[0]'] as String;
        var end = e['xaxis.range[1]'] as String;
        var startDate = Date.parse((start).substring(0, 10),
            location: path.iso.preferredTimeZoneLocation);
        var endDate = Date.parse((end).substring(0, 10),
            location: path.iso.preferredTimeZoneLocation);
        setState(() {
          dataModel.focusTerm = Term(startDate, endDate);
        });
      } else {
        setState(() {
          dataModel.focusTerm = null;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final path = context.watch<RegionSourceSinkModel>();
    final dataModel = context.watch<DataModel>();

    return FutureBuilder(
        future: dataModel.makeHourlyTrace(path.ftrPath),
        builder: (context, snapshot) {
          List<Widget> children;
          if (snapshot.hasData) {
            var traces = snapshot.data!;
            plotly.plot.react(traces, dataModel.layout, displaylogo: false);
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
