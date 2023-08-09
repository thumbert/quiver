library models.polygraph.variables.time_variable;

import 'package:date/date.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service.dart';
import 'package:timeseries/timeseries.dart';
import 'variable.dart';

class TimeVariable extends PolygraphVariable {
  TimeVariable({this.skipWeekends = false}) {
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
        'type': 'TimeVariable',
        'config': {
          'skipWeekends': skipWeekends,
        }
      };

  static TimeVariable fromJson(Map<String, dynamic> x) {
    if (x
        case {
          'type': 'TimeVariable',
          'config': {
            'skipWeekends': bool skipWeekends,
          },
        }) {
      return TimeVariable(skipWeekends: skipWeekends);
    } else {
      throw ArgumentError('Input $x is not a correctly formatted TimeVariable');
    }
  }

  @override
  Future<TimeSeries<num>> get(DataService service, Term term) {
    // TODO: implement get
    throw UnimplementedError();
  }
}
