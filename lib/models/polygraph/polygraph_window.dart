library models.polygraph.polygraph_window;

import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
import 'package:flutter_quiver/models/polygraph/variables/realized_electricity_variable.dart' as rev;
import 'package:flutter_quiver/models/polygraph/variables/forward_electricity_variable.dart' as fev;
import 'package:flutter_quiver/models/polygraph/variables/time_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';

final providerOfPolygraphWindow =
  StateNotifierProvider<PolygraphWindowNotifier, PolygraphWindow>(
        (ref) => PolygraphWindowNotifier(ref));


class PolygraphWindow {
  PolygraphWindow({
    required term,
    required this.timezone,
    required this.xVariable,
    required this.yVariables,
  }) {
    this.term = Term.fromInterval(term.interval.withTimeZone(timezone));
  }

  /// Historical term in the given timezone
  late final Term term;
  final Location timezone;
  final PolygraphVariable xVariable;
  final List<PolygraphVariable> yVariables;

  ///
  PolygraphWindow fromMongo(Map<String,dynamic> x) {
    return PolygraphWindow.getDefault();
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

  static PolygraphWindow getDefault() {
    var today = Date.today(location: UTC);
    var term =
    Term(Month.fromTZDateTime(today.start).subtract(4).startDate, today);

    var xVariable = TimeVariable();
    var yVariables = [
      rev.massHubDa..timeAggregation = TimeAggregation(frequency: 'daily', function: 'mean'),
      fev.massHubDa5x16LmpCal24,
    ];

    return PolygraphWindow(
        term: term,
        timezone: UTC,
        xVariable: xVariable, yVariables: yVariables);
  }

  PolygraphWindow copyWith({
    Term? term,
    Location? timezone,
    PolygraphVariable? xVariable,
    List<PolygraphVariable>? yVariables,
  }) {
    return PolygraphWindow(
      term: term ?? this.term,
      timezone: timezone ?? this.timezone,
      xVariable: xVariable ?? this.xVariable,
      yVariables: yVariables ?? this.yVariables,
    );
  }
}



class PolygraphWindowNotifier extends StateNotifier<PolygraphWindow> {
  PolygraphWindowNotifier(this.ref) : super(PolygraphWindow.getDefault());

  final Ref ref;

  set term(Term value) {
    state = state.copyWith(term: value);
  }

  set timezone(Location value) {
    state = state.copyWith(timezone: value);
  }

  set xVariable(PolygraphVariable value) {
    state = state.copyWith(xVariable: value);
  }

  set yVariables(List<PolygraphVariable> values) {
    state = state.copyWith(yVariables: values);
  }
}

