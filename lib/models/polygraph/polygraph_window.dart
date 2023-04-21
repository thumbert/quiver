library models.polygraph.polygraph_window;

import 'dart:math' as math;

import 'package:dama/dama.dart';
import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec/risk_system.dart';
import 'package:flutter_quiver/models/polygraph/display/variable_display_config.dart';
import 'package:flutter_quiver/models/polygraph/editors/horizontal_line.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_lmp.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';

class PolygraphWindow {
  PolygraphWindow({
    required this.term,
    required this.xVariable,
    required this.yVariables,
  }) {
    // this.term = Term.fromInterval(term.interval.withTimeZone(tzLocation));
  }

  /// Historical term in the given timezone
  late final Term term;
  // final Location tzLocation;
  final PolygraphVariable xVariable;
  final List<PolygraphVariable> yVariables;

  /// A stale cache requires a trip to the database, so it should be avoided
  /// if possible.
  /// How does the [cache] become stale?
  /// 1) At initialization
  /// 2) When a new transformed variable is added to the window
  /// 3) An existing transformed variable has its expression modified
  /// 4) When the window term is modified beyond the existing term
  // bool isCacheStale = true;  /// NOT NEEDED I THINK!

  /// Should we make a trip to the database when updating the cache?  This
  /// needs to happen when
  /// 1) We are at initialization (cache is empty)
  /// 2) The window term is modified beyond the existing term
  ///
  bool refreshDataFromDb = true;

  /// Keep the evaluated expressions (which will most likely be TimeSeries),
  /// but also other variables of different type.
  var cache = <String, dynamic>{};

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

  /// Get the data for external variables.
  /// Re-calculate the [TransformedVariable]s if needed.
  /// The cache needs to be updated for several reasons.
  Future<void> updateCache() async {
    if (!(xVariable is TimeVariable || xVariable is TransformedVariable)) {
      var ts = await xVariable.get(PolygraphState.service, term);
      cache[xVariable.id] = ts;
    }

    // get the data for all the variables that are not transformed variables
    if (refreshDataFromDb) {
      for (var variable in yVariables) {
        if (variable is! TransformedVariable) {
          var ts = await variable.get(PolygraphState.service, term);
          cache[variable.id] = ts;
        }
      }
    }

    // process all the transformed variables that need to be updated
    for (var variable in yVariables) {
      if (variable is TransformedVariable) {
        if (variable.isDirty) {
          variable.eval(cache);
          /// TODO: the lines below should not be needed.  There should be
          /// NO parsing error here.  Parsing errors need to be checked at
          /// variable creation only.
          if (variable.error != '') {
            // parsing has failed, remove the variable from the cache
            cache.remove(variable.id);
          }
        }
      } else if (variable is HorizontalLine) {
        /// TODO:  I don't need to recalculate these every time!
        var ts = variable.timeSeries(term);
        cache[variable.id] = ts;
      }
    }
    refreshDataFromDb = false;
  }


  /// Construct the Plotly traces.
  /// Note that the cache may contain more history than needed for the plot.
  List<Map<String, dynamic>> makeTraces() {
    var traces = <Map<String, dynamic>>[];
    if (xVariable is TimeVariable) {
      for (var i = 0; i < yVariables.length; i++) {
        // print(i);
        if (yVariables[i].isHidden) continue;
        var ts = cache[yVariables[i].id] ?? TimeSeries<num>();
        if (ts is TimeSeries<num>) {
          ts = TimeSeries.fromIterable(ts.window(term.interval));
        }

        var color = (yVariables[i].color ?? VariableDisplayConfig.defaultColors[i]);

        /// show a stepwise function (default)
        var one = {
          'x': ts.intervals
              .expand((e) => [e.start, e.end])
              .toList(),
          'y': ts.values.expand((e) => [e, e]).toList(),
          'name': yVariables[i].id,
          'mode': 'lines',
          'line': {
            'color': VariableDisplayConfig.colorToHex(color),
          },
          // 'line': {'shape': 'hv'},

          // 'yaxis': 'y2',  // if you want it on the right side
        };
        // print(one['line']);
        // yVariables[i].config
        traces.add(one);
      }
    } else {
      /// When you have a scatter plot
      throw StateError('Need more work to support this!');
    }
    return traces;
  }

  /// Make the summary for variable [i].
  /// If cache is empty return an empty list.
  List<String> makeSummary(int i) {
    if (!cache.containsKey(yVariables[i].label)) {
      return <String>[];
    }
    var ys = cache[yVariables[i].label] as TimeSeries<num>;
    if (ys.isEmpty) {
      return <String>[];
    }
    var aux = summary(ys.values);
    var precision = math
        .max(5 - math.min(4, math.log(aux['Max.']!.abs().round())), 1)
        .ceil();
    return [
      'Start: ${ys.first.interval.start},    End: ${ys.last.interval.end}',
      'Observations:  ${ys.length}',
      'First:  ${ys.first.value.toStringAsFixed(precision)}',
      'Min.:  ${aux['Min.']!.toStringAsFixed(precision)}',
      '1st Qu.:  ${aux['1st Qu.']!.toStringAsFixed(precision)}',
      'Median:  ${aux['Median']!.toStringAsFixed(precision)}',
      'Mean:  ${aux['Mean']!.toStringAsFixed(precision)}',
      '3rd Qu.:  ${aux['3rd Qu.']!.toStringAsFixed(precision)}',
      'Max.:  ${aux['Max.']!.toStringAsFixed(precision)}',
      'Last: ${ys.last.value.toStringAsFixed(precision)}',
    ];
  }

  /// What gets serialized to Mongo
  Map<String, dynamic> toMap() {
    return {
      'term': term.toString(),
      'tzLocation': term.location.name,
      // 'xVariable': xVariable.toMap(),
      // 'yVariables': [
      //   for (var variable in yVariables) variable.toMap()
      // ]
    };
  }

  static PolygraphWindow empty() {
    var today = Date.today(location: UTC);
    var term =
        Term(Month.fromTZDateTime(today.start).subtract(14).startDate, today);
    var xVariable = TimeVariable();
    return PolygraphWindow(
        term: term, xVariable: xVariable, yVariables: <PolygraphVariable>[]);
  }

  static PolygraphWindow getDefault() {
    var window = PolygraphWindow(
      term: Term.parse('Jan20-Dec21', UTC),
      xVariable: TimeVariable(),
      yVariables: [
        TemperatureVariable(
          airportCode: 'BOS',
          variable: 'mean',
          frequency: 'daily',
          isForecast: false,
          dataSource: 'NOAA',
          id: 'bos_daily_temp',
        ),
        TransformedVariable(
            expression: 'toMonthly(bos_daily_temp, min)',
            id: 'bos_monthly_min'),
        TransformedVariable(
            expression: 'toMonthly(bos_daily_temp, max)',
            id: 'bos_monthly_max'),
      ],
    );
    return window;
  }

  static PolygraphWindow getLmpWindow() {
    var window = PolygraphWindow(
        term:
            Term.parse('Jan21-Dec21', Iso.newEngland.preferredTimeZoneLocation),
        xVariable: TimeVariable(),
        yVariables: [
          VariableLmp(
              iso: Iso.newEngland,
              market: Market.da,
              ptid: 4000,
              lmpComponent: LmpComponent.lmp)
            ..id = 'hub_da_lmp'
            ..label = 'hub_da_lmp',
          TransformedVariable(expression: 'toMonthly(hub_da_lmp, mean)',
              id: 'monthly_mean'),
        ]);
    // print(window.toMap());
    return window;
  }

  PolygraphWindow copyWith({
    Term? term,
    // Location? tzLocation,
    PolygraphVariable? xVariable,
    List<PolygraphVariable>? yVariables,
    bool? refreshDataFromDb,
  }) {
    var window = PolygraphWindow(
      term: term ?? this.term,
      // tzLocation: tzLocation ?? this.tzLocation,
      xVariable: xVariable ?? this.xVariable,
      yVariables: yVariables ?? this.yVariables,
    )..refreshDataFromDb = refreshDataFromDb ?? this.refreshDataFromDb;
    if (!window.refreshDataFromDb) {
      /// If you don't need to get the data from Db, copy the existing cache
      window.cache = Map.from(cache);
    }
    return window;
  }
}

class PolygraphWindowNotifier extends StateNotifier<PolygraphWindow> {
  PolygraphWindowNotifier(this.ref) : super(PolygraphWindow.getDefault());

  final Ref ref;

  set term(Term value) {
    state = state.copyWith(term: value);
  }

  // set tzLocation(Location value) {
  //   state = state.copyWith(tzLocation: value);
  // }

  set xVariable(PolygraphVariable value) {
    state = state.copyWith(xVariable: value);
  }

  set yVariables(List<PolygraphVariable> values) {
    state = state.copyWith(yVariables: values);
  }
}
