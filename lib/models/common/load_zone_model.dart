library models.load_zone_model;

import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';

class LoadZoneModel extends ChangeNotifier {
  LoadZoneModel({required String zone}) {
    _zone = zone;
  }

  late String _zone;

  static const List<String> zones = <String>[
    '(All)',
    'Maine',
    'NH',
    'VT',
    'CT',
    'RI',
    'SEMA',
    'WCMA',
    'NEMA',
  ];

  set zone(String zone) {
    _zone = zone;
    // propagate the changes from the UI
    notifyListeners();
  }

  String get zone => _zone;
}
