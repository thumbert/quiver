library models.ftr_path.region_source_sink_model;

import 'package:elec/elec.dart';
import 'package:http/http.dart' as http;
import 'package:elec_server/client/other/ptids.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RegionSourceSinkModel extends ChangeNotifier {
  RegionSourceSinkModel({
    String region = 'ISONE',
  }) {
    _region = region;
    if (region == 'ISONE') {
      _bucket = Bucket.b5x16;
    } else {
      // NYISO
      _bucket = Bucket.atc;
    }
    client = PtidsApi(http.Client(), rootUrl: dotenv.env['ROOT_URL']!);
  }

  late final PtidsApi client;

  final allowedRegions = <String>['ISONE', 'NYISO'];

  /// region -> name -> ptid
  final _cacheNameMap = <String, Map<String, int>>{};

  late String _region;
  String? _sourceName;
  String? _sinkName;
  late Bucket _bucket;


  Future<Map<String, int>> getNameMap() async {
    if (!_cacheNameMap.containsKey(region)) {
      var aux = await client.getPtidTable(region: region.toLowerCase());
      _cacheNameMap[region] = {for (var e in aux) e['name']: e['ptid']};
    }
    return _cacheNameMap[region]!;
  }

  List<String> allowedBuckets() {
    if (region == 'ISONE') {
      return ['5x16', 'Offpeak'];
    } else {
      return ['7x24'];
    }
  }

  set region(String value) {
    _region = value;
    _sourceName = null;
    _sinkName = null;
    if (_region == 'ISONE') {
      _bucket = Bucket.b5x16;
    } else {
      _bucket = Bucket.atc;
    }
    notifyListeners();
  }

  String get region => _region;

  set sourceName(String? value) {
    _sourceName = value;
    notifyListeners();
  }

  String? get sourceName => _sourceName;

  set sinkName(String? value) {
    _sinkName = value;
    notifyListeners();
  }

  String? get sinkName => _sinkName;

  /// A map from name -> ptid
  Map<String, int> get nameMap => _cacheNameMap[region]!;

  set bucket(String bucket) {
    _bucket = Bucket.parse(bucket);
    notifyListeners();
  }

  String get bucket => _bucket.toString();


}
