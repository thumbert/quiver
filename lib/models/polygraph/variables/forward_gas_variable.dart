library models.polygraph.variables.forward_gas_variable;

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:timeseries/src/timeseries_base.dart';
import 'package:timezone/timezone.dart';

final agtcgFG24 = ForwardGasVariable(
  deliveryPoint: 'AGT CG',
  product: 'IFerc',
  strip: Term.parse('F24-G24', UTC),
);

class ForwardGasVariable extends PolygraphVariable {
  ForwardGasVariable({
    required this.deliveryPoint,
    required this.product,
    required this.strip,
  }) {
    id = 'Gas (Forward)';
    label = _makeLabel();
  }

  String deliveryPoint;
  String product;
  Term strip;

  static final allProducts = [
    'IFerc', 'GasDaily', 'Physical'
  ];

  @override
  Map<String, dynamic> toMap() {
    throw UnimplementedError();
  }

  String _makeLabel() {
    var out = 'Forward ${prettyTerm(strip.interval)} $deliveryPoint $product';
    return out;
  }

  @override
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
