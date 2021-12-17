library models.weather.instrument_model;

import 'package:flutter/material.dart';
import 'package:elec/src/risk_system/pricing/calculators/weather/cdd_hdd.dart';

class InstrumentModel extends ChangeNotifier {
  InstrumentModel() {
    _instruments = <String>[];
  }

  late List<String> _instruments;

  void insert(int index, String value) {
    _instruments.insert(index, value);
  }

  void removeAt(int index) {
    _instruments.removeAt(index);
  }

  String operator [](int i) => _instruments[i];

  operator []=(int i, String value) {
    _instruments[i] = value;
    notifyListeners();
  }

  /// List of available values in the dropdown
  static final List<String> instruments = [
    'HDD swap',
    'HDD call',
    'HDD put',
    'CDD swap',
    'CDD call',
    'CDD put',
    'Daily T call',
    'Daily T put',
  ];
}
