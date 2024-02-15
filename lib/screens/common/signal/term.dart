library screens.signal.term;

import 'package:flutter/material.dart';
import 'package:date/date.dart';
import 'package:timezone/timezone.dart';
import 'package:signals_flutter/signals_flutter.dart';

class TermUi extends StatefulWidget {
  const TermUi({required this.term, required this.error, super.key});

  final Signal<Term> term;
  final Signal<String?> error;

  @override
  State<StatefulWidget> createState() => _TermUiState();
}

class _TermUiState extends State<TermUi> {
  _TermUiState();

  final controller = TextEditingController();
  final focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    controller.text = widget.term.toString().replaceAll('-', ' - ');
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        /// validate when you lose focus (Tab out of the field)
        setState(() {
          try {
            widget.term.value = Term.parse(controller.text, UTC);
            widget.error.value = null; // all good
          } catch (e) {
            widget.error.value = e.toString();
          }
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
          try {
            widget.term.value = Term.parse(controller.text, UTC);
            widget.error.value = null; // all good
          } catch (e) {
            widget.error.value = e.toString();
          }
        });
      },
    );
  }
}
