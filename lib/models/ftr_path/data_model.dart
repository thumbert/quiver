library models.ftr_path.data_model;

import 'package:date/date.dart';
import 'package:elec/ftr.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:timezone/timezone.dart';

class DataModel extends ChangeNotifier {
  DataModel();

  /// Keep track fo the checkboxes on the screen
  Map<String, bool> checkboxesTerm = {
    '2 year': true,
    '1 year': true,
    '6 month': true,
    'monthly': true,
    'monthly bopp': true,
  };

  /// TODO: not implemented yet
  final Map<String, List<String>> checkboxLabels = {
    'ISONE': ['1 year', 'monthly', 'monthly bopp'],
    'NYISO': ['2 year', '1 year', '6 month', 'monthly', 'monthly bopp'],
  };

  /// A cache with CpSp prices
  var _cacheCpSp = <Map<String, dynamic>>[];

  /// What gets displayed on the screen after the filtering
  var _tableCpSp = <Map<String, dynamic>>[];

  final location = getLocation('America/New_York');
  final layout = <String, dynamic>{
    'width': 900.0,
    'height': 600.0,
    'margin': {
      't': 10,
      'l': 50,
      'r': 20,
      'b': 50,
      'pad': 4,
    },
    'yaxis': {
      'title': 'Congestion price, \$/MWh',
    },
    'showlegend': false,
    'hovermode': 'closest',
  };

  /// Get the data and make the Plotly hourly traces.
  ///
  Future<List<Map<String, dynamic>>> makeHourlyTrace(FtrPath ftrPath) async {
    var sp = await ftrPath.getDailySettlePrices(term: getTerm());
    return [
      {
        'x': sp.intervals.map((e) => e.start).toList(),
        'y': sp.values.toList(),
        'type': 'bar',
      }
    ];
  }

  /// Prepare the CpSp table for display.
  /// Only pull from the database if the path changes.
  Future<List<Map<String, dynamic>>> getCpSpTable(FtrPath ftrPath) async {
    /// Get the data with Clearing prices and Settled prices
    _cacheCpSp = await ftrPath.makeTableCpSp(fromDate: getTerm().startDate);
    Iterable<Map<String, dynamic>> cpsp = [..._cacheCpSp];

    /// Any sorting and filtering here
    if (checkboxesTerm['2 year']! == false) {
      cpsp =
          cpsp.where((e) => (e['auction'] as FtrAuction) is! TwoYearFtrAuction);
    }
    if (checkboxesTerm['1 year']! == false) {
      cpsp =
          cpsp.where((e) => (e['auction'] as FtrAuction) is! AnnualFtrAuction);
    }
    if (checkboxesTerm['6 month']! == false) {
      cpsp =
          cpsp.where((e) => (e['auction'] as FtrAuction) is! TwoYearFtrAuction);
    }
    if (checkboxesTerm['monthly']! == false) {
      cpsp =
          cpsp.where((e) => (e['auction'] as FtrAuction) is! MonthlyFtrAuction);
    }
    if (checkboxesTerm['monthly bopp']! == false) {
      cpsp = cpsp
          .where((e) => (e['auction'] as FtrAuction) is! MonthlyBoppFtrAuction);
    }

    _tableCpSp = cpsp.toList()
      ..sort((a, b) => a['auction'].compareTo(b['auction']));
    return _tableCpSp;
  }

  List<Map<String, dynamic>> get tableCpSp => _tableCpSp;

  void checkboxModified() {
    notifyListeners();
  }

  /// historical term to plot
  Term getTerm() {
    var now = TZDateTime.now(location);
    var today = TZDateTime(location, now.year, now.month, now.day)
        .add(const Duration(days: 1));
    var start = today.subtract(const Duration(days: 420));
    var interval = Interval(start, today);
    print(interval);
    return Term.fromInterval(interval);
  }
}
