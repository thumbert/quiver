library models.weather.notional_model;

import 'package:flutter/material.dart';

class NotionalModel extends ChangeNotifier {
  NotionalModel({required num notional}) {
    _notional = notional;
  }

  final allDigitsRegExp = RegExp(r'^[0-9]*$');

  late num _notional;

  set notional(num value) {
    _notional = value;
    notifyListeners();
  }

  num get notional => _notional;

  bool isValid(String text) => allDigitsRegExp.hasMatch(text);
}
