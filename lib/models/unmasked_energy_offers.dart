library models.unmasked_energy_offers_model;

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:elec_server/client/da_energy_offer.dart';
import 'package:elec_server/client/masked_ids.dart';
import 'package:http/http.dart';
import 'package:collection/collection.dart';
import 'package:timeseries/timeseries.dart';

class UnmaskedEnergyOffersModel extends ChangeNotifier {
  UnmaskedEnergyOffersModel() {
    rootUrl = dotenv.env['ROOT_URL']!;
    _iso = Iso.newEngland;
    api = DaEnergyOffers(_client, iso: Iso.newEngland, rootUrl: rootUrl);
    maskedAssetsApi = MaskedIds(_client, iso: Iso.newEngland, rootUrl: rootUrl);
  }

  final _client = Client();
  late final String rootUrl;
  late DaEnergyOffers api;
  late MaskedIds maskedAssetsApi;
  late Iso _iso;

  late List<bool> checkboxes;

  /// A map from term -> ptid -> Energy Offers for the assets clicked.
  var cache = <Term, Map<int, List<Map<String, dynamic>>>>{};

  /// Each element has this form
  /// ```
  /// {
  ///   'Masked Asset ID': 77459,
  ///   'ptid': 14614,
  ///   'name': 'KLEEN ENERGY',
  /// },
  /// ```
  var assetData = <Map<String, dynamic>>[];

  set iso(Iso value) {
    _iso = value;
    // reassign Apis
    api = DaEnergyOffers(_client, iso: _iso, rootUrl: rootUrl);
    maskedAssetsApi = MaskedIds(_client, iso: _iso, rootUrl: rootUrl);
    cache.clear();
    deselectAll();
    getMaskedAssetIds();
    // notifyListeners();
  }

  Iso get iso => _iso;

  /// Called in the initState() method
  Future<void> getMaskedAssetIds() async {
    assetData = await maskedAssetsApi.getAssets(type: 'generator');
    checkboxes = List.filled(assetData.length, false);
    late int index;
    if (iso == Iso.newEngland) {
      // select Kleen on init
      index = assetData.indexWhere((e) => e['name'] == 'KLEEN ENERGY');
    } else if (iso == Iso.newYork) {
      // select Ravenswood on init
      index = assetData.indexWhere((e) => e['name'] == 'Ravenswood ST 03');
    }
    checkboxes[index] = true;
    notifyListeners();
  }

  void clickCheckbox(int index) {
    checkboxes[index] = !checkboxes[index];
    notifyListeners();
  }

  void deselectAll() {
    checkboxes = List.filled(assetData.length, false);
  }

  /// Get a list of assets selected (checkbox clicked)
  List<Map<String, dynamic>> assetsSelected() =>
      assetData.whereIndexed((index, e) => checkboxes[index]).toList();

  /// Make the line traces for Plotly.  Update cache if needed.
  ///
  Future<List<Map<String, dynamic>>> makeTraces(Term term) async {
    // print('in makeTraces, iso: $iso');

    // make sure that the term is in the right tz!  A constant headache
    var _interval = term.interval.withTimeZone(iso.preferredTimeZoneLocation);
    term = Term.fromInterval(_interval);
    // print(cache.keys);
    if (!cache.containsKey(term)) {
      cache[term] = <int, List<Map<String, dynamic>>>{};
    }

    /// get the data if not in cache already
    var assets = assetsSelected();
    var ptids = assetsSelected().map((e) => e['ptid'] as int).toList();
    for (var asset in assets) {
      if (!cache[term]!.containsKey(asset['ptid'])) {
        cache[term]![asset['ptid']] = await api.getDaEnergyOffersForAsset(
            asset['Masked Asset ID'], term.startDate, term.endDate);
      }
    }
    // print('selected ptids: $ptids');
    // print('ptids in cache: ${cache[term]!.keys}');
    List<Map<String, dynamic>> out;
    if (ptids.length == 1) {
      /// Display all energy offers
      out = _makeTracesOneUnit(term, ptids.first);
    } else {
      /// Display the volume weighted energy offers
      out = _makeTracesAllUnits(term, ptids);
    }
    return out;
  }

  final layout = {
    'width': 750,
    'height': 550,
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
    'showlegend': true,
    'hovermode': 'closest',
  };

  List<Map<String, dynamic>> _makeTracesOneUnit(Term term, int ptid) {
    var hData = cache[term]![ptid]!;
    var series = priceQuantityOffers(hData, iso: _iso);

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

  List<Map<String, dynamic>> _makeTracesAllUnits(Term term, List<int> ptids) {
    var series = <int, TimeSeries>{};
    for (var ptid in ptids) {
      if (cache[term]!.containsKey(ptid) && cache[term]![ptid]!.isNotEmpty) {
        var aux = priceQuantityOffers(cache[term]![ptid]!, iso: _iso);
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
}
