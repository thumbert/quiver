library weather.strike;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/weather/strike_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Strike extends StatefulWidget {
  const Strike({Key? key}) : super(key: key);

  @override
  _StrikeState createState() => _StrikeState();
}

class _StrikeState extends State<Strike> {
  final controller = TextEditingController();
  String? error;
  final focus = FocusNode();
  var fmt = NumberFormat.currency(decimalDigits: 0, symbol: '');

  final _errorBorder = const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 2),
  );

  @override
  void initState() {
    final model = context.read<StrikeModel>();
    controller.text = fmt.format(model.strike);
    focus.addListener(() {
      if (focus.hasFocus) {
        controller.text = model.strike.toString();
      } else {
        setState(validate(model));
        controller.text = fmt.format(model.strike); // format on exit
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

  validate(StrikeModel model) => () {
        error = null;
        try {
          model.strike = fmt.parse(controller.text);
          error = null; // all good
        } catch (e) {
          error = 'Not a valid number';
        }
      };

  @override
  Widget build(BuildContext context) {
    final model = context.watch<StrikeModel>();
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
