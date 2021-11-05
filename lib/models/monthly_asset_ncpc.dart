library models.monthly_asset_ncpc;

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:elec_server/client/isoexpress/monthly_asset_ncpc.dart';
import 'package:http/http.dart';

class MonthlyAssetNcpcModel extends ChangeNotifier {
  MonthlyAssetNcpcModel(
      {bool byZone = false,
      bool byMarket = false,
      String market = '(All)',
      bool byAsset = false,
      String assetName = '(All)',
      bool byMonth = true}) {
    _byZone = byZone;
    _byMarket = byMarket;
    _market = market;
    _byAsset = byAsset;
    _assetName = assetName;
    _byMonth = byMonth;
    client = MonthlyAssetNcpc(Client(), rootUrl: dotenv.env['rootUrl']!);
  }

  late MonthlyAssetNcpc client;
  late bool _byZone;
  late bool _byMarket;
  late String _market;
  late bool _byAsset;
  late String _assetName;
  late bool _byMonth;

  var _cache = <Map<String, dynamic>>[];
  // late Iterable<Map<String,dynamic>> _tableData;

  /// Get the data from the webservice.
  Future<Iterable<Map<String, dynamic>>> getData(Term term) async {
    var start = Month.utc(term.startDate.year, term.startDate.month);
    var end = Month.utc(term.endDate.year, term.endDate.month);
    // if (_cache.isEmpty) {
    _cache = await client.getAllAssets(start, end);
    // }
    var _start = start.toIso8601String();
    var _end = end.toIso8601String();
    return _cache;
    // print(_cache.first);
    // return _cache.where((e) => e['month'] >= _start && e['month'] <= _end);
  }

  set byZone(bool value) {
    _byZone = value;
    notifyListeners();
  }

  bool get byZone => _byZone;

  set byMarket(bool value) {
    _byMarket = value;
    notifyListeners();
  }

  bool get byMarket => _byMarket;

  set market(String value) {
    _market = value;
    notifyListeners();
  }

  String get market => _market;

  set byAsset(bool value) {
    _byAsset = value;
    notifyListeners();
  }

  bool get byAsset => _byAsset;

  set assetName(String value) {
    _assetName = value;
    notifyListeners();
  }

  String get assetName => _assetName;

  set byMonth(bool value) {
    _byMonth = value;
    notifyListeners();
  }

  bool get byMonth => _byMonth;
}
