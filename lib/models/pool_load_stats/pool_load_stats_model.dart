library models.pool_load_stats;

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dama/dama.dart';
import 'package:elec/src/time/calendar/calendars/nerc_calendar.dart';
import 'package:elec/risk_system.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec_server/client/weather/noaa_daily_summary.dart';
import 'package:elec_server/client/isoexpress/zonal_demand.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:table/table.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';
import 'package:tuple/tuple.dart';

final providerOfPoolLoadStats =
    StateNotifierProvider<PoolLoadStatsNotifier, PoolLoadStatsState>(
        (ref) => PoolLoadStatsNotifier(ref));

final providerOfLoad =
    FutureProvider.family<TimeSeries<num>, Tuple2<String, String>>(
        (ref, tuple) async {
  return PoolLoadStatsState.getLoad(tuple.item1, tuple.item2);
});

final providerOfTemperature =
    FutureProvider.family<TimeSeries<num>, String>((ref, airport) async {
  return PoolLoadStatsState.getTemperature(airport);
});

class PoolLoadStatsState {
  PoolLoadStatsState({
    required this.term,
    required this.region,
    required this.zone,
    required this.aggregation,
    required this.years,
    required this.months,
    required this.dayType,
    required this.airport,
    required this.xVariable,
    required this.yVariable,
    required this.bucket,
    required this.colorBy,
  });

  /// in UTC!
  final Term term;
  final String region;
  final String zone;
  final String aggregation;
  final List<int> years;
  final List<int> months;
  final String dayType;
  final String airport;
  final String xVariable;
  final String yVariable;
  final String bucket;
  final String colorBy;

  static Map<String, Map<String, dynamic>> allRegions = {
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

  static const allAggregations = ['Month', 'Date', 'Hour'];

  static const allDayTypes = ['(All)', 'Weekday', 'Weekend & Holiday'];

  static const allXVariables = [
    'Temperature',
    'Hour beginning',
    'Date',
    'Month',
    'Year'
  ];

  static const allYVariables = [
    'Average Hourly Load',
    'Max Hourly Load',
    'Min Hourly Load',
  ];

  static final calendar = NercCalendar();

  static bool needsData = true;

  /// Store the time-series historical data for one (Region, zoneName) pair
  ///
  static var loadCache = <Tuple2<String, String>, TimeSeries<num>>{};

  /// Store the time-series Airport -> TimeSeries<num>
  static var temperatureCache = <String, TimeSeries<num>>{};

  static final clientTemperature =
      NoaaDailySummary(Client(), rootUrl: dotenv.env['ROOT_URL']!);

  static final clientIsoneDemand =
      IsoneZonalDemand(Client(), rootUrl: dotenv.env['ROOT_URL']!);

  static Future<TimeSeries<num>> getLoad(String region, String zone) async {
    var t2 = Tuple2(region, zone);
    if (!loadCache.containsKey(t2)) {
      var start = Date.utc(2016, 1, 1);
      var end = Date.today(location: UTC);
      if (region == 'ISONE') {
        late TimeSeries<num> ts;
        if (zone == '(All)') {
          ts = await clientIsoneDemand.getPoolDemand(Market.rt, start, end);
        } else {
          var ptid = Iso.newEngland.loadZones[zone]!;
          ts = await clientIsoneDemand.getZonalDemand(
              ptid, Market.rt, start, end);
        }
        loadCache[t2] = ts;
      }
    }
    return loadCache[t2]!;
  }

  static Future<TimeSeries<num>> getTemperature(String airport) async {
    if (!temperatureCache.containsKey(airport)) {
      var interval = Interval(TZDateTime.utc(1991), TZDateTime.now(UTC));
      temperatureCache[airport] = await clientTemperature
          .getDailyHistoricalTemperature(airport, interval);
    }
    return temperatureCache[airport]!;
  }

  Future<List<Map<String, dynamic>>> getData() async {
    if (xVariable == 'Temperature') {
      if (!temperatureCache.containsKey(airport)) {
        temperatureCache[airport] = await getTemperature(airport);
      }
    }
    if (!loadCache.containsKey(Tuple2(region, zone))) {
      loadCache[Tuple2(region, zone)] = await getLoad(region, zone);
    }

    needsData = false;
    return <Map<String, dynamic>>[];
  }

  ///
  List<Map<String, dynamic>> filterData(Iterable<Map<String, dynamic>> data) {
    if (years.isNotEmpty) {
      data = data.where((e) => years.contains(e['year']));
    }
    if (months.isNotEmpty) {
      data = data.where((e) => months.contains(e['month']));
    }
    if (dayType != '(All)') {
      data = data.where((e) {
        var date = Date.fromIsoString(e['date'], location: UTC);
        if (calendar.isHoliday(date)) {
          e['holiday'] = calendar.getHolidayType(date).toString();
          return dayType == 'Weekend & Holiday';
        } else {
          if (date.isWeekend()) {
            return dayType == 'Weekend & Holiday';
          } else {
            return dayType == 'Weekday';
          }
        }
      });
    }
    return data.toList();
  }

  List<Map<String, dynamic>> makeTraces() {
    var traces = <Map<String, dynamic>>[];
    var t2 = Tuple2(region, zone);
    if (!loadCache.containsKey(t2)) return traces;

    /// For temperature - load plots
    if (xVariable == 'Temperature') {
      if (!temperatureCache.containsKey(airport)) {
        return traces;
      }
      var x = temperatureCache[airport]!
          .window(term.interval)
          .map((e) => {
                'date': e.interval.start.toString().substring(0, 10),
                'x': e.value,
              })
          .toList();
      var hourlyData = loadCache[t2]!
          .window(term.interval.withTimeZone(IsoNewEngland.location));
      late TimeSeries<num> aux;
      if (yVariable == 'Average Hourly Load') {
        aux = toDaily(hourlyData, mean);
      } else if (yVariable == 'Max Hourly Load') {
        aux = toDaily(hourlyData, max);
      } else if (yVariable == 'Min Hourly Load') {
        aux = toDaily(hourlyData, min);
      } else {
        debugPrint('Unsupported yVariable $yVariable');
        return traces;
      }
      var y = aux
          .map((e) => {
                'year': e.interval.start.year,
                'month': e.interval.start.month,
                'date': e.interval.start.toString().substring(0, 10),
                'y': e.value,
              })
          .toList();
      var xy = join(x, y);
      xy = filterData(xy);

      /// coloring??
      if (colorBy == '') {
        traces.add({
          'x': xy.map((e) => e['x']).toList(),
          'y': xy.map((e) => e['y']).toList(),
          'text': xy.map((e) => '${e['date']} ${e['holiday']??''}').toList(),
          'mode': 'markers',
        });
      } else if (colorBy == 'Year') {
        var byYear = groupBy(xy, (Map e) => e['date'].substring(0, 4));
        for (var year in byYear.keys) {
          traces.add({
            'x': byYear[year]!.map((e) => e['x']).toList(),
            'y': byYear[year]!.map((e) => e['y']).toList(),
            'text': byYear[year]!.map((e) => '${e['date']} ${e['holiday']??''}').toList(),
            'mode': 'markers',
            'name': year,
          });
        }
      }
    }

    return traces;
  }

  static PoolLoadStatsState getDefault() => PoolLoadStatsState(
        term: Term(Date.utc(2018, 1, 1), Date.today(location: UTC)),
        region: 'ISONE',
        zone: '(All)',
        aggregation: 'Date',
        years: <int>[],
        months: <int>[],
        dayType: '(All)',
        airport: allRegions['ISONE']!['airport'],
        xVariable: 'Temperature',
        yVariable: 'Average Hourly Load',
        bucket: 'ATC',
        colorBy: '',
      );

  PoolLoadStatsState copyWith({
    Term? term,
    String? region,
    String? zone,
    String? aggregation,
    List<int>? years,
    List<int>? months,
    String? dayType,
    String? airport,
    String? xVariable,
    String? yVariable,
    String? bucket,
    String? colorBy,
  }) {
    return PoolLoadStatsState(
      term: term ?? this.term,
      region: region ?? this.region,
      zone: zone ?? this.zone,
      aggregation: aggregation ?? this.aggregation,
      years: years ?? this.years,
      months: months ?? this.months,
      dayType: dayType ?? this.dayType,
      airport: airport ?? this.airport,
      xVariable: xVariable ?? this.xVariable,
      yVariable: yVariable ?? this.yVariable,
      bucket: bucket ?? this.bucket,
      colorBy: colorBy ?? this.colorBy,
    );
  }

  Map<String, dynamic> layout() => {
        'width': 850,
        'height': 550,
        'title': '',
        'xaxis': {
          'title': xVariable,
          'showgrid': true,
        },
        'yaxis': {
          'showgrid': true,
          'zeroline': false,
          'title': yVariable,
        },
        // 'showlegend': true,
        'hovermode': 'closest',
      };
}

class PoolLoadStatsNotifier extends StateNotifier<PoolLoadStatsState> {
  PoolLoadStatsNotifier(this.ref) : super(PoolLoadStatsState.getDefault());

  final Ref ref;

  set term(Term value) {
    state = state.copyWith(term: value);
  }

  set region(String value) {
    // when region changes, reset the zone to '(All)', and change the airport
    // to the default airport
    state = state.copyWith(
        region: value,
        zone: '(All)',
        airport: PoolLoadStatsState.allRegions[value]!['airport']);
  }

  set zone(String value) {
    state = state.copyWith(zone: value);
  }

  set aggregation(String value) {
    state = state.copyWith(aggregation: value);
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

  set airport(String value) {
    state = state.copyWith(airport: value);
  }

  set xVariable(String value) {
    // if (value == 'Temperature') {
    //   state = state.copyWith(
    //     xVariable: 'Temperature',
    //     yVariable: 'Energy',
    //   );
    // } else {
    state = state.copyWith(xVariable: value);
    // }
  }

  set yVariable(String value) {
    state = state.copyWith(yVariable: value);
  }

  set colorBy(String value) {
    state = state.copyWith(colorBy: value);
  }
}
