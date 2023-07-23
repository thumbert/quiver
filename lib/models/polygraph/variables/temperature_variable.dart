library models.polygraph.variables.temperature_variable;

import 'package:date/date.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:timeseries/timeseries.dart';

class TemperatureVariable extends PolygraphVariable {
  TemperatureVariable({
    required this.airportCode,
    required this.variable,
    required this.frequency,
    required this.isForecast,
    required this.dataSource,
    required String label,
  }) {
    this.label = label;
  }

  /// For example, 'BOS' for Logan International Airport in Boston
  final String airportCode;

  /// One of 'min', 'max', 'mean'
  final String variable;

  /// One of 'day' or 'hour'
  final String frequency;

  /// historical or forecast?
  final bool isForecast;

  /// Where is the data coming from, e.g. 'NOAA'
  final String dataSource;

  TemperatureVariable copyWith({
    String? airportCode,
    String? variable,
    String? frequency,
    bool? isForecast,
    String? dataSource,
    String? label,
  }) =>
      TemperatureVariable(
          airportCode: airportCode ?? this.airportCode,
          variable: variable ?? this.variable,
          frequency: frequency ?? this.frequency,
          isForecast: isForecast ?? this.isForecast,
          dataSource: dataSource ?? this.dataSource,
        label: label ?? this.label,
      );

  @override
  Future<TimeSeries<num>> get(DataService service, Term term) {
    return service.getTemperature(this, term);
  }

  @override
  TemperatureVariable fromMongo(Map<String,dynamic> x) {
    // TODO: implement fromMongo
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'variableType': 'TemperatureVariable',
      'airportCode': airportCode,
      'variable': variable,
      'frequency': frequency,
      'bool': isForecast,
      'dataSource': dataSource,
    };
  }
}
