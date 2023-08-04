import 'package:date/date.dart';
import 'package:elec_server/client/dalmp.dart';
import 'package:elec_server/client/marks/forward_marks2.dart';
import 'package:elec_server/client/weather/noaa_daily_summary.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_lmp.dart';
import 'package:flutter_quiver/models/polygraph/variables/temperature_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_marks_asofdate.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_marks_historical_view.dart';
import 'package:http/http.dart';
import 'package:timeseries/timeseries.dart';

class DataServiceLocal extends DataService {
  DataServiceLocal({String rootUrl = 'http://localhost:8080'}) {
    final client = Client();
    clientDaLmp = DaLmp(client, rootUrl: rootUrl);
    clientNoaa = NoaaDailySummary(client, rootUrl: rootUrl);
    clientFwdMarks = ForwardMarks2(rootUrl: rootUrl, client: client);
  }

  static late final DaLmp clientDaLmp;
  static late final NoaaDailySummary clientNoaa;
  static late final ForwardMarks2 clientFwdMarks;

  @override
  Future<TimeSeries<num>> getMarksAsOfDate(
      VariableMarksAsOfDate variable, Term term) async {
    var data = await clientFwdMarks.getPriceCurveForAsOfDate(curveName: variable.curveName,
        asOfDate: variable.asOfDate, location: term.location);
    return data.window(term.interval).toTimeSeries();
  }

  @override
  Future<TimeSeries<num>> getLmp(VariableLmp variable, Term term) async {
    var data = await clientDaLmp.getHourlyLmp(variable.iso, variable.ptid,
        variable.lmpComponent, term.startDate, term.endDate);
    return data;
  }

  @override
  Future<TimeSeries<num>> getTemperature(
      TemperatureVariable variable, Term term) async {
    if (variable.dataSource == 'NOAA' && variable.isForecast == false) {
      var aux = await clientNoaa.getDailyHistoricalMinMaxTemperature(
          variable.airportCode, term.interval);
      if (variable.variable == 'min') {
        return TimeSeries<num>.fromIterable(aux
            .window(term.interval)
            .map((e) => IntervalTuple(e.interval, e.value['min']!)));
      } else if (variable.variable == 'max') {
        return TimeSeries<num>.fromIterable(aux
            .window(term.interval)
            .map((e) => IntervalTuple(e.interval, e.value['max']!)));
      } else if (variable.variable == 'mean') {
        return TimeSeries<num>.fromIterable(aux.window(term.interval).map((e) =>
            IntervalTuple(
                e.interval, 0.5 * (e.value['min']! + e.value['max']!))));
      } else {
        return TimeSeries<num>();
      }
    }

    throw UnimplementedError();
  }

  @override
  Future<TimeSeries<num>> getMarksHistoricalView(
      VariableMarksHistoricalView variable, Term term) async {
    var bucket = clientFwdMarks.getBucket(variable.curveName);
    var data = await clientFwdMarks.getCurveStrip(
        curveName: variable.curveName,
        strip: variable.forwardStrip,
        startDate: term.startDate,
        endDate: term.endDate,
        markType: MarkType.price,
        location: term.location,
        bucket: bucket);
    return data;
  }
}
