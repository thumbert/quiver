import 'package:dama/dama.dart';
import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec/ftr.dart';
import 'package:elec/risk_system.dart';
import 'package:elec_server/client/binding_constraints.dart';
import 'package:elec_server/client/lmp.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_quiver/models/historical_lmp_model.dart'
    show LocationRow;
import 'package:signals/signals_flutter.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

final model = signal(FtrPathAnalysisModel.regionDefaults['ISONE']!);

final locations = futureSignal(() async {
  final iso = model.value.iso;
  if (LocationRow.ptidCache[iso.name]!.length < 2) {
    final locations = await LocationRow.getLocations(iso);
    LocationRow.ptidCache[iso.name] = locations;
  }
  return LocationRow.ptidCache[iso.name]!;
}, dependencies: [model]);

/// What to plot
final dailyLmp = futureSignal(() async {
  try {
    var ts = await getLmpData(model.value);
    var dTs = ts
        .where((e) => model.value.bucket.containsHour(e.interval as Hour))
        .toDaily(mean);
    return dTs;
  } catch (e) {
    rethrow;
  }
}, dependencies: [model]);

class FtrPathAnalysisModel {
  FtrPathAnalysisModel(
      {required this.iso,
      required this.sinkLocation,
      required this.sourceLocation,
      required this.bucket,
      required this.market,
      required this.term});

  final Iso iso;
  final String sinkLocation;
  final String sourceLocation;
  final Bucket bucket;
  final Market market;
  final Term term;

  // For ISONE, location is like ".H.INTERNAL_HUB, ptid: 4000"
  static int getPtid(String location) {
    final parts = location.split(', ptid: ');
    if (parts.length != 2) {
      throw ArgumentError('Location string is malformed: $location');
    }
    final ptidStr = parts[1].trim();
    return int.parse(ptidStr);
  }

  static final regionDefaults = <String, FtrPathAnalysisModel>{
    'ISONE': FtrPathAnalysisModel(
        iso: Iso.newEngland,
        sourceLocation: '.H.INTERNAL_HUB, ptid: 4000',
        sinkLocation: '.Z.MAINE, ptid: 4001',
        bucket: Bucket.b5x16,
        market: Market.da,
        term: getDefaultTerm()),
    'NYISO': FtrPathAnalysisModel(
        iso: Iso.newYork,
        sourceLocation: 'Zone A, ptid: 61752',
        sinkLocation: 'Zone G, ptid: 61758',
        bucket: Bucket.b5x16,
        market: Market.da,
        term: getDefaultTerm()),
  };

  static Term getDefaultTerm() {
    final today = Date.today(location: UTC);
    final start = Date.utc(today.year - 2, 1, 1);
    final end = today;
    return Term(start, end);
  }

  final layout = <String, dynamic>{
    'width': 900.0,
    'height': 600.0,
    'margin': {
      't': 10,
      'l': 50,
      'r': 20,
      'b': 50,
      'pad': 4,
    },
    'yaxis': {
      'title': 'Congestion price, \$/MWh',
    },
    'showlegend': false,
    'hovermode': 'closest',
    'displaylogo': false,
  };

  static final cache = <({
    Iso iso,
    String location,
    Market market,
  }),
      TimeSeries<num>>{};
}

// final lmp = Lmp(http.Client(), rustServer: dotenv.env['RUST_SERVER']!);

Future<TimeSeries<num>> getLmpData(FtrPathAnalysisModel model) async {
  final hTerm = Term.fromInterval(
      model.term.interval.withTimeZone(IsoNewEngland.location));

  var sink = (
    iso: model.iso,
    location: model.sinkLocation,
    market: model.market,
  );
  if (!FtrPathAnalysisModel.cache.containsKey(sink)) {
    // var ts = await lmp.getHourlyLmp(
    //     iso: Iso.newEngland,
    //     ptid: FtrPathAnalysisModel.getPtid(model.sinkLocation),
    //     component: LmpComponent.congestion,
    //     term: hTerm,
    //     market: model.market);
    var ts = TimeSeries.fill(hTerm.days(), 0);
    FtrPathAnalysisModel.cache[sink] = ts;
  }
  var sinkTs = FtrPathAnalysisModel.cache[sink]!;

  var source = (
    iso: model.iso,
    location: model.sourceLocation,
    market: model.market,
  );
  if (!FtrPathAnalysisModel.cache.containsKey(source)) {
    // var ts = await lmp.getHourlyLmp(
    //     iso: Iso.newEngland,
    //     ptid: FtrPathAnalysisModel.getPtid(model.sourceLocation),
    //     component: LmpComponent.congestion,
    //     term: hTerm,
    //     market: model.market);
    var ts = TimeSeries.fill(hTerm.days(), 0);
    FtrPathAnalysisModel.cache[source] = ts;
  }
  var sourceTs = FtrPathAnalysisModel.cache[source]!;

  return model.iso == Iso.newYork ? sourceTs - sinkTs : sinkTs - sourceTs;
}

class DataModel extends ChangeNotifier {
  DataModel() {
    _focusTerm = defaultTerm();
  }

  // late Term _term;

  /// what you get from the plotly relayout
  Term? _focusTerm;

  /// Keep track fo the checkboxes on the screen
  Map<String, bool> checkboxesTerm = {
    '2 year': true,
    '1 year': true,
    '6 month': true,
    'monthly': true,
    'monthly bopp': true,
  };

  /// TODO: not implemented yet
  final Map<String, List<String>> checkboxLabels = {
    'ISONE': ['1 year', 'monthly', 'monthly bopp'],
    'NYISO': ['2 year', '1 year', '6 month', 'monthly', 'monthly bopp'],
  };

  FtrPath? _currentFtrPath;

  /// A cache with historical binding constraints for the current path
  var _cacheBindingConstraints = <String, TimeSeries<num>>{};

  /// What gets displayed on the screen after the filtering
  var _tableCpSp = <Map<String, dynamic>>[];
  // bool sortAscendingCpSp = false;

  /// What gets displayed on the screen for binding constraint cost
  var _tableConstraintCost = <Map<String, dynamic>>[];
  bool sortAscendingBc = false;
  String sortColumnBc = 'Cumulative Spread';

  final location = getLocation('America/New_York');
  final layout = <String, dynamic>{
    'width': 900.0,
    'height': 600.0,
    'margin': {
      't': 10,
      'l': 50,
      'r': 20,
      'b': 50,
      'pad': 4,
    },
    'yaxis': {
      'title': 'Congestion price, \$/MWh',
    },
    'showlegend': false,
    'hovermode': 'closest',
    'displaylogo': false,
  };

  /// Get the data and make the Plotly hourly traces.
  ///
  Future<List<Map<String, dynamic>>> makeHourlyTrace(FtrPath ftrPath) async {
    // var sp = await ftrPath.getDailySettlePrices(term: focusTerm);
    // mock the prices for now
    var sp = TimeSeries.fill(
        focusTerm!.days(), ftrPath.sinkPtid - ftrPath.sourcePtid);

    return [
      {
        'x': sp.intervals.map((e) => e.start.toIso8601String()).toList(),
        'y': sp.values.toList(),
        'type': 'bar',
      }
    ];
  }

  /// Prepare the CpSp table for display.
  /// Only pull from the database if the path changes.
  Future<List<Map<String, dynamic>>> getCpSpTable(FtrPath ftrPath) async {
    /// Get the data with Clearing prices and Settled prices.
    /// TODO: should this be cached?
    var _cacheCpSp =
        await ftrPath.makeTableCpSp(fromDate: defaultTerm().startDate);
    Iterable<Map<String, dynamic>> cpsp = [..._cacheCpSp];

    /// Any sorting and filtering here
    if (checkboxesTerm['2 year']! == false) {
      cpsp =
          cpsp.where((e) => (e['auction'] as FtrAuction) is! TwoYearFtrAuction);
    }
    if (checkboxesTerm['1 year']! == false) {
      cpsp =
          cpsp.where((e) => (e['auction'] as FtrAuction) is! AnnualFtrAuction);
    }
    if (checkboxesTerm['6 month']! == false) {
      cpsp = cpsp
          .where((e) => (e['auction'] as FtrAuction) is! SixMonthFtrAuction);
    }
    if (checkboxesTerm['monthly']! == false) {
      cpsp =
          cpsp.where((e) => (e['auction'] as FtrAuction) is! MonthlyFtrAuction);
    }
    if (checkboxesTerm['monthly bopp']! == false) {
      cpsp = cpsp
          .where((e) => (e['auction'] as FtrAuction) is! MonthlyBoppFtrAuction);
    }

    _tableCpSp = cpsp.toList()
      ..sort((a, b) => a['auction'].compareTo(b['auction']));
    return _tableCpSp;
  }

  /// Input [term] can be used to control the constraints table based on the
  /// chart selection.
  Future<List<Map<String, dynamic>>> getRelevantBindingConstraints(
      {required FtrPath ftrPath}) async {
    if (_currentFtrPath == null || _currentFtrPath != ftrPath) {
      /// get the binding constraints for the default term
      var client = BindingConstraints(http.Client(),
          iso: ftrPath.iso, rootUrl: dotenv.env['ROOT_URL']!);
      _cacheBindingConstraints =
          await client.getDaBindingConstraints(defaultTerm().interval);
      _currentFtrPath = ftrPath;
    }

    _focusTerm ??= defaultTerm();

    /// get the relevant constraints
    var aux = await ftrPath.bindingConstraintEffect(focusTerm!,
        bindingConstraints: _cacheBindingConstraints);

    /// sort the table
    var sign = sortAscendingBc ? 1 : -1;
    aux.sort((a, b) =>
        (a[sortColumnBc].abs()).compareTo(b[sortColumnBc].abs()) * sign);
    _tableConstraintCost = aux;
    return _tableConstraintCost;
  }

  List<Map<String, dynamic>> get tableCpSp => _tableCpSp;

  List<Map<String, dynamic>> get tableConstraintCost => _tableConstraintCost;

  set focusTerm(Term? value) {
    _focusTerm = value;
    notifyListeners();
  }

  Term? get focusTerm => _focusTerm;

  void checkboxModified() {
    notifyListeners();
  }

  /// the default historical term to plot
  Term defaultTerm() {
    var now = TZDateTime.now(location);
    var today = TZDateTime(location, now.year, now.month, now.day)
        .add(const Duration(days: 1));
    var start = today.subtract(const Duration(days: 480));
    var interval =
        Interval(TZDateTime(location, start.year, start.month), today);
    return Term.fromInterval(interval);
  }
}
