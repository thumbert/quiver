


class TimeAggregation {
  TimeAggregation({
    required this.timeFrequency,
    required this.function}) {
    /// TODO: checks on function name, timeFrequency values, etc.
  }

  String timeFrequency;
  String function;

  Map<String,dynamic> toJson() {
    return {
      'aggregate': {
        'time': {
          'frequency': timeFrequency,
          'function': function,
        },
      }
    };
  }

}