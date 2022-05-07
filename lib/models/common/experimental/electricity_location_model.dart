library models.electricity_location_model;

import 'package:flutter/material.dart';

class ElectricityLocationModel extends ChangeNotifier {
  ElectricityLocationModel({
    required String region,
    required String deliveryPoint,
    required String market, // DA, RT
    required String bucket,
    required String lmpComponent}) {
    _bucket = bucket;
  }

  late String _bucket;

  static List<String> allowedBuckets = <String>[
    'Peak',
    'Offpeak',
    '2x16H',
    '7x8',
    '7x24',
  ];

  static List<String> allowedMarkets = ['DA', 'RT'];

  set bucket(String bucket) {
    _bucket = bucket;
    notifyListeners();
  }

  String get bucket => _bucket;
}
