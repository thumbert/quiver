import 'package:timeseries/timeseries.dart';

enum AggregationFrequency {
  fifteenMinutes,
  thirtyMinutes,
  hourly,
  daily,
  monthly,
  yearly,
}

extension AggregationExtension on TimeSeries<num> {
  TimeSeries<num> aggregate(
      {required AggregationFrequency aggregationFrequency,
      required num Function(List<num>) aggregationFunction}) {
    if (aggregationFrequency == AggregationFrequency.daily) {
      return toDaily(this, aggregationFunction);
    } else {
      throw ArgumentError('Not supported $aggregationFrequency');
    }
  }
}
