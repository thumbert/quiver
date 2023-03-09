library models.polygraph.polygraph_model;

import 'package:flutter_quiver/models/polygraph/polygraph_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeseries/timeseries.dart';

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



  ///
  PolygraphState fromMongo(Map<String,dynamic> x) {
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

  static final cache = <String,TimeSeries<num>>{};

  /// What gets serialized to Mongo
  Map<String,dynamic> toMongo() {
    return <String,dynamic>{
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

  // PolygraphState copyWith({
  //   Term? term,
  //   PolygraphVariable? xVariable,
  //   List<PolygraphVariable>? yVariables,
  // }) {
  //   return PolygraphState(
  //     term: term ?? this.term,
  //     xVariable: xVariable ?? this.xVariable,
  //     yVariables: yVariables ?? this.yVariables,
  //   );
  // }
}



class PolygraphNotifier extends StateNotifier<PolygraphState> {
  PolygraphNotifier(this.ref) : super(PolygraphState.getDefault());

  final Ref ref;

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

