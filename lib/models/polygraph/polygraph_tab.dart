library models.polygraph.polygraph_tab;

import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
import 'package:flutter_quiver/models/polygraph/variables/realized_electricity_variable.dart' as rev;
import 'package:flutter_quiver/models/polygraph/variables/forward_electricity_variable.dart' as fev;
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';

final providerOfPolygraphTab =
StateNotifierProvider<PolygraphTabNotifier, PolygraphTab>(
        (ref) => PolygraphTabNotifier(ref));


class PolygraphTab {
  PolygraphTab({
    required this.term,
    required this.xVariable,
    required this.yVariables,
  });

  /// Historical term, in UTC
  final Term term;
  final PolygraphVariable xVariable;
  final List<PolygraphVariable> yVariables;

  ///
  PolygraphTab fromMongo(Map<String,dynamic> x) {
    return PolygraphTab.getDefault();
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

  /// Construct the Plotly traces.
  List<Map<String,dynamic>> makeTraces() {
    var traces = <Map<String,dynamic>>[];
    if (xVariable is TimeVariable) {
      for (var i=0; i<yVariables.length; i++) {
        var ts = yVariables[i].timeSeries(term);
        var one = {
          'x': ts.intervals.map((e) => e.start).toList(),
          'y': ts.values.toList(),
          // 'yaxis': 'y2',  // if you want it on the right side
        };
        // yVariables[i].config
        traces.add(one);
      }
    } else {
      /// When you have a scatter plot
      throw StateError('Need more work to support this!');
    }
    return traces;
  }

  /// What gets serialized to Mongo
  Map<String,dynamic> toMongo() {
    return {};
  }



  static PolygraphTab getDefault() {
    var today = Date.today(location: UTC);
    var term =
    Term(Month.fromTZDateTime(today.start).subtract(4).startDate, today);

    var xVariable = TimeVariable();
    var yVariables = [
      rev.massHubDa..timeAggregation = TimeAggregation(frequency: 'daily', function: 'mean'),
      fev.massHubDa5x16LmpCal24,
    ];

    return PolygraphTab(
        term: term, xVariable: xVariable, yVariables: yVariables);
  }

  PolygraphTab copyWith({
    Term? term,
    PolygraphVariable? xVariable,
    List<PolygraphVariable>? yVariables,
  }) {
    return PolygraphTab(
      term: term ?? this.term,
      xVariable: xVariable ?? this.xVariable,
      yVariables: yVariables ?? this.yVariables,
    );
  }
}



class PolygraphTabNotifier extends StateNotifier<PolygraphTab> {
  PolygraphTabNotifier(this.ref) : super(PolygraphTab.getDefault());

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

