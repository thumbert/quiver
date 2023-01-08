library models.polygraph.variables.realized_electricity_variable;

import 'package:elec/elec.dart';
import 'package:flutter_quiver/models/polygraph/variables/aggregation.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';

final massHubDa = RealizedElectricityVariable(
    region: 'ISONE',
    deliveryPoint: '.H.INTERNAL_HUB, ptid: 4000',
    market: 'DA',
    component: 'LMP');

class RealizedElectricityVariable extends Object with PolygraphVariable {
  RealizedElectricityVariable({
    required this.region,
    required this.deliveryPoint,
    required this.market,
    required this.component,
    this.bucket,
    this.timeAggregation,
  }) {
    name = 'Electricity (Realized)';
  }

  String region;
  String deliveryPoint;
  String market;
  String component;
  Bucket? bucket;
  TimeAggregation? timeAggregation;

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }

  @override
  String label() {
    late String out;
    if (deliveryPoint == '.H.INTERNAL_HUB, ptid: 4000') {
      out = 'Realized MassHub DA LMP';
    } else {
      out = '$deliveryPoint $market $component';
    }
    if (bucket != null) {
      out = '$out, ${bucket.toString()}';
    }
    return out;
  }
}
