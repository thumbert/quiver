library screens.grim_spreader.grim_spreader;

import 'package:date/date.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/widgets.dart' hide Interval;
import 'package:flutter_quiver/models/common/experimental/power_deliverypoint_model.dart';
import 'package:flutter_quiver/models/common/experimental/select_variable_model.dart';
import 'package:flutter_quiver/models/common/market_model.dart';
import 'package:flutter_quiver/models/common/region_model.dart';
import 'package:flutter_quiver/models/common/term_model.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/screens/polygraph/polygraph_ui.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart';

class Polygraph extends StatefulWidget {
  const Polygraph({Key? key}) : super(key: key);

  static const route = '/polygraph';

  @override
  _PolygraphState createState() => _PolygraphState();
}

class _PolygraphState extends State<Polygraph> {
  // final term = Term.parse(Month.current().subtract(4).toString(), UTC);
  final term = Term.parse('Apr18', getLocation('America/New_York'));

  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => TermModel(term: term)),
      ChangeNotifierProvider(create: (context) => SelectVariableModel()),
      ChangeNotifierProvider(create: (context) => RegionModel('ISONE')),
      ChangeNotifierProvider(
          create: (context) =>
              PowerDeliveryPointModel('.H.INTERNAL_HUB, ptid: 4000')),
      ChangeNotifierProvider(create: (context) => PolygraphModel()),
    ], child: const PolygraphUi());
  }
}
