library models.historical_gas_model;

import 'dart:math';

import 'package:dama/dama.dart';
import 'package:date/date.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';

class HistoricalGasModel {
  HistoricalGasModel({required this.locations, required this.indices});

  final List<String> locations;
  final List<String> indices;

  static List<String> regions() => mappedLocations.keys.toList();
  static final mappedLocations = <String, List<String>>{
    'NorthEast': [
      'Algonquin, CG',
      'Iroquois, Zn2',
      'Chicago, CG',
      'Tetco, M3',
      'Tennessee, Zn6 South',
      'Tennesee, Zn6 North',
      'Henry Hub',
      'PG&E, CG'
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
  static final allGasIndices = <String>['Gas Daily', 'IFerc'];

  static final cache = <(String, String), TimeSeries<num>>{};

  static Term cacheTerm = getDefaultTerm();

  static List<String> allLocations() =>
      mappedLocations.values.expand((e) => e).toList();

  /// Insert a new row at position [index] + 1
  HistoricalGasModel addRowAt(int index) {
    late List<String> newLocations;
    late List<String> newIndices;
    // var ind = allLocations.indexWhere((e) => e == allLocations[index]);
    late String nextLocation;
    // if (ind == allLocations.length - 1 || ind < 0) {
    //   nextLocation = allLocations.first;
    // } else {
    //   nextLocation = allLocations[ind + 1];
    // }
    nextLocation = mappedLocations['NorthEast']!.first;
    newLocations = locations..insert(index + 1, nextLocation);
    newIndices = indices
      ..insert(index + 1, HistoricalGasModel.allGasIndices.first);
    return HistoricalGasModel(locations: newLocations, indices: newIndices);
  }

  /// remove row at position [index]
  HistoricalGasModel removeRowAt(int index) {
    if (locations.length > 1) {
      var newLocations = locations..removeAt(index);
      var newIndices = indices..removeAt(index);
      return HistoricalGasModel(locations: newLocations, indices: newIndices);
    } else {
      return this;
    }
  }

  static Future<Map<(String, String), TimeSeries<num>>> getData(
      Term term, List<String> locations, List<String> gasIndices) async {
    var out = <(String, String), TimeSeries<num>>{};
    var days = term.days();
    var rand = Random();
    for (var i = 0; i < locations.length; i++) {
      var t2 = (locations[i], gasIndices[i]);
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

  List<Map<String, dynamic>> makeTraces(Term term) {
    var out = <Map<String, dynamic>>[];
    for (var i = 0; i < locations.length; i++) {
      var ts = cache[(locations[i], indices[i])]!.window(term.interval);
      out.add({
        'x': ts
            .map((e) => e.interval.start.toString().substring(0, 10))
            .toList(),
        'y': ts.map((e) => e.value),
        'name': '${locations[i]}_${indices[i]}',
        'type': 'lines',
      });
    }
    return out;
  }

  /// in UTC
  static Term getDefaultTerm() {
    final year = Date.today(location: UTC).year;
    final start = Date.utc(year - 4, 1, 1);
    final end = Date.today(location: UTC);
    return Term(start, end);
  }

  static HistoricalGasModel getDefault() {
    return HistoricalGasModel(
        locations: ['Algonquin, CG', 'Algonquin, CG'],
        indices: ['Gas Daily', 'IFerc']);
  }

  HistoricalGasModel copyWith(
      {List<String>? locations, List<String>? indices}) {
    return HistoricalGasModel(
        locations: locations ?? this.locations,
        indices: indices ?? this.indices);
  }

  static Map<String, dynamic> layout = {
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
}
