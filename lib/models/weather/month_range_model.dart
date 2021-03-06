library models.weather.month_range_model;

import 'package:flutter/material.dart';

class MonthRangeModel extends ChangeNotifier {
  MonthRangeModel() {
    _monthRanges = <String>[];
  }

  late List<String> _monthRanges;

  void insert(int index, String value) {
    _monthRanges.insert(index, value);
  }

  void removeAt(int index) {
    _monthRanges.removeAt(index);
  }

  String operator [](int i) => _monthRanges[i];

  operator []=(int i, String value) {
    _monthRanges[i] = value;
    notifyListeners();
  }

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
