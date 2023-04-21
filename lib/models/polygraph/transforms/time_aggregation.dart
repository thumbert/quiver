library models.polygraph.transforms.time_aggregation;

import 'package:flutter_quiver/models/polygraph/transforms/transform.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeseries/timeseries.dart';

class TimeAggregation extends Object with Transform {
  TimeAggregation({
    required this.frequency,
    required this.function,
    String? error,
  }) {
    this.error = error ?? '';
  }

  final String frequency;
  final String function;
  String error = '';

  TimeAggregation.empty() : frequency = '', function = '';

  static final allFrequencies = [
    '',
    'hour',
    'day',
    'week',
    'month',
    'year',
    'contiguous term',   // allows for different month groupings, etc.
  ];

  bool isEmpty() => frequency == '' && function == '';
  bool isNotEmpty() => !isEmpty();

  void validate() {
    error = '';
    if (frequency == '' && function != '') {
      error = 'Frequency can\'t be empty';
    }
    if (function == '' && frequency != '') {
      error = 'Function can\'t be empty';
    }
    print('in time_aggregation validate(), error=$error');
  }

  Map<String,dynamic> toMongo() {
    return {
      'time': {
        'frequency': frequency,
        'function': function,
      },
    };
  }
  
  
  @override
  Map<String,dynamic> toJson() {
    return {
      'aggregate': {
        'time': {
          'frequency': frequency,
          'function': function,
        },
      }
    };
  }

  @override
  Iterable<IntervalTuple<num>> apply(Iterable<IntervalTuple<num>> ts) {
    if (frequency == 'day') {
      return toDaily(ts, Transform.aggregations[function]!);
    } else if (frequency == 'month') {
      return toMonthly(ts, Transform.aggregations[function]!);
    } else if (frequency == 'hour') {
      return toHourly(ts, Transform.aggregations[function]!);
    } else {
      throw StateError('Unsupported timeFrequency $frequency');
    }
  }
  
  TimeAggregation copyWith({String? frequency, String? function, String? error}) =>
      TimeAggregation(frequency: frequency ?? this.frequency, 
          function: function ?? this.function, error: error ?? this.error);
}


class TimeAggregationNotifier extends StateNotifier<TimeAggregation> {
  TimeAggregationNotifier(this.ref) : super(TimeAggregation.empty());

  final Ref ref;

  set frequency(String value) {
    state = state.copyWith(frequency: value);
  }

  set function(String value) {
    state = state.copyWith(function: value);
  }

  set error(String value) {
    state = state.copyWith(error: value);
  }
}