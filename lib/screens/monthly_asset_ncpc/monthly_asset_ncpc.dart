library screens.monthly_asset_ncpc.monthly_asset_ncpc;

import 'package:date/date.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/widgets.dart' hide Interval;
import 'package:flutter_quiver/models/common/load_zone_model.dart';
import 'package:flutter_quiver/models/common/term_model.dart';
import 'package:flutter_quiver/models/monthly_asset_ncpc/asset_autocomplete_model.dart';
import 'package:flutter_quiver/models/monthly_asset_ncpc/monthly_asset_ncpc.dart';
import 'package:flutter_quiver/screens/monthly_asset_ncpc/monthly_asset_ncpc_ui.dart';
import 'package:flutter_quiver/screens/monthly_lmp/monthly_lmp_ui.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart';

class MonthlyAssetNcpc extends StatefulWidget {
  const MonthlyAssetNcpc({Key? key}) : super(key: key);

  static const route = '/monthly_asset_ncpc';

  @override
  _MonthlyAssetNcpcState createState() => _MonthlyAssetNcpcState();
}

class _MonthlyAssetNcpcState extends State<MonthlyAssetNcpc> {
  Term initialTerm() {
    var dt = TZDateTime.now(UTC);
    // data is published with a 4 months lag
    var lastMonth = Month.utc(dt.year, dt.month).subtract(4);
    var startMonth = lastMonth.subtract(12);
    return Term.fromInterval(Interval(startMonth.start, lastMonth.end));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(
          create: (context) => TermModel(term: initialTerm())),
      ChangeNotifierProvider(create: (context) => LoadZoneModel(zone: '(All)')),
      ChangeNotifierProvider(create: (context) => AssetAutocompleteModel()),
      ChangeNotifierProvider(create: (context) => MonthlyAssetNcpcModel()),
    ], child: const MonthlyAssetNcpcUi());
  }
}
