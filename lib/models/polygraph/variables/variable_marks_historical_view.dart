library models.polygraph.variables.variable_marks_historical_view;

import 'package:date/date.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service.dart';
import 'package:flutter_quiver/models/polygraph/display/variable_display_config.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';

// final providerOfPolygraphCurveNames = FutureProvider<List<String>>((ref) async {
//     await Future.delayed(const Duration(seconds: 2));
//     return MarksHistoricalView.getAllCurveNames();
// });

class VariableMarksHistoricalView extends PolygraphVariable {
  VariableMarksHistoricalView({
    required this.curveName,
    String? label,
    required this.forwardStrip,
  }) {
    this.label = label ?? curveName;
  }

  final String curveName;

  /// in UTC
  final Term forwardStrip;
  String errorForwardStrip = '';

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

  bool hasInvalidLabel() => label == '';

  bool hasWrongForwardStrip() => errorForwardStrip != '';

  List<String> getErrors() {
    return [
      if (hasInvalidLabel()) 'Label can\'t be empty',
      if (hasWrongForwardStrip()) 'Error parsing Forward strip',
    ];
  }

  static getDefault() {
    return VariableMarksHistoricalView(
      curveName: 'NG_HENRY_HUB_CME',
      forwardStrip: Term.parse('Cal24', UTC),
      label: 'HH Cal24',
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'VariableMarksHistoricalView',
      'label': label,
      'curveName': curveName,
      'forwardStrip': forwardStrip.toString(),
      'displayConfig':
          displayConfig == null ? <String, dynamic>{} : displayConfig!.toJson(),
    };
  }

  VariableMarksHistoricalView copyWith(
          {String? curveName, String? label, Term? forwardStrip, String? error}) =>
      VariableMarksHistoricalView(
        curveName: curveName ?? this.curveName,
        label: label ?? this.label,
        forwardStrip: forwardStrip ?? this.forwardStrip,
      )..error = error ?? this.error;

  static VariableMarksHistoricalView fromMongo(Map<String, dynamic> x) {
    if (x['type'] != 'VariableMarksHistoricalView') {
      throw ArgumentError('Input doesn\'t have type TransformedVariable');
    }
    if (x
        case {
          'curveName': String curveName,
          'label': String label,
          'forwardStrip': String forwardStrip,
          'displayConfig': Map<String, dynamic> displayConfig,
        }) {
      var config = VariableDisplayConfig.fromMongo(displayConfig);
      return VariableMarksHistoricalView(
        curveName: curveName,
        label: label,
        forwardStrip: Term.parse(forwardStrip, UTC),
      )..displayConfig = config;
    } else {
      throw ArgumentError(
          'Input is not a correctly formatted VariableMarksHistoricalView');
    }
  }

  @override
  Future<TimeSeries<num>> get(DataService service, Term term) {
    return service.getMarksHistoricalView(this, term);
  }
}

class VariableMarksHistoricalViewNotifier
    extends StateNotifier<VariableMarksHistoricalView> {
  VariableMarksHistoricalViewNotifier(this.ref)
      : super(VariableMarksHistoricalView.getDefault());

  final Ref ref;

  set curveName(String value) {
    state = state.copyWith(curveName: value);
  }

  set label(String value) {
    state = state.copyWith(label: value);
  }

  set forwardStrip(Term value) {
    state = state.copyWith(forwardStrip: value);
  }

  set error(String value) {
    state = state.copyWith(error: value);
  }

  void fromMongo(Map<String,dynamic> x) {
    state = VariableMarksHistoricalView.fromMongo(x);
  }

  void reset() {
    state = VariableMarksHistoricalView.getDefault();
  }


}

