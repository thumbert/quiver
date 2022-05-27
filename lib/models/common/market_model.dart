library models.market_model;

import 'package:flutter/material.dart';

mixin MarketMixin on ChangeNotifier {
  late String _market;
  static final allowedValues = <String>['DA', 'RT'];

  set market(String market) {
    if (allowedValues.contains(market)) {
      _market = market;
      notifyListeners();
    }
  }

  void setMarket(String value) {
    _market = value;
  }

  String get market => _market;
}

class MarketModel extends ChangeNotifier with MarketMixin {
  MarketModel(String market) {
    _market = market;
  }

  // void init(String market) {
  //   if (MarketMixin.allowedValues.contains(market)) {
  //     _market = market;
  //   }
  // }
}
