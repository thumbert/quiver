library screens.ftr_path.ftr_path;

import 'package:date/date.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_quiver/models/common/term_model.dart';
import 'package:flutter_quiver/models/ftr_path/data_model.dart';
import 'package:flutter_quiver/models/ftr_path/region_source_sink_model.dart';
import 'package:flutter_quiver/screens/ftr_path/ftr_path_ui.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart';

class FtrPath extends StatefulWidget {
  const FtrPath({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _FtrPathState();
}

class _FtrPathState extends State<FtrPath> {
  Term initialTerm() {
    var dt = TZDateTime.now(UTC);
    return Term.fromInterval(Month.utc(dt.year, dt.month));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(
          create: (context) => TermModel(term: initialTerm())),
      ChangeNotifierProvider(create: (context) => RegionSourceSinkModel()),
      ChangeNotifierProvider(create: (context) => DataModel()),
    ], child: const FtrPathUi());
  }
}
