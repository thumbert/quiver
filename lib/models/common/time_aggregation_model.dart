library models.time_aggregation_model;

import 'package:flutter/material.dart';

class TimeAggregationModel extends ChangeNotifier {
  TimeAggregationModel({required String level, List<String>? levels}) {
    _level = level;
    if (levels != null) {
      this.levels = levels;
    }
  }

  late String _level;

  List<String> levels = <String>[
    'Term',
    'Month',
    'Day',
  ];

  set level(String value) {
    _level = value;
    notifyListeners();
  }

  String get level => _level;
}
