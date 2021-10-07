library screens.demand_bids.demand_bids;

import 'package:date/date.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/widgets.dart' hide Interval;
import 'package:flutter_quiver/models/common/asset_id_model.dart';
import 'package:flutter_quiver/models/common/entity_model.dart';
import 'package:flutter_quiver/models/common/load_aggregation_model.dart';
import 'package:flutter_quiver/models/common/load_zone_model.dart';
import 'package:flutter_quiver/models/common/term_model.dart';
import 'package:flutter_quiver/screens/demand_bids/demand_bids_ui.dart';
import 'package:flutter_quiver/screens/historical_plc/historical_plc_ui.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart';

class DemandBids extends StatefulWidget {
  const DemandBids({Key? key}) : super(key: key);

  @override
  _DemandBidsState createState() => _DemandBidsState();
}

class _DemandBidsState extends State<DemandBids> {
  Term initialTerm() {
    var dt = TZDateTime.now(UTC);
    var currentMonth = Month.utc(dt.year, dt.month);
    return Term.fromInterval(
        Interval(TZDateTime.utc(2021, 6), currentMonth.end));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(
          create: (context) => TermModel(term: initialTerm())),
      ChangeNotifierProvider(
          create: (context) =>
              EntityModel(entity: 'Invertase', subaccount: '(All)')),
      ChangeNotifierProvider(
          create: (context) => LoadAggregationModel()..init('(All)')),
      ChangeNotifierProvider(create: (context) => AssetIdModel()..init([2481])),
      ChangeNotifierProvider(create: (context) => LoadZoneModel(zone: '(All)')),
    ], child: const DemandBidsUi());
  }
}
