library models.weather.instrument_model;

import 'package:flutter/material.dart';

class InstrumentModel extends ChangeNotifier {
  InstrumentModel({required String instrument}) {
    _instrument = instrument;
  }

  late String _instrument;

  set instrument(String value) {
    _instrument = value;
    notifyListeners();
  }

  String get instrument => _instrument;

  /// List of available values in the dropdown
  static final List<String> instruments = [
    'HDD swap',
    'HDD call',
    'HDD put',
    'CDD swap',
    'CDD call',
    'CDD put',
    'Daily call',
    'Daily put',
  ];
}
