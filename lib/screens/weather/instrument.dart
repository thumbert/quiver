library screens.weather.month_range;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/weather/instrument_model.dart';
import 'package:provider/provider.dart';

class Instrument extends StatefulWidget {
  const Instrument({Key? key}) : super(key: key);

  @override
  _InstrumentState createState() => _InstrumentState();
}

class _InstrumentState extends State<Instrument> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<InstrumentModel>();

    return DropdownButtonFormField(
      value: model.instrument,
      icon: const Icon(Icons.expand_more),
      hint: const Text('Filter'),
      elevation: 16,
      onChanged: (String? newValue) {
        setState(() {
          model.instrument = newValue!;
        });
      },
      items: InstrumentModel.instruments
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
    );
  }
}
