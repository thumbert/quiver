library models.rate_board_model;

import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dama/dama.dart';
import 'package:elec/src/time/calendar/calendars/nerc_calendar.dart';
import 'package:elec/risk_system.dart';
import 'package:elec_server/client/utilities/retail_offers/retail_supply_offer.dart';
import 'package:elec_server/client/utilities/retail_suppliers_offers.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec_server/client/weather/noaa_daily_summary.dart';
import 'package:elec_server/client/isoexpress/zonal_demand.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:more/comparator.dart';
import 'package:table/table.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';
import 'package:tuple/tuple.dart';

final providerOfRateBoard =
    StateNotifierProvider<RateBoardNotifier, RateBoardState>(
        (ref) => RateBoardNotifier(ref));

final providerOfRetailOffers =
    FutureProvider.family<List<RetailSupplyOffer>, String>((ref, state) async {
  return RateBoardState.getOffers('ISONE', state);
});

class RateBoardState {
  RateBoardState({
    required this.region,
    required this.stateName,
    required this.loadZone,
    required this.utility,
    required this.accountType,
    required this.billingCycles,
    required this.term,
  });

  /// Historical term to see behavior of offers, in UTC.  Used for the plot
  final Term term;

  /// For example ISONE.  Don't allow '(All)'
  final String region;

  /// An actual state name, e.g. 'CT'.  Don't allow '(All)'
  final String stateName;

  /// An actual load zone, e.g. 'NEMA'.  Don't allow '(All)'
  final String loadZone;

  /// A standard utility name, e.g. Eversource, United Illuminating, NGrid, etc.
  final String utility;

  /// Can be only 'Business' or 'Residential' are allowed.
  final String accountType;

  // final String rateClass;

  /// Either '(All)' or something like '12', '24', '33', '36'
  final String billingCycles;

  /// How the 'sortColumn' should be sorted
  bool sortAscending = false;

  /// Rate table is always sorted by increasingly by rate.  This is the other
  /// column you may want it sorted by (say 'Billing cycles' or 'Account Type').
  String sortColumn = 'Months';

  /// Used to find default utility for different (region,state,loadZone).
  /// Not the complete combinations.
  static final definitions = <Map<String, dynamic>>[
    {
      'region': 'ISONE',
      'state': 'CT',
      'loadZone': 'CT',
      'utility': 'Eversource'
    },
    {
      'region': 'ISONE',
      'state': 'MA',
      'loadZone': 'NEMA',
      'utility': 'NGrid',
    },
    {
      'region': 'ISONE',
      'state': 'MA',
      'loadZone': 'SEMA',
      'utility': 'NGrid',
    },
    {
      'region': 'ISONE',
      'state': 'MA',
      'loadZone': 'WCMA',
      'utility': 'NGrid',
    },
  ];

  /// Store the retail offers by state (region == 'ISONE' for the foreseeable future)
  static var offersCache = <String, List<RetailSupplyOffer>>{};

  static final clientOffers =
      RetailSuppliersOffers(Client(), rootUrl: dotenv.env['ROOT_URL']!);

  static Future<List<RetailSupplyOffer>> getOffers(
      String region, String state) async {
    if (!offersCache.containsKey(state)) {
      var term = Term(Date.utc(2022, 1, 1), Date.today(location: UTC));
      offersCache[state] = await clientOffers.getOffers(
          region: region, state: state, term: term);
    }
    // print('Got ${offersCache[state]!.length} offers for state $state');
    return offersCache[state]!;
  }

  /// Right now only ISONE
  List<String> getAllRegions() {
    return ['ISONE'];
  }

  // So far only [CT, MA]
  List<String> getAllStates() {
    return ['CT', 'MA'];
  }

  List<String> getAllZones() {
    if (stateName == 'CT') {
      return ['CT'];
    } else if (stateName == 'MA') {
      return ['NEMA', 'SEMA', 'WCMA'];
    } else {
      debugPrint('State $stateName needs to be supported in getAllZones()');
      throw StateError(
          'State $stateName needs to be supported in getAllZones()');
    }
  }

  List<String> getAllUtilities() {
    if (stateName == 'CT') {
      return ['Eversource', 'United Illuminating'];
      //
      //
    } else if (stateName == 'MA') {
      var values = ['Eversource', 'NGrid'];
      if (loadZone == 'WCMA') {
        return [...values, 'Unitil'];
      } else {
        return values;
      }
    } else {
      throw StateError(
          'State $stateName needs to be supported in getAllUtilities()');
    }
  }

  List<String> getAllBillingCycles() {
    if (offersCache.containsKey(stateName)) {
      var aux = offersCache[stateName]!.where((e) =>
          e.loadZone == loadZone &&
          e.utility == utility &&
          e.accountType == accountType);
      var values = aux.map((e) => e.countOfBillingCycles).toSet().toList();
      values.sort();
      return ['(All)', ...values.map((e) => e.toString())];
    } else {
      return ['(All)'];
    }
  }

  List<RetailSupplyOffer> makeOfferTable({Date? asOfDate}) {
    if (!offersCache.containsKey(stateName)) {
      return <RetailSupplyOffer>[];
    }
    asOfDate ??= Date.today(location: UTC);

    /// get the offers from the cache
    Iterable<RetailSupplyOffer> all = offersCache[stateName]!;
    all = all.where((e) =>
        e.loadZone == loadZone &&
        e.accountType == accountType &&
        e.utility == utility);

    if (billingCycles != '(All)') {
      var term = int.parse(billingCycles);
      all = all.where((e) => e.countOfBillingCycles == term);
    }
    if (all.isEmpty) {
      return <RetailSupplyOffer>[];
    }

    // print('in makeOfferTable, all length: ${all.length}');
    // print(asOfDate);
    // print(all.first.toMap());
    var data = RetailSuppliersOffers.getCurrentOffers(all, asOfDate);
    // print(data.length);

    /// sort decreasingly by rate and 'sortedColumn'
    var byRate = naturalComparable<num>.onResultOf((RetailSupplyOffer e) => e.rate);
    var comparator = byRate;

    // var sign = sortAscending ? 1 : -1;

    if (sortColumn == 'Months') {
      var byMonths = naturalComparable<num>
          .onResultOf((RetailSupplyOffer e) => e.countOfBillingCycles);
      // var byMonths3 = naturalComparable<num>.onResultOf((RetailSupplyOffer e) => e.countOfBillingCycles);

      if (sortAscending) byMonths = byMonths.reversed;
      comparator = byMonths.thenCompare(byRate);
    } else if (sortColumn == 'Posted Date') {
      var byDate = naturalComparable<num>
          .onResultOf((RetailSupplyOffer e) => e.offerPostedOnDate.value);
      if (sortAscending) byDate = byDate.reversed;
      comparator = byDate.thenCompare(byRate);
    } else if (sortColumn == 'Supplier') {
      var bySupplier = naturalComparable<String>
          .onResultOf((RetailSupplyOffer e) => e.supplierName);
      if (sortAscending) bySupplier = bySupplier.reversed;
      comparator = bySupplier.thenCompare(byRate);
    } else if (sortColumn == 'Recs') {
      var byRecs = naturalComparable<num>
          .onResultOf((RetailSupplyOffer e) => e.minimumRecs);
      if (sortAscending) byRecs = byRecs.reversed;
      comparator = byRecs.thenCompare(byRate);
    }

    return comparator.sorted(data);
  }

  // List<Map<String, dynamic>> makeTraces() {
  //   var traces = <Map<String, dynamic>>[];
  //   var t2 = Tuple2(region, zone);
  //   if (!loadCache.containsKey(t2)) return traces;
  //
  //   /// For temperature - load plots
  //   if (xVariable == 'Temperature') {
  //     if (!offersCache.containsKey(airport)) {
  //       return traces;
  //     }
  //     var x = offersCache[airport]!
  //         .window(term.interval)
  //         .map((e) => {
  //               'date': e.interval.start.toString().substring(0, 10),
  //               'x': e.value,
  //             })
  //         .toList();
  //     var hourlyData = loadCache[t2]!
  //         .window(term.interval.withTimeZone(IsoNewEngland.location));
  //     late TimeSeries<num> aux;
  //     if (yVariable == 'Average Hourly Load') {
  //       aux = toDaily(hourlyData, mean);
  //     } else if (yVariable == 'Max Hourly Load') {
  //       aux = toDaily(hourlyData, max);
  //     } else if (yVariable == 'Min Hourly Load') {
  //       aux = toDaily(hourlyData, min);
  //     } else {
  //       debugPrint('Unsupported yVariable $yVariable');
  //       return traces;
  //     }
  //     var y = aux
  //         .map((e) => {
  //               'year': e.interval.start.year,
  //               'month': e.interval.start.month,
  //               'date': e.interval.start.toString().substring(0, 10),
  //               'y': e.value,
  //             })
  //         .toList();
  //     var xy = join(x, y);
  //     xy = filterData(xy);
  //
  //     /// coloring??
  //     if (colorBy == '') {
  //       traces.add({
  //         'x': xy.map((e) => e['x']).toList(),
  //         'y': xy.map((e) => e['y']).toList(),
  //         'text': xy.map((e) => '${e['date']} ${e['holiday']??''}').toList(),
  //         'mode': 'markers',
  //       });
  //     } else if (colorBy == 'Year') {
  //       var byYear = groupBy(xy, (Map e) => e['date'].substring(0, 4));
  //       for (var year in byYear.keys) {
  //         traces.add({
  //           'x': byYear[year]!.map((e) => e['x']).toList(),
  //           'y': byYear[year]!.map((e) => e['y']).toList(),
  //           'text': byYear[year]!.map((e) => '${e['date']} ${e['holiday']??''}').toList(),
  //           'mode': 'markers',
  //           'name': year,
  //         });
  //       }
  //     }
  //   }
  //
  //   return traces;
  // }

  static RateBoardState getDefault() => RateBoardState(
        term: Term(Date.utc(2022, 12, 1), Date.today(location: UTC)),
        region: 'ISONE',
        stateName: 'CT',
        loadZone: 'CT',
        utility: 'Eversource',
        accountType: 'Residential',
        billingCycles: '(All)',
      );

  RateBoardState copyWith({
    Term? term,
    String? region,
    String? stateName,
    String? loadZone,
    String? utility,
    String? accountType,
    String? billingCycles,
  }) {
    return RateBoardState(
      term: term ?? this.term,
      region: region ?? this.region,
      stateName: stateName ?? this.stateName,
      loadZone: loadZone ?? this.loadZone,
      utility: utility ?? this.utility,
      accountType: accountType ?? this.accountType,
      billingCycles: billingCycles ?? this.billingCycles,
    );
  }

  // Map<String, dynamic> layout() => {
  //       'width': 850,
  //       'height': 550,
  //       'title': '',
  //       'xaxis': {
  //         'title': xVariable,
  //         'showgrid': true,
  //       },
  //       'yaxis': {
  //         'showgrid': true,
  //         'zeroline': false,
  //         'title': yVariable,
  //       },
  //       // 'showlegend': true,
  //       'hovermode': 'closest',
  //     };
}

class RateBoardNotifier extends StateNotifier<RateBoardState> {
  RateBoardNotifier(this.ref) : super(RateBoardState.getDefault());

  final Ref ref;

  set term(Term value) {
    state = state.copyWith(term: value);
  }

  set region(String value) {
    if (value == 'ISONE') {
      state = state.copyWith(
        region: 'ISONE',
        stateName: 'CT',
        loadZone: 'CT',
        utility: 'Eversource',
        billingCycles: '(All)',
      );
    }
  }

  set stateName(String value) {
    var x0 = RateBoardState.definitions.firstWhere((e) => e['state'] == value);

    state = state.copyWith(
      region: x0['region'],
      stateName: value,
      loadZone: x0['loadZone'],
      utility: x0['utility'],
      billingCycles: '(All)',
    );
  }

  set loadZone(String value) {
    var x0 = RateBoardState.definitions.firstWhere((e) =>
        e['state'] == state.stateName && e['loadZone'] == state.loadZone);
    state = state.copyWith(
      region: x0['region'],
      stateName: state.stateName,
      loadZone: value,
      utility: x0['utility'],
      billingCycles: '(All)',
    );
  }

  set utility(String value) {
    state = state.copyWith(utility: value, billingCycles: '(All)');
  }

  set billingCycle(String value) {
    state = state.copyWith(billingCycles: value);
  }

  set checkboxBusiness(bool value) {
    if (!state.accountType.contains('Business')) {
      state = state.copyWith(accountType: 'Business');
    }
  }

  set checkboxResidential(bool value) {
    if (!state.accountType.contains('Residential')) {
      state = state.copyWith(accountType: 'Residential');
    }
  }
}
