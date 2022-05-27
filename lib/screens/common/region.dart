library screens.common.region;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/region_model.dart';
import 'package:provider/provider.dart';

class Region extends StatefulWidget {
  const Region({Key? key}) : super(key: key);

  @override
  _RegionState createState() => _RegionState();
}

class _RegionState extends State<Region> {
  final _background = Colors.orange[100]!;
  final maxOptionsHeight = 350.0;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<RegionModel>();

    return Row(
      children: [
        //
        // Region
        // if (model.showLabel)
        //   Container(
        //     padding: const EdgeInsets.only(right: 12),
        //     child: const Text(
        //       'Region',
        //       style: TextStyle(fontSize: 16),
        //     ),
        //   ),
        Container(
          color: _background,
          padding: const EdgeInsetsDirectional.only(start: 6, end: 6),
          width: 100,
          child: DropdownButtonFormField(
            value: model.region,
            icon: const Icon(Icons.expand_more),
            hint: const Text('Filter'),
            decoration: const InputDecoration(
              isDense: true,
              enabledBorder: InputBorder.none,
            ),
            elevation: 16,
            onChanged: (String? newValue) {
              setState(() {
                model.region = newValue!;
              });
            },
            items: model.allowedRegions
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
          ),
        ),
      ],
    );
  }
}
