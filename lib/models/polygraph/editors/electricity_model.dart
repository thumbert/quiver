library models.polygraph.polygraph_model;

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/polygraph/variables/realized_electricity_variable.dart' as rev;
import 'package:flutter_quiver/models/polygraph/variables/forward_electricity_variable.dart' as fev;
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart';

final providerOfPolygraph =
StateNotifierProvider<PolygraphNotifier, PolygraphState>(
        (ref) => PolygraphNotifier(ref));

class PolygraphState {
  PolygraphState({
    required this.term,
    required this.xVariable,
    required this.yVariables,
  });

  /// Historical term, in UTC
  final Term term;
  final PolygraphVariable xVariable;
  final List<PolygraphVariable> yVariables;

  static PolygraphState getDefault() {
    var today = Date.today(location: UTC);
    var term =
    Term(Month.fromTZDateTime(today.start).subtract(4).startDate, today);

    var xVariable = TimeVariable();
    var yVariables = [
      rev.massHubDa..bucket = Bucket.b5x16,
      fev.massHubDa5x16LmpCal24,
    ];

    return PolygraphState(
        term: term, xVariable: xVariable, yVariables: yVariables);
  }

  PolygraphState copyWith({
    Term? term,
    PolygraphVariable? xVariable,
    List<PolygraphVariable>? yVariables,
  }) {
    return PolygraphState(
      term: term ?? this.term,
      xVariable: xVariable ?? this.xVariable,
      yVariables: yVariables ?? this.yVariables,
    );
  }
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

class PolygraphModel extends ChangeNotifier {
  static final layout = {
    'width': 900,
    'height': 700,
    // 'title': 'Energy offer prices',
    'xaxis': {
      'showgrid': true,
      'gridcolor': '#bdbdbd',
    },
    'yaxis': {
      'showgrid': true,
      'gridcolor': '#bdbdbd',
      'zeroline': false,
      // 'title': 'Energy offers, \$/Mwh',
    },
    'showlegend': true,
    'hovermode': 'closest',
  };
}
