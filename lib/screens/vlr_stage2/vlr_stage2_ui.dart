library screens.demand_bids.demand_bids_ui;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/entity_model.dart';
import 'package:flutter_quiver/models/common/entity_with_checkbox_model.dart';
import 'package:flutter_quiver/screens/common/entity_with_checkbox.dart';
import 'package:flutter_quiver/screens/common/load_zone_with_checkbox.dart';
import 'package:flutter_quiver/screens/common/time_aggregation.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quiver/screens/common/entity.dart';
import 'package:flutter_quiver/screens/common/load_zone.dart';
import 'package:flutter_quiver/screens/common/term.dart';

class VlrStage2Ui extends StatefulWidget {
  const VlrStage2Ui({Key? key}) : super(key: key);

  @override
  _VlrStage2UiState createState() => _VlrStage2UiState();
}

class _VlrStage2UiState extends State<VlrStage2Ui> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 48),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Historical VLR Stage 2 costs'),
          ),
          body: Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TermUi(),
                const EntityWithCheckbox(),
                const LoadZoneWithCheckbox(),
                const TimeAggregation(),
                const SizedBox(
                  height: 12,
                ),
                Text('Selected: ${getSelection(context)}'),
              ],
            ),
          ),
        ));
  }

  String getSelection(BuildContext context) {
    var selection = '';
    final entityModel = context.read<EntityWithCheckboxModel>();
    selection +=
        'Entity: ${entityModel.entity}, Subaccount: ${entityModel.subaccount}';
    return selection;
  }
}
