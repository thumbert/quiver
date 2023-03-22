library models.polygraph_data_provider;

import 'package:date/date.dart';
import 'package:timeseries/timeseries.dart';


abstract class DataProvider {
  late DataExtractionSpec spec;
  
  Future<TimeSeries<num>> getValues(Term term);
}

class DataExtractionSpec {

}

class MoomooDataExtractionSpec extends DataExtractionSpec {
  late String expression;
}


// class LocalDataProvider extends DataProvider {
//  
// }

class ShoojuDataProvider extends DataProvider {
  ShoojuDataProvider();
  
  @override
  Future<TimeSeries<num>> getValues(Term term) {
    /// use spec.expression to get the values
    // TODO: implement getValues
    throw UnimplementedError();
  }
  
}

