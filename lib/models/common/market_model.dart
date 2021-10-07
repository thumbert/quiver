library models.market_model;

import 'package:flutter/material.dart';

class MarketModel extends ChangeNotifier {
  MarketModel({required String market}) {
    _market = market;
  }

  late String _market;

  set market(String market) {
    _market = market;
    notifyListeners();
  }

  String get market => _market;
}
