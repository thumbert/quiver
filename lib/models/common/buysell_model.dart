library models.buysell_model;

import 'package:flutter/material.dart';

class BuySellModel extends ChangeNotifier {
  BuySellModel({required String buySell}) {
    if (!values.contains(buySell)) {
      throw ArgumentError('Invalid value $buySell in BuySell constructor');
    }
    _buysell = buySell;
  }

  static const values = {'Buy', 'Sell'};

  late String _buysell;

  set buySell(String value) {
    _buysell = value;
    notifyListeners();
  }

  String get buySell => _buysell;
}
