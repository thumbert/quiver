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
  @override
  Widget build(BuildContext context) {
    final model = context.watch<TimeAggregationModel>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 150,
          child: Text(
            'Time aggregation',
            style: TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(
          width: 150,
          child: DropdownButtonFormField(
            value: model.level,
            icon: const Icon(Icons.expand_more),
            hint: const Text('Filter'),
            decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor))),
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
