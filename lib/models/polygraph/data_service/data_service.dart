library models.polygraph_data_provider;

import 'package:date/date.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_marks_as_of_date.dart';
import 'package:flutter_quiver/models/polygraph/variables/temperature_variable.dart';
import 'package:timeseries/timeseries.dart';

import '../variables/variable_lmp.dart';


abstract class DataService {
  Future<TimeSeries<num>> getLmp(VariableLmp variable, Term term);
  // Future<TimeSeries<num>> getMarksAsOfDate(VariableMarksAsOfDate variable, Term term);
  Future<TimeSeries<num>> getTemperature(TemperatureVariable variable, Term term);
}



