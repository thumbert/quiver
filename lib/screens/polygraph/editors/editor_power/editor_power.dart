library screens.polygraph.editors.editor_power;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/screens/common/asof_date.dart';
import 'package:flutter_quiver/screens/common/bucket2.dart';
import 'package:flutter_quiver/screens/common/forward_term.dart';
import 'package:flutter_quiver/screens/common/historical_term.dart';
import 'package:flutter_quiver/screens/common/time_filter.dart';
import 'package:flutter_quiver/screens/polygraph/editors/editor_power/forward_asof_view.dart';
import 'package:flutter_quiver/screens/polygraph/editors/editor_power/realized_view.dart';
import 'package:flutter_quiver/screens/polygraph/editors/view_editor.dart';
import 'package:flutter_quiver/screens/polygraph/editors/power_location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Note this is a mere 'StateProvider' not a 'StateNotifierProvider'
final providerOfEditorPower = StateProvider<EditorPower>((ref) {
  var powerLocation = ref.watch(providerOfPowerLocation);
  var tabIndex = ref.watch(providerOfTabIndexView);
  late ViewEditor viewEditor;
  if (tabIndex == 0) {
    var historicalTerm = ref.watch(providerOfHistoricalTerm);
    var timeFilter = ref.watch(providerOfTimeFilter);
    viewEditor = RealizedView(term: historicalTerm, timeFilter: timeFilter);
  } else if (tabIndex == 1) {
    /// Forward curve, as of
    var asOfDate = ref.watch(providerOfAsOfDate);
    var forwardTerm = ref.watch(providerOfForwardTerm);
    var bucket = ref.watch(providerOfBucket);
    viewEditor = ForwardAsOfView(
        asOfDate: asOfDate, bucket: bucket, forwardTerm: forwardTerm);
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
