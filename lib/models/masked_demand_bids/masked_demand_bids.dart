import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as client;
import 'package:signals_flutter/signals_flutter.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';

final term = signal(getDefaultTerm());
final participant = signal('(All)');
// this checkbox available only when participant is not '(All)'
final byZone = signal(false);
final zoneName = signal('(All)');

final data = futureSignal(() async {
  if (zoneName.value == '(All)') {
    final keys = cache.keys.where((k) => k.zoneName == '(All)');
    if (keys.isNotEmpty) {
      if (participant.value == '(All)') {
        return {for (var k in keys) k: cache[k]!};
      } else {
        final key = (
          maskedParticipantId: getMaskedParticipantId(participant.value),
          zoneName: '(All)'
        );
        return {key: cache[key]!};
      }
    }
    // add all participants to cache
    var aux = await getAggDataByParticipant(term.value);
    cache.addAll(aux);
    return aux;
  }

  if (participant.value != '(All)') {
    // look for the specific participant and zone in cache
    final key = (
      maskedParticipantId: getMaskedParticipantId(participant.value),
      zoneName: zoneName.value
    );
    if (cache.containsKey(key)) {
      return {key: cache[key]!};
    }
    // add all zones for the participant to cache
    var aux = await getZonalDataByParticipant(
        term.value, getMaskedParticipantId(participant.value));
    cache.addAll(aux);
    return aux;
  }
}, options: AsyncSignalOptions(dependencies: [term, participant, zoneName]));

final cache = <({int maskedParticipantId, String zoneName}), TimeSeries<num>>{};

final allParticipants = futureSignal(() async {
  await data.future;
  // get all unique participant ids from cache
  final participantIds = cache.keys
      .where((e) => e.zoneName == '(All)')
      .map((k) => k.maskedParticipantId)
      .toSet();
  // map participant ids to strings
  final out = <String>{'(All)'};
  for (var id in participantIds) {
    out.add('$id: Participant $id');
  }
  return out;
});

List<Map<String, dynamic>> makeTracesByParticipant(
    Map<({int maskedParticipantId, String zoneName}), TimeSeries<num>> data) {
  // calculate total volume for each participant and sort by volume
  var participantVolumes = <int, num>{};
  for (var entry in data.entries) {
    final key = entry.key;
    final ts = entry.value;
    participantVolumes[key.maskedParticipantId] =
        (participantVolumes[key.maskedParticipantId] ?? 0) +
            ts.fold(0, (sum, e) => sum + e.value);
  }
  var sortedParticipants = participantVolumes.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  // take top 30 participants by volume
  var topParticipants = sortedParticipants.take(30).map((e) => e.key).toSet();

  var out = <Map<String, dynamic>>[];
  for (var participantId in topParticipants) {
    final key = (maskedParticipantId: participantId, zoneName: '(All)');
    final ts = data[key]!;
    out.add({
      'x': ts.map((e) => e.interval.start.toString().substring(0, 10)).toList(),
      'y': ts.map((e) => e.value).toList(),
      'name': '${key.maskedParticipantId}',
      'type': 'lines',
    });
  }
  return out;
}

List<Map<String, dynamic>> makeTracesByZone(
    Map<({int maskedParticipantId, String zoneName}), TimeSeries<num>> data) {
  var out = <Map<String, dynamic>>[];
  for (var entry in data.entries) {
    final key = entry.key;
    final ts = entry.value;
    out.add({
      'x': ts.map((e) => e.interval.start.toString().substring(0, 10)).toList(),
      'y': ts.map((e) => e.value).toList(),
      'name': key.zoneName,
      'type': 'lines',
    });
  }
  return out;
}



int getMaskedParticipantId(String participant) {
  final aux = participant.split(':');
  return int.parse(aux[0]);
}

/// Return a timeseries for each zone, for the given term and participant
Future<Map<({int maskedParticipantId, String zoneName}), TimeSeries<num>>>
    getZonalDataByParticipant(Term term, int maskedParticipantId) async {
  final url = '${dotenv.env['RUST_SERVER']}/isone/masked/demand_bids/daily'
      '/load_zone'
      '/start/${term.startDate.toString()}/end/${term.endDate.toString()}'
      '?masked_participant_ids=$maskedParticipantId';
  final response = await client.get(Uri.parse(url));
  if (response.statusCode != 200) {
    throw Exception('Failed to load records: ${response.statusCode}');
  }
  final List<dynamic> jsonList = jsonDecode(response.body);
  final aux = groupBy(jsonList, (json) => json['masked_location_id'] as int);

  final out = <({int maskedParticipantId, String zoneName}), TimeSeries<num>>{};
  for (var entry in aux.entries) {
    final zoneName = maskedIdToZone[entry.key]!;
    entry.value.sort((a, b) => a['day'].compareTo(b['day']));
    final ts = entry.value
        .map((e) => IntervalTuple<num>(
            Date.parse(e['day'], location: IsoNewEngland.location), e['mwh']))
        .toTimeSeries();
    out[(maskedParticipantId: maskedParticipantId, zoneName: zoneName)] = ts;
  }
  return out;
}

/// Return one timeseries for each participant, for the given term
Future<Map<({int maskedParticipantId, String zoneName}), TimeSeries<num>>>
    getAggDataByParticipant(Term term) async {
  final url = '${dotenv.env['RUST_SERVER']}/isone/masked/demand_bids/daily'
      '/load_zone/agg'
      '/start/${term.startDate.toString()}/end/${term.endDate.toString()}';
  final response = await client.get(Uri.parse(url));
  if (response.statusCode != 200) {
    throw Exception('Failed to load records: ${response.statusCode}');
  }
  final List<dynamic> jsonList = jsonDecode(response.body);
  final aux = groupBy(jsonList, (json) => json['masked_participant_id'] as int);

  final out = <({int maskedParticipantId, String zoneName}), TimeSeries<num>>{};
  for (var entry in aux.entries) {
    final maskedParticipantId = entry.key;
    entry.value.sort((a, b) => a['day'].compareTo(b['day']));
    final ts = entry.value
        .map((e) => IntervalTuple<num>(
            Date.parse(e['day'], location: IsoNewEngland.location), e['mwh']))
        .toTimeSeries();
    out[(maskedParticipantId: maskedParticipantId, zoneName: '(All)')] = ts;
  }
  return out;
}

final allZones = <String, int?>{
  '(All)': null,
  'CT': 28934,
  'Maine': 67184,
  'NEMA': 37894,
  'NH': 39271,
  'RI': 89933,
  'SEMA': 70291,
  'VT': 80396,
  'WCMA': 41856,
};

final maskedIdToZone = {
  28934: 'CT',
  67184: 'Maine',
  37894: 'NEMA',
  39271: 'NH',
  89933: 'RI',
  70291: 'SEMA',
  80396: 'VT',
  41856: 'WCMA',
};

/// in UTC
Term getDefaultTerm() {
  final start = Date.utc(2026, 1, 1);
  final monthEnd = Month.containing(Date.today(location: UTC).start);
  return Term(start, monthEnd.subtract(4).endDate);
}

final Map<String, dynamic> layout = {
  'width': 1100,
  'height': 800,
  'title': '',
  'xaxis': {
    'title': '',
    'showgrid': true,
  },
  'yaxis': {
    'showgrid': true,
    'zeroline': false,
    'title': 'MWh',
  },
  'showlegend': true,
  // 'legend': {
  //   'orientation': 'h',
  // },
  'hovermode': 'closest',
  'margin': {
    't': 40,
  },
};
