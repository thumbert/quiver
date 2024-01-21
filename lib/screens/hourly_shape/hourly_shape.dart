library screens.hourly_shape;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/hourly_shape/day_filter.dart';
import 'package:flutter_quiver/models/hourly_shape/hourly_shape_model.dart';
import 'package:flutter_quiver/models/hourly_shape/settings.dart';
import 'package:flutter_quiver/screens/hourly_shape/day_filter_widget.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:signals/signals_flutter.dart';
import 'package:timeseries/timeseries.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;

class HourlyShapeApp extends StatefulWidget {
  const HourlyShapeApp({super.key});

  static const route = '/hourly_shape';

  @override
  State<HourlyShapeApp> createState() => _HourlyShapeAppState();
}

class _HourlyShapeAppState extends State<HourlyShapeApp> {
  final seriesName = signal(HourlyShapeModel.allNames.first);
  static final analysisName = signal(SettingsIndividualDays.analysisName);
  final settings = computed(() {
    return switch (analysisName.value) {
      SettingsIndividualDays.analysisName => SettingsIndividualDays(),
      SettingsForMedianByYear.analysisName => SettingsForMedianByYear(),
      _ => throw 'Unsupported analysis ${analysisName.value}',
    };
  });
  final dayFilter = signal(DayFilter.getDefault());

  late final traces = futureSignal(() async {
    try {
      await HourlyShapeModel.getData(seriesName.value);
    } catch (e) {
      rethrow;
    }
    return HourlyShapeModel.getTraces(dayFilter.value, settings.value);
  });

  final scrollControllerV = ScrollController();
  final scrollControllerH = ScrollController();
  final seriesNameController = TextEditingController();
  final analysisNameController = TextEditingController();
  late List<Plotly> plotly;

  @override
  void initState() {
    seriesNameController.text = seriesName.value;
    analysisNameController.text = SettingsIndividualDays.analysisName;
    var aux = DateTime.now().hashCode;
    plotly = [0, 1]
        .map((i) => Plotly(
              viewId: 'plotly-hourly-shape-$i-$aux',
              data: const [],
              layout: HourlyShapeModel.layout,
            ))
        .toList();

    // for Hourly weights by day, register the callbacks...
    plotly[0].plot.onHover.forEach((data) {
      var xs = js.context['Object'].callMethod('values', data['points']);
      int traceNumber = xs[2];

      // ignore: no_leading_underscores_for_local_identifiers
      var _traces = traces.requireValue;
      var one = Map<String, dynamic>.from(_traces[traceNumber]);
      one['line'] = {'color': '#ff9900', 'width': 4};
      _traces[_traces.length - 1] = one;
      plotly[0]
          .plot
          .react(_traces, HourlyShapeModel.layout, displaylogo: false);
    });
    plotly[0].plot.onUnhover.forEach((data) {
      // ignore: no_leading_underscores_for_local_identifiers
      var _traces = traces.requireValue;
      _traces[_traces.length - 1]['line'] = {'color': '#add8e6', 'width': 2};
      plotly[0]
          .plot
          .react(_traces, HourlyShapeModel.layout, displaylogo: false);
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollControllerV.dispose();
    scrollControllerH.dispose();
    analysisNameController.dispose();
    seriesNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hourly shape analysis'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const SimpleDialog(
                      contentPadding: EdgeInsets.all(12),
                      children: [Text('Ola')],
                    );
                  });
            },
            icon: const Icon(Icons.info_outline),
            tooltip: 'Info',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 0.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: scrollControllerV,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 300,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 8.0, bottom: 16.0),
                          child: Watch((context) => DropdownMenu<String>(
                                width: 300.0,
                                menuHeight: 600.0,
                                trailingIcon:
                                    const Icon(Icons.keyboard_arrow_down),
                                controller: seriesNameController,
                                enableFilter: true,
                                leadingIcon: const Icon(Icons.search),
                                label: const Text('Select'),
                                textStyle: const TextStyle(fontSize: 14),
                                dropdownMenuEntries: [
                                  for (var asset in HourlyShapeModel.allNames)
                                    DropdownMenuEntry(
                                        value: asset,
                                        label: asset,
                                        style: const ButtonStyle(
                                            padding: MaterialStatePropertyAll(
                                                EdgeInsets.only(left: 8)),
                                            visualDensity:
                                                VisualDensity.compact))
                                ],
                                inputDecorationTheme: InputDecorationTheme(
                                  isDense: true,
                                  isCollapsed: true,
                                  filled: true,
                                  fillColor: Colors.blueGrey.shade50,
                                  contentPadding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  border: const OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                  enabledBorder: const OutlineInputBorder(
                                      borderSide: BorderSide.none),
                                ),
                                onSelected: (String? name) {
                                  seriesName.value = name!;
                                  HourlyShapeModel.ts = TimeSeries<num>();
                                },
                              )),
                        ),

                        ///
                        /// Settings (Analysis)
                        ///
                        Card(
                          color: Colors.amber.shade50,
                          surfaceTintColor: Colors.transparent,
                          child: SizedBox(
                            width: 300,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Settings',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Watch((context) => DropdownMenu<String>(
                                        label: const Text('Analysis'),
                                        controller: analysisNameController,
                                        textStyle:
                                            const TextStyle(fontSize: 14),
                                        width: 270.0,
                                        trailingIcon: const Icon(
                                            Icons.keyboard_arrow_down),
                                        dropdownMenuEntries: const [
                                          DropdownMenuEntry(
                                              value: SettingsIndividualDays
                                                  .analysisName,
                                              label: SettingsIndividualDays
                                                  .analysisName),
                                          DropdownMenuEntry(
                                              value: SettingsForMedianByYear
                                                  .analysisName,
                                              label: SettingsForMedianByYear
                                                  .analysisName),
                                        ],
                                        onSelected: (String? name) {
                                          analysisName.value = name!;
                                        },
                                      )),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 8.0,
                        ),

                        ///
                        /// Day filter
                        ///
                        Card(
                          color: Colors.amber.shade50,
                          surfaceTintColor: Colors.transparent,
                          child: SizedBox(
                            width: 300,
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Day filter',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(
                                    height: 8.0,
                                  ),
                                  DayFilterWidget(dayFilter),
                                ],
                              ),
                            ),
                          ),
                        ),

                        ///
                        /// Refresh button
                        ///
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple.shade100),
                              child: const Text('Refresh'),
                              onPressed: () => traces.refresh(),
                            ),
                          ),
                        ),
                      ]),
                ),
                const SizedBox(width: 15),
                Watch((context) {
                  switch (traces.value) {
                    // ignore: unused_local_variable
                    case AsyncData data:
                      return updatePlot();
                    case AsyncError error:
                      return Row(children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        Text(
                          error.error.toString(),
                          style: const TextStyle(fontSize: 16),
                        )
                      ]);
                    case AsyncLoading():
                      return const SizedBox(
                        width: 900,
                        height: 600,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(
                                value: 20,
                              ),
                              Text('  Loading ...'),
                            ]),
                      );
                  }
                }),
                const SizedBox(
                  height: 12,
                  width: 1500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget updatePlot() {
    var layout = HourlyShapeModel.layout;
    layout['title'] = seriesName.value;
    var i = switch (settings.value) {
      SettingsIndividualDays() => 0,
      SettingsForMedianByYear() => 1,
    };
    plotly[i].plot.react(traces.requireValue, HourlyShapeModel.layout,
        displaylogo: false);
    return Row(children: [
      SizedBox(width: 900, height: 600, child: plotly[i]),
    ]);
  }
}
