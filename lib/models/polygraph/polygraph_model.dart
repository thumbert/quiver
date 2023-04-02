library models.polygraph.polygraph_model;

import 'package:date/date.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service_local.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_tab.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_window.dart';
import 'package:flutter_quiver/models/polygraph/variables/time_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';

final providerOfPolygraph =
    StateNotifierProvider<PolygraphNotifier, PolygraphState>(
        (ref) => PolygraphNotifier(ref));

class PolygraphConfig {
  PolygraphConfig({required this.canvasWidth, required this.canvasHeight});

  final int canvasWidth;
  final int canvasHeight;

  static PolygraphConfig getDefault() =>
      PolygraphConfig(canvasWidth: 1200, canvasHeight: 950);
}

class PolygraphState {
  PolygraphState({
    required this.config,
    required this.tabs,
  });

  final PolygraphConfig config;

  /// Each sheet has at least one tab, can have multiple.
  /// Each tab has at least one window, can have multiple.
  /// Each window has its own variables to plot.
  final List<PolygraphTab> tabs;

  static final DataService service = DataServiceLocal();


  /// Add tab at the end
  void addTab() {
    var i = tabs.length+1;
    while (tabs.any((e) => e.name == 'Tab $i')) {
      i = i + 1;
    }
    var tab = PolygraphTab(
        tab: tabs.length,
        name: 'Tab $i',
        windowLayout: WindowLayout(rows: 1, cols: 1),
        windows: [
          PolygraphWindow(
              term: Term.parse('-10d', UTC),
              tzLocation: UTC,
              xVariable: TimeVariable(),
              yVariables: <PolygraphVariable>[])
        ]);
    tabs.add(tab);
  }

  /// No doubts
  void deleteTab(int index) {
    tabs.removeAt(index);
  }


  ///
  PolygraphState fromMongo(Map<String, dynamic> x) {
    return PolygraphState.getDefault();
  }


  static final cache = <String, TimeSeries<num>>{};

  /// What gets serialized to Mongo
  Map<String, dynamic> toMongo() {
    return <String, dynamic>{
      'config': {
        'canvasSize': [config.canvasWidth, config.canvasHeight],
      },
      'tabs': [for (var tab in tabs) tab.toMongo()],
    };
  }

  /// An empty state containing one tab with an empty window.
  static PolygraphState empty() {
    return PolygraphState(
      config: PolygraphConfig.getDefault(),
      tabs: [PolygraphTab.empty()],
    );
  }

  static PolygraphState getDefault() {
    return PolygraphState(
      config: PolygraphConfig.getDefault(),
      tabs: [PolygraphTab.getDefault()],
    );
  }

  PolygraphState copyWith({
    List<PolygraphTab>? tabs,
    PolygraphConfig? config,
  }) {
    return PolygraphState(
      tabs: tabs ?? this.tabs,
      config: config ?? this.config,
    );
  }
}

class PolygraphNotifier extends StateNotifier<PolygraphState> {
  PolygraphNotifier(this.ref) : super(PolygraphState.getDefault());

  final Ref ref;

  set tabs(List<PolygraphTab> values) {
    state = state.copyWith(tabs: values);
  }

  // set term(Term value) {
  //   state = state.copyWith(term: value);
  // }

  //
  // set xVariable(PolygraphVariable value) {
  //   state = state.copyWith(xVariable: value);
  // }
  //
  // set yVariables(List<PolygraphVariable> values) {
  //   state = state.copyWith(yVariables: values);
  // }
}
