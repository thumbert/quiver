library models.experimental.select_variable_model;

import 'package:flutter/material.dart';

/// Something to use when you want to plot different variables on the screen.
/// The user can choose between different categories of variable to select:
/// ['', 'Time', 'Temperature', 'Gas', 'Electricity', 'Gas Spreads', 'DA/RT'].
/// If one choice is made, several elements are now required to fill,
/// 'Temperature' requires an airport name,
/// 'Electricity' requires a region, location name, market (DA, RT), bucket,
/// 'Gas' requires a location name, product name (GD, IFerc, Phys)
/// etc.
///
/// These choices need to be supported as arrays, so several widgets can be
/// tied to them.
class SelectVariableModel extends ChangeNotifier {
  SelectVariableModel();

  late Map<String, dynamic> _valueXaxis;
  late List<Map<String, dynamic>> _valuesYaxis1;
  late List<Map<String, dynamic>> _valuesYaxis2;

  void init() {
    _valueXaxis = {
      'category': 'Time',
    };
    _valuesYaxis1 = [
      {
        'category': 'Power',
        'region': 'ISONE',
        'location': 'Mass Hub',
        'market': 'DA',
        'bucket': '5x16',
      },
    ];
    _valuesYaxis2 = [
      {
        'category': '',
      }
    ];
  }

  String get valueXaxis => _valueXaxis.values.toList().join(' ');
  String valueYaxis1(int index) =>
      _valuesYaxis1[index].values.toList().join(' ');

  void insert(int index, int tabValue, Map<String, dynamic> xs) {
    // _buySells.insert(index, value);
  }

  // void removeAt(int index) {
  //   _buySells.removeAt(index);
  // }

  // String operator [](int i) => _buySells[i];
  //
  // operator []=(int i, String value) {
  //   _buySells[i] = value;
  //   notifyListeners();
  // }
}
