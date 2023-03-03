library models.polygraph.variables.realized_electricity_variable;

import 'package:date/src/term.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:timeseries/src/timeseries_base.dart';

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
    this.timeAggregation,
  }) {
    name = 'Electricity (Realized)';
  }

  String region;
  String deliveryPoint;
  String market;
  String component;
  TimeAggregation? timeAggregation;

  @override
  Map<String, dynamic> toJson() {
    var out = <String,dynamic>{
      'region': region,
      'deliveryPoint': deliveryPoint,
      'market': market,
      'component': component,
      if (timeAggregation != null) ...timeAggregation!.toJson(),
    };
    return out;
  }

  @override
  String label() {
    late String out;
    if (deliveryPoint == '.H.INTERNAL_HUB, ptid: 4000') {
      out = 'Realized MassHub DA LMP';
    } else {
      out = '$deliveryPoint $market $component';
    }
    if (timeAggregation?.function != 'mean') {
      out = '$out, ${timeAggregation?.function}';
    }
    return out;
  }

  @override
  String id() {
    var out = 'Elec|Realized|$region|$deliveryPoint|$market|$component';
    return out;
  }

  @override
  TimeSeries<num> timeSeries(Term term) {
    // TODO: implement timeSeries
    throw UnimplementedError();
  }
}
