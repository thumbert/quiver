library models.pool_load_stats;

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';
import 'package:tuple/tuple.dart';

final providerOfPoolLoadStats =
    StateNotifierProvider<PoolLoadStatsNotifier, PoolLoadStatsState>(
        (ref) => PoolLoadStatsNotifier(ref));

class PoolLoadStatsState {
  PoolLoadStatsState(
      {required this.term, required this.region, required this.zone,
        required this.years,
        required this.months,
        required this.dayType,
        required this.xVariable,
        required this.yVariable,
        required this.bucket,
        required this.colorBy,
      });

  /// in UTC!
  final Term term;
  final String region;
  final String zone;
  final List<int> years;
  final List<int> months;
  final String dayType;
  final String xVariable;
  final String yVariable;
  final String bucket;
  final String colorBy;

  static Map<String, Map<String,dynamic>> allRegions = {
    'ISONE': {
      'airport': 'BOS',
      'zoneNames': Iso.newEngland.loadZones.keys.toList(),
    },
    'PJM': {
      'airport': 'PHI',
      'zoneNames': Iso.pjm.loadZones.keys.toList(),
    },
    'NYISO': {
      'airport': 'LGA',
      'zoneNames': Iso.newYork.loadZones.keys.toList(),
    },
  };

  static const allBuckets = ['ATC', 'Peak', '2x16H', '7x8'];

  static const allDayTypes = ['(All)', 'Weekday', 'Weekend'];

  /// Store the time-series historical data for one (Region, zoneName) pair
  static var loadCache = <Tuple2<String,String>, TimeSeries<num>>{};
  /// Store the time-series Airport -> TimeSeries<num>
  static var temperatureCache = <String, TimeSeries<num>>{};

  Future<TimeSeries<num>> getCacheData() async {
    var t2 = Tuple2(region, zone);
    if (!loadCache.containsKey(t2)) {
      /// get the data  
      /// what if this fails ... ?  Need to report it
    }

    return loadCache[t2]!;
  }


  List<Map<String,dynamic>> makeTraces() {
    var traces = <Map<String, dynamic>>[];
    var t2 = Tuple2(region, zone);
    if (!loadCache.containsKey(t2)) return traces;


    return traces;
  }



  static PoolLoadStatsState getDefault() => PoolLoadStatsState(
      term: Term(Date.utc(2018, 1, 1), Date.today(location: UTC)),
      region: 'NYISO',
      zone: '(All)',
      years: <int>[],
      months: <int>[],
      dayType: '(All)',
      xVariable: 'Temperature',
      yVariable: 'Energy',
      bucket: 'ATC',
      colorBy: '',
  );

  PoolLoadStatsState copyWith({Term? term, String? region, String? zone,
    List<int>? years, List<int>? months, String? dayType,
    String? xVariable, String? yVariable, String? bucket, String? colorBy,
  }) {
    return PoolLoadStatsState(
        term: term ?? this.term,
        region: region ?? this.region,
        zone: zone ?? this.zone,
        years: years ?? this.years,
        months: months ?? this.months,
        dayType: dayType ?? this.dayType,
        xVariable: xVariable ?? this.xVariable,
        yVariable: yVariable ?? this.yVariable,
        bucket:  bucket ?? this.bucket,
        colorBy: colorBy ?? this.colorBy,
    );
  }
}

class PoolLoadStatsNotifier extends StateNotifier<PoolLoadStatsState> {
  PoolLoadStatsNotifier(this.ref) : super(PoolLoadStatsState.getDefault());

  final Ref ref;

  set term(Term value) {
    state = state.copyWith(term: value);
  }

  set region(String value) {
    // when region changes, set the zone to '(All)'
    state = state.copyWith(region: value, zone: '(All)');
  }

  set zone(String value) {
    state = state.copyWith(zone: value);
  }

  set years(List<int> xs) {
    state = state.copyWith(years: xs);
  }

  set months(List<int> xs) {
    state = state.copyWith(months: xs);
  }

  set dayType(String value) {
    state = state.copyWith(dayType: value);
  }
  
  set xVariable(String value) {
    state = state.copyWith(xVariable: value);
  }

  set yVariable(String value) {
    state = state.copyWith(yVariable: value);
  }

  set colorBy(String value) {
    state = state.copyWith(colorBy: value);
  }


}
