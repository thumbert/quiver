library models.weather.strike_model;

import 'package:flutter/material.dart';

class StrikeModel extends ChangeNotifier {
  StrikeModel({required num strike}) {
    _strike = strike;
  }

  final allDigitsRegExp = RegExp(r'^[0-9]*$');

  late num _strike;

  set strike(num value) {
    _strike = value;
    notifyListeners();
  }

  num get strike => _strike;

  bool isValid(String text) => allDigitsRegExp.hasMatch(text);
}
