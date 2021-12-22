library models.mcc_surfer.constraint_table_model;

import 'package:collection/collection.dart';
import 'package:date/date.dart' as date;
import 'package:elec_server/client/isoexpress/binding_constraints.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart';
import 'package:tuple/tuple.dart';

class ConstraintTableModel extends ChangeNotifier {
  ConstraintTableModel({this.rootUrl = 'http://127.0.0.1:8080'}) {
    client = BindingConstraintsApi(http.Client(), rootUrl: rootUrl);
  }

  final String rootUrl;
  late final BindingConstraintsApi client;
  final location = getLocation('America/New_York');
  var h1 = const Duration(hours: 1);

  static var maxConstraints = 40;

  /// show only 20 top constraints for the selected term
  List<bool> selected = <bool>[];

  /// reuse the table
  late List<Map<String, dynamic>> table;

  /// current term
  late date.Term currentTerm;

  /// cache the hourly constraints for a given term
  var cache = <date.Interval, List<Map<String, dynamic>>>{};

  void clickConstraint(int i) {
    selected[i] = !selected[i];
    notifyListeners();
  }

  /// Return a list of this form
  /// ```
  ///  {
  ///    'Constraint Name': 'WALNGF',
  ///    'start': TZDateTime(2021, 7, 8, 10),
  ///    'end': TZDateTime(2021, 7, 9, 4),
  ///  },
  /// ```
  List<Map<String, dynamic>> getHighlightedBlocks() {
    var ind = <int>[];
    for (var i = 0; i < selected.length; ++i) {
      if (selected[i]) ind.add(i);
    }

    var out = <Map<String, dynamic>>[];

    for (var i in ind) {
      var constraintName = table[i]['Constraint Name'];
      var obs = cache[currentTerm.interval]!
          .where((e) => e['Constraint Name'] == constraintName);
      // obs.map((e) => e['hourBeginning']).forEach(print);
      var one = <String, dynamic>{};
      for (var x in obs) {
        var start = TZDateTime.parse(location, x['hourBeginning']);
        if (one.isEmpty) {
          one = {
            'Constraint Name': constraintName,
            'start': start,
            'end': start.add(h1),
          };
        } else {
          if (one['end'] == start) {
            /// contiguous hours, modify the end
            one['end'] = start.add(h1);
          } else {
            /// it's a new interval, need to restart the process
            out.add(one);
            one = {
              'Constraint Name': constraintName,
              'start': start,
              'end': start.add(h1),
            };
          }
        }
      }

      /// need to add the last interval
      out.add(one);
    }

    return out;
  }

  /// Show the top constraints in the focusTerm.  The [focusTerm] can be a sub
  /// interval of the [term] that you get from zooming into the plot.
  Future<List<Map<String, dynamic>>> topConstraints(date.Term term,
      {date.Term? focusTerm}) async {
    var xs = await getData(term.interval);
    currentTerm = term;

    var groups = groupBy(
        xs,
        (Map e) => Tuple2(
            e['Constraint Name'].toString(), e['Contingency Name'].toString()));
    var table = [
      for (var group in groups.entries)
        {
          'Constraint Name': group.key.item1,
          'Contingency Name': group.key.item2,
          'Marginal Value':
              group.value.map((Map e) => e['Marginal Value'] as num).sum,
          'Hours Count': group.value.length,
        }
    ];

    /// sort descending by absolute Marginal Value
    table.sort((a, b) =>
        (a['Marginal Value'] as num).compareTo(b['Marginal Value'] as num));

    if (selected.isEmpty) {
      selected = List.filled(table.length, false);
    }
    this.table = table;

    return table;
  }

  /// Get the data from the cache or from Db
  Future<List<Map<String, dynamic>>> getData(date.Interval interval) async {
    if (!cache.containsKey(interval)) {
      selected = <bool>[];
      cache[interval] = await client.getDaBindingConstraints(interval);
    }
    return cache[interval]!;
  }
}
