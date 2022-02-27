library screens.vlr_stage2.vlr_stage2;

import 'package:date/date.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/widgets.dart' hide Interval;
import 'package:flutter_quiver/models/common/entity_with_checkbox_model.dart';
import 'package:flutter_quiver/models/common/load_zone_with_checkbox_model.dart';
import 'package:flutter_quiver/models/common/term_model.dart';
import 'package:flutter_quiver/models/common/time_aggregation_model.dart';
import 'package:flutter_quiver/screens/vlr_stage2/vlr_stage2_ui.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart';

class VlrStage2 extends StatefulWidget {
  const VlrStage2({Key? key}) : super(key: key);

  static const route = 'vlr_stage2';

  @override
  _VlrStage2State createState() => _VlrStage2State();
}

class _VlrStage2State extends State<VlrStage2> {
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
          create: (context) => EntityWithCheckboxModel(
              entity: 'Invertase',
              subaccount: '(All)',
              checkboxEntity: false,
              checkboxSubaccount: false)),
      ChangeNotifierProvider(
          create: (context) =>
              LoadZoneWithCheckboxModel(zone: '(All)', checkbox: false)),
      ChangeNotifierProvider(
          create: (context) => TimeAggregationModel(level: 'Month')),
    ], child: const VlrStage2Ui());
  }
}
