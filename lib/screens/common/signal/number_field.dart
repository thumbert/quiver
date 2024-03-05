library screens.signal.number_field;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:signals_flutter/signals_flutter.dart';

class NumberFieldUi extends StatefulWidget {
  NumberFieldUi(
      {required this.number,
      required this.error,
      NumberFormat? fmt,
      super.key}) {
    this.fmt = fmt ?? NumberFormat('#,###.##', 'en_US');
  }

  final Signal<num> number;
  late final NumberFormat fmt;
  final Signal<String?> error;

  @override
  State<StatefulWidget> createState() => _NumberFieldUiState();
}

class _NumberFieldUiState extends State<NumberFieldUi> {
  _NumberFieldUiState();

  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller.text = widget.fmt.format(widget.number.value);
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        setState(() {
          validateInput();
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      style: const TextStyle(fontSize: 14),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      ),
      controller: controller,

      /// validate when Enter is pressed
      onEditingComplete: () {
        setState(() {
          validateInput();
        });
      },
    );
  }

  void validateInput() {
    try {
      var aux = widget.fmt.parse(controller.text);
      widget.number.value = aux; 
      widget.error.value = null; // all good
    } catch (e) {
      widget.error.value = 'Invalid number format';
    }
  }
}



