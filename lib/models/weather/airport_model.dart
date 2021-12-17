library models.weather.airport_model;

import 'package:flutter/material.dart';

class AirportModel extends ChangeNotifier {
  AirportModel() {
    _airportCodes = <String>[];
  }

  late List<String> _airportCodes;

  List<String> get values => _airportCodes;

  void insert(int index, String value) {
    _airportCodes.insert(index, value.toUpperCase());
  }

  void removeAt(int index) {
    _airportCodes.removeAt(index);
  }

  void clear() => _airportCodes.clear();

  String operator [](int i) => _airportCodes[i];

  operator []=(int i, String value) {
    _airportCodes[i] = value;
    notifyListeners();
  }

  final allLettersRegExp = RegExp(r'[A-Z]{3}', caseSensitive: false);

  /// Perform validation.  Needs to be exactly 3 letters.
  bool isValid(String value) {
    return value.length == 3 && allLettersRegExp.hasMatch(value);
  }

  // set airportCode(String value) {
  //   _airportCode = value;
  //   notifyListeners();
  // }
  //
  // String get airportCode => _airportCode;
}
