library models.polygraph.editors.marks_asof;

import 'package:date/date.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_filter.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';

class MarksAsof extends PolygraphVariable {
  MarksAsof({
    required this.asOfDate,
    String? label,
    required this.curveName,
  }) {
    this.label = label ?? curveName;
  }
  
  final Date asOfDate;
  final String curveName;

  static getDefault() => MarksAsof(
      asOfDate: Date.utc(2023, 7, 7),
      label: 'Henry',
      curveName: 'NG_HENRY_HUB_CME',
      );

  void validate() {}

  Map<String, dynamic> toMap() {
    // TODO: implement toJson
    throw UnimplementedError();
  }

  MarksAsof copyWith(
      {Date? asOfDate,
        String? curveName,
        String? label,
      }) =>
      MarksAsof(
          asOfDate: asOfDate ?? this.asOfDate,
          label: label ?? this.label,
          curveName: curveName ?? this.curveName,
      );

  PolygraphVariable fromMongo(Map<String,dynamic> x) {
    // TODO: implement fromMongo
    throw UnimplementedError();
  }

  @override
  Future<TimeSeries<num>> get(DataService service, Term term) {
    // TODO: implement get
    throw UnimplementedError();
  }
}

class MarksAsofNotifier extends StateNotifier<MarksAsof> {
  MarksAsofNotifier(this.ref) : super(MarksAsof.getDefault());

  final Ref ref;

  set asOfDate(Date value) {
    state = state.copyWith(asOfDate: value);
  }

  set curveName(String value) {
    state = state.copyWith(curveName: value);
  }

  set label(String value) {
    state = state.copyWith(label: value);
  }
}
