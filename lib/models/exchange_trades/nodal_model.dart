library models.exchange_trades.nodal_model;

import 'package:date/date.dart';
import 'package:signals/signals_flutter.dart';
import 'package:timezone/timezone.dart';

final cache = <Map<String, dynamic>>[].toSignal();

/// Trades comes from a Db or from the cache if they're already there.
/// Keep this function separated from the rows signal to allow for better
/// testing.
Future<List<Map<String, dynamic>>> getTrades(Term term) async {
  await Future.delayed(const Duration(milliseconds: 2000));
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
], debugLabel: 'rows');

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
final startDate = Date.utc(2024, 4, 1).asSignal();
final startError = signal<String?>(null);
final endDate = Date.today(location: UTC).asSignal();
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
}, debugLabel: 'cachedTerm');

//
final getAllIsos = futureSignal(() async {
  await rows.future;
  var isos = filterRows(tradeKind: tradeKind.value)
      .map<String>((e) => e['iso'])
      .toList();
  isos.sort();
  return isos.toSet();
});
final isos = ListSignal(<String>['PJM'], debugLabel: 'isos');

//
final getAllLocations = futureSignal(() async {
  await rows.future;
  var locations = filterRows(tradeKind: tradeKind.value)
      .map<String>((e) => e['location'])
      .toList();
  locations.sort();
  return locations.toSet();
});
final locations = ListSignal(<String>[], debugLabel: 'locations');

//
final getAllStrips = futureSignal(() async {
  await rows.future;
  var strips = filterRows(tradeKind: tradeKind.value)
      .map<String>((e) => e['strip'])
      .toList();
  strips.sort();
  return strips.toSet();
});
final strips = ListSignal(<String>[], debugLabel: 'strips');

//
final getAllBuckets = futureSignal(() async {
  await rows.future;
  var strips = filterRows(tradeKind: tradeKind.value)
      .map<String>((e) => e['bucket'])
      .toList();
  strips.sort();
  return strips.toSet();
});
final buckets = ListSignal(<String>[], debugLabel: 'buckets');

// Trade kind
final allTradeKinds = ['Outright', 'Spread', 'Option'];
final tradeKind = 'Outright'.asSignal();

// Paginate the trades displayed on the screen
final pageNumber = signal(0);
