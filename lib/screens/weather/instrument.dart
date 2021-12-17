library screens.weather.month_range;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/weather/instrument_model.dart';
import 'package:provider/provider.dart';

class Instrument extends StatefulWidget {
  const Instrument({this.index = 0, Key? key}) : super(key: key);

  final int index;

  @override
  _InstrumentState createState() => _InstrumentState();
}

class _InstrumentState extends State<Instrument> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<InstrumentModel>();

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
      items: InstrumentModel.instruments
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
    );
  }
}
