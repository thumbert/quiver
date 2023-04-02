library models.polygraph.polygraph_window;


import 'package:date/date.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_variable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';


class PolygraphWindow {
  PolygraphWindow({
    required term,
    required this.tzLocation,
    required this.xVariable,
    required this.yVariables,
  }) {
    this.term = Term.fromInterval(term.interval.withTimeZone(tzLocation));
  }

  /// Historical term in the given timezone
  late final Term term;
  final Location tzLocation;
  final PolygraphVariable xVariable;
  final List<PolygraphVariable> yVariables;

  /// Keep the evaluated expressions (which will most likely be TimeSeries),
  /// but also other variables of different type.
  final cache = <String, dynamic>{};

  ///
  static PolygraphWindow fromMongo(Map<String, dynamic> x) {
    return PolygraphWindow.getDefault();
  }

  final layout = <String, dynamic>{
    'width': 900.0,
    'height': 600.0,
    'xaxis': {
      'showgrid': true,
      // 'gridcolor': '#bdbdbd',
      'gridcolor': '#f5f5f5',
    },
    'yaxis': {
      'showgrid': true,
      'gridcolor': '#f5f5f5',
      // 'zeroline': false,
    },
    // if you need a secondary axis on the right add
    // 'yaxis2': {
    //   'anchor': 'x', // 'free'
    //   'overlaying': 'y',
    //   'side': 'right',
    // },

    'showlegend': true,
    'legend': {'orientation': 'h'},
    'hovermode': 'closest',
    'displaylogo': false,
  };

  ///
  ///
  Future<void> updateCache() async {
    if (!(xVariable is TimeVariable || xVariable is TransformedVariable)) {
      var ts = await xVariable.get(PolygraphState.service, term);
      cache[xVariable.id] = ts;
    }

    /// check if a recalc on transformed variables is needed
    bool isDirty = yVariables.any((e) => e.isDirty);

    // get the data for all the variables that are not transformed variables
    for (var variable in yVariables) {
      if (variable is! TransformedVariable) {
        if (variable.isDirty) {
          var ts = await variable.get(PolygraphState.service, term);
          cache[variable.id] = ts;
        }
      }
    }

    // process all the transformed variables
    if (isDirty) {
      for (var variable in yVariables) {
        if (variable is TransformedVariable) {
          variable.eval(cache);
          if (variable.error != '') {
            // parsing has failed, remove the variable from the cache
            cache.remove(variable.id);
          }
        }
      }
    }
  }


  /// Construct the Plotly traces.
  List<Map<String, dynamic>> makeTraces() {
    var traces = <Map<String, dynamic>>[];
    if (xVariable is TimeVariable) {
      for (var i = 0; i < yVariables.length; i++) {
        var ts = cache[yVariables[i].id] ?? TimeSeries<num>();
        var one = {
          'x': ts.intervals.map((e) => e.start).toList(),
          'y': ts.values.toList(),
          'name': yVariables[i].id,
          'mode': 'lines',
          'line': {'shape': 'hv'},

          // 'yaxis': 'y2',  // if you want it on the right side
        };
        // yVariables[i].config
        traces.add(one);
      }
    } else {
      /// When you have a scatter plot
      throw StateError('Need more work to support this!');
    }
    return traces;
  }



  /// What gets serialized to Mongo
  Map<String, dynamic> toMongo() {
    return {};
  }

  static PolygraphWindow empty() {
    var today = Date.today(location: UTC);
    var term =
        Term(Month.fromTZDateTime(today.start).subtract(14).startDate, today);
    var xVariable = TimeVariable();
    return PolygraphWindow(
        term: term,
        tzLocation: UTC,
        xVariable: xVariable,
        yVariables: <PolygraphVariable>[]);
  }

  static PolygraphWindow getDefault() {
    var term = Term.parse('Jan20-Dec21', UTC);
    var xVariable = TimeVariable();
    var yVariables = [
      TemperatureVariable(
        airportCode: 'BOS',
        variable: 'mean',
        frequency: 'daily',
        isForecast: false,
        dataSource: 'NOAA',
        id: 'bos_daily_temp',
      ),
      // TransformedVariable(
      //     expression: 'toMonthly(bos_daily_temp, mean)',
      //     id: 'bos_monthly_temp'),
    ];

    var window = PolygraphWindow(
        term: term,
        tzLocation: term.location,
        xVariable: xVariable,
        yVariables: yVariables);
    return window;
  }

  PolygraphWindow copyWith({
    Term? term,
    Location? tzLocation,
    PolygraphVariable? xVariable,
    List<PolygraphVariable>? yVariables,
  }) {
    return PolygraphWindow(
      term: term ?? this.term,
      tzLocation: tzLocation ?? this.tzLocation,
      xVariable: xVariable ?? this.xVariable,
      yVariables: yVariables ?? this.yVariables,
    );
  }
}

class PolygraphWindowNotifier extends StateNotifier<PolygraphWindow> {
  PolygraphWindowNotifier(this.ref) : super(PolygraphWindow.getDefault());

  final Ref ref;

  set term(Term value) {
    state = state.copyWith(term: value);
  }

  set tzLocation(Location value) {
    state = state.copyWith(tzLocation: value);
  }

  set xVariable(PolygraphVariable value) {
    state = state.copyWith(xVariable: value);
  }

  set yVariables(List<PolygraphVariable> values) {
    state = state.copyWith(yVariables: values);
  }
}
