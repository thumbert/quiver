import 'package:flutter/material.dart';

class AssetAutocompleteModel extends ChangeNotifier {
  AssetAutocompleteModel();

  static var assetNames = <String>{};

  String? _assetName;

  set assetName(String? value) {
    _assetName = value;
    notifyListeners();
  }

  String? get assetName => _assetName;
}
