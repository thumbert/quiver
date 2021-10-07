library models.entity_model;

import 'package:flutter_quiver/models/common/entity_model.dart';

class EntityWithCheckboxModel extends EntityModel {
  EntityWithCheckboxModel(
      {required String entity,
      required String subaccount,
      required bool checkboxEntity,
      required bool checkboxSubaccount})
      : super(entity: entity, subaccount: subaccount) {
    _checkboxEntity = checkboxEntity;
    _checkboxSubaccount = checkboxSubaccount;
  }

  late bool _checkboxEntity;
  late bool _checkboxSubaccount;

  set checkboxEntity(bool value) {
    _checkboxEntity = value;
    notifyListeners();
  }

  bool get checkboxEntity => _checkboxEntity;

  set checkboxSubaccount(bool value) {
    _checkboxSubaccount = value;
    notifyListeners();
  }

  bool get checkboxSubaccount => _checkboxSubaccount;
}
