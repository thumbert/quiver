library screens.common.load_zone_with_checkbox;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/date_with_checkbox_model.dart';
import 'package:provider/provider.dart';

class DateWithCheckbox extends StatefulWidget {
  const DateWithCheckbox({Key? key}) : super(key: key);

  @override
  _DateWithCheckboxState createState() => _DateWithCheckboxState();
}

class _DateWithCheckboxState extends State<DateWithCheckbox> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<DateWithCheckboxModel>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 110,
          child: CheckboxListTile(
            title: const Text('Date'),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: const EdgeInsets.all(0),
            value: model.checkbox,
            onChanged: (bool? value) {
              setState(() {
                model.checkbox = value!;
              });
            },
          ),
        ),
        SizedBox(
          width: 150,
          child: DropdownButtonFormField(
            value: model.date,
            icon: const Icon(Icons.expand_more),
            hint: const Text('Filter'),
            decoration: InputDecoration(
                enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor))),
            elevation: 16,
            onChanged: (String? newValue) {
              setState(() {
                model.date = newValue!;
              });
            },
            items: ['(All)', ...model.allowedDates.map((e) => e.toString())]
                .map((e) =>
                    DropdownMenuItem(value: e, child: Text(e.toString())))
                .toList(),
          ),
        ),
      ],
    );
  }
}
