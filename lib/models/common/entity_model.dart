library models.entity_model;

import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart';

class EntityModel extends ChangeNotifier {
  EntityModel({required String entity, required String subaccount}) {
    _entity = entity;
    _subaccount = subaccount;
  }

  late String _entity;
  late String _subaccount;

  static final _data = <String, List<String>>{
    'Invertase': ['Gen', 'Load'],
    'Puff Energy': ['Default', 'Virtuals', 'Load'],
  };

  /// Get the list of all accounts
  List<String> entities() => <String>[
        '(All)',
        ..._data.keys,
      ];

  List<String> subaccounts(String entity) => <String>[
        '(All)',
        ..._data[entity]!,
      ];

  set entity(String entity) {
    _entity = entity;

    /// if the existing subaccount doesn't exist, you need to switch to a
    /// valid one
    if (!subaccounts(entity).contains(_subaccount)) {
      _subaccount = subaccounts(entity).first;
    }
    notifyListeners();
  }

  String get entity => _entity;

  set subaccount(String subaccount) {
    _subaccount = subaccount;
    notifyListeners();
  }

  String get subaccount => _subaccount;
}
