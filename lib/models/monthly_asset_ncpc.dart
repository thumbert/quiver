library models.monthly_asset_ncpc;

import 'package:elec/risk_system.dart';
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

  /// TODO: implement caching
  var _cache = <Map<String, dynamic>>[];
  var tableData = <Map<String, dynamic>>[];
  late List<String> columns;
  bool sortAscending = false;

  /// Get the data from the webservice.
  Future<Iterable<Map<String, dynamic>>> getData(Term term) async {
    var start = Month.utc(term.startDate.year, term.startDate.month);
    var end = Month.utc(term.endDate.year, term.endDate.month);
    _cache = await client.getAllAssets(start, end);
    tableData = _cache;
    return _cache;
  }

  void aggregateData({required int? zoneId}) {
    tableData = client.summary(
      _cache,
      zoneId: zoneId,
      byZoneId: byZone,
      market: market == '(All)' ? null : Market.parse(market),
      byMarket: byMarket,
      assetName: assetName == '(All)' ? null : assetName,
      byAssetName: byAsset,
      byMonth: byMonth,
    );
    columns = tableData.first.keys.toList();
  }

  void sortByColumn({required String name, required sortAscending}) {
    print('in sortByColumn');
    var sign = sortAscending ? 1 : -1;
    if (name == 'value') {
      tableData.sort((a, b) => a['value'].compareTo(b['value']) * sign);
      tableData = List.from(tableData);
      print(tableData);
    }

    notifyListeners();
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
