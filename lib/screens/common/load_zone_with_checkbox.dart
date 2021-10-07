library screens.common.load_zone_with_checkbox;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/load_zone_with_checkbox_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quiver/models/common/load_zone_model.dart';

class LoadZoneWithCheckbox extends StatefulWidget {
  const LoadZoneWithCheckbox({Key? key}) : super(key: key);

  @override
  _LoadZoneWithCheckboxState createState() => _LoadZoneWithCheckboxState();
}

class _LoadZoneWithCheckboxState extends State<LoadZoneWithCheckbox> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<LoadZoneWithCheckboxModel>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 150,
          child: CheckboxListTile(
            title: const Text('Zone'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.all(0),
            value: model.checkbox,
            onChanged: (bool? value) {
              setState(() {
                model.checkbox = value!;
              });
            },
          ),
        ),
        SizedBox(
          width: 150,
          child: DropdownButtonFormField(
            value: model.zone,
            icon: const Icon(Icons.expand_more),
            hint: const Text('Filter'),
            decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor))),
            elevation: 16,
            onChanged: (String? newValue) {
              setState(() {
                model.zone = newValue!;
              });
            },
            items: LoadZoneModel.zones
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
          ),
        ),
      ],
    );
  }
}
