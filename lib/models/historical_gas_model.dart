library models.historical_gas_model;

import 'dart:math';

import 'package:dama/dama.dart';
import 'package:date/date.dart';
import 'package:flutter_quiver/screens/common/signal/dropdown.dart';
import 'package:flutter_quiver/screens/common/signal/multiselect.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';

typedef RowId = ({Signal<String> location, Signal<String> index});

final termSignal = getDefaultTerm().toSignal();
final termErrorSignal = signal<String?>(null);

final SelectionModel region = SelectionModel(
    initialSelection: setSignal(<String>{}), choices: allRegions().toSet());

final DropdownModel timeAggregationModel =
    DropdownModel(selection: signal('Daily'), choices: {'Daily', 'Monthly'});

/// Which regions are selected
final regions = region.selection;

/// Which rows to show
final rows = getDefaultRows().toSignal();

final updateRows = effect(() {
      if (regions.value != regions.previousValue) {
        var newLocations = {
          ...regions.value
              .expand((region) => mappedLocations[region]!)
        };
        if (newLocations.isEmpty) {
          newLocations =
              getDefaultRows().map((e) => e.location.value).toSet();
        }
        var newRows = <RowId>[];
        for (var location in newLocations) {
          newRows.add((location: signal(location), index: signal('Gas Daily')));
        }
        rows.value = [...newRows];
      }
    });

/// What to plot
final traces = futureSignal(() async {
  if (!cacheTerm.interval.containsInterval(termSignal.value.interval)) {
    cache.clear();
    cacheTerm = termSignal.value;
  }
  try {
    await getData(termSignal.value, rows.value);
  } catch (e) {
    rethrow;
  }
  return makeTraces(rows.value, termSignal.value);
}, dependencies: [
  termSignal,
  rows,
]);

const mappedLocations = <String, List<String>>{
  'NorthEast': [
    'Algonquin, CG',
    'Iroquois, Zn2',
    'Tetco, M3',
    'Tennessee, Zn6 South',
    'Tennesee, Zn6 North',
  ],
  'Appalachia': [
    'Columbia Gas, App',
    'Lebanon Hub',
    'Texas Eastern, M2',
  ],
  'MidCon': [
    'NGPL',
    'Panhandle, Tx-Okla',
  ],
  'Upper Midwest': [
    'Chicago, CG',
    'Dawn, Ontario',
    'Mich Con, CG',
  ],
  'East Texas': [
    'Katy',
    'Tennessee, Zn0',
    'Transco, Zn2',
  ],
  'Louisiana/Southeast': [
    'Columbia Gulf, mainline',
    'Henry Hub',
    'Transco, Zn3',
  ],
  'Rockies/Northwest': [
    'Cheyenne Hub',
  ],
  'Southwest': [
    'SoCal Gas, CG',
    'Waha',
  ],
};
List<String> allRegions() => mappedLocations.keys.toList();
List<String> allLocations() => mappedLocations.values.expand((e) => e).toList();
final allGasIndices = <String>['Gas Daily', 'IFerc'];

/// Keep all the historical data
final cache = <({String location, String index}), TimeSeries<num>>{};

///
Term cacheTerm = getDefaultTerm();

Future<Map<({String location, String index}), TimeSeries<num>>> getData(
    Term term, List<RowId> rows) async {
  var out = <({String location, String index}), TimeSeries<num>>{};
  var days = term.days();
  var rand = Random();
  for (var i = 0; i < rows.length; i++) {
    var t2 = (location: rows[i].location.value, index: rows[i].index.value);
    if (!cache.containsKey(t2)) {
      await Future.delayed(const Duration(seconds: 1));
      var aux = TimeSeries.from(
          days,
          List.generate(days.length, (index) => rand.nextDouble() - 0.5)
              .cumSum());
      cache[t2] = aux;
    }
    out[t2] = cache[t2]!;
  }
  return out;
}

List<Map<String, dynamic>> makeTraces(List<RowId> rows, Term term) {
  var out = <Map<String, dynamic>>[];
  for (var i = 0; i < rows.length; i++) {
    var t2 = (location: rows[i].location.value, index: rows[i].index.value);
    var ts = cache[t2]!.window(term.interval);
    out.add({
      'x': ts.map((e) => e.interval.start.toString().substring(0, 10)).toList(),
      'y': ts.map((e) => e.value),
      'name': '${rows[i].location}_${rows[i].index}',
      'type': 'lines',
    });
  }
  return out;
}

/// in UTC
Term getDefaultTerm() {
  final year = Date.today(location: UTC).year;
  final start = Date.utc(year - 4, 1, 1);
  final end = Date.today(location: UTC);
  return Term(start, end);
}

List<RowId> getDefaultRows() {
  return [
    (location: signal('Algonquin, CG'), index: signal('Gas Daily')),
  ];
}

final Map<String, dynamic> layout = {
  'width': 900,
  'height': 600,
  'title': '',
  'xaxis': {
    'title': '',
    'showgrid': true,
  },
  'yaxis': {
    'showgrid': true,
    'zeroline': false,
    'title': 'Price, \$/MMBtu',
  },
  'showlegend': true,
  'legend': {
    'orientation': 'h',
  },
  'hovermode': 'closest',
  'margin': {
    't': 40,
  },
};
