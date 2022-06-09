library screens.grim_spreader.grim_spreader;

import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/widgets.dart' hide Interval;
import 'package:flutter_quiver/screens/polygraph/polygraph_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Polygraph extends StatefulWidget {
  const Polygraph({Key? key}) : super(key: key);

  static const route = '/polygraph';

  @override
  State<Polygraph> createState() => _PolygraphState();
}

class _PolygraphState extends State<Polygraph> {
  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: PolygraphUi());
  }
}
