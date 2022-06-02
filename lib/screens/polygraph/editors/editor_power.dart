library screens.polygraph.editors.editor_power;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/entity_with_checkbox_model.dart';
import 'package:flutter_quiver/models/common/experimental/power_deliverypoint_model.dart';
import 'package:flutter_quiver/models/common/experimental/select_variable_model.dart';
import 'package:flutter_quiver/models/common/lmp_component_model.dart';
import 'package:flutter_quiver/models/common/market_model.dart';
import 'package:flutter_quiver/models/common/region_model.dart';
import 'package:flutter_quiver/screens/polygraph/editors/historical_forward.dart';
import 'package:flutter_quiver/screens/polygraph/editors/power_location.dart';
import 'package:provider/provider.dart';

class EditorPower extends StatefulWidget {
  const EditorPower({Key? key}) : super(key: key);

  @override
  _EditorPowerState createState() => _EditorPowerState();
}

class _EditorPowerState extends State<EditorPower> {
  // @override
  // void initState() {
  //   final model = context.read<PowerLocationModel>();
  //   // print(model.region);
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    final regionModel = context.watch<RegionModel>();
    final deliveryPointModel = context.watch<PowerDeliveryPointModel>();
    final marketModel = context.watch<MarketModel>();
    final lmpComponentModel = context.watch<LmpComponentModel>();
    final modelSelectVariable = context.watch<SelectVariableModel>();
    var ys = modelSelectVariable.getEditedVariable();
    ys['region'] = regionModel.region;
    ys['deliveryPoint'] = deliveryPointModel.deliveryPointName;
    ys['market'] = marketModel.market;
    ys['component'] = lmpComponentModel.lmpComponent;
    modelSelectVariable.update(ys);

    return Column(
      children: const [
        PowerLocation(),
        SizedBox(
          height: 12,
        ),
        HistoricalOrForward(),
      ],
    );
  }
}
