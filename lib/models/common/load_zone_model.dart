library models.load_zone_model;

import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';

class LoadZoneModel extends ChangeNotifier {
  LoadZoneModel({required String zone}) {
    _zone = zone;
  }

  late String _zone;

  static const zones = <String, int?>{
    '(All)': null,
    'Maine': 4001,
    'NH': 4002,
    'VT': 4003,
    'CT': 4004,
    'RI': 4005,
    'SEMA': 4006,
    'WCMA': 4007,
    'NEMA': 4008,
  };

  set zone(String zone) {
    _zone = zone;
    // propagate the changes from the UI
    notifyListeners();
  }

  String get zone => _zone;

  /// Return [null] for Zone = '(All)'
  int? get zoneId => zones[_zone];
}
