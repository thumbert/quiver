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
  final int ptid;
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
          ptid: ptid ?? this.ptid,
          lmpComponent: lmpComponent ?? this.lmpComponent);

  @override
  Future<TimeSeries<num>> get(DataService service, Term term) {
    return service.getLmp(this, term);
  }

  static VariableLmp fromJson(Map<String, dynamic> x) {
    if (x
        case {
          'type': 'VariableLmp',
          'iso': String _iso,
          'market': String _market,
          'ptid': int ptid,
          'lmpComponent': String _lmpComponent,
        }) {
      return VariableLmp(
          iso: Iso.parse(_iso),
          market: Market.parse(_market),
          ptid: ptid,
          lmpComponent: LmpComponent.parse(_lmpComponent));
    } else {
      throw ArgumentError('Input $x is not a correctly formatted VariableLmp');
    }
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'VariableLmp',
      'iso': iso.name,
      'market': market.name,
      'ptid': ptid,
      'lmpComponent': lmpComponent.name,
    };
  }
}
