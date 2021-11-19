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
  var fmt = NumberFormat.currency(decimalDigits: 0, symbol: '');

  final _errorBorder = const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 2),
  );

  @override
  void initState() {
    final model = context.read<NotionalModel>();
    controller.text = fmt.format(model.notional);
    focus.addListener(() {
      if (focus.hasFocus) {
        controller.text = model.notional.toString();
      } else {
        setState(validate(model));
        controller.text = fmt.format(model.notional); // format on exit
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
        try {
          model.notional = fmt.parse(controller.text);
          error = null; // all good
        } catch (e) {
          error = 'Not a valid number';
        }
      };

  @override
  Widget build(BuildContext context) {
    final model = context.watch<NotionalModel>();
    return TextField(
      focusNode: focus,
      controller: controller,
      decoration: InputDecoration(
        isDense: true,
        errorText: error,
        contentPadding: const EdgeInsets.all(12),
        errorBorder: _errorBorder,
        focusedErrorBorder: _errorBorder,
        enabledBorder: InputBorder.none,
      ),
      onChanged: (value) {
        setState(validate(model));
      },
      textAlign: TextAlign.right,
      scrollPadding: const EdgeInsets.all(5),
    );
  }
}
