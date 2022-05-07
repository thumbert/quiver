library screens.demand_bids.demand_bids_ui;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/entity_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quiver/screens/common/entity.dart';
import 'package:flutter_quiver/screens/common/load_zone.dart';
import 'package:flutter_quiver/screens/common/term.dart';

class DemandBidsUi extends StatefulWidget {
  const DemandBidsUi({Key? key}) : super(key: key);

  @override
  _DemandBidsUiState createState() => _DemandBidsUiState();
}

class _DemandBidsUiState extends State<DemandBidsUi> {
  final _variableCheck = <bool>[true, true, true, true, false];
  final _temperatureCheck = List.filled(6, false);
  final _tempShocks = <String>['-9F', '-6F', '-3F', '+3F', '+6F', '+9F'];

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
                const SizedBox(width: 140, child: TermUi()),
                const Entity(),
                Row(
                  children: const [
                    SizedBox(
                      width: 120,
                      child: Text(
                        'Zone',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    LoadZone(),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _variableCheck[0],
                      onChanged: (bool? value) {
                        setState(() {
                          _variableCheck[0] = value!;
                        });
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 12, right: 36),
                      child: const Text('RT load'),
                    ),
                    //
                    //
                    Checkbox(
                      value: _variableCheck[1],
                      onChanged: (bool? value) {
                        setState(() {
                          _variableCheck[1] = value!;
                        });
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.only(left: 12, right: 36),
                      child: const Text('Demand bids'),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 10,
                  alignment: WrapAlignment.start,
                  children: [
                    SizedBox(
                      width: 180,
                      child: CheckboxListTile(
                        title: const Text('RT load'),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.all(0),
                        value: _variableCheck[0],
                        onChanged: (bool? value) {
                          setState(() {
                            _variableCheck[0] = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: CheckboxListTile(
                        title: const Text('Demand bid'),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.all(0),
                        value: _variableCheck[1],
                        onChanged: (bool? value) {
                          setState(() {
                            _variableCheck[1] = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: CheckboxListTile(
                        title: const Text('QA forecast'),
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _variableCheck[2],
                        onChanged: (bool? value) {
                          setState(() {
                            _variableCheck[2] = value!;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      width: 180,
                      child: CheckboxListTile(
                        title: const Text('WT forecast'),
                        controlAffinity: ListTileControlAffinity.leading,
                        value: _variableCheck[3],
                        onChanged: (bool? value) {
                          setState(() {
                            _variableCheck[3] = value!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
                Wrap(
                  direction: Axis.horizontal,
                  spacing: 5,
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text(
                      'Temperature',
                      style: TextStyle(fontSize: 16),
                    ),
                    ...[
                      for (var i = 0; i < 6; i++)
                        SizedBox(
                          width: 80,
                          child: CheckboxListTile(
                            title: Text(_tempShocks[i]),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: const EdgeInsets.all(0),
                            value: _temperatureCheck[i],
                            onChanged: (bool? value) {
                              setState(() {
                                _temperatureCheck[i] = value!;
                              });
                            },
                          ),
                        ),
                    ],
                  ],
                ),
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
    final entityModel = context.read<EntityModel>();
    selection +=
        'Entity: ${entityModel.entity}, Subaccount: ${entityModel.subaccount}';
    return selection;
  }
}
