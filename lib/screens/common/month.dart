library screens.term;

import 'package:flutter/material.dart';
import 'package:date/date.dart' as date;
import 'package:flutter_quiver/models/common/month_model.dart';
import 'package:timezone/timezone.dart';
import 'package:provider/provider.dart';

class MonthUi extends StatefulWidget {
  const MonthUi({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MonthUiState();
}

class _MonthUiState extends State<MonthUi> {
  _MonthUiState();

  final controller = TextEditingController();
  final focusNode = FocusNode();
  String? _error;

  @override
  void initState() {
    super.initState();
    final model = context.read<MonthModel>();
    controller.text = model.month.toString();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        /// validate when you lose focus (Tab out of the field)
        setState(() {
          try {
            model.month = date.Month.parse(controller.text, location: UTC);
            _error = null; // all good
          } on ArgumentError catch (e) {
            print(e);
            _error = 'Error: not a month';
          } catch (e) {
            _error = 'Parsing error';
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
    final model = context.watch<MonthModel>();

    return TextFormField(
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: 'Month',
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
            model.month = date.Month.parse(controller.text, location: UTC);
            _error = null; // all good
          } on ArgumentError catch (e) {
            print(e);
            _error = 'Error: not a month';
          } catch (e) {
            print(e);
          }
        });
      },
    );
  }
}
