library models.common.region_model;

import 'package:elec/elec.dart';
import 'package:elec_server/client/other/ptids.dart';
import 'package:flutter/material.dart';
import 'package:elec/ftr.dart';

class RegionModel extends ChangeNotifier {
  RegionModel({region = 'ISONE', List<String>? allowedRegions}) {
    _region = region;
    if (allowedRegions == null) {
      this.allowedRegions = allRegions.keys.toList();
    } else {
      this.allowedRegions = allowedRegions;
    }
  }

  late final PtidsApi client;
  late final List<String> allowedRegions;

  static final allRegions = <String, Iso>{
    'ISONE': Iso.newEngland,
    'NYISO': Iso.newYork
  };

  late String _region;

  Iso get iso => allRegions[region]!;

  /// When the region is reset
  set region(String value) {
    if (allowedRegions.contains(value)) {
      _region = value;
      notifyListeners();
    }
  }

  String get region => _region;
}
