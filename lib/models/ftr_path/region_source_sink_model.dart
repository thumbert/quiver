library models.ftr_path.region_source_sink_model;

import 'package:http/http.dart' as http;
import 'package:elec_server/client/other/ptids.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RegionSourceSinkModel extends ChangeNotifier {
  RegionSourceSinkModel({
    String region = 'ISONE',
    String sourceName = '4000',
    String sinkName = '4008',
  }) {
    _region = region;
    client = PtidsApi(http.Client(), rootUrl: dotenv.env['rootUrl']!);
  }

  late final PtidsApi client;

  final allowedRegions = <String>['ISONE', 'NYISO'];

  /// region -> name -> ptid
  final _cacheNameMap = <String, Map<String, int>>{};

  Future<Map<String, int>> getNameMap() async {
    if (!_cacheNameMap.containsKey(region)) {
      var aux = await client.getPtidTable(region: region.toLowerCase());
      _cacheNameMap[region] = {for (var e in aux) e['name']: e['ptid']};
    }
    return _cacheNameMap[region]!;
  }

  late String _region;
  late String _sourceName;
  late String _sinkName;

  set region(String value) {
    _region = value;
    notifyListeners();
  }

  String get region => _region;

  set sourceName(String value) {
    _sourceName = value;
    notifyListeners();
  }

  String get sourceName => _sourceName;

  set sinkName(String value) {
    _sinkName = value;
    notifyListeners();
  }

  String get sinkName => _sinkName;

  Map<String, int> get nameMap => _cacheNameMap[region]!;
}
