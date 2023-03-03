library models.polygraph.transforms.time_aggregation;

import 'package:flutter_quiver/models/polygraph/transforms/transform.dart';
import 'package:timeseries/timeseries.dart';

class TimeAggregation extends Object with Transform {
  TimeAggregation({
    required this.timeFrequency,
    this.function = 'mean',
  });

  String timeFrequency;
  String function;

  @override
  Map<String,dynamic> toJson() {
    return {
      'aggregate': {
        'time': {
          'frequency': timeFrequency,
          'function': function,
          // if (bucket != null) 'bucket': bucket.toString(),
        },
      }
    };
  }

  @override
  Iterable<IntervalTuple<num>> apply(Iterable<IntervalTuple<num>> ts) {
    if (timeFrequency == 'daily') {
      return toDaily(ts, Transform.aggregations[function]!);
    } else if (timeFrequency == 'monthly') {
      return toMonthly(ts, Transform.aggregations[function]!);
    } else if (timeFrequency == 'hourly') {
      return toHourly(ts, Transform.aggregations[function]!);
    } else {
      throw StateError('Unsupported timeFrequency $timeFrequency');
    }
  }

}