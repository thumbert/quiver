library models.common.region_load_zone_model;

import 'package:elec/elec.dart';
import 'package:elec_server/client/other/ptids.dart';
import 'package:flutter/material.dart';
import 'package:elec/ftr.dart';

class RegionLoadZoneModel extends ChangeNotifier {
  RegionLoadZoneModel({region = 'NYISO', zoneName = '(All)'}) {
    _region = region;
    _zoneName = zoneName;
  }

  late final PtidsApi client;
  late FtrPath ftrPath;

  static final allowedRegions = <String, Iso>{
    'ISONE': Iso.newEngland,
    'NYISO': Iso.newYork
  };

  late String _region;
  late String _zoneName;

  Iso get iso => allowedRegions[region]!;

  /// When the region is reset
  set region(String value) {
    _region = value;
    _zoneName = '(All)'; // reset the zone too
    notifyListeners();
  }

  String get region => _region;

  set zoneName(String value) {
    _zoneName = value;
    notifyListeners();
  }

  String get zoneName => _zoneName;

  /// For zoneName = '(All)' return null, otherwise return the correct ptid.
  int? get zoneId => iso.loadZones[zoneName];

  /// All the available load zones
  Iterable<String> getZoneNames() => iso.loadZones.keys;
}
