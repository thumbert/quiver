library weather.max_payoff;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/multiple/maxpayoff_model.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MaxPayoff extends StatefulWidget {
  const MaxPayoff({this.index = 0, Key? key}) : super(key: key);

  final int index;

  @override
  _MaxPayoffState createState() => _MaxPayoffState();
}

class _MaxPayoffState extends State<MaxPayoff> {
  final controller = TextEditingController();
  String? error;
  final focus = FocusNode();
  var fmt = NumberFormat.currency(decimalDigits: 0, symbol: '');

  final _outlineInputBorder = const OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.zero),
    borderSide: BorderSide.none,
  );
  final _errorBorder = const OutlineInputBorder(
    borderSide: BorderSide(color: Colors.red, width: 2),
  );

  @override
  void initState() {
    final model = context.read<MaxPayoffModel>();
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

  void validate(MaxPayoffModel model) {
    error = null;
    try {
      model[widget.index] = fmt.parse(controller.text);
      error = null; // all good
    } catch (e) {
      error = 'Not a valid number';
    }
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MaxPayoffModel>();

    return TextField(
      focusNode: focus,
      controller: controller,
      decoration: InputDecoration(
        isDense: true,
        errorText: error,
        contentPadding: const EdgeInsets.all(12),
        errorBorder: _errorBorder,
        focusedErrorBorder: _errorBorder,
        // border: _outlineInputBorder,
        enabledBorder: _outlineInputBorder,
      ),
      onChanged: (value) {
        setState(() => validate(model));
      },
      textAlign: TextAlign.right,
      scrollPadding: const EdgeInsets.all(5),
    );
  }
}
