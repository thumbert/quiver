library models.load_zone_with_checkbox_model;

import 'package:flutter_quiver/models/common/load_zone_model.dart';

class LoadZoneWithCheckboxModel extends LoadZoneModel {
  LoadZoneWithCheckboxModel({required String zone, required bool checkbox})
      : super(zone: zone) {
    _checkbox = checkbox;
  }

  late bool _checkbox;

  set checkbox(bool value) {
    _checkbox = value;
    notifyListeners();
  }

  bool get checkbox => _checkbox;
}
