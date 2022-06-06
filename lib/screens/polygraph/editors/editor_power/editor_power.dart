library screens.polygraph.editors.editor_power;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/screens/polygraph/editors/editor_power/forward_asof.dart';
import 'package:flutter_quiver/screens/polygraph/editors/view_editor.dart';
import 'package:flutter_quiver/screens/polygraph/editors/power_location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Note this is a mere 'StateProvider' not a 'StateNotifierProvider'
final providerOfEditorPower = StateProvider<EditorPower>((ref) {
  var powerLocation = ref.watch(providerOfPowerLocation);
  var tabIndex = ref.watch(tabProvider);
  late ViewEditor viewEditor;
  if (tabIndex == 0) {
    viewEditor = ref.watch(providerOfRealizedView);
  } else if (tabIndex == 1) {
    viewEditor = ref.watch(providerOfForwardAsOfView);
  } else if (tabIndex == 2) {
    // viewEditor = ref.watch(pro)
  }
  return EditorPower(powerLocation: powerLocation, viewEditor: viewEditor);
});

class EditorPower {
  EditorPower({
    required this.powerLocation,
    required this.viewEditor,
  });

  late final PowerLocation powerLocation;
  late final ViewEditor viewEditor;

  EditorPower copyWith({
    PowerLocation? powerLocation,
    ViewEditor? viewEditor,
  }) {
    return EditorPower(
      powerLocation: powerLocation ?? this.powerLocation,
      viewEditor: viewEditor ?? this.viewEditor,
    );
  }
}

class EditorPowerUi extends StatefulWidget {
  const EditorPowerUi({Key? key}) : super(key: key);

  @override
  State<EditorPowerUi> createState() => _EditorPowerUiState();
}

class _EditorPowerUiState extends State<EditorPowerUi> {
  // @override
  // void initState() {
  //   final model = context.read<PowerLocationModel>();
  //   // print(model.region);
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        PowerLocationUi(),
        SizedBox(
          height: 12,
        ),
        ViewEditorUi(),
      ],
    );
  }
}
