library screens.term;

import 'package:flutter/material.dart';
import 'package:date/date.dart' as date;
import 'package:flutter_quiver/models/common/term_model.dart';
import 'package:timezone/timezone.dart';
import 'package:provider/provider.dart';

class TermUi extends StatefulWidget {
  const TermUi({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _TermUiState();
}

class _TermUiState extends State<TermUi> {
  _TermUiState();

  final controller = TextEditingController();
  final focusNode = FocusNode();
  String? _error;

  @override
  void initState() {
    super.initState();
    final model = context.read<TermModel>();
    controller.text = model.term.toString();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        /// validate when you lose focus (Tab out of the field)
        setState(() {
          try {
            model.term = date.Term.parse(controller.text, UTC);
            _error = null; // all good
          } on ArgumentError catch (e) {
            print(e);
            _error = 'Parsing error';
          } catch (e) {
            print(e);
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
    final model = context.watch<TermModel>();

    return SizedBox(
        width: 140.0,
        child: TextFormField(
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Term',
            labelStyle: TextStyle(color: Theme.of(context).primaryColor),
            helperText: '',
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            errorText: _error,
          ),
          controller: controller,

          /// validate when Enter is pressed
          onEditingComplete: () {
            setState(() {
              try {
                model.term = date.Term.parse(controller.text, UTC);
                _error = null; // all good
              } on ArgumentError catch (e) {
                print(e);
                _error = 'Parsing error';
              } catch (e) {
                print(e);
              }
            });
          },
        ));
  }
}
