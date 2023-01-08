library models.polygraph.polygraph_model;

import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart';

final providerOfPolygraph =
    StateNotifierProvider<PolygraphNotifier, PolygraphState>(
        (ref) => PolygraphNotifier(ref));


class PolygraphState {
  PolygraphState({
    required this.term,
  });

  /// Historical term, in UTC
  final Term term;

  static PolygraphState getDefault() {
    var today = Date.today(location: UTC);
    var term =
        Term(Month.fromTZDateTime(today.start).subtract(4).startDate, today);

    return PolygraphState(term: term);
  }

  PolygraphState copyWith({
    Term? term,
  }) {
    return PolygraphState(term: term ?? this.term);
  }
}

class PolygraphNotifier extends StateNotifier<PolygraphState> {
  PolygraphNotifier(this.ref) : super(PolygraphState.getDefault());

  final Ref ref;

  set term(Term value) {
    state = state.copyWith(term: value);
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
