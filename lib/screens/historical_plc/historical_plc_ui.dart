library screens.historical_plc.historical_plc_ui;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/entity_model.dart';
import 'package:flutter_quiver/models/common/load_aggregation_model.dart';
import 'package:flutter_quiver/models/common/load_zone_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quiver/models/common/asset_id_model.dart';
import 'package:flutter_quiver/screens/common/asset_id.dart';
import 'package:flutter_quiver/screens/common/entity.dart';
import 'package:flutter_quiver/screens/common/load_aggregation.dart';
import 'package:flutter_quiver/screens/common/load_zone.dart';
import 'package:flutter_quiver/screens/common/term.dart';

class HistoricalPlcUi extends StatefulWidget {
  const HistoricalPlcUi({Key? key}) : super(key: key);

  @override
  _HistoricalPlcUiState createState() => _HistoricalPlcUiState();
}

class _HistoricalPlcUiState extends State<HistoricalPlcUi> {
  final _formKey = GlobalKey<FormState>();

  var _buttonSelection = 0;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
          padding: const EdgeInsets.only(left: 48),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Historical Peak Load Contribution'),
            ),
            body: Padding(
              padding: const EdgeInsets.only(left: 12.0, top: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 200, child: TermUi()),
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
                    height: 20,
                  ),
                  Text('Selected: ${getSelection(context)}'),
                ],
              ),
            ),
          )),
    );
  }

  String getSelection(BuildContext context) {
    var selection = '';
    if (_buttonSelection == 0) {
      final entityModel = context.read<EntityModel>();
      selection +=
          'Entity: ${entityModel.entity}, Subaccount: ${entityModel.subaccount}';
      final zoneModel = context.read<LoadZoneModel>();
      selection += ', Zone: ${zoneModel.zone}';
    } else if (_buttonSelection == 1) {
      final aggregationModel = context.read<LoadAggregationModel>();
      selection += 'Aggregation: ${aggregationModel.aggregationName}';
      final zoneModel = context.read<LoadZoneModel>();
      selection += ', Zone: ${zoneModel.zone}';
    } else if (_buttonSelection == 2) {
      final assetIdModel = context.read<AssetIdModel>();
      selection += 'AssetId: ${assetIdModel.ids.join(', ')}';
    }
    return selection;
  }
}
