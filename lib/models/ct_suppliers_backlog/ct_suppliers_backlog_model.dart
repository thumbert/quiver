library models.unmasked_energy_offers.unmasked_energy_offers_model;

import 'package:collection/collection.dart';
import 'package:dama/dama.dart';
import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec_server/client/utilities/ct_supplier_backlog_rates.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timezone/timezone.dart';

final providerOfCtSuppliersBacklogModel =
    StateNotifierProvider<CtSupplierBacklogNotifier, CtSuppliersBacklogModel>(
        (ref) => CtSupplierBacklogNotifier(ref));

final providerOfCtSuppliersBacklogData = FutureProvider.family<List<Map<String,dynamic>>, Term>((ref, term) async {
  var model = ref.read(providerOfCtSuppliersBacklogModel);
  await CtSuppliersBacklogModel.getData(term, model.utility);
  return CtSuppliersBacklogModel.cache[model.utility] ??
      <Map<String, dynamic>>[];
});

class CtSuppliersBacklogModel {
  CtSuppliersBacklogModel({
    required this.term,
    required this.utility,
    required this.customerClass,
    required this.selectedSuppliers,
    required this.variableName,
    required this.aggregate,
  });

  final Term term;
  final Utility utility;
  final String customerClass;
  Set<String> selectedSuppliers;
  bool aggregate = false;

  /// what to plot, e.g. 'Customer count'
  final String variableName;

  static final client = Client();
  final variableNames = const {
    'Customer count': 'customerCount',
    'Average price weighted by customer count':
        'averagePriceWeightedByCustomerCount',
    'KWh': 'kWh',
    'Average price weighted by volume': 'averagePriceWeightedByVolume',
  };

  static Map<Utility, List<Map<String, dynamic>>> cache =
      <Utility, List<Map<String, dynamic>>>{
    Utility.eversource: <Map<String, dynamic>>[],
    Utility.ui: <Map<String, dynamic>>[],
  };

  /// Including '(All)'
  Set<String> getAllSupplierNames() {
    if (cache[utility]!.isEmpty) {
      return {'(All)'};
    }
    var aux = cache[utility]!
        .map((e) => e['supplierName'])
        .toSet()
        .toList()
        .cast<String>();
    aux.sort();
    return {'(All)', ...aux};
  }

  List<String> getCustomerClasses() {
    if (cache[utility]!.isEmpty) {
      return [customerClass];
    }
    var aux = cache[utility]!
        .map((e) => e['customerClass'])
        .toSet()
        .toList()
        .cast<String>();
    aux.sort();
    return aux;
  }

  ///
  static Future<List<Map<String, dynamic>>> getData(
      Term? term, Utility utility) async {
    cache[utility]!.clear();
    var _api = CtSupplierBacklogRates(client, rootUrl: dotenv.env['ROOT_URL']!);
    if (term == null) {
      var start = Month.utc(2022, 1).startDate;
      var end = Month.current(location: UTC).startDate.previous;
      term = Term(start, end);
    }
    var start = Month.containing(term.startDate.start);
    var end = Month.containing(term.endDate.start);
    var aux = await _api.getBacklogForUtility(
        utility: utility, start: start, end: end);
    cache[utility]!.addAll(aux);
    return cache[utility]!;
  }

  /// Make the line traces for Plotly.  Update cache if needed.
  ///
  Future<List<Map<String, dynamic>>> makeTraces() async {
    var data =
        cache[utility]!.where((e) => e['customerClass'] == customerClass);
    if (selectedSuppliers.first != '(All)') {
      data = data.where((e) => selectedSuppliers.contains(e['supplierName']));
    }

    var fieldName = variableNames[variableName];
    var traces = <Map<String, dynamic>>[];

    if (aggregate) {
      var byMonth = groupBy(data, (e) => e['month']);
      var xs = byMonth.entries
          .where((entry) => entry.value.first['summary'][fieldName] != null)
          .map((entry) => [
                entry.key,
                sum(entry.value
                    .where((e) => e['summary'][fieldName] != null)
                    .map((e) => e['summary'][fieldName] ?? 0))
              ])
          .toList();
      xs.sort((a, b) => a[0].compareTo(b[0]));
      traces.add({
        'x': xs.map((e) => e[0]).toList(),
        'y': xs.map((e) => e[1]).toList(),
        'mode': 'lines+markers',
        'text': '(All)',
        'name': 'Aggregate',
      });
    } else {
      /// split the data by supplier
      var groups = groupBy(data, (e) => e['supplierName']);
      for (var supplierName in groups.keys) {
        var xs = groups[supplierName]!;
        traces.add({
          'x': xs.map((e) => e['month']).toList(),
          'y': xs.map((e) => e['summary'][fieldName]).toList(),
          'name': supplierName,
          'mode': 'lines+markers',
          'text': supplierName,
        });
      }
    }

    return traces;
  }

  String getSupplierDropdownLabel() {
    if (selectedSuppliers.isEmpty) return '(None)';
    if (!selectedSuppliers.contains('(All)')) {
      return '(Some)';
    } else {
      return '(All)';
    }
  }

  void addSupplier(String value) {
    if (value == '(All)') {
      selectedSuppliers = getAllSupplierNames();
    } else {
      selectedSuppliers.add(value);
    }
  }

  void removeSupplier(String value) {
    if (value == '(All)') {
      selectedSuppliers.clear();
    } else {
      selectedSuppliers.remove(value);
      selectedSuppliers.remove('(All)');
    }
  }

  Map<String, dynamic> getLayout() {
    return {
      'width': 1200,
      'height': 700,
      'xaxis': {
        'showgrid': true,
        'gridcolor': '#bdbdbd',
      },
      'yaxis': {
        'showgrid': true,
        'gridcolor': '#bdbdbd',
        'zeroline': false,
        'title': variableName,
      },
      'margin': {
        't': 40,
      },
      'showlegend': true,
      'hovermode': 'closest',
    };
  }

  static CtSuppliersBacklogModel getDefault() {
    var start = Month(2022, 1, location: IsoNewEngland.location);
    var end = Month.current(location: IsoNewEngland.location).previous;
    return CtSuppliersBacklogModel(
      term: Term(start.startDate, end.endDate),
      utility: Utility.eversource,
      customerClass: 'Residential',
      selectedSuppliers: {'(All)'},
      variableName: 'Customer count',
      aggregate: false,
    );
  } 
  
  CtSuppliersBacklogModel copyWith({
    Term? term,
    Utility? utility,
    String? customerClass,
    Set<String>? selectedSuppliers,
    String? variableName,
    bool? aggregate,
  }) {
    return CtSuppliersBacklogModel(
      term: term ?? this.term,
      utility: utility ?? this.utility,
      customerClass: customerClass ?? this.customerClass,
      selectedSuppliers: selectedSuppliers ?? this.selectedSuppliers,
      variableName: variableName ?? this.variableName,
      aggregate: aggregate ?? this.aggregate,
    );
  }
}

class CtSupplierBacklogNotifier extends StateNotifier<CtSuppliersBacklogModel> {
  CtSupplierBacklogNotifier(this.ref)
      : super(CtSuppliersBacklogModel.getDefault());

  final Ref ref;

  set term(Term value) {
    state = state.copyWith(term: value);
  }

  set utility(Utility value) {
    state = state.copyWith(utility: value);
  }

  set customerClass(String value) {
    state = state.copyWith(customerClass: value);
  }

  set addSupplier(String value) {
    state = state.copyWith(selectedSuppliers: state.selectedSuppliers);
    state.addSupplier(value);
  }

  set removeSupplier(String value) {
    state = state.copyWith(selectedSuppliers: state.selectedSuppliers);
    state.removeSupplier(value);
  }

  set variableName(String value) {
    state = state.copyWith(variableName: value);
  }

  set aggregate(bool value) {
    state = state.copyWith(aggregate: value);
  }
}
