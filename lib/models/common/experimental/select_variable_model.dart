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
  SelectVariableModel() {
    init();
  }

  late Map<String, dynamic> _valueXaxis;
  late List<Map<String, dynamic>> _valuesYaxis;
  late List<bool> yVariablesHighlightStatus;

  /// Which variable is currently being edited,
  /// 0 is for the xAxis, 1, 2, ... for the yAxis
  int? editedIndex;

  List<Map<String, dynamic>> yAxisVariables() => _valuesYaxis;

  Map<String, dynamic> getEditedVariable() {
    if (editedIndex == 0) {
      return _valueXaxis;
    } else {
      return _valuesYaxis[editedIndex! - 1];
    }
  }

  /// Update the variable
  void update(Map<String, dynamic> xs) {
    if (editedIndex == 0) {
      _valueXaxis = Map.from(xs);
    } else {
      _valuesYaxis[editedIndex! - 1] = Map.from(xs);
    }
  }

  /// Copy the Y value from index to one index below.
  void copy(int index) {
    _valuesYaxis.insert(index, _valuesYaxis[index]);
    yVariablesHighlightStatus.insert(index, false);
    notifyListeners();
  }

  /// Remove the Y variable at position [index]
  void removeVariableAt(int index) {
    if (yVariablesHighlightStatus.length > 1) {
      _valuesYaxis.removeAt(index);
      yVariablesHighlightStatus.removeAt(index);
    }
    notifyListeners();
  }

  static final allowedCategories = {
    'Time',
    'Power',
  };

  void init() {
    _valueXaxis = {
      'category': 'Time',
      'config': {
        'skipWeekends': false,
      }
    };
    _valuesYaxis = [
      {
        'category': 'Power',
        'region': 'ISONE',
        'deliveryPoint': '.H.INTERNAL_HUB, ptid: 4000',
        'market': 'DA',
        'component': 'LMP',
        'view': {
          'name': 'Realized',
          'historicalTerm': '',
          'filter': {
            'time': {
              'bucket': '5x16',
            },
          },
          'aggregate': {
            'time': {
              'frequency': {
                'day',
              }
            },
            'function': 'mean',
          }
        },
        'label': 'MassHub DA LMP, 5x16',
      },
      {
        'category': 'Power',
        'region': 'NYISO',
        'deliveryPoint': 'Zone G',
        'market': 'DA',
        'component': 'LMP',
        'view': {
          'name': 'Forward, as of',
          'asOfDate': '2022-05-13',
          'bucket': '5x16',
          'forwardTerm': '',
        },
        'label': 'Zone G DA LMP, 5x16',
      },
      {
        'category': 'Power',
        'region': 'NYISO',
        'deliveryPoint': 'Zone G',
        'market': 'DA',
        'component': 'LMP',
        'view': {
          'name': 'Forward strip',
          'strip': 'Jan23-Feb23',
          'startDate': '2022-01-01',
          'endDate': '2022-05-31',
          'bucket': '5x16',
        },
        'label': 'Zone G DA LMP, 5x16',
      },
    ];
    yVariablesHighlightStatus =
        List.filled(_valuesYaxis.length, false, growable: true);
  }

  /// What is printed on the screen in the text button for the X axis
  String xAxisLabel() {
    if (_valueXaxis['category'] == 'Time') {
      return 'Time';
    }
    return _valueXaxis.keys
        .where((e) => e != 'category' && e != 'config')
        .map((e) => _valueXaxis[e])
        .toList()
        .join(' ');
  }

  /// What is printed on the screen in the text button for the Y axis.
  ///
  String yAxisLabel(int index) {
    if (_valuesYaxis[index].containsKey('label')) {
      return _valuesYaxis[index]['label'];
    }
    return _valuesYaxis[index]
        .keys
        .where((e) => e != 'category' && e != 'config')
        .map((e) => _valuesYaxis[index][e])
        .toList()
        .join(' ');
  }
}
