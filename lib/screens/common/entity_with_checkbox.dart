library screens.common.entity_with_checkbox;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/entity_with_checkbox_model.dart';
import 'package:provider/provider.dart';

class EntityWithCheckbox extends StatefulWidget {
  const EntityWithCheckbox({Key? key}) : super(key: key);

  @override
  _EntityWithCheckboxState createState() => _EntityWithCheckboxState();
}

class _EntityWithCheckboxState extends State<EntityWithCheckbox> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<EntityWithCheckboxModel>();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: CheckboxListTile(
                title: const Text('Entity'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.all(0),
                value: model.checkboxEntity,
                onChanged: (bool? value) {
                  setState(() {
                    model.checkboxEntity = value!;
                  });
                },
              ),
            ),
            SizedBox(
              width: 150,
              child: DropdownButtonFormField(
                value: model.entity,
                icon: const Icon(Icons.expand_more),
                hint: const Text('Filter'),
                decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor))),
                elevation: 16,
                onChanged: (String? newValue) {
                  setState(() {
                    model.entity = newValue!;
                  });
                },
                items: model
                    .entities()
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 150,
              child: CheckboxListTile(
                title: const Text('Subaccount'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: const EdgeInsets.all(0),
                value: model.checkboxSubaccount,
                onChanged: (bool? value) {
                  setState(() {
                    model.checkboxSubaccount = value!;
                  });
                },
              ),
            ),
            SizedBox(
              width: 150,
              child: DropdownButtonFormField(
                value: model.subaccount,
                icon: const Icon(Icons.expand_more),
                hint: const Text('Filter'),
                decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Theme.of(context).primaryColor))),
                elevation: 16,
                onChanged: (String? newValue) {
                  setState(() {
                    model.subaccount = newValue!;
                  });
                },
                items: model
                    .subaccounts(model.entity)
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
