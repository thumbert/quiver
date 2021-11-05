library screens.common.load_zone;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quiver/models/common/load_zone_model.dart';

class LoadZone extends StatefulWidget {
  const LoadZone({Key? key}) : super(key: key);

  @override
  _LoadZoneState createState() => _LoadZoneState();
}

class _LoadZoneState extends State<LoadZone> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<LoadZoneModel>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // const SizedBox(
        //   width: 120,
        //   child: Text(
        //     'Zone',
        //     style: TextStyle(fontSize: 16),
        //   ),
        // ),
        SizedBox(
          width: 150,
          child: DropdownButtonFormField(
            value: model.zone,
            icon: const Icon(Icons.expand_more),
            hint: const Text('Filter'),
            // decoration: InputDecoration(
            //     enabledBorder: UnderlineInputBorder(
            //         borderSide:
            //             BorderSide(color: Theme.of(context).primaryColor))),
            elevation: 16,
            onChanged: (String? newValue) {
              setState(() {
                model.zone = newValue!;
              });
            },
            items: LoadZoneModel.zones.keys
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
          ),
        ),
      ],
    );
  }
}
