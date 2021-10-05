library models.load_zone_model;

import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';

class LoadZoneModel extends ChangeNotifier {
  LoadZoneModel() {
    _zone = zones.first;
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

  /// Set the _zone without triggering a notification.
  void init(String zone) => _zone = zone;

  set zone(String zone) {
    _zone = zone;
    // propagate the changes from the UI
    notifyListeners();
  }

  String get zone => _zone;
}
