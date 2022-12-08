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
import 'package:table/table.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';
import 'package:tuple/tuple.dart';

final providerOfRateBoard =
    StateNotifierProvider<RateBoardNotifier, RateBoardState>(
        (ref) => RateBoardNotifier(ref));

final providerOfRetailOffers =
    FutureProvider.family<List<RetailSupplyOffer>, String>((ref, region) async {
  return RateBoardState.getOffers(region);
});

class RateBoardState {
  RateBoardState({
    required this.term,
    required this.region,
    required this.state,
    required this.utility,
    required this.accountType,
    required this.billingCycles,
  });

  /// Historical term to see behavior of offers, in UTC.  Used for the plot
  final Term term;
  /// For example ISONE
  final String region;
  /// An actual state name, e.g. CT.  Don't allow '(All)'
  final String state;
  /// A standard utility name, e.g. Eversource or United Illuminating or '(All)'.
  final String utility;
  /// Only the elements 'Business', 'Residential' are allowed.  Can't be empty!
  final List<String> accountType;
  /// Either '(All)' something like '12', '24', '33', '36'
  final String billingCycles;

  static final definitions = <Map<String, dynamic>>[
    {'region': 'ISONE', 'state': 'CT', 'utility': 'Eversource'},
    {'region': 'ISONE', 'state': 'CT', 'utility': 'United Illuminating'},
  ];

  // static List<String> allStates = ['CT'];
  //
  // static List<String> allUtilities = ['(All)'];
  //
  // static List<String> allBillingCycles = ['(All)'];

  /// Store the retail offers by region
  static var offersCache = <String, List<RetailSupplyOffer>>{};

  static final clientOffers =
      RetailSuppliersOffers(Client(), rootUrl: dotenv.env['ROOT_URL']!);

  static Future<List<RetailSupplyOffer>> getOffers(String region) async {
    if (!offersCache.containsKey(region)) {
      var term = Term(Date.utc(2022, 1, 1), Date.today(location: UTC));
      offersCache[region] =
          await clientOffers.getOffersForRegionTerm(region, term);
    }
    return offersCache[region]!;
  }

  // When I have more states, so far only CT
  List<String> getAllStates() {
    if (offersCache.containsKey(region)) {
      return offersCache[region]!.map((e) => e.state).toSet().toList();
    } else {
      return ['(All)'];
    }
  }

  List<String> getAllUtilities() {
    if (offersCache.containsKey(region)) {
      var aux = offersCache[region]!.where((e) => e.state == state);
      return aux.map((e) => e.state).toSet().toList();
    } else {
      return ['(All)'];
    }
  }

  List<String> getAllBillingCycles() {
    if (offersCache.containsKey(region)) {
      var aux = offersCache[region]!.where((e) => e.state == state);
      if (utility != '(All)') {
        aux = aux.where((e) => e.utility == utility);
      }
      if (accountType.length == 1) {
        // either Residential or Business
        aux = aux.where((e) => e.accountType == accountType.first);
      }
      return ['(All)',
        ...aux.map((e) => e.countOfBillingCycles.toString()).toSet()];
    } else {
      return ['(All)'];
    }
  }


  List<Map<String,dynamic>> makeOfferTable() {
    if (!offersCache.containsKey(region)) {
      return <Map<String,dynamic>>[];
    }
    /// get the offers from the cache
    Iterable<RetailSupplyOffer> all = offersCache[region]!;
    all = all.where((e) => e.state == state);
    if (utility != '(All)') {
      all = all.where((e) => e.utility == utility);
    }
    if (accountType.length == 1) {
      all = all.where((e) => accountType.contains(e.accountType)).toList();
    }
    if (billingCycles != '(All)') {
      var term = int.parse(billingCycles);
      all = all.where((e) => e.countOfBillingCycles == term);
    }
    var data = RetailSuppliersOffers.getCurrentOffers(all.toList(),
        Date.today(location: UTC));
    // sort decreasingly by term and rate
    // var comparator = naturalComparator

    data.sort((a,b) => a.rate.compareTo(b.rate));

    var res = data.map((e) => {
      'Utility': e.utility,
      'Supplier': e.supplierName,
      'Account Type': e.accountType,
      'Term': e.countOfBillingCycles,
      'Recs': e.minimumRecs,
      'Rate': e.rate,
      'Posted Date': e.offerPostedOnDate.toString(),
    }).toList();

    return res;
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
        state: 'CT',
        utility: 'Eversource',
        accountType: <String>['Residential'],
        billingCycles: '(All)',
      );

  RateBoardState copyWith({
    Term? term,
    String? region,
    String? state,
    String? utility,
    List<String>? accountType,
    String? billingCycles,
  }) {
    return RateBoardState(
      term: term ?? this.term,
      region: region ?? this.region,
      state: state ?? this.state,
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
      state =
          state.copyWith(region: 'ISONE', state: 'CT', 
              utility: 'Eversource', accountType: ['Residential']);
    }
  }

  set stateName(String value) {
    var x0 = RateBoardState.definitions.firstWhere((e) => e['state'] == value);
    state = state.copyWith(
      region: x0['region'],
      state: value,
      utility: x0['utility'],
      accountType: ['Residential'],
    );
  }

  set utility(String value) {
    state = state.copyWith(utility: value);
  }
}
