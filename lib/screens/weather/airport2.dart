library weather.airport2;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/weather/airport_model.dart';
import 'package:provider/provider.dart';

class Airport2 extends StatefulWidget {
  const Airport2({Key? key}) : super(key: key);

  @override
  _Airport2State createState() => _Airport2State();
}

class _Airport2State extends State<Airport2> {
  final airportController = TextEditingController();
  String? errorAirport;
  final focusAirport = FocusNode();

  @override
  void initState() {
    final model = context.read<AirportModel>();
    airportController.text = model.airportCode;
    focusAirport.addListener(() {
      if (!focusAirport.hasFocus) {
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
          model.airportCode = airportController.text.toUpperCase();
          errorAirport = null; // all good
        } else {
          errorAirport = 'Error: Only 3 letters allowed';
        }
      };

  @override
  Widget build(BuildContext context) {
    final model = context.watch<AirportModel>();
    return TextFormField(
      focusNode: focusAirport,
      controller: airportController,
      decoration: InputDecoration(
        labelText: 'Airport code',
        // helperText: '3 letter airport code',
        errorText: errorAirport,
      ),
      onEditingComplete: () {
        setState(validateAirport(model));
      },
    );
  }
}
