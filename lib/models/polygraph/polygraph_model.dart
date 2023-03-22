library models.polygraph.polygraph_model;

import 'package:date/date.dart';
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

  /// Add tab at the end
  void addTab() {
    var i = tabs.length+1;
    while (tabs.any((e) => e.name == 'Tab $i')) {
      i = i + 1;
    }
    print(i);
    var tab = PolygraphTab(
        tab: tabs.length,
        name: 'Tab $i',
        windowLayout: WindowLayout(rows: 1, cols: 1),
        windows: [
          PolygraphWindow(
              term: Term.parse('-10d', UTC),
              timezone: UTC,
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

  static final layout = <String, dynamic>{
    'width': 900.0,
    'height': 600.0,
    'xaxis': {
      'showgrid': true,
      'gridcolor': '#bdbdbd',
    },
    'yaxis': {
      'showgrid': true,
      'gridcolor': '#bdbdbd',
      // 'zeroline': false,
    },
    // if you need a secondary axis on the right add
    // 'yaxis2': {
    //   'anchor': 'x', // 'free'
    //   'overlaying': 'y',
    //   'side': 'right',
    // },

    'showlegend': true,
    'hovermode': 'closest',
    'displaylogo': false,
  };

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

  static PolygraphState getDefault() {
    return PolygraphState(
      config: PolygraphConfig(canvasWidth: 1200, canvasHeight: 950),
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
