library models.common.region_model;

import 'package:elec/elec.dart';
import 'package:elec_server/client/other/ptids.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';

mixin PowerDeliveryPointMixin on ChangeNotifier {
  late final PtidsApi ptidClient;

  late String _deliveryPointName;
  late String _currentRegion;

  late final List<String> _allowedRegions;

  static final allRegions = <String, Iso>{
    'ISONE': Iso.newEngland,
    'NYISO': Iso.newYork
  };

  /// A cache of region -> nodeName -> ptid
  /// Exposing this so you can restrict or maybe add nodes on top of what
  /// already exist in the database.
  final cacheNameMap = <String, Map<String, int>>{};

  /// Map the String that shows up in the TextField to the ptid
  ///
  Future<Map<String, int>> getNameMap() async {
    if (!cacheNameMap.containsKey(_currentRegion)) {
      cacheNameMap[_currentRegion] = <String, int>{};
      var aux =
          await ptidClient.getPtidTable(region: _currentRegion.toLowerCase());
      if (_currentRegion == 'NYISO') {
        /// add the zones first, in a spoken form (the alphabet soup)
        var _zones = aux.where((e) => e['type'] == 'zone');
        for (var _zone in _zones) {
          if (_zone.containsKey('spokenName')) {
            var label = '${_zone['spokenName']}, ptid: ${_zone['ptid']}';
            cacheNameMap[_currentRegion]![label] = _zone['ptid'];
          }
        }
      }
      if (aux.isNotEmpty) {
        cacheNameMap[_currentRegion]!.addAll(
            {for (var e in aux) '${e['name']}, ptid: ${e['ptid']}': e['ptid']});
      }
    }
    return cacheNameMap[_currentRegion]!;
  }

  ///
  set deliveryPointName(String value) {
    _deliveryPointName = value;
    notifyListeners();
  }

  set currentRegion(String value) {
    _currentRegion = value;
    _deliveryPointName = defaultName(value);
  }

  String get currentRegion => _currentRegion;

  void setDeliveryPointName(String value) {
    _deliveryPointName = value;
  }

  /// What gets displayed on the screen
  String get deliveryPointName => _deliveryPointName;

  /// Get the default delivery point name for a given region, e.g.
  /// for ISONE: '.H.INTERNAL_HUB, ptid: 4000'.
  String defaultName(String region) {
    if (region == 'ISONE') {
      return '.H.INTERNAL_HUB, ptid: 4000';
    } else if (region == 'NYISO') {
      return 'Zone G, ptid: 61758';
    } else {
      throw ArgumentError('Unsupported region $region');
    }
  }
}

class PowerDeliveryPointModel extends ChangeNotifier
    with PowerDeliveryPointMixin {
  PowerDeliveryPointModel(String deliveryPoint) {
    _deliveryPointName = deliveryPoint;
    ptidClient = PtidsApi(http.Client(), rootUrl: dotenv.env['ROOT_URL']!);
  }
}
