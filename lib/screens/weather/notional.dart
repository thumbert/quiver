library weather.notional;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/weather/airport_model.dart';
import 'package:flutter_quiver/models/common/multiple/notional_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Notional extends StatefulWidget {
  const Notional({this.index = 0, Key? key}) : super(key: key);

  final int index;

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
    controller.text = fmt.format(model[widget.index]);
    focus.addListener(() {
      if (focus.hasFocus) {
        controller.text = model[widget.index].toString();
      } else {
        setState(() => validate(model));
        controller.text = fmt.format(model[widget.index]); // format on exit
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

  void validate(NotionalModel model) {
    error = null;
    try {
      model[widget.index] = fmt.parse(controller.text).round();
      error = null; // all good
    } catch (e) {
      error = 'Not a valid number';
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<NotionalModel>();
    controller.text = fmt.format(model[widget.index]);

    return TextField(
      focusNode: focus,
      controller: controller,
      decoration: InputDecoration(
        isDense: true,
        errorText: error,
        contentPadding: const EdgeInsets.all(9),
        errorBorder: _errorBorder,
        focusedErrorBorder: _errorBorder,
        enabledBorder: InputBorder.none,
      ),
      onSubmitted: (value) {
        setState(() => validate(model));
      },
      textAlign: TextAlign.right,
      scrollPadding: const EdgeInsets.all(5),
    );
  }
}
