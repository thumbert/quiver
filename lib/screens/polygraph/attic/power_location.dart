library screens.polygraph.editors.editor_power_location;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/experimental/power_deliverypoint_model.dart';
import 'package:flutter_quiver/models/common/lmp_component_model.dart';
import 'package:flutter_quiver/models/common/market_model.dart';
import 'package:flutter_quiver/models/common/region_model.dart';
import 'package:flutter_quiver/screens/common/lmp_component.dart';
import 'package:flutter_quiver/screens/common/region.dart';
import 'package:flutter_quiver/screens/polygraph/attic/power_deliverypoint.dart';
import 'package:flutter_quiver/screens/polygraph/attic/power_market.dart';
import 'package:provider/provider.dart';

class PowerLocation extends StatefulWidget {
  const PowerLocation({Key? key}) : super(key: key);

  @override
  _PowerLocationState createState() => _PowerLocationState();
}

class _PowerLocationState extends State<PowerLocation> {
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
            Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Region',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Region(),
                  ]),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Location',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    PowerDeliveryPoint(),
                  ]),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Market',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                        color: _background,
                        width: 100,
                        child: const PowerMarket()),
                  ]),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8.0, top: 8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        'Component',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    Container(
                        color: _background,
                        width: 140,
                        child: const LmpComponent()),
                  ]),
            ),
          ],
        ),
      ],
    );
  }
}
