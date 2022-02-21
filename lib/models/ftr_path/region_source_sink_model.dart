library models.ftr_path.region_source_sink_model;

import 'package:elec/elec.dart';
import 'package:http/http.dart' as http;
import 'package:elec_server/client/other/ptids.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:elec/ftr.dart';

class RegionSourceSinkModel extends ChangeNotifier {
  RegionSourceSinkModel() {
    _region = 'NYISO';
    _sourceName = initialValues[region]!['sourceName'] as String;
    _sinkName = initialValues[region]!['sinkName'] as String;
    _bucket = initialValues[region]!['bucket'] as Bucket;
    client = PtidsApi(http.Client(), rootUrl: dotenv.env['ROOT_URL']!);
    ftrPath = FtrPath(
        sourcePtid: initialValues[region]!['sourcePtid'] as int,
        sinkPtid: initialValues[region]!['sinkPtid'] as int,
        bucket: _bucket,
        iso: iso,
        rootUrl: dotenv.env['ROOT_URL']!);
  }

  late final PtidsApi client;
  late FtrPath ftrPath;

  final allowedRegions = <String, Iso>{
    'ISONE': Iso.newEngland,
    'NYISO': Iso.newYork
  };

  final initialValues = {
    'ISONE': {
      'sourceName': '.H.INTERNAL HUB, ptid: 4000',
      'sourcePtid': 4000,
      'sinkName': '.Z.MAINE, ptid: 4001',
      'sinkPtid': 4001,
      'bucket': Bucket.b5x16,
    },
    'NYISO': {
      'sourceName': 'Zone A, ptid: 61752',
      'sourcePtid': 61752,
      'sinkName': 'Zone G, ptid: 61758',
      'sinkPtid': 61758,
      'bucket': Bucket.atc,
    },
  };

  /// region -> nodeName -> ptid
  final _cacheNameMap = <String, Map<String, int>>{};

  late String _region;
  late String _sourceName;
  late String _sinkName;
  late Bucket _bucket;

  /// when all components are set properly, this is non-null.

  /// Map the String that shows up in the TextField to the ptid
  Future<Map<String, int>> getNameMap() async {
    if (!_cacheNameMap.containsKey(region)) {
      _cacheNameMap[region] = <String, int>{};
      var aux = await client.getPtidTable(region: region.toLowerCase());
      if (region == 'NYISO') {
        /// add the zones first, in a spoken form
        var _zones = aux.where((e) => e['type'] == 'zone');
        for (var _zone in _zones) {
          if (_zone.containsKey('spokenName')) {
            var label = '${_zone['spokenName']}, ptid: ${_zone['ptid']}';
            _cacheNameMap[region]![label] = _zone['ptid'];
          }
        }
      }
      _cacheNameMap[region]!.addAll(
          {for (var e in aux) '${e['name']}, ptid: ${e['ptid']}': e['ptid']});
    }
    return _cacheNameMap[region]!;
  }

  int get sourcePtid =>
      _cacheNameMap[_region]![_sourceName] ??
      initialValues[_region]!['sourcePtid'] as int;

  int get sinkPtid =>
      _cacheNameMap[_region]![_sinkName] ??
      initialValues[_region]!['sinkPtid'] as int;

  Iso get iso => allowedRegions[region]!;

  /// When the region is reset, populate with the default path
  set region(String value) {
    _region = value;
    _sourceName = initialValues[_region]!['sourceName'] as String;
    _sinkName = initialValues[_region]!['sinkName'] as String;
    _bucket = initialValues[_region]!['bucket'] as Bucket;
    ftrPath = FtrPath(
        sourcePtid: initialValues[region]!['sourcePtid'] as int,
        sinkPtid: initialValues[region]!['sinkPtid'] as int,
        bucket: _bucket,
        iso: iso,
        rootUrl: dotenv.env['ROOT_URL']!);
    notifyListeners();
  }

  String get region => _region;

  set sourceName(String value) {
    _sourceName = value;
    ftrPath = FtrPath(
        sourcePtid: sourcePtid,
        sinkPtid: sinkPtid,
        bucket: _bucket,
        iso: iso,
        rootUrl: dotenv.env['ROOT_URL']!);
    notifyListeners();
  }

  String get sourceName => _sourceName;

  set sinkName(String value) {
    _sinkName = value;
    ftrPath = FtrPath(
        sourcePtid: sourcePtid,
        sinkPtid: sinkPtid,
        bucket: _bucket,
        iso: iso,
        rootUrl: dotenv.env['ROOT_URL']!);
    notifyListeners();
  }

  String get sinkName => _sinkName;

  /// A map from name -> ptid
  Map<String, int> get nameMap => _cacheNameMap[region]!;

  set bucket(String bucket) {
    _bucket = Bucket.parse(bucket);
    ftrPath = FtrPath(
        sourcePtid: sourcePtid,
        sinkPtid: sinkPtid,
        bucket: _bucket,
        iso: iso,
        rootUrl: dotenv.env['ROOT_URL']!);
    notifyListeners();
  }

  String get bucket => _bucket.toString();

  Bucket get bucketObject => _bucket;

  List<String> allowedBuckets() {
    if (region == 'ISONE') {
      return ['5x16', 'Offpeak'];
    } else {
      return ['7x24'];
    }
  }
}
