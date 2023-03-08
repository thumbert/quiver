library models.polygraph.polygraph_model;

import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_tab.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
import 'package:flutter_quiver/models/polygraph/variables/realized_electricity_variable.dart' as rev;
import 'package:flutter_quiver/models/polygraph/variables/forward_electricity_variable.dart' as fev;
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';

final providerOfPolygraph =
    StateNotifierProvider<PolygraphNotifier, PolygraphState>(
        (ref) => PolygraphNotifier(ref));


class PolygraphState {
  PolygraphState({
    required this.tabs,
  });

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
    return {};
  }

  static PolygraphState getDefault() {
    return PolygraphState(tabs: [PolygraphTab.getDefault()]);
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

  set term(Term value) {
    state = state.copyWith(term: value);
  }

  set xVariable(PolygraphVariable value) {
    state = state.copyWith(xVariable: value);
  }

  set yVariables(List<PolygraphVariable> values) {
    state = state.copyWith(yVariables: values);
  }
}

