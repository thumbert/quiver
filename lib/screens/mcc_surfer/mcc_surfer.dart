library screens.mcc_surfer.mcc_surfer;

import 'package:date/date.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_quiver/models/common/load_zone_model.dart';
import 'package:flutter_quiver/models/common/term_model.dart';
import 'package:flutter_quiver/models/mcc_surfer/congestion_chart_model.dart';
import 'package:flutter_quiver/models/mcc_surfer/constraint_table_model.dart';
import 'package:flutter_quiver/screens/mcc_surfer/mcc_surfer_ui.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart';

class MccSurfer extends StatefulWidget {
  const MccSurfer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CongestionViewerState();
}

class _CongestionViewerState extends State<MccSurfer> {
  Term initialTerm() {
    var dt = TZDateTime.now(UTC);
    return Term.fromInterval(Month.utc(dt.year, dt.month));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(
          create: (context) => TermModel(term: initialTerm())),
      ChangeNotifierProvider(create: (context) => ConstraintTableModel()),
      ChangeNotifierProvider(create: (context) => LoadZoneModel()),
      ChangeNotifierProvider(create: (context) => CongestionChartModel())
    ], child: const MccSurferUi());
  }
}
