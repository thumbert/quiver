library models.ptid_model;

import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';

class PtidModel extends ChangeNotifier {
  PtidModel({int? ptid}) {
    if (ptid != null) {
      _ptid = ptid;
    }
  }

  /// Should empty lists be allowed?
  late int _ptid;

  /// to be filled from a webservice and then cached ...
  static const List<int> allIds = <int>[];

  set ptid(int value) {
    _ptid = value;
    notifyListeners();
  }

  int get ptid => _ptid;
}
