library models.common.region_model;

import 'package:elec/elec.dart';
import 'package:flutter/material.dart';

mixin RegionMixin on ChangeNotifier {
  late List<String> allowedRegions;

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

  void setRegion(String region) {
    _region = region;
  }

  String get region => _region;
}

class RegionModel extends ChangeNotifier with RegionMixin {
  RegionModel(String region) {
    _region = region;
    allowedRegions = RegionMixin.allRegions.keys.toList();
  }

  // void init(String region, {List<String>? allowedRegions}) {
  //   if (allowedRegions == null) {
  //     this.allowedRegions = RegionMixin.allRegions.keys.toList();
  //   } else {
  //     this.allowedRegions = allowedRegions;
  //   }
  //   if (this.allowedRegions.contains(region)) {
  //     _region = region;
  //   }
  // }
}
