library weather.notional;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/weather/airport_model.dart';
import 'package:flutter_quiver/models/weather/notional_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Notional extends StatefulWidget {
  const Notional({Key? key}) : super(key: key);

  @override
  _NotionalState createState() => _NotionalState();
}

class _NotionalState extends State<Notional> {
  final controller = TextEditingController();
  String? error;
  final focus = FocusNode();
  var fmt = NumberFormat.currency(decimalDigits: 0);

  @override
  void initState() {
    final model = context.read<NotionalModel>();
    controller.text = fmt.format(model.notional);
    focus.addListener(() {
      if (!focus.hasFocus) {
        setState(validate(model));
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    focus.dispose();
    super.dispose();
  }

  validate(NotionalModel model) => () {
        error = null;
        if (model.isValid(controller.text)) {
          model.notional = fmt.parse(controller.text);
          error = null; // all good
        } else {
          error = 'Not a valid number';
        }
      };

  @override
  Widget build(BuildContext context) {
    final model = context.watch<NotionalModel>();
    return TextFormField(
      focusNode: focus,
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Notional, \$',
        // helperText: '3 letter airport code',
        errorText: error,
      ),
      onEditingComplete: () {
        setState(validate(model));
      },
    );
  }
}
