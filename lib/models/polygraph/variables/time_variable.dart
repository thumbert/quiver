library models.polygraph.variables.time_variable;

import 'package:date/date.dart';
import 'package:timeseries/timeseries.dart';
import 'variable.dart';

class TimeVariable extends Object with PolygraphVariable {
  TimeVariable({this.skipWeekends = false}) {
    name = 'Time';
    label = 'Time';
  }

  bool skipWeekends;

  /// List of available timezones
  static List<String> timezones = const [
    'UTC',
    'America/Chicago',
    'America/Los_Angeles',
    'America/New_York',
  ];

  @override
  Map<String, dynamic> toJson() => {
        'category': 'Time',
        'config': {
          'skipWeekends': skipWeekends,
        }
      };

  @override
  TimeSeries<num> timeSeries(Term term) {
    // TODO: implement timeSeries
    throw UnimplementedError();
  }
}
