library models.polygraph.variables.variable;

import 'package:elec/elec.dart';
import 'package:flutter_quiver/models/polygraph/variables/aggregation.dart';


mixin PolygraphVariable {
  late final String name;
  String label();
  Map<String,dynamic> toJson();
}

class TimeVariable extends Object with PolygraphVariable {
  TimeVariable({this.skipWeekends = false}) {
    name = 'Time';
  }

  bool skipWeekends;

  @override
  Map<String,dynamic> toJson() => {
    'category': 'Time',
    'config': {
      'skipWeekends': skipWeekends,
    }
  };

  @override
  String label() => 'Time';
}

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
    if (deliveryPoint == '.H.INTERNAL_HUB, ptid: 4000') {
      return 'MassHub DA LMP, 5x16';
    } else {
      return '$deliveryPoint $market $component';
    }
  }
  
}



