library models.date_with_checkbox_model;

import 'package:date/date.dart';
import 'package:flutter/material.dart';

class DateWithCheckboxModel extends ChangeNotifier {
  DateWithCheckboxModel(
      {String date = '(All)',
      bool checkbox = false,
      required List<Date> allowedDates}) {
    _date = date;
    _allowedDates = allowedDates;
    _checkbox = checkbox;
  }

  late String _date;
  late List<Date> _allowedDates; // in UTC
  late bool _checkbox;

  set date(String value) {
    _date = value;
    notifyListeners();
  }

  String get date => _date;

  set allowedDates(List<Date> values) {
    _allowedDates = [...values];
  }

  List<Date> get allowedDates => _allowedDates;

  set checkbox(bool value) {
    _checkbox = value;
    notifyListeners();
  }

  bool get checkbox => _checkbox;
}
