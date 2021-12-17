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
      this.assetName, // autocomplete is empty
      bool byMonth = true}) {
    _byZone = byZone;
    _byMarket = byMarket;
    _market = market;
    _byAsset = byAsset;
    _byMonth = byMonth;
    client = MonthlyAssetNcpc(Client(), rootUrl: dotenv.env['rootUrl']!);
  }

  late MonthlyAssetNcpc client;
  late bool _byZone;
  late bool _byMarket;
  late String _market;
  late bool _byAsset;
  String? assetName;
  late bool _byMonth;
  Term? _term;
  int? _zoneId;

  /// TODO: implement caching
  var _cache = <Map<String, dynamic>>[];
  var _tableData = <Map<String, dynamic>>[];
  var assetNames = <String>{};
  String sortColumn = 'month';
  bool sortAscending = false;

  /// Get the data from the webservice and aggregate it.
  Future<Iterable<Map<String, dynamic>>> getData(Term term) async {
    if (_term == null || _term != term) {
      var start = Month.utc(term.startDate.year, term.startDate.month);
      var end = Month.utc(term.endDate.year, term.endDate.month);
      _cache = await client.getAllAssets(start, end);
      assetNames = _cache.map((e) => e['name'] as String).toSet();
    }
    _term = term;
    _tableData = client.summary(
      _cache,
      zoneId: _zoneId,
      byZoneId: byZone,
      market: market == '(All)' ? null : Market.parse(market),
      byMarket: byMarket,
      assetName: assetName,
      byAssetName: byAsset,
      byMonth: byMonth,
    );
    var sign = sortAscending ? 1 : -1;
    if (_tableData.first.keys.contains(sortColumn)) {
      /// there may be no sorted column in your aggregated table
      _tableData.sort((a, b) => a[sortColumn].compareTo(b[sortColumn]) * sign);
    }
    return _tableData;
  }

  List<Map<String, dynamic>> get data => _tableData;

  set zoneId(int? value) => _zoneId = value;

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

  set byMonth(bool value) {
    _byMonth = value;
    notifyListeners();
  }

  bool get byMonth => _byMonth;
}
