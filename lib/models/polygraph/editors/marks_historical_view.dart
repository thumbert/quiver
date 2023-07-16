library models.polygraph.editors.marks_historical_strip;

import 'package:date/date.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';

// final providerOfPolygraphCurveNames = FutureProvider<List<String>>((ref) async {
//     await Future.delayed(const Duration(seconds: 2));
//     return MarksHistoricalView.getAllCurveNames();
// });

class MarksHistoricalView extends PolygraphVariable {
  MarksHistoricalView({
    required this.curveName,
    String? label,
    required this.historicalTerm,
    required this.forwardStrip,
  }) {
    this.label = label ?? curveName;
    id = this.label;
  }

  final String curveName;
  final Term historicalTerm;
  final Term forwardStrip;

  static List<String> _allCurveNames = <String>[];

  static Future<List<String>> getAllCurveNames() async {
    if (_allCurveNames.isEmpty) {
      /// TODO: implement the real thing ...
      await Future.delayed(const Duration(seconds: 2));
      _allCurveNames = [
        'OIL_WTI_CME',
        'OIL_HO_CME',
        'NG_HENRY_HUB_CME',
        'NG_TTF_USD_CME',
      ];
    }
    return _allCurveNames;
  }

  static getDefault() {
    var today = Date.today(location: UTC);
    var hTerm = Term(Month.utc(today.year, today.month).subtract(6).startDate, today);
    return MarksHistoricalView(
        curveName: 'NG_HENRY_HUB_CME', historicalTerm: hTerm,
        forwardStrip: Term.parse('Cal24', UTC),
      label: 'HH Cal24',
    );
  }
  // void validate() {
  //   timeAggregation.validate();
  //   error = timeAggregation.error;
  //   print('in horizontal_line validate(), error=$error');
  // }

  Map<String, dynamic> toMap() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  MarksHistoricalView copyWith({String? curveName, String? label, Term? historicalTerm, Term? forwardStrip}) =>
      MarksHistoricalView(
        curveName: curveName ?? this.curveName,
        label: label ?? this.label,
        historicalTerm: historicalTerm ?? this.historicalTerm,
        forwardStrip: forwardStrip ?? this.forwardStrip,
      );

  PolygraphVariable fromMongo(Map<String, dynamic> x) {
    // TODO: implement fromMongo
    throw UnimplementedError();
  }

  @override
  Future<TimeSeries<num>> get(DataService service, Term term) {
    // TODO: implement get
    throw UnimplementedError();
  }
}

class MarksHistoricalViewNotifier extends StateNotifier<MarksHistoricalView> {
  MarksHistoricalViewNotifier(this.ref) : super(MarksHistoricalView.getDefault());

  final Ref ref;

  set curveName(String value) {
    state = state.copyWith(curveName: value);
  }

  set label(String value) {
    state = state.copyWith(label: value);
  }

  set historicalTerm(Term value) {
    state = state.copyWith(historicalTerm: value);
  }

  set forwardStrip(Term value) {
    state = state.copyWith(forwardStrip: value);
  }
}
