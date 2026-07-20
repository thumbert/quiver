import 'package:dama/basic/num_iterable_extensions.dart';
import 'package:date/date.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:timezone/timezone.dart';
import 'package:elec_server/client/isoexpress/mra_capacity_results.dart'
    hide MraCapacityRecord;
import 'package:elec_server/client/isoexpress/mra_capacity_bidoffer.dart';

final month =
    signal<Month>(getDefaultMonth(), options: SignalOptions(name: 'month'));
final region = signal<String>('ISONE', options: SignalOptions(name: 'region'));
// final zoneId = signal<int?>(null, options: SignalOptions(name: 'zoneId'));
final zoneName =
    signal<String>('(All)', options: SignalOptions(name: 'zoneName'));

final allRegions = ['ISONE', 'NYISO'];
final allZonesIsone = {
  '(All)': null,
  'Rest-of-Pool': 8500,
  'Maine': 8503,
  'Northern New England': 8505,
  'Southeast New England': 8506,
};

final traces = computed(() {
  // Track getData so this re-runs when async loading completes
  final dataState = getData.value;
  if (dataState is! AsyncData) return <Map<String, dynamic>>[];

  if (region.value == 'ISONE') {
    if (!isoneCacheBidsOffers.containsKey(month.value) ||
        !isoneCacheClearingPrices.containsKey(month.value)) {
      return <Map<String, dynamic>>[];
    }
    final zoneId = allZonesIsone[zoneName.value];
    return isoneMakeTracesForZone(month.value, zoneId);
  }
  return <Map<String, dynamic>>[];
});

/// Creates a list of Plotly traces for a given zone based on the region and
/// month.
/// If `zoneId` is provided, the traces will be filtered for that specific zone.
/// If `zoneId` is null, the traces will include the bids/offers for all zones.
/// Returns a list of traces suitable for plotting with Plotly.
///
List<Map<String, dynamic>> isoneMakeTracesForZone(Month month, int? zoneId) {
  final data = isoneCacheBidsOffers[month]!;
  final cp = isoneCacheClearingPrices[month]!;

  var bids = data.where((e) => e.bidOffer == BidOffer.bid).toList();
  if (zoneId != null) {
    bids = bids.where((e) => e.maskedCapacityZoneId == zoneId).toList();
  }
  bids.sort((a, b) => -a.price.compareTo(b.price));

  var offers = data.where((e) => e.bidOffer == BidOffer.offer).toList();
  if (zoneId != null) {
    offers = offers.where((e) => e.maskedCapacityZoneId == zoneId).toList();
  }
  offers.sort((a, b) => a.price.compareTo(b.price));

  // make traces for bids and offers
  var traces = <Map<String, dynamic>>[
    {
      'x': bids.map((e) => e.quantity).cumSum().toList(),
      'y': bids.map((e) => e.price).toList(),
      'text': bids
          .map((e) =>
              'Masked Asset Id: ${e.maskedResourceId}, Participant: ${e.maskedParticipantId}')
          .toList(),
      'mode': 'lines+markers',
      'line': {'shape': 'vh'},
      'name': 'bids'
    },
    {
      'x': offers.map((e) => e.quantity).cumSum().toList(),
      'y': offers.map((e) => e.price).toList(),
      'text': offers
          .map((e) =>
              'Masked Asset Id: ${e.maskedResourceId}, Participant: ${e.maskedParticipantId}')
          .toList(),
      'mode': 'lines+markers',
      'line': {'shape': 'hv'},
      'name': 'offers'
    }
  ];
  if (zoneId != null) {
    final results = cp.firstWhere((e) => e.capacityZoneId == zoneId);
    traces.add({
      'x': [
        results.supplyOffersCleared,
        -results.demandBidsCleared,
      ],
      'y': [results.clearingPrice, results.clearingPrice],
      'mode': 'lines+markers',
      'line': {'color': 'black', 'width': 2},
      'name': 'clearing price'
    });
  }

  return traces;
}

final layout = computed(
  () {
    final name = zoneName.value;
    return {
      'title': {'text': '${region.value} ${month.value} MRA bids/offers, $name'},
      'xaxis': {
        'title': {'text': 'Cumulative quantity, MW'}
      },
      'yaxis': {
        'title': {'text': 'Price, \$/kW-month'}
      },
      'height': 600,
      'width': 800,
    };
  },
);

/// Aggregate all the data you need for the selected region and month
final getData = futureSignal(() async {
  if (region.value == 'ISONE') {
    return Future.wait([isoneClearingPrices.future, isoneBidsOffers.future]);
  }
}, options: AsyncSignalOptions(dependencies: [month, region]));

final isoneClearingPrices = futureSignal<List<MraCapacityZoneRecord>>(() async {
  final key = month.value;
  if (isoneCacheClearingPrices.containsKey(key)) {
    return isoneCacheClearingPrices[key]!;
  }
  final result = await getMraClearingPriceZone(month.value,
      rootUrl: dotenv.env['RUST_SERVER']!);
  isoneCacheClearingPrices[key] = result;
  return result;
},
    options: AsyncSignalOptions(
        dependencies: [month, region], name: 'isoneClearingPrices'));

final isoneBidsOffers = futureSignal<List<MraCapacityRecord>>(() async {
  final key = month.value;
  if (isoneCacheBidsOffers.containsKey(key)) {
    return isoneCacheBidsOffers[key]!;
  }
  final result =
      await getMraBidsOffers(month.value, rootUrl: dotenv.env['RUST_SERVER']!);
  isoneCacheBidsOffers[key] = result;
  return result;
},
    options: AsyncSignalOptions(
        dependencies: [month, region], name: 'isoneBidsOffers'));

final isoneCacheClearingPrices = <Month, List<MraCapacityZoneRecord>>{};
final isoneCacheBidsOffers = <Month, List<MraCapacityRecord>>{};

/// in UTC
Month getDefaultMonth() {
  // final today = Date.today(location: UTC);
  // final month = Month.utc(today.year, today.month);
  // return month.subtract(4);
  return Month.utc(2025, 12);
}
