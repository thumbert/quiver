library models.load_aggregation_model;

import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';

class LoadAggregationModel extends ChangeNotifier {
  LoadAggregationModel() {
    _aggregationName = zones.first;
  }

  late String _aggregationName;

  /// ideally this will come from a webservice
  static const List<String> zones = <String>[
    '(All)',
    'City of Paris',
    'City of Gotham',
    'City of Periferi',
  ];

  void init(String aggregationName) => _aggregationName = aggregationName;

  set aggregationName(String name) {
    _aggregationName = name;
    notifyListeners();
  }

  String get aggregationName => _aggregationName;
}
