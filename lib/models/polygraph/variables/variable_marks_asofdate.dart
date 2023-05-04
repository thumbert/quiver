library models.polygraph.variables.variable_marks_asofdate;

import 'package:date/date.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_variable.dart';
import 'package:timeseries/timeseries.dart';

class VariableMarksAsOfDate extends PolygraphVariable {

  VariableMarksAsOfDate({required this.curveId, required this.asOfDate});

  final String curveId;
  final Date asOfDate;

  @override
  Future<TimeSeries<num>> get(DataService service, Term term) {
    return service.getMarksAsOfDate(this, term);
  }

}