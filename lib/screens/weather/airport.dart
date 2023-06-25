library weather.airport;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/weather/airport_model.dart';
import 'package:provider/provider.dart';

class Airport extends StatefulWidget {
  const Airport({this.index = 0, Key? key}) : super(key: key);

  final int index;

  @override
  _AirportState createState() => _AirportState();
}

class _AirportState extends State<Airport> {
  final airportController = TextEditingController();
  String? error;
  final focusAirport = FocusNode();

  @override
  void initState() {
    final model = context.read<AirportModel>();
    // print('in airport init for ${widget.index} value ${model[widget.index]}');
    airportController.text = model[widget.index];
    focusAirport.addListener(() {
      if (!focusAirport.hasFocus) {
        airportController.text = airportController.text.toUpperCase();
        setState(() {
          validateAirport(model);
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    airportController.dispose();
    focusAirport.dispose();
    super.dispose();
  }

  void validateAirport(AirportModel model) {
    error = null;
    if (model.isValid(airportController.text)) {
      model[widget.index] = airportController.text.toUpperCase();
      error = null; // all good
    } else {
      error = 'Error: Only 3 letters allowed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AirportModel>();
    return TextField(
      focusNode: focusAirport,
      controller: airportController,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.all(9),
        errorText: error,
        enabledBorder: InputBorder.none,
      ),
      onSubmitted: (String value) {
        setState(() {
          validateAirport(model);
        });
      },
    );
  }
}
