library screens.common.lmp_component;

import 'package:elec/risk_system.dart' as elec;
import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/lmp_component_model.dart';
import 'package:flutter_quiver/screens/polygraph/editors/power_location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';

class LmpComponent extends ConsumerStatefulWidget {
  const LmpComponent({Key? key}) : super(key: key);

  @override
  ConsumerState<LmpComponent> createState() => _LmpComponentState();
}

class _LmpComponentState extends ConsumerState<LmpComponent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(providerOfPowerLocation);

    return DropdownButtonFormField(
      value: formatValue(model.component.toString()),
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
          ref.read(providerOfPowerLocation.notifier).component =
              elec.LmpComponent.parse(newValue!);
        });
      },
      items: LmpComponentMixin.allowedValues
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
    );
  }

  /// Input value is one of 'lmp', 'congestion', 'loss'.  Convert to
  /// allowed values of 'LMP', 'Congestion', 'Loss'.
  String formatValue(String value) {
    if (value == 'lmp') {
      return 'LMP';
    } else {
      return value[0].toUpperCase() + value.substring(1);
    }
  }
}
