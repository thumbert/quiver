library screens.grim_spreader.editor;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/experimental/power_deliverypoint_model.dart';
import 'package:flutter_quiver/models/common/experimental/select_variable_model.dart';
import 'package:flutter_quiver/models/common/lmp_component_model.dart';
import 'package:flutter_quiver/models/common/market_model.dart';
import 'package:flutter_quiver/models/common/region_model.dart';
import 'package:flutter_quiver/screens/polygraph/editors/editor_power.dart';
import 'package:provider/provider.dart';

class EditorMain extends StatefulWidget {
  const EditorMain({Key? key}) : super(key: key);
  @override
  _EditorMainState createState() => _EditorMainState();
}

class _EditorMainState extends State<EditorMain> {
  _EditorMainState();

  late TextEditingController _labelController;
  final _background = Colors.orange[100]!;

  @override
  void initState() {
    final model = context.read<SelectVariableModel>();
    var ys = model.getEditedVariable();
    _labelController = TextEditingController(text: ys['label']);
    super.initState();
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SelectVariableModel>();
    var ys = model.getEditedVariable();
    ys['label'] = _labelController.text;
    model.update(ys);

    return Column(
      children: [
        Row(children: [
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Text('Category'),
          ),
          Container(
            color: _background,
            padding: const EdgeInsetsDirectional.only(start: 6, end: 6),
            width: 100,
            child: DropdownButtonFormField(
              value: ys['category'],
              icon: const Icon(Icons.expand_more),
              hint: const Text('Filter'),
              decoration: const InputDecoration(
                isDense: true,
                enabledBorder: InputBorder.none,
              ),
              elevation: 16,
              onChanged: (newValue) {
                setState(() {
                  ys['category'] = newValue!;
                  model.update(ys);
                });
              },
              items: SelectVariableModel.allowedCategories
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
          ),
        ]),
        const SizedBox(
          height: 12,
        ),
        if (ys['category'] == 'Power')
          MultiProvider(providers: [
            ChangeNotifierProvider(
                create: (context) => RegionModel(ys['region'])),
            ChangeNotifierProvider(
                create: (context) =>
                    PowerDeliveryPointModel(ys['deliveryPoint'])),
            ChangeNotifierProvider(
                create: (context) => MarketModel(ys['market'])),
            ChangeNotifierProvider(
                create: (context) => LmpComponentModel(ys['component'])),
          ], child: const EditorPower()),
        //
        //
        const SizedBox(
          height: 12,
        ),
        //
        // Label
        Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 8),
              child: Text('Label'),
            ),
            IntrinsicWidth(
              child: TextField(
                controller: _labelController,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
