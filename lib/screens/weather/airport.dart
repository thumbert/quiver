library weather.airport;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/weather/airport_model.dart';
import 'package:provider/provider.dart';

class Airport extends StatefulWidget {
  const Airport({Key? key}) : super(key: key);

  @override
  _AirportState createState() => _AirportState();
}

class _AirportState extends State<Airport> {
  final airportController = TextEditingController();
  String? errorAirport;
  final focusAirport = FocusNode();

  @override
  void initState() {
    final model = context.read<AirportModel>();
    airportController.text = model.airportCode;
    focusAirport.addListener(() {
      if (!focusAirport.hasFocus) {
        airportController.text = airportController.text.toUpperCase();
        setState(validateAirport(model));
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

  validateAirport(AirportModel model) => () {
        errorAirport = null;
        if (model.isValid(airportController.text)) {
          // airportController.text = airportController.text.toUpperCase();
          model.airportCode = airportController.text.toUpperCase();
          errorAirport = null; // all good
        } else {
          errorAirport = 'Error: Only 3 letters allowed';
        }
      };

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AirportModel>();

    return TextField(
      focusNode: focusAirport,
      controller: airportController,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.all(12),
        errorText: errorAirport,
        enabledBorder: InputBorder.none,
      ),
      onSubmitted: (String value) {
        setState(validateAirport(model));
      },
    );
  }
}
