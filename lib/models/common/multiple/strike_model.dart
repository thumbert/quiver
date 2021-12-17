library models.weather.strike_model;

import 'package:flutter/material.dart';

class StrikeModel extends ChangeNotifier {
  StrikeModel() {
    _strikes = <num>[];
  }

  final allDigitsRegExp = RegExp(r'^[0-9]*$');

  late List<num> _strikes;

  void insert(int index, num value) {
    _strikes.insert(index, value);
  }

  void removeAt(int index) {
    _strikes.removeAt(index);
  }

  num operator [](int i) => _strikes[i];

  operator []=(int i, num value) {
    _strikes[i] = value;
    notifyListeners();
  }

  bool isValid(String text) => allDigitsRegExp.hasMatch(text);
}
