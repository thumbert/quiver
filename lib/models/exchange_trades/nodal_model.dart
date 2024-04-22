library models.exchange_trades.nodal_model;

import 'package:date/date.dart';
import 'package:flutter_quiver/screens/common/signal/multiselect.dart';
import 'package:signals/signals_flutter.dart';
import 'package:timezone/timezone.dart';

final cache = <Map<String, dynamic>>[].toSignal();

/// Trades comes from a Db or from the cache if they're already there
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
  var trades = [
    ...cache.where((e) =>
        e['tradeDate'].compareTo(term.startDate.toString()) >= 0 &&
        e['tradeDate'].compareTo(term.endDate.toString()) <= 0)
  ];
  return trades;
}

/// Filter only the trades that will be displayed
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

/// Apply this function before displaying results
List<Map<String, dynamic>> filterRows(Iterable<Map<String, dynamic>> xs) {
  if (selectedIsos.isNotEmpty) {
    xs = xs.where((e) => selectedIsos.contains(e['iso']));
  }
  if (selectedLocations.isNotEmpty) {
    xs = xs.where((e) => selectedLocations.contains(e['location']));
  }
  if (selectedStrips.isNotEmpty) {
    xs = xs.where((e) => selectedStrips.contains(e['strip']));
  }
  if (selectedBuckets.isNotEmpty) {
    xs = xs.where((e) => selectedBuckets.contains(e['bucket']));
  }
  xs = xs.where((e) => e['tradeKind'] == tradeKind.value);
  return xs.toList();
}

/// Start, end date filter
// final startDate = Date.today(location: UTC).subtract(10).toSignal();
final startDate = Date.utc(2024, 4, 1).toSignal();
final startError = signal<String?>(null);
final endDate = Date.today(location: UTC).toSignal();
final endError = signal<String?>(null);
// calculate the date range of trades cached
final cachedTerm = computed(() {
  var start = '1900-01-01';
  var end = '2100-01-01';
  for (var trade in cache) {
    if (trade['tradeDate'].compareTo(start) > 0) end = trade['tradeDate'];
    if (trade['tradeDate'].compareTo(end) < 0) start = trade['tradeDate'];
  }
  // print('start: $start, end: $end');
  return Term(Date.fromIsoString(start), Date.fromIsoString(end));
});

/// ISO filter
final allIsos = computed(() => cache.map<String>((e) => e['iso']).toSet());
final selectedIsos = {'PJM'}.toSignal();
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
  return cache.value
      .where((e) => selectedIsos.value.contains(e['iso']))
      .map<String>((e) => e['location'])
      .toSet();
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
  return cache.value
      .where((e) => selectedIsos.value.contains(e['iso']))
      .where((e) => selectedLocations.value.contains(e['location']))
      .map<String>((e) => e['strip'])
      .toSet();
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
  return cache.value
      .where((e) => selectedIsos.value.contains(e['iso']))
      .where((e) => selectedLocations.value.contains(e['location']))
      .where((e) => selectedStrips.value.contains(e['strip']))
      .map<String>((e) => e['bucket'])
      .toSet();
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

final updateRows = effect(() {
  // if (regions.value != regions.previousValue) {
  //   var newLocations = {
  //     ...regions.value
  //         .expand((region) => mappedLocations[region]!)
  //   };
  //   if (newLocations.isEmpty) {
  //     newLocations =
  //         getDefaultRows().map((e) => e.location.value).toSet();
  //   }
  //   var newRows = <RowId>[];
  //   for (var location in newLocations) {
  //     newRows.add((location: signal(location), index: signal('Gas Daily')));
  //   }
  //   rows.value = [...newRows];
  // }
});

/// What to plot
// final traces = futureSignal(() async {
// //   if (!cacheTerm.interval.containsInterval(termSignal.value.interval)) {
// //     cache.clear();
// //     cacheTerm = termSignal.value;
// //   }
// //   try {
// //     await getData(termSignal.value, rows.value);
// //   } catch (e) {
// //     rethrow;
// //   }
//   await Future.delayed(Duration(seconds: 1));
//   return makeTraces(rows.value);
// }, dependencies: [
//   startDate,
//   endDate,
//   selectedIsos,
//   selectedLocations,
//   selectedStrips,
//   rows,
// ]);

List<Map<String, dynamic>> makeTraces(List<Map<String, dynamic>> rows) {
  var out = <Map<String, dynamic>>[];
  // for (var i = 0; i < rows.length; i++) {
  //   var t2 = (location: rows[i].location.value, index: rows[i].index.value);
  //   var ts = cache[t2]!.window(term.interval);
  //   out.add({
  //     'x': ts.map((e) => e.interval.start.toString().substring(0, 10)).toList(),
  //     'y': ts.map((e) => e.value),
  //     'name': '${rows[i].location}_${rows[i].index}',
  //     'type': 'lines',
  //   });
  // }
  return out;
}

final Map<String, dynamic> layout = {
  'width': 900,
  'height': 600,
  'title': '',
  'xaxis': {
    'title': '',
    'showgrid': true,
  },
  'yaxis': {
    'showgrid': true,
    'zeroline': false,
    'title': 'Price, \$/MMBtu',
  },
  'showlegend': true,
  'legend': {
    'orientation': 'h',
  },
  'hovermode': 'closest',
  'margin': {
    't': 40,
  },
};
