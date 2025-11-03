import 'package:flutter_quiver/models/common/load_zone_model.dart';

class LoadZoneWithCheckboxModel extends LoadZoneModel {
  LoadZoneWithCheckboxModel({required super.zone, required bool checkbox}) {
    _checkbox = checkbox;
  }

  late bool _checkbox;

  set checkbox(bool value) {
    _checkbox = value;
    notifyListeners();
  }

  bool get checkbox => _checkbox;
}
