library models.polygraph.variables.forward_heatrate_variable;

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_quiver/models/polygraph/variables/forward_electricity_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/forward_gas_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:timeseries/src/timeseries_base.dart';

class ForwardHeatRateVariable extends Object with PolygraphVariable {
  ForwardHeatRateVariable({
    required this.electricityVariable,
    required this.gasVariable,
  }) {
    name = 'Heat Rate (Forward)';
    label = _makeLabel();
  }

  ForwardElectricityVariable electricityVariable;
  ForwardGasVariable gasVariable;

  String? givenLabel;

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }

  String _makeLabel() {
    var out = 'Forward Heatrate ${electricityVariable.deliveryPoint}';
    if (givenLabel != null) return givenLabel!;

    var eName = electricityVariable.deliveryPoint;
    if (ForwardElectricityVariable.shortNames.containsKey(electricityVariable.deliveryPoint)) {
      eName = ForwardElectricityVariable.shortNames[electricityVariable.deliveryPoint]!;
     }

    out = 'Forward Heat Rate $eName ${electricityVariable.bucket.toString()} '
        'vs. ${gasVariable.deliveryPoint}';
    return out;
  }

  @override
  TimeSeries<num> timeSeries(Term term) {
    // TODO: implement timeSeries
    throw UnimplementedError();
  }
}
