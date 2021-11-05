library models.weather.airport_model;

import 'package:flutter/material.dart';

class AirportModel extends ChangeNotifier {
  AirportModel({required String airportCode}) {
    _airportCode = airportCode;
  }

  late String _airportCode;

  final allLettersRegExp = RegExp(r'[A-Z]{3}', caseSensitive: false);

  /// Perform validation.  Needs to be exactly 3 letters.
  bool isValid(String value) {
    return value.length == 3 && allLettersRegExp.hasMatch(value);
  }

  set airportCode(String value) {
    _airportCode = value;
    notifyListeners();
  }

  String get airportCode => _airportCode;
}
