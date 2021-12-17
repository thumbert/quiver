library models.common.multiple.notional_model;

import 'package:flutter/material.dart';

class NotionalModel extends ChangeNotifier {
  NotionalModel() {
    _notionals = <num>[];
  }

  final allDigitsRegExp = RegExp(r'^[0-9]*$');

  late List<num> _notionals;

  void insert(int index, num value) {
    _notionals.insert(index, value);
  }

  void removeAt(int index) {
    _notionals.removeAt(index);
  }

  num operator [](int i) => _notionals[i];

  operator []=(int i, num value) {
    _notionals[i] = value;
    notifyListeners();
  }

  bool isValid(String text) => allDigitsRegExp.hasMatch(text);
}
