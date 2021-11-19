library models.weather.maxpayoff_model;

import 'package:flutter/material.dart';

class MaxPayoffModel extends ChangeNotifier {
  MaxPayoffModel({required num maxPayoff}) {
    _maxPayoff = maxPayoff;
  }

  final allDigitsRegExp = RegExp(r'^[0-9]*$');

  late num _maxPayoff;

  set maxPayoff(num value) {
    _maxPayoff = value;
    notifyListeners();
  }

  num get maxPayoff => _maxPayoff;

  bool isValid(String text) => allDigitsRegExp.hasMatch(text);
}
