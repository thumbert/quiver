library models.polygraph.transforms.time_filter;

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_quiver/models/polygraph/transforms/transform.dart';
import 'package:timeseries/timeseries.dart';

abstract class TimeFilter extends Object with Transform {

  late bool Function(Interval) _f;

  @override
  Iterable<IntervalTuple<num>> apply(Iterable<IntervalTuple<num>> ts) {
    return ts.where((e) => _f(e.interval));
  }

  /// Something like:
  /// ```
  /// {
  ///   'filter': {
  ///      'time': {
  ///         'type': 'bucketFilter',
  ///         'bucket': '5x16',
  ///      },
  ///   }
  /// }
  /// ```
  /// or
  /// ```
  /// {
  ///   'filter': {
  ///      'time': {
  ///         'type': 'monthFilter',
  ///         'months': [12, 1, 2],
  ///      },
  ///   }
  /// }
  /// ```
  TimeFilter fromJson(Map<String,dynamic> x) {
    var filterType = x['filter']['time']['type'] as String?;
    if (filterType == null) {
      throw StateError('Format error for time filter, missing [filter][time][type]');
    }

    // if (!x.containsKey('filter')) {
    //   throw StateError('Format error for time filter, missing key filter');
    // }
    // if (!(x['filter'] as Map).containsKey('time')) {
    //   throw StateError('Format error for time filter, missing key time');
    // }
    // if (!(x['filter']['time'] as Map).containsKey('type')) {
    //   throw StateError('Format error for time filter, missing key type');
    // }

    if (filterType == 'bucketFilter') {
      var bucket = x['filter']['time']['bucket'] as String?;
      if (bucket == null) {
        throw StateError('Bucket not specified for time filter for bucket');
      }
      return TimeFilterForBucket(bucket: Bucket.parse(bucket));
      ///
      ///
    } else if (filterType == 'monthFilter') {
      var months = x['filter']['time']['months'] as List?;
      if (months == null) {
        throw StateError('Months not specified for time filter for months');
      }
      return TimeFilterForMonths(months: months.toSet().cast<int>());
      ///
      ///
    } else {
      throw StateError('Unsupported time filter type: $filterType');
    }
  }

}

class TimeFilterForBucket extends TimeFilter {
  TimeFilterForBucket({required this.bucket}) {
    _f = (Interval interval) => bucket.containsHour(Hour.containing(interval.start));
  }
  final Bucket bucket;

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

class TimeFilterForMonths extends TimeFilter {
  TimeFilterForMonths({required this.months}) {
    _f = (Interval interval) => months.contains(interval.start.month);
  }
  final Set<int> months;

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

