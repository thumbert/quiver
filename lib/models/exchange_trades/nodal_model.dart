library models.exchange_trades.nodal_model;

import 'package:date/date.dart';
import 'package:flutter_quiver/screens/common/signal/multiselect.dart';
import 'package:signals/signals_flutter.dart';
import 'package:timezone/timezone.dart';

final cache = <Map<String, dynamic>>[].toSignal();

/// Trades comes from a Db or from the cache if they're already there.
/// Keep this function separated from the rows signal to allow for better
/// testing.
Future<List<Map<String, dynamic>>> getTrades(Term term) async {
  await Future.delayed(const Duration(milliseconds: 200));
  if (!cachedTerm.value.interval.containsInterval(term.interval) ||
      cache.value.isEmpty) {
    cache.value = <Map<String, dynamic>>[
      {
        'iso': 'PJM',
        'location': 'WH',
        'strip': 'Cal24',
        'price': 10,
        'tradeDate': '2024-04-01',
        'bucket': 'Peak',
        'tradeKind': 'Outright',
      },
      {
        'iso': 'PJM',
        'location': 'PECO',
        'strip': 'Cal24',
        'price': 12,
        'tradeDate': '2024-04-03',
        'bucket': 'Peak',
        'tradeKind': 'Outright',
      },
      {
        'iso': 'PJM',
        'location': 'WH',
        'strip': 'Cal25',
        'price': 12,
        'tradeDate': '2024-04-01',
        'bucket': 'Offpeak',
        'tradeKind': 'Outright',
      },
      {
        'iso': 'PJM',
        'location': 'WH',
        'strip': 'Cal26',
        'price': 14,
        'tradeDate': '2024-04-02',
        'bucket': 'Offpeak',
        'tradeKind': 'Outright',
      },
      {
        'iso': 'PJM',
        'location': 'BGE',
        'strip': 'Cal24',
        'price': 10,
        'tradeDate': '2024-04-02',
        'bucket': 'Peak',
        'tradeKind': 'Outright',
      },
      {
        'iso': 'PJM',
        'location': 'BGE',
        'strip': 'Cal26',
        'price': 14.3,
        'tradeDate': '2024-04-03',
        'bucket': 'Peak',
        'tradeKind': 'Outright',
      },
      {
        'iso': 'ISONE',
        'location': 'MH',
        'strip': 'Cal24',
        'price': 11,
        'tradeDate': '2024-04-01',
        'bucket': 'Peak',
        'tradeKind': 'Outright',
      },
      {
        'iso': 'NYISO',
        'location': 'ZoneA',
        'strip': 'Cal26',
        'price': 7.3,
        'tradeDate': '2024-04-01',
        'bucket': 'Peak',
        'tradeKind': 'Outright',
      },
      {
        'iso': 'NYISO',
        'location': 'ZoneG',
        'strip': 'Cal24',
        'price': 13,
        'tradeDate': '2024-04-02',
        'bucket': 'Peak',
        'tradeKind': 'Outright',
      },
    ];
  }
  return cache.value;
}

final rows = futureSignal(() async {
  try {
    return getTrades(Term(startDate.value, endDate.value));
  } catch (e) {
    rethrow;
  }
}, dependencies: [
  startDate,
  endDate,
]);

/// All filtering is done functionally (stateless, on the fly) on the entire
/// local cache.
///
/// Function is applied before displaying results, and used to calculate the
/// filter dropdowns on the fly in the computed signals.
/// This setup guarantees that the filter dropdowns are always correct.
///
List<Map<String, dynamic>> filterRows({
  Set<String> isos = const <String>{},
  String tradeKind = 'Outright',
  Set<String> locations = const <String>{},
  Set<String> strips = const <String>{},
  Set<String> buckets = const <String>{},
}) {
  var xs = cache.value.where((e) =>
      e['tradeDate'].compareTo(startDate.toString()) >= 0 &&
      e['tradeDate'].compareTo(endDate.toString()) <= 0);
  if (tradeKind == 'Outright') {
    xs = xs.where((e) => e['tradeKind'] == tradeKind);
  } else {
    throw StateError('Trade kind $tradeKind not implemented yet!');
  }
  if (isos.isNotEmpty) {
    xs = xs.where((e) => isos.contains(e['iso']));
  }
  if (locations.isNotEmpty) {
    xs = xs.where((e) => locations.contains(e['location']));
  }
  if (strips.isNotEmpty) {
    xs = xs.where((e) => strips.contains(e['strip']));
  }
  if (buckets.isNotEmpty) {
    xs = xs.where((e) => buckets.contains(e['bucket']));
  }
  return xs.toList();
}

/// Start, end date filter
final startDate = Date.utc(2024, 4, 1).toSignal();
final startError = signal<String?>(null);
final endDate = Date.today(location: UTC).toSignal();
final endError = signal<String?>(null);

/// Calculate the date range of trades cached.  Need this to be able to decide
/// if the cache needs to be updated.
final cachedTerm = computed(() {
  var start = '1900-01-01';
  var end = '2100-01-01';
  for (var trade in cache) {
    if (trade['tradeDate'].compareTo(start) > 0) end = trade['tradeDate'];
    if (trade['tradeDate'].compareTo(end) < 0) start = trade['tradeDate'];
  }
  return Term(Date.fromIsoString(start), Date.fromIsoString(end));
});

/// ISO filter{
final allIsos = computed(() {
  var isos = filterRows(tradeKind: tradeKind.value)
      .map<String>((e) => e['iso'])
      .toList();
  isos.sort();
  return isos.toSet();
});
// final selectedIsos = {'PJM'}.toSignal();
final selectedIsos = {...allIsos.value}.toSignal();
final labelIsos = computed(() {
  if (allIsos.value.isEmpty) return SelectionState.all.toString();
  if (selectedIsos.isEmpty) return SelectionState.none.toString();
  if (selectedIsos.length == 1) return selectedIsos.first;
  if (allIsos.value.length == selectedIsos.value.length) {
    return SelectionState.all.toString();
  } else {
    return SelectionState.some.toString();
  }
});
final tempSelectionIso = <String>{}.toSignal();

/// Location filter
final allLocations = computed(() {
  var locations =
      filterRows(tradeKind: tradeKind.value, isos: {...selectedIsos.value})
          .map<String>((e) => e['location'])
          .toSet();
  return locations;
});
final selectedLocations = {...allLocations.value}.toSignal();
final labelLocations = computed(() {
  if (allLocations.value.isEmpty) return SelectionState.all.toString();
  if (selectedLocations.isEmpty) return SelectionState.none.toString();
  if (selectedLocations.length == 1) return selectedLocations.first;
  if (allLocations.value.length == selectedLocations.value.length) {
    return SelectionState.all.toString();
  } else {
    return SelectionState.some.toString();
  }
});
final tempSelectionLocation = <String>{}.toSignal();

// Strip filter
final allStrips = computed(() {
  var aux = filterRows(
          tradeKind: tradeKind.value,
          isos: {...selectedIsos.value},
          locations: {...selectedLocations.value})
      .map<String>((e) => e['strip'])
      .toList();
  aux.sort();
  return aux.toSet();
});
final selectedStrips = {...allStrips.value}.toSignal();
final labelStrips = computed(() {
  if (allStrips.value.isEmpty) return SelectionState.all.toString();
  if (selectedStrips.isEmpty) return SelectionState.none.toString();
  if (selectedStrips.length == 1) return selectedStrips.first;
  if (allStrips.value.length == selectedStrips.value.length) {
    return SelectionState.all.toString();
  } else {
    return SelectionState.some.toString();
  }
});
final tempSelectionStrip = <String>{}.toSignal();

// Bucket filter
final allBuckets = computed(() {
  var buckets = filterRows(
          tradeKind: tradeKind.value,
          isos: {...selectedIsos.value},
          locations: {...selectedLocations.value},
          strips: {...selectedStrips.value})
      .map<String>((e) => e['bucket'])
      .toSet();
  return buckets;
});
final selectedBuckets = {...allBuckets.value}.toSignal();
final labelBuckets = computed(() {
  if (allBuckets.value.isEmpty) return SelectionState.all.toString();
  if (selectedBuckets.isEmpty) return SelectionState.none.toString();
  if (selectedBuckets.length == 1) return selectedBuckets.first;
  if (allBuckets.value.length == selectedBuckets.value.length) {
    return SelectionState.all.toString();
  } else {
    return SelectionState.some.toString();
  }
});
final tempSelectionBucket = <String>{}.toSignal();

// Trade kind
final allTradeKinds = ['Outright', 'Spread', 'Option'];
final tradeKind = 'Outright'.toSignal();

// Paginate the trades displayed on the screen
final pageNumber = signal(0);
