library models.asset_id_model;

import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';

class AssetIdModel extends ChangeNotifier {
  AssetIdModel();

  /// Should empty lists be allowed?
  late List<int> _ids;

  /// to be filled from a webservice
  static const List<int> allIds = <int>[];

  void init(List<int> ids) => _ids = ids;

  set ids(List<int> ids) {
    _ids = ids;
    notifyListeners();
  }

  List<int> get ids => _ids;
}
