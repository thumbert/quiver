library screens.ny_spreads.ny_spreads_plot;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/pool_load_stats/pool_load_stats_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';

class LoadStatsPlot extends ConsumerStatefulWidget {
  const LoadStatsPlot({Key? key}) : super(key: key);

  @override
  ConsumerState<LoadStatsPlot> createState() => _LoadStatsPlotState();
}

class _LoadStatsPlotState extends ConsumerState<LoadStatsPlot> {
  late Plotly plotly;

  @override
  void initState() {
    super.initState();
    setState(() {
      final model = ref.read(providerOfPoolLoadStats);
      var aux = DateTime.now().hashCode;
      plotly = Plotly(
        viewId: 'plotly-pool-load-stats-$aux',
        data: const [],
        layout: model.layout(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return justPlot();
  }

  Widget getFuture() {
    final model = ref.watch(providerOfPoolLoadStats);
    return FutureBuilder(
      future: model.getData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Text(
              'Error retrieving data from the database',
              style: TextStyle(color: Colors.red),
            );
          }
          var traces = model.makeTraces();
          print(traces.first['x'].take(3));
          plotly.plot.react(traces, model.layout(), displaylogo: false);

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (traces.isNotEmpty)
                SizedBox(width: 850, height: 550, child: plotly),
              const SizedBox(
                width: 8,
              ),
            ],
          );
        } else {
          return Row(
            children: const [
              CircularProgressIndicator(),
              SizedBox(
                width: 12,
              ),
              Text('Getting the data from Shooju...  Go get a coffee.')
            ],
          );
        }
      },
    );
  }

  /// Just recolor
  Widget justPlot() {
    final model = ref.watch(providerOfPoolLoadStats);
    var traces = model.makeTraces();
    plotly.plot.react(traces, model.layout(), displaylogo: false);
    return SizedBox(width: 850, height: 550, child: plotly);
  }
}
