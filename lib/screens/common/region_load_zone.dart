library screens.common.region_load_zone;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/region_load_zone_model.dart';
import 'package:provider/provider.dart';

class RegionLoadZone extends StatefulWidget {
  const RegionLoadZone({Key? key}) : super(key: key);

  @override
  _RegionLoadZoneState createState() => _RegionLoadZoneState();
}

class _RegionLoadZoneState extends State<RegionLoadZone> {
  final _background = Colors.orange[100]!;
  final maxOptionsHeight = 350.0;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<RegionLoadZoneModel>();

    return Row(
      children: [
        //
        // Region
        Container(
          padding: const EdgeInsets.only(right: 12),
          child: const Text(
            'Region',
            style: TextStyle(fontSize: 16),
          ),
        ),
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
            items: RegionLoadZoneModel.allowedRegions.keys
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
          ),
        ),

        //
        // Load Zone
        Container(
          padding: const EdgeInsets.only(left: 24, right: 12),
          child: const Text(
            'Load Zone',
            style: TextStyle(fontSize: 16),
          ),
        ),
        Container(
          color: _background,
          padding: const EdgeInsetsDirectional.only(start: 6, end: 6),
          width: 100,
          child: DropdownButtonFormField(
            value: model.zoneName,
            icon: const Icon(Icons.expand_more),
            hint: const Text('Filter'),
            decoration: const InputDecoration(
              isDense: true,
              enabledBorder: InputBorder.none,
            ),
            elevation: 16,
            onChanged: (String? newValue) {
              setState(() {
                model.zoneName = newValue!;
              });
            },
            items: ['(All)', ...model.getZoneNames()]
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
          ),
        ),
      ],
    );
  }
}
