library models.polygraph.variables.time_variable;

import 'package:date/date.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service.dart';
import 'package:timeseries/timeseries.dart';
import 'variable.dart';

class TimeVariable extends PolygraphVariable {
  TimeVariable({this.skipWeekends = false}) {
    id = 'Time';
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
  Map<String, dynamic> toMap() => {
        'category': 'Time',
        'config': {
          'skipWeekends': skipWeekends,
        }
      };

  @override
  PolygraphVariable fromMongo(Map<String,dynamic> x) {
    // TODO: implement fromMongo
    throw UnimplementedError();
  }

  @override
  Future<TimeSeries<num>> get(DataService service, Term term) {
    // TODO: implement get
    throw UnimplementedError();
  }
}
