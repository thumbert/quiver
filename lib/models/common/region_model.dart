library models.common.region_model;

import 'package:elec/elec.dart';
import 'package:elec_server/client/other/ptids.dart';
import 'package:flutter/material.dart';
import 'package:elec/ftr.dart';

class RegionModel extends ChangeNotifier {
  RegionModel({region = 'ISONE'}) {
    _region = region;
  }

  late final PtidsApi client;

  static final allowedRegions = <String, Iso>{
    'ISONE': Iso.newEngland,
    'NYISO': Iso.newYork
  };

  late String _region;

  Iso get iso => allowedRegions[region]!;

  /// When the region is reset
  set region(String value) {
    _region = value;
    notifyListeners();
  }

  String get region => _region;
}
