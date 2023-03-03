library models.polygraph.transforms.transform;

import 'package:dama/dama.dart';
import 'package:timeseries/timeseries.dart';

/// Data transformations
mixin Transform {

  Iterable<IntervalTuple<num>> apply(Iterable<IntervalTuple<num>> ts);

  static final aggregations = <String, num Function(Iterable<num>)> {
    'count': (Iterable<num> xs) => xs.length,
    'first': (Iterable<num> xs) => xs.first,
    'last': (Iterable<num> xs) => xs.last,
    'mean': (Iterable<num> xs) => mean(xs),
    'min': (Iterable<num> xs) => min(xs),
    'max': (Iterable<num> xs) => max(xs),
    'sum': (Iterable<num> xs) => sum(xs),
  };

  /// TODO: define rolling functions
  static final transforms = {
    'cumsum': (Iterable<num> xs) => cumsum(xs),
  };

  /// How it's going to be persisted to the database
  Map<String,dynamic> toJson();
}



