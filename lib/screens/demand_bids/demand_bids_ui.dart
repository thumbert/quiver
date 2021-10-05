library screens.demand_bids.demand_bids_ui;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/entity_model.dart';
import 'package:flutter_quiver/models/common/load_aggregation_model.dart';
import 'package:group_button/group_button.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quiver/models/common/asset_id_model.dart';
import 'package:flutter_quiver/screens/common/asset_id.dart';
import 'package:flutter_quiver/screens/common/entity.dart';
import 'package:flutter_quiver/screens/common/load_aggregation.dart';
import 'package:flutter_quiver/screens/common/load_zone.dart';
import 'package:flutter_quiver/screens/common/term.dart';

class DemandBidsUi extends StatefulWidget {
  const DemandBidsUi({Key? key}) : super(key: key);

  @override
  _DemandBidsUiState createState() => _DemandBidsUiState();
}

class _DemandBidsUiState extends State<DemandBidsUi> {
  var _buttonSelection = 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(left: 48),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Demand bids, Forecast, and RT Load'),
          ),
          body: Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const TermUi(),
                Wrap(
                  direction: Axis.horizontal,
                  spacing: 10,
                  children: [
                    _buttonSelection == 0
                        ? ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _buttonSelection = 0;
                              });
                            },
                            child: const Text('Entity'),
                          )
                        : OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _buttonSelection = 0;
                              });
                            },
                            child: const Text('Entity'),
                          ),
                    _buttonSelection == 1
                        ? ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _buttonSelection = 1;
                              });
                            },
                            child: const Text('Aggregation'),
                          )
                        : OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _buttonSelection = 1;
                              });
                            },
                            child: const Text('Aggregation'),
                          ),
                    _buttonSelection == 2
                        ? ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _buttonSelection = 2;
                              });
                            },
                            child: const Text('Asset Id'),
                          )
                        : OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _buttonSelection = 2;
                              });
                            },
                            child: const Text('Asset Id'),
                          ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                _buttonSelection == 0
                    ? const Entity()
                    : _buttonSelection == 1
                        ? const LoadAggregation()
                        : const AssetId(),
                if (_buttonSelection < 2) const LoadZone(),
                const SizedBox(
                  height: 12,
                ),
                const SizedBox(
                  height: 20,
                ),
                Text('Selected: ${getSelection(context)}'),
              ],
            ),
          ),
        ));
  }

  String getSelection(BuildContext context) {
    var selection = '';
    if (_buttonSelection == 0) {
      final entityModel = context.read<EntityModel>();
      selection +=
          'Entity: ${entityModel.entity}, Subaccount: ${entityModel.subaccount}';
    } else if (_buttonSelection == 1) {
      final aggregationModel = context.read<LoadAggregationModel>();
      selection += 'Aggregation: ${aggregationModel.aggregationName}';
    } else if (_buttonSelection == 2) {
      final assetIdModel = context.read<AssetIdModel>();
      selection += 'AssetId: ${assetIdModel.ids.join(', ')}';
    }
    return selection;
  }
}
