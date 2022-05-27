library screens.common.lmp_component;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/lmp_component_model.dart';
import 'package:provider/provider.dart';

class LmpComponent extends StatefulWidget {
  const LmpComponent({Key? key}) : super(key: key);

  @override
  _LmpComponentState createState() => _LmpComponentState();
}

class _LmpComponentState extends State<LmpComponent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<LmpComponentModel>();

    return DropdownButtonFormField(
      value: model.lmpComponent,
      icon: const Icon(Icons.expand_more),
      hint: const Text('Filter'),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.only(left: 12, right: 2, top: 9, bottom: 9),
        enabledBorder: InputBorder.none,
      ),
      elevation: 16,
      onChanged: (String? newValue) {
        setState(() {
          model.lmpComponent = newValue!;
        });
      },
      items: LmpComponentMixin.allowedValues
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
    );
  }
}
