library models.historical_gas_model;

import 'dart:math';

import 'package:dama/dama.dart';
import 'package:date/date.dart';
import 'package:flutter_quiver/screens/common/signal/multiselect.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';

typedef RowId = ({Signal<String> location, Signal<String> index});

final SelectionModel region = SelectionModel(
    initialSelection: setSignal(<String>{}), choices: allRegions().toSet());

// /// Which regions are selected
final regions = region.currentSelection;
// /// Which rows to show
final rows = getDefaultRows().toSignal();

// final insertRowAtIndex = signal(-1);
// final removeRowAtIndex = signal(-1);
// final modifyLocationAtIndex = signal<(int, String)?>(null);
// final modifyGasIndexAtIndex = signal<(int, String)?>(null);

// final location = signal('Algonquin, CG');
// final index = signal('Gas Daily');
// final row = computed(() => (location: location.value, index: index.value));
// final rows = [row].toSignal();
/// Do I need to dispose of these effects?  // 2/18/2024
// registerEffects() {
//   effect(() {
//     if (insertRowAtIndex.value >= 0) {
//       var row = rows.value[insertRowAtIndex.value];
//       rows.value.insert(insertRowAtIndex.value + 1, row);
//       insertRowAtIndex.value = -1; // reset it
//     }
//   });
//   effect(() {
//     if (removeRowAtIndex.value > 0 &&
//         removeRowAtIndex.value < rows.value.length) {
//       rows.value.removeAt(removeRowAtIndex.value);
//       removeRowAtIndex.value = -1; // reset it
//     }
//   });

//   effect(() {
//     if (modifyLocationAtIndex.value != null) {
//       final i = modifyLocationAtIndex.value!.$1;
//       rows.value[i] = (
//         location: modifyLocationAtIndex.value!.$2,
//         index: rows.value[i].index
//       );
//     }
//   });
//   effect(() {
//     if (modifyGasIndexAtIndex.value != null) {
//       final i = modifyGasIndexAtIndex.value!.$1;
//       rows.value[i] = (
//         location: rows.value[i].location,
//         index: modifyGasIndexAtIndex.value!.$2
//       );
//     }
//   });
//   effect(() {
//     if (regions.value != regions.previousValue) {
//       // note: you need to use untracked to break the dependency cycle
//       // var existingLocations = untracked(() => getLocations());
//       var newLocations = {
//         ...regions.expand((region) => mappedLocations[region]!)
//       };
//       if (newLocations.isEmpty) {
//         newLocations = getDefaultRows().map((e) => e.location).toSet();
//       }
//       var newRows = <RowId>[];
//       for (var location in newLocations) {
//         newRows.add((location: location, index: 'Gas Daily'));
//       }
//       rows.value = [...newRows];
//     }
//   });
// }

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
List<String> bllLocations = [
  'Algonquin, CG',
  'Tetco, M3',
];

// List<String> getLocations() => rows.value.map((e) => e.location).toList();
// List<RowId> getRows() => rows.value;

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









/// Reset the UI
// static void reset() {
//   HistoricalGasModel.baseRows.value = HistoricalGasModel.getDefaultRows();
//   HistoricalGasModel.regions.value = <String>{};
// }

// static HistoricalGasModel getDefault() {
//   return HistoricalGasModel(getDefaultRows(), regions: <String>{});
// }

// HistoricalGasModel copyWith(
//     {List<String>? locations, List<String>? indices}) {
//   return HistoricalGasModel(
//       locations: locations ?? this.locations,
//       indices: indices ?? this.indices);
// }



//}

// HistoricalGasModel(this.rows, {required this.regions}) {

// }

// static final regions = setSignal(<String>{});
// static final baseRows = listSignal(getDefaultRows());
// static final newRows = computed(() {
//   if (regions.isEmpty) {
//     return <RowId>[];
//   } else {
//     var newLocations = {
//       ...regions.expand((region) => mappedLocations[region]!)
//     }.difference(baseRows.map((e) => e.location).toSet());
//     var newRows = <RowId>[];
//     for (var newLocation in newLocations) {
//       newRows.add((location: newLocation, index: 'Gas Daily'));
//     }
//     return newRows;
//   }
// });

// static final allRows = computed(() {
//   var rows = [
//     ...baseRows.value,
//     ...newRows.value,
//   ];
//   if (modifyLocationAtIndex.value != null) {
//     final i = modifyLocationAtIndex.value!.$1;
//     rows[i] =
//         (location: modifyLocationAtIndex.value!.$2, index: rows[i].index);
//   }
//   if (modifyGasIndexAtIndex.value != null) {
//     final i = modifyGasIndexAtIndex.value!.$1;
//     rows[i] =
//         (location: rows[i].location, index: modifyGasIndexAtIndex.value!.$2);
//   }
//   return rows;
// });

// /// Add the locations from the input [regions] to the existing [rows].
// HistoricalGasModel withRegions(Set<String> regions) {
//   var newLocations = {...regions.expand((region) => mappedLocations[region]!)}
//       .difference(rows.map((e) => e.location).toSet());
//   var newRows = [...rows];
//   for (var newLocation in newLocations) {
//     newRows.add((location: newLocation, index: 'Gas Daily'));
//   }
//   return HistoricalGasModel(newRows);
// }

/// Insert a new row at position [index] + 1
// HistoricalGasModel addRowAt(int index) {
//   late String nextLocation;
//   nextLocation = mappedLocations['NorthEast']!.first;
//   var newRows = [...rows];
//   newRows.insert(index + 1, (location: nextLocation, index: 'Gas Daily'));
//   return HistoricalGasModel(newRows, regions: <String>{});
// }

/// remove row at position [index]
// HistoricalGasModel removeRowAt(int index) {
//   if (rows.length > 1) {
//     var newRows = rows..removeAt(index);
//     return HistoricalGasModel(newRows, regions: <String>{});
//   } else {
//     return this;
//   }
// }
