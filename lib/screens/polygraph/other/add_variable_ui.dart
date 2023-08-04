library screens.polygraph.other.add_variable_ui;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/screens/polygraph/editors/marks_asof_editor.dart';
import 'package:flutter_quiver/screens/polygraph/editors/transformed_variable_editor.dart';
import 'package:flutter_quiver/screens/polygraph/editors/marks_historical_view_editor.dart';
import 'package:flutter_quiver/screens/polygraph/other/variable_selection_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddVariableUi extends ConsumerStatefulWidget {
  const AddVariableUi({super.key});

  @override
  ConsumerState<AddVariableUi> createState() => _AddVariableUiState();
}

class _AddVariableUiState extends ConsumerState<AddVariableUi> {
  @override
  Widget build(BuildContext context) {
    var selection = ref.watch(providerOfVariableSelection);

    Widget editorWidget = const Text('');
    if (selection.isSelectionDone()) {
      editorWidget = switch (selection.selection) {
        'Expression' => const TransformedVariableEditor(),
        'Marks,Prices,As of' => const MarksAsOfEditor(),
        'Marks,Prices,Historical' => const MarksHistoricalViewEditor(),
        _ => Text('Selection ${selection.selection} is not implemented.  Edit other/add_variable_ui!'),
      };
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a variable'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 24.0, top: 12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const VariableSelectionUi(),
            editorWidget,
          ],
        ),
      ),
    );
  }
}
