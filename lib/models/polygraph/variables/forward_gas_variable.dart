library models.polygraph.variables.forward_gas_variable;

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:timezone/timezone.dart';

final agtcgFG24 = ForwardGasVariable(
  deliveryPoint: 'AGT CG',
  product: 'IFerc',
  strip: Term.parse('F24-G24', UTC),
);

class ForwardGasVariable extends Object with PolygraphVariable {
  ForwardGasVariable({
    required this.deliveryPoint,
    required this.product,
    required this.strip,
  }) {
    name = 'Gas (Forward)';
  }

  String deliveryPoint;
  String product;
  Term strip;

  static final allProducts = [
    'IFerc', 'GasDaily', 'Physical'
  ];

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }

  @override
  String label() {
    var out = 'Forward ${prettyTerm(strip.interval)} $deliveryPoint $product';
    return out;
  }
}
