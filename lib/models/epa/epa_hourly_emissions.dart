import 'package:collection/collection.dart';
import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';
import 'package:elec_server/client/epa/hourly_emissions.dart' as he;

final term = signal(getDefaultTerm());
final rows = ListSignal<FacilityRow>([
  FacilityRow(
    state: 'MA',
    facilityName: 'Fore River Energy Center',
    variableName: 'Gross Load (MW)',
    aggregateUnits: false,
  )
]);

/// Derived signal that only changes when the set of states changes,
/// not when facilityName/variableName/etc. change.
final _rowStates = computed(() => rows.value.map((e) => e.state).toSet());

final traces = FutureSignal<List<Map<String, dynamic>>>(makeTraces,
    dependencies: [rows, term]);

Future<List<Map<String, dynamic>>> makeTraces() async {
  var out = <Map<String, dynamic>>[];
  for (var row in rows.value) {
    var nulls = term.value
        .withTimeZone(allStatesTz[row.state]!)
        .hours()
        .map((e) => IntervalTuple(e, null))
        .toTimeSeries();
    var data = await row.getData(term.value);
    if (row.aggregateUnits) {
      if (data.isEmpty) {
        continue;
      }
      data = {
        'agg': data.values.reduce((a, b) {
          return a.merge(b,
              joinType: JoinType.Outer, f: (x, y) => (x ?? 0.0) + (y ?? 0.0));
        })
      };
    }

    for (var unitId in data.keys) {
      final ts = data[unitId]!;
      final tsWithNulls = nulls.merge(ts,
          joinType: JoinType.Left, f: (x, y) => y ?? x); // fill in the nulls
      out.add({
        'x': tsWithNulls.map((e) => e.interval.start.toString()).toList(),
        'y': tsWithNulls.map((e) => e.value).toList(),
        'name': '${row.facilityName}_${row.variableName}_$unitId',
        'type': tsWithNulls.length > 50 ? 'lines' : 'lines+markers',
      });
    }
  }
  return out;
}

final class FacilityRow {
  FacilityRow({
    required this.state,
    required this.facilityName,
    required this.variableName,
    required this.aggregateUnits,
  });

  final String state;
  final String facilityName;
  final String variableName;
  final bool aggregateUnits;

  static final FutureSignal<int> allFacilities = FutureSignal(() async {
    final states = _rowStates.value;
    await Future.wait(states.map((state) => getFacilities(state)));
    return 0;
  }, dependencies: [_rowStates]);

  static Future<Set<String>> getFacilities(String state) async {
    if (!cacheFacilities.containsKey(state)) {
      final data = await he.allFacilities(
        state: state,
        rootUrl: dotenv.env['RUST_SERVER']!,
      );
      cacheFacilities[state] = data.toSet();
    }
    return cacheFacilities[state]!;
  }

  FacilityRow copyWith({
    String? state,
    String? facilityName,
    String? variableName,
    bool? aggregateUnits,
  }) {
    return FacilityRow(
      state: state ?? this.state,
      facilityName: facilityName ?? this.facilityName,
      variableName: variableName ?? this.variableName,
      aggregateUnits: aggregateUnits ?? this.aggregateUnits,
    );
  }

  /// Get the timeseries for this facility and variable.  There is one series
  /// for each unit_id.
  ///
  Future<Map<String, TimeSeries<num>>> getData(Term term) async {
    final key =
        (state: state, facilityName: facilityName, variableName: variableName);
    if (cacheTs.containsKey(key)) {
      return cacheTs[key]!;
    }
    if (facilityName.isEmpty) {
      return {};
    }
    final column = allVariables[variableName]!;
    final data = await he.getData(
      state: state,
      term: term,
      facilityNames: [facilityName],
      columns: ['date', 'hour', 'unit_id', column],
      nonNullGenerationOnly: true,
      rootUrl: dotenv.env['RUST_SERVER']!,
    );
    final tz = allStatesTz[state]!;
    var grp = groupBy(data, (e) => e['unit_id'] as String);
    var out = <String, TimeSeries<num>>{};
    for (var unitId in grp.keys) {
      var aux = grp[unitId]!.map((e) {
        var date = Date.fromIsoString(e['date']);
        var t0 = TZDateTime(UTC, date.year, date.month, date.day);
        var dtz = t0.add(Duration(hours: e['hour'] as int));
        var dt = TZDateTime.fromMillisecondsSinceEpoch(
            tz, dtz.millisecondsSinceEpoch);
        var value = e[column] as num;
        return IntervalTuple(Hour.beginning(dt), value);
      }).toList();
      aux.sort((a, b) => a.interval.start.compareTo(b.interval.start));
      var ts = aux.toTimeSeries();
      out[unitId] = ts;
    }

    cacheTs[key] = out;
    return out;
  }
}

/// Get all the trace data and convert it to CSV format.
/// This is used for the "Copy" button in the UI.
String toCsv() {
  var csv = StringBuffer()..writeln('name,datetime,value');
  for (var trace in traces.requireValue) {
    var x = trace['x'] as List;
    var y = trace['y'] as List;
    var name = trace['name'] as String;
    for (var i = 0; i < x.length; i++) {
      csv.writeln('$name,${x[i]},${y[i]}');
    }
  }
  return csv.toString();
}

/// key is (state, facilityName, variableName) -> (unit_id -> timeseries)
final cacheTs = <({
  String state,
  String facilityName,
  String variableName,
}),
    Map<String, TimeSeries<num>>>{};

/// key is state -> set of facility names
final cacheFacilities = <String, Set<String>>{};

final allVariables = {
  'Gross Load (MW)': 'gross_load',
  'Heat Input (mmBtu)': 'heat_input',
  'Steam Load (1000 lb/hr)': 'steam_load',
  'SO2 Mass (lbs)': 'so2_mass',
  'SO2 Rate (lbs/mmBtu)': 'so2_rate',
  'NOx Mass (lbs)': 'nox_mass',
  'NOx Rate (lbs/mmBtu)': 'nox_rate',
  'CO2 Mass (short tons)': 'co2_mass',
  'CO2 Rate (short tons/mmBtu)': 'co2_rate',
};

/// List of all available states with their timezones.
/// This is used to populate the dropdown and also to set the timezone
/// for the x-axis.
final allStatesTz = {
  'CT': IsoNewEngland.location,
  'MA': IsoNewEngland.location,
  'ME': IsoNewEngland.location,
  'NH': IsoNewEngland.location,
  'NY': IsoNewEngland.location,
  'RI': IsoNewEngland.location,
  'VA': IsoNewEngland.location,
  'VT': IsoNewEngland.location,
};

/// in UTC
Term getDefaultTerm() {
  final today = Date.today(location: UTC);
  final start = Date.utc(today.year - 1, 1, 1);
  final end = Date.utc(today.year, today.month, 1).previous;
  // final start = Date.utc(2025, 3, 9);
  // final end = Date.utc(2025, 4, 30);
  return Term(start, end);
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
    // 'title': 'Price, \$/MMBtu',
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
