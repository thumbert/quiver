library models.mcc_surfer.constraint_table_model;

import 'package:collection/collection.dart';
import 'package:date/date.dart' as date;
import 'package:elec_server/client/binding_constraints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/region_load_zone_model.dart';
import 'package:http/http.dart' as http;
import 'package:timezone/timezone.dart';
import 'package:tuple/tuple.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ConstraintTableModel extends ChangeNotifier {
  ConstraintTableModel() {
    _currentRegion = 'NYISO';
  }

  final location = getLocation('America/New_York');
  var h1 = const Duration(hours: 1);

  static var maxConstraints = 40;

  /// show only 20 top constraints for the selected term
  List<bool> selected = <bool>[];

  /// reuse the table
  var table = <Map<String, dynamic>>[];

  bool hasChangedHighlight = false;

  /// current term
  date.Term? currentTerm;

  /// current region
  late String _currentRegion;

  BindingConstraints get client => BindingConstraints(http.Client(),
      iso: RegionLoadZoneModel.allowedRegions[_currentRegion]!,
      rootUrl: dotenv.env['ROOT_URL']!);

  /// cache the hourly constraints for a given term
  var cache = <date.Interval, List<Map<String, dynamic>>>{};

  void clickConstraint(int i) {
    selected[i] = !selected[i];
    hasChangedHighlight = true;
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
      var obs = cache[currentTerm!.interval]!
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

  /// Get the constraints for the [term] from the database.
  /// Show the top constraints in the focusTerm.
  /// [focusTerm] can be a sub-interval of the [term] that you get from
  /// zooming into the plot.
  ///
  Future<List<Map<String, dynamic>>> getTopConstraints(date.Term term,
      {required String region, date.Term? focusTerm}) async {
    if (region != _currentRegion) {
      table.clear();
      _currentRegion = region;
    }

    if (term != currentTerm || table.isEmpty) {
      hasChangedHighlight = false; // restart it
      cache.clear();
      var xs = await getData(term.interval);

      var groups = groupBy(
          xs,
          (Map e) => Tuple2(e['Constraint Name'].toString(),
              e['Contingency Name'].toString()));
      var _table = <Map<String, dynamic>>[
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
      _table.sort((a, b) =>
          -(a['Marginal Value'].abs()).compareTo(b['Marginal Value'].abs()));

      if (selected.isEmpty) {
        selected = List.filled(_table.length, false);
      }
      table = _table.take(maxConstraints).toList();
      currentTerm = term;
    }

    return table;
  }

  /// Get the data from the cache or from Db
  Future<List<Map<String, dynamic>>> getData(date.Interval interval) async {
    if (!cache.containsKey(interval)) {
      selected = <bool>[];
      var aux = await client.getDaBindingConstraintsDetails(interval);
      if (_currentRegion == 'NYISO') {
        /// rearrange to match the expected format
        aux = aux
            .expand((e) => [
                  for (var y in e['hours'] as List)
                    {
                      'Constraint Name': e['limitingFacility'],
                      'Contingency Name': y['contingency'],
                      'Marginal Value': y['cost'],
                      'hourBeginning': y['hourBeginning'],
                    }
                ])
            .toList();
      }
      cache[interval] = aux;
    }
    return cache[interval]!;
  }
}
