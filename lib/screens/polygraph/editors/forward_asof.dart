library screens.polygraph.editors.forward_asof;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/experimental/power_deliverypoint_model.dart';
import 'package:flutter_quiver/models/common/lmp_component_model.dart';
import 'package:flutter_quiver/models/common/market_model.dart';
import 'package:flutter_quiver/models/common/region_model.dart';
import 'package:flutter_quiver/screens/common/lmp_component.dart';
import 'package:flutter_quiver/screens/common/region.dart';
import 'package:flutter_quiver/screens/polygraph/editors/power_deliverypoint.dart';
import 'package:flutter_quiver/screens/polygraph/editors/power_market.dart';
import 'package:provider/provider.dart';

class ForwardAsof extends StatefulWidget {
  const ForwardAsof({Key? key}) : super(key: key);

  @override
  _ForwardAsofState createState() => _ForwardAsofState();
}

class _ForwardAsofState extends State<ForwardAsof> {
  final _background = Colors.orange[100]!;

  @override
  void initState() {
    final regionModel = context.read<RegionModel>();
    final deliveryPointModel = context.read<PowerDeliveryPointModel>();
    deliveryPointModel.currentRegion = regionModel.region;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final regionModel = context.watch<RegionModel>();
    final deliveryPointModel = context.watch<PowerDeliveryPointModel>();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Forward Term',
              style: TextStyle(fontSize: 16),
            ),
            Region(),
          ],
        ),
      ],
    );
  }
}
