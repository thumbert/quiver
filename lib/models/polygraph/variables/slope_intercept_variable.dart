library models.polygraph.variables.slope_intercept_variable;

import 'package:date/date.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_filter.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:timeseries/timeseries.dart';


class SlopeInterceptVariable extends Object with PolygraphVariable {
  SlopeInterceptVariable({
    required this.slope,
    required this.intercept,
  }) {
    name = 'slope*time + intercept line';
    label = _makeLabel();
  }

  num slope;
  num intercept;

  /// Apply all the transforms
  @override
  TimeSeries<num> timeSeries(Term term) {
    Iterable<IntervalTuple<num>> out = [IntervalTuple(term.interval, intercept)];
    for (var tr in transforms) {
      out = tr.apply(out);
    }
    return TimeSeries.fromIterable(out);
  }

  @override
  Map<String, dynamic> toJson() {
    var out = <String,dynamic>{
      'slope': slope,
      'intercept': intercept,
    };
    return out;
  }

  String _makeLabel() {
    if (slope == 0) {
      return 'h: $intercept';
    }
    return 'slope: $slope, intercept: $intercept';
  }

  @override
  String id() => _makeLabel();
}
