library screens.weather.month_range;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quiver/models/weather/month_range_model.dart';

/// Support one or more MonthRange dropdowns.
class MonthRange extends StatefulWidget {
  const MonthRange({this.index = 0, Key? key}) : super(key: key);

  final int index;

  @override
  _MonthRangeState createState() => _MonthRangeState();
}

class _MonthRangeState extends State<MonthRange> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MonthRangeModel>();

    return DropdownButtonFormField(
      value: model[widget.index],
      icon: const Icon(Icons.expand_more),
      hint: const Text('Filter'),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.only(left: 12, right: 2, top: 9, bottom: 9),
        enabledBorder: InputBorder.none,
      ),
      elevation: 16,
      onChanged: (String? newValue) {
        setState(() {
          model[widget.index] = newValue!;
        });
      },
      items: MonthRangeModel.ranges.keys
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
    );
  }
}
