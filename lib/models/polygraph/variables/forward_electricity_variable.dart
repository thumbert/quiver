library models.polygraph.variables.forward_electricity_variable;

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:timeseries/src/timeseries_base.dart';

final massHubDa5x16LmpCal24 = ForwardElectricityVariable(
    region: 'ISONE',
    deliveryPoint: '.H.INTERNAL_HUB, ptid: 4000',
    market: 'DA',
    component: 'LMP',
    bucket: IsoNewEngland.bucket5x16,
    strip: Term.parse('Cal25', IsoNewEngland.location),
);

class ForwardElectricityVariable extends PolygraphVariable {
  ForwardElectricityVariable({
    required this.region,
    required this.deliveryPoint,
    required this.market,
    required this.component,
    required this.bucket,
    required this.strip,
  }) {
    id = 'Electricity (Forward)';
    label = _makeLabel();
  }

  String region;
  String deliveryPoint;
  String market;
  String component;
  Bucket bucket;
  Term strip;

  static final shortNames = <String, String>{
    '.H.INTERNAL_HUB, ptid: 4000' : 'MassHub',
  };

  @override
  Map<String, dynamic> toMap() {
    throw UnimplementedError();
  }

  String _makeLabel() {
    var name = deliveryPoint;
    if (shortNames.containsKey(deliveryPoint)) {
      name = shortNames[deliveryPoint]!;
    }
    var out = 'Forward ${prettyTerm(strip.interval)} $name $market $component, '
        '${bucket.toString()}';
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
