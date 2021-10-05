library screens.common.load_aggregation;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_quiver/models/common/load_aggregation_model.dart';

class LoadAggregation extends StatefulWidget {
  const LoadAggregation({Key? key}) : super(key: key);

  @override
  _LoadAggregationState createState() => _LoadAggregationState();
}

class _LoadAggregationState extends State<LoadAggregation> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<LoadAggregationModel>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(
          width: 120,
          child: Text(
            'Aggregation',
            style: TextStyle(fontSize: 16),
          ),
        ),
        SizedBox(
          width: 150,
          child: DropdownButtonFormField(
            value: model.aggregationName,
            icon: const Icon(Icons.expand_more),
            hint: const Text('Filter'),
            decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor))),
            elevation: 16,
            onChanged: (String? newValue) {
              setState(() {
                model.aggregationName = newValue!;
              });
            },
            items: LoadAggregationModel.zones
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
          ),
        ),
      ],
    );
  }
}
