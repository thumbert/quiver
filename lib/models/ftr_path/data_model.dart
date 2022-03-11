library models.ftr_path.data_model;

import 'package:date/date.dart';
import 'package:elec/ftr.dart';
import 'package:elec_server/client/binding_constraints.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class DataModel extends ChangeNotifier {
  DataModel() {
    _focusTerm = defaultTerm();
  }

  // late Term _term;

  /// what you get from the plotly relayout
  Term? _focusTerm;

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

  FtrPath? _currentFtrPath;

  /// A cache with historical binding constraints for the current path
  var _cacheBindingConstraints = <String, TimeSeries<num>>{};

  /// What gets displayed on the screen after the filtering
  var _tableCpSp = <Map<String, dynamic>>[];
  // bool sortAscendingCpSp = false;

  /// What gets displayed on the screen for binding constraint cost
  var _tableConstraintCost = <Map<String, dynamic>>[];
  bool sortAscendingBc = false;
  String sortColumnBc = 'Cumulative Spread';

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
    'displaylogo': false,
  };

  /// Get the data and make the Plotly hourly traces.
  ///
  Future<List<Map<String, dynamic>>> makeHourlyTrace(FtrPath ftrPath) async {
    var sp = await ftrPath.getDailySettlePrices(term: focusTerm);
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
    /// Get the data with Clearing prices and Settled prices.
    /// TODO: should this be cached?
    var _cacheCpSp =
        await ftrPath.makeTableCpSp(fromDate: defaultTerm().startDate);
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
      cpsp = cpsp
          .where((e) => (e['auction'] as FtrAuction) is! SixMonthFtrAuction);
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

  /// Input [term] can be used to control the constraints table based on the
  /// chart selection.
  Future<List<Map<String, dynamic>>> getRelevantBindingConstraints(
      {required FtrPath ftrPath}) async {
    if (_currentFtrPath == null || _currentFtrPath != ftrPath) {
      /// get the binding constraints for the default term
      var client = BindingConstraints(http.Client(),
          iso: ftrPath.iso, rootUrl: dotenv.env['ROOT_URL']!);
      _cacheBindingConstraints =
          await client.getDaBindingConstraints(defaultTerm().interval);
      _currentFtrPath = ftrPath;
    }

    _focusTerm ??= defaultTerm();

    /// get the relevant constraints
    var aux = await ftrPath.bindingConstraintEffect(focusTerm!,
        bindingConstraints: _cacheBindingConstraints);

    /// sort the table
    var sign = sortAscendingBc ? 1 : -1;
    aux.sort((a, b) =>
        (a[sortColumnBc].abs()).compareTo(b[sortColumnBc].abs()) * sign);
    _tableConstraintCost = aux;
    return _tableConstraintCost;
  }

  List<Map<String, dynamic>> get tableCpSp => _tableCpSp;

  List<Map<String, dynamic>> get tableConstraintCost => _tableConstraintCost;

  set focusTerm(Term? value) {
    _focusTerm = value;
    notifyListeners();
  }

  Term? get focusTerm => _focusTerm;

  void checkboxModified() {
    notifyListeners();
  }

  /// the default historical term to plot
  Term defaultTerm() {
    var now = TZDateTime.now(location);
    var today = TZDateTime(location, now.year, now.month, now.day)
        .add(const Duration(days: 1));
    var start = today.subtract(const Duration(days: 480));
    var interval =
        Interval(TZDateTime(location, start.year, start.month), today);
    return Term.fromInterval(interval);
  }
}
