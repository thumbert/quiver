library models.common.multiple.maxpayoff_model;

import 'package:flutter/material.dart';

class MaxPayoffModel extends ChangeNotifier {
  MaxPayoffModel() {
    _maxPayoffs = <num>[];
  }

  final allDigitsRegExp = RegExp(r'^[0-9]*$');

  late List<num> _maxPayoffs;

  void insert(int index, num value) {
    _maxPayoffs.insert(index, value);
  }

  void removeAt(int index) {
    _maxPayoffs.removeAt(index);
  }

  num operator [](int i) => _maxPayoffs[i];

  operator []=(int i, num value) {
    _maxPayoffs[i] = value;
    notifyListeners();
  }

  bool isValid(String text) => allDigitsRegExp.hasMatch(text);
}
