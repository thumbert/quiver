library screens.common.entity;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quiver/models/common/entity_model.dart';

class Entity extends StatefulWidget {
  const Entity({Key? key}) : super(key: key);

  @override
  _EntityState createState() => _EntityState();
}

class _EntityState extends State<Entity> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<EntityModel>();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              width: 120,
              child: Text(
                'Entity',
                style: TextStyle(fontSize: 16),
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
                items: EntityModel.entities()
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
            const SizedBox(
              width: 120,
              child: Text(
                'Subaccount',
                style: TextStyle(fontSize: 16),
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
                items: EntityModel.subaccounts(model.entity)
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
