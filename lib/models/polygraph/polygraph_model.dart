library models.polygraph.polygraph_model;

import 'package:flutter/material.dart';

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
