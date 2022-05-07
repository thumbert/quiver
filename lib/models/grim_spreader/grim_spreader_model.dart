library models.grim_spreader.grim_spreader_model;

import 'package:flutter/material.dart';

class GrimSpreaderModel extends ChangeNotifier {
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
