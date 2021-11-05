library models.weather.month_range_model;

import 'package:flutter/material.dart';

class MonthRangeModel extends ChangeNotifier {
  MonthRangeModel({required String monthRange}) {
    _monthRange = monthRange;
  }

  late String _monthRange;

  set monthRange(String value) {
    _monthRange = value;
    notifyListeners();
  }

  String get monthRange => _monthRange;

  /// List of available values in the dropdown
  static final Map<String, List<int>> ranges = {
    'Jan': [1, 1],
    'Jan-Feb': [1, 2],
    'Feb': [2, 2],
    'Mar': [3, 3],
    'Apr': [4, 4],
    'May': [5, 5],
    'Jun': [6, 6],
    'Jun-Aug': [6, 8],
    'Jun-Sep': [6, 9],
    'Jul': [7, 7],
    'Jul-Aug': [7, 8],
    'Aug': [8, 8],
    'Sep': [9, 9],
    'Oct': [10, 10],
    'Nov': [11, 11],
    'Nov-Mar': [11, 3],
    'Dec': [12, 12],
    'Dec-Feb': [12, 2],
    'Dec-Mar': [12, 3],
  };
}
