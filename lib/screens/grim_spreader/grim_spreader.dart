library screens.grim_spreader.grim_spreader;

import 'package:date/date.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/widgets.dart' hide Interval;
import 'package:flutter_quiver/models/common/experimental/select_variable_model.dart';
import 'package:flutter_quiver/models/common/region_model.dart';
import 'package:flutter_quiver/models/common/term_model.dart';
import 'package:flutter_quiver/screens/grim_spreader/grim_spreader_ui.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart';

class GrimSpreader extends StatefulWidget {
  const GrimSpreader({Key? key}) : super(key: key);

  static const route = '/grim_spreader';

  @override
  _GrimSpreaderState createState() => _GrimSpreaderState();
}

class _GrimSpreaderState extends State<GrimSpreader> {
  // final term = Term.parse(Month.current().subtract(4).toString(), UTC);
  final term = Term.parse('Apr18', getLocation('America/New_York'));

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => RegionModel()),
      ChangeNotifierProvider(create: (context) => TermModel(term: term)),
      ChangeNotifierProvider(create: (context) => SelectVariableModel()),
    ], child: const GrimSpreaderUi());
  }
}
