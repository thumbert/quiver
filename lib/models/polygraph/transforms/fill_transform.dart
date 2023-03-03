library models.polygraph.transforms.fill_transform;

import 'package:date/date.dart';
import 'package:flutter_quiver/models/polygraph/transforms/transform.dart';
import 'package:timeseries/timeseries.dart';

class FillTransform extends Object with Transform {

  FillTransform({required this.timeFrequency});

  String timeFrequency;

  @override
  Iterable<IntervalTuple<num>> apply(Iterable<IntervalTuple<num>> ts) {
    if (timeFrequency == 'hourly') {
      return ts.expand((e) {
        var hours = e.interval.splitLeft((dt) => Hour.beginning(dt));
        return hours.map((f) => IntervalTuple(f, e.value));
      });
    } else if (timeFrequency == 'daily') {
      return ts.expand((e) {
        var days = e.interval.splitLeft((dt) => Date(dt.year, dt.month, dt.day, location: dt.location));
        return days.map((f) => IntervalTuple(f, e.value));
      });
    } else if (timeFrequency == 'monthly') {
      return ts.expand((e) {
        var months = e.interval.splitLeft((dt) => Month(dt.year, dt.month, location: dt.location));
        return months.map((f) => IntervalTuple(f, e.value));
      });
    } else {
      throw StateError('Unsupported timeFrequency $timeFrequency');
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'transform': {
        'fill': timeFrequency,
      }
    };
  }

}