library screens.common.time_aggregation;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/time_aggregation_model.dart';
import 'package:provider/provider.dart';

class TimeAggregation extends StatefulWidget {
  const TimeAggregation({Key? key}) : super(key: key);

  @override
  _TimeAggregationState createState() => _TimeAggregationState();
}

class _TimeAggregationState extends State<TimeAggregation> {
  final _background = Colors.orange[100]!;

  @override
  Widget build(BuildContext context) {
    final model = context.watch<TimeAggregationModel>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.only(right: 12),
          child: const Text(
            'Time aggregation',
            style: TextStyle(fontSize: 16),
          ),
        ),
        Container(
          color: _background,
          child: DropdownButtonFormField(
            value: model.level,
            icon: const Icon(Icons.expand_more),
            hint: const Text('Filter'),
            decoration: const InputDecoration(
              isDense: true,
              enabledBorder: InputBorder.none,
            ),
            elevation: 16,
            onChanged: (String? newValue) {
              setState(() {
                model.level = newValue!;
              });
            },
            items: model.levels
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
          ),
        ),
      ],
    );
  }
}
