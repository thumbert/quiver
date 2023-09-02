library screens.polygraph.other.add_variable_ui;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_variable.dart';
import 'package:flutter_quiver/screens/polygraph/editors/transformed_variable_editor.dart';
import 'package:flutter_quiver/screens/polygraph/editors/marks_historical_view_editor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditVariableUi extends ConsumerStatefulWidget {
  const EditVariableUi({required this.variable, super.key});

  /// the index of the variable that is edited in the activeTab, activeWindow
  final PolygraphVariable variable;

  @override
  ConsumerState<EditVariableUi> createState() => _EditVariableUiState();
}

class _EditVariableUiState extends ConsumerState<EditVariableUi> {
  @override
  Widget build(BuildContext context) {
    var xs = widget.variable.toJson();
    // print(xs);

    var editorWidget = switch (xs['type']) {
      'TransformedVariable' => const TransformedVariableEditor(),
      'VariableMarksHistoricalView' => const MarksHistoricalViewEditor(),
      _ => Text('Don\'t know how to edit variable of type ${xs['type']}'),
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit variable'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 24.0, top: 12.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // const VariableSelectionUi(),
              editorWidget,
            ],
          ),
        ),
      ),
    );
  }
}
