import 'package:date/date.dart';
import 'package:elec_server/client/dalmp.dart';
import 'package:elec_server/client/weather/noaa_daily_summary.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_lmp.dart';
import 'package:flutter_quiver/models/polygraph/variables/temperature_variable.dart';
import 'package:http/http.dart';
import 'package:timeseries/timeseries.dart';

class DataServiceLocal extends DataService {
  DataServiceLocal({String rootUrl = 'http://localhost:8080'}) {
    var client = Client();
    clientDaLmp = DaLmp(client, rootUrl: rootUrl);
    clientNoaa = NoaaDailySummary(client, rootUrl: rootUrl);
  }

  static late final DaLmp clientDaLmp;
  static late final NoaaDailySummary clientNoaa;

  // @override
  // Future<TimeSeries<num>> getMarksAsOfDate(
  //     VariableMarksAsOfDate variable, Term term) {
  //   // TODO: implement getMarksAsOfDate
  //   throw UnimplementedError();
  // }

  @override
  Future<TimeSeries<num>> getLmp(VariableLmp variable, Term term) {
    // TODO: implement getLmp
    throw UnimplementedError();
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

}
