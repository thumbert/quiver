library models.unmasked_energy_offers.unmasked_energy_offers_model;

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec_server/client/da_energy_offer.dart';
import 'package:elec_server/client/masked_ids.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:timeseries/timeseries.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final providerOfUnmaskedEnergyOffersModel = StateNotifierProvider<
    UnmaskedEnergyOfferNotifier,
    UnmaskedEnergyOffersModel>((ref) => UnmaskedEnergyOfferNotifier(ref));

final providerOfUnmaskedAssets = FutureProvider.family<List<Map<String, dynamic>>, Iso>((ref, iso) async {
  await UnmaskedEnergyOffersModel.getMaskedAssetIds(iso);
  return UnmaskedEnergyOffersModel.assetData;
});

class UnmaskedEnergyOffersModel {
  UnmaskedEnergyOffersModel(
      {required this.term, required this.iso, required this.selectedAssets}) {
    _api = DaEnergyOffers(client, iso: iso, rootUrl: dotenv.env['ROOT_URL']!);
  }

  final Term term;
  final Iso iso;
  final List<String?> selectedAssets;

  late final DaEnergyOffers _api;

  static final defaultAssets = {
    Iso.newEngland: ['KLEEN ENERGY', null, null, null, null],
    Iso.newYork: ['Ravenswood ST 03'],
  };

  final client = Client();

  /// A map from term -> ptid -> Energy Offers for the assets clicked.
  static Map<Term, Map<int, List<Map<String, dynamic>>>> cache =
      <Term, Map<int, List<Map<String, dynamic>>>>{};

  /// Each element has this form
  /// ```
  /// {
  ///   'Masked Asset ID': 77459,
  ///   'ptid': 14614,
  ///   'name': 'KLEEN ENERGY',
  /// },
  /// ```
  static List<Map<String, dynamic>> assetData = <Map<String, dynamic>>[];

  /// Called in the initState() method
  static Future<void> getMaskedAssetIds(Iso iso) async {
    var _maskedAssetsApi =
        MaskedIds(Client(), iso: iso, rootUrl: dotenv.env['ROOT_URL']!);
    var aux = await _maskedAssetsApi.getAssets(type: 'generator');
    aux.sort((a,b) => a['name'].compareTo(b['name']));
    assetData = aux;
  }

  /// Make the line traces for Plotly.  Update cache if needed.
  ///
  Future<List<Map<String, dynamic>>> makeTraces() async {
    if (!cache.containsKey(term)) {
      cache[term] = <int, List<Map<String, dynamic>>>{};
    }

    /// get the data if not in cache already
    var ptids = assetData
        .where((e) => selectedAssets.contains(e['name']))
        .map((e) => e['ptid'] as int)
        .toList();
    for (var ptid in ptids) {
      if (!cache[term]!.containsKey(ptid)) {
        // print('loading ptid: $ptid');
        var asset = assetData.firstWhere((e) => e['ptid'] == ptid);
        cache[term]![ptid] = await _api.getDaEnergyOffersForAsset(
            asset['Masked Asset ID'], term.startDate, term.endDate);
      }
    }
    // print('selected ptids: $ptids');
    // print('ptids in cache: ${cache[term]!.keys}');
    List<Map<String, dynamic>> out;
    if (ptids.length == 1) {
      /// Display all energy offers
      out = _makeTracesOneUnit(ptids.first);
    } else {
      /// Display the volume weighted energy offers
      out = _makeTracesAllUnits(ptids);
    }
    return out;
  }

  final layout = {
    'width': 900,
    'height':600,
    'title': 'Energy offer prices',
    'xaxis': {
      'showgrid': true,
      'gridcolor': '#bdbdbd',
    },
    'yaxis': {
      'showgrid': true,
      'gridcolor': '#bdbdbd',
      'zeroline': false,
      'title': 'Energy offers, \$/Mwh',
    },
    'margin': {
      't': 40,
    },
    'showlegend': true,
    'hovermode': 'closest',
  };

  List<Map<String, dynamic>> _makeTracesOneUnit(int ptid) {
    var hData = cache[term]![ptid]!;
    var series = priceQuantityOffers(hData, iso: iso);

    // create the indicator series, to populate all hours
    // missing data for unavailable units will show up as null
    var hours = term.interval.splitLeft((dt) => Hour.beginning(dt));
    var ts = TimeSeries.fill(hours, null);

    var out = <Map<String, dynamic>>[];
    for (var i = 0; i < series.length; i++) {
      var aux = ts.merge(series[i], joinType: JoinType.Left, f: (x, dynamic y) {
        y ??= {};
        return y;
      });
      var x = [];
      var price = [];
      var text = [];
      for (var e in aux) {
        x.add(e.interval.start);
        price.add(e.value['price']);
        text.add('MW: ${e.value['quantity']}');
      }
      out.add({
        'x': x,
        'y': price,
        'text': text,
        'name': 'price $i',
        'mode': 'lines',
        'line': {
          'width': 2,
        },
      });
    }
    return out;
  }

  List<Map<String, dynamic>> _makeTracesAllUnits(List<int> ptids) {
    var series = <int, TimeSeries>{};
    for (var ptid in ptids) {
      if (cache[term]!.containsKey(ptid) && cache[term]![ptid]!.isNotEmpty) {
        var aux = priceQuantityOffers(cache[term]![ptid]!, iso: iso);
        series[ptid] = averageOfferPrice(aux);
      }
    }

    // create the indicator series, to populate all hours
    // missing data for unavailable units will show up as null
    var hours = term.interval.splitLeft((dt) => Hour.beginning(dt));
    var ts = TimeSeries.fill(hours, null);

    var out = <Map<String, dynamic>>[];
    for (var id in series.keys) {
      var aux =
          ts.merge(series[id]!, joinType: JoinType.Left, f: (x, dynamic y) {
        y ??= {};
        return y;
      });
      var x = [];
      var price = [];
      var text = [];
      for (var e in aux) {
        x.add(e.interval.start);
        price.add(e.value['price']);
        text.add('MW: ${e.value['quantity']}');
      }

      out.add({
        'x': x,
        'y': price,
        'text': text,
        'name': assetData.firstWhere((e) => e['ptid'] == id)['name'],
        'mode': 'lines',
        'line': {
          'width': 2,
        },
      });
    }
    return out;
  }

  static UnmaskedEnergyOffersModel getDefault() => UnmaskedEnergyOffersModel(
        term: Term.parse('Apr18', IsoNewEngland.location),
        iso: Iso.newEngland,
        selectedAssets:
            UnmaskedEnergyOffersModel.defaultAssets[Iso.newEngland]!,
      );

  UnmaskedEnergyOffersModel copyWith({
    Term? term,
    Iso? iso,
    List<String?>? selectedAssets,
  }) {
    return UnmaskedEnergyOffersModel(
      term: term ?? this.term,
      iso: iso ?? this.iso,
      selectedAssets: selectedAssets ?? this.selectedAssets,
    );
  }
}

class UnmaskedEnergyOfferNotifier
    extends StateNotifier<UnmaskedEnergyOffersModel> {
  UnmaskedEnergyOfferNotifier(this.ref)
      : super(UnmaskedEnergyOffersModel.getDefault());

  final Ref ref;

  set term(Term value) {
    state = state.copyWith(term: value);
  }

  set iso(Iso iso) {
    UnmaskedEnergyOffersModel.assetData.clear();
    UnmaskedEnergyOffersModel.cache.clear();
    state = state.copyWith(
        iso: iso, selectedAssets: UnmaskedEnergyOffersModel.defaultAssets[iso]);
  }

  set selectedAssets(List<String?> values) {
    state = state.copyWith(selectedAssets: values);
  }
}
