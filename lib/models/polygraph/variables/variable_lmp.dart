library models.polygraph.variables.variable_lmp;

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec/risk_system.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:timeseries/timeseries.dart';

class VariableLmp extends PolygraphVariable {
  VariableLmp({
    required this.iso,
    required this.market,
    required this.ptid,
    required this.lmpComponent,
  });

  /// For example, Iso.newEngland
  final Iso iso;

  /// For example, Market.da
  final Market market;

  /// One of 'min', 'max', 'mean'
  final int ptid;

  /// One of 'day' or 'hour'
  final LmpComponent lmpComponent;

  VariableLmp copyWith({
    Iso? iso,
    Market? market,
    int? ptid,
    LmpComponent? lmpComponent,
  }) =>
      VariableLmp(
          iso: iso ?? this.iso,
          market: market ?? this.market,
          ptid:  ptid ?? this.ptid,
          lmpComponent: lmpComponent ?? this.lmpComponent);

  @override
  Future<TimeSeries<num>> get(DataService service, Term term) {
    return service.getLmp(this, term);
  }

  @override
  VariableLmp fromMongo(Map<String,dynamic> x) {
    // TODO: implement fromMongo
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toMongo() {
    // TODO: implement toMongo
    throw UnimplementedError();
  }
}
