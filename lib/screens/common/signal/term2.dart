import 'package:flutter/material.dart';
import 'package:date/date.dart';
import 'package:timezone/timezone.dart';
import 'package:signals_flutter/signals_flutter.dart';

class TermUi<T> extends StatefulWidget {
  const TermUi({
    required this.model,
    super.key,
    required this.setTerm,
    required this.getTerm,
  });

  final Signal<T> model;
  /// Set the term value inside the model
  final void Function(Term value) setTerm;
  final Term? Function(T model) getTerm;

  @override
  State<TermUi<T>> createState() => _TermUiState<T>();
}

class _TermUiState<T> extends State<TermUi<T>> {
  _TermUiState();

  final controller = TextEditingController();
  final focusNode = FocusNode();
  String? error;

  @override
  void initState() {
    super.initState();
    controller.text =
        widget.getTerm(widget.model.value).toString().replaceAll('-', ' - ');
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        /// validate when you lose focus (Tab out of the field)
        setState(() {
          try {
            widget.setTerm(Term.parse(controller.text, UTC));
            error = null; // all good
          } catch (e) {
            error = e.toString();
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
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
        errorText: error,
      ),
      controller: controller,

      /// validate when Enter is pressed
      onEditingComplete: () {
        setState(() {
          try {
            widget.setTerm(Term.parse(controller.text, UTC));
            error = null; // all good
          } catch (e) {
            error = e.toString();
          }
        });
      },
    );
  }
}
