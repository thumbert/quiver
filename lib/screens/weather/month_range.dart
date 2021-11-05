library screens.weather.month_range;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quiver/models/weather/month_range_model.dart';

class MonthRange extends StatefulWidget {
  const MonthRange({Key? key}) : super(key: key);

  @override
  _MonthRangeState createState() => _MonthRangeState();
}

class _MonthRangeState extends State<MonthRange> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<MonthRangeModel>();

    return DropdownButtonFormField(
      value: model.monthRange,
      icon: const Icon(Icons.expand_more),
      hint: const Text('Filter'),
      elevation: 16,
      onChanged: (String? newValue) {
        setState(() {
          model.monthRange = newValue!;
        });
      },
      items: MonthRangeModel.ranges.keys
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
    );
  }
}
