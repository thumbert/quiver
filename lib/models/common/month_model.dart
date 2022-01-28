library models.month_model;

import 'package:date/date.dart';
import 'package:flutter/material.dart';

class MonthModel extends ChangeNotifier {
  MonthModel({required Month month}) {
    _month = month;
  }

  late Month _month;

  set month(Month month) {
    _month = month;
    notifyListeners();
  }

  Month get month => _month;
}
