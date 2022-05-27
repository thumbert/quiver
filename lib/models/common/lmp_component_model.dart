library models.common.lmp_component_model;

import 'package:flutter/material.dart';

mixin LmpComponentMixin on ChangeNotifier {
  late String _component;
  static final allowedValues = <String>['LMP', 'Congestion', 'Loss'];

  set lmpComponent(String value) {
    if (allowedValues.contains(value)) {
      _component = value;
      notifyListeners();
    }
  }

  void setLmpComponent(String value) {
    _component = value;
  }

  /// One of 'LMP', 'Congestion', 'Loss'
  String get lmpComponent => _component;
}

class LmpComponentModel extends ChangeNotifier with LmpComponentMixin {
  LmpComponentModel(String lmpComponent) {
    _component = lmpComponent;
  }

  // void init(String value) {
  //   if (LmpComponentMixin.allowedValues.contains(value)) {
  //     _component = value;
  //   }
  // }
}
