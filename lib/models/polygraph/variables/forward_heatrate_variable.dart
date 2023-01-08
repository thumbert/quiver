library models.polygraph.variables.forward_heatrate_variable;

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_quiver/models/polygraph/variables/forward_electricity_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/forward_gas_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';

class ForwardHeatRateVariable extends Object with PolygraphVariable {
  ForwardHeatRateVariable({
    required this.electricityVariable,
    required this.gasVariable,
  }) {
    name = 'Heat Rate (Forward)';
  }

  ForwardElectricityVariable electricityVariable;
  ForwardGasVariable gasVariable;

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }

  @override
  String label() {
    late String out;
    out = 'Forward Heatrate ${electricityVariable.deliveryPoint}'


    if (electricityVariable.deliveryPoint == '.H.INTERNAL_HUB, ptid: 4000') {
      out = 'Forward ${prettyTerm(strip.interval)} MassHub DA LMP';
    } else {
      out = 'Forward ${prettyTerm(strip.interval)} $deliveryPoint $market $component';
    }
    out = '$out, ${bucket.toString()} ';
    return out;
  }
}
