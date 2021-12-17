library models.buysell_model;

import 'package:flutter/material.dart';

class BuySellModel extends ChangeNotifier {
  BuySellModel() {
    _buySells = <String>[];
  }

  static const values = {'Buy', 'Sell'};

  late List<String> _buySells;

  void insert(int index, String value) {
    _buySells.insert(index, value);
  }

  void removeAt(int index) {
    _buySells.removeAt(index);
  }

  String operator [](int i) => _buySells[i];

  operator []=(int i, String value) {
    _buySells[i] = value;
    notifyListeners();
  }
}
