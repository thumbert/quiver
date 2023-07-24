library screens.polygraph.other.add_variable_ui;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/polygraph/editors/marks_asof.dart';
import 'package:flutter_quiver/screens/polygraph/editors/editor_transformed_variable.dart';
import 'package:flutter_quiver/screens/polygraph/editors/marks_historical_view.dart';
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

    Widget widget = const Text('');
    if (selection.isSelectionDone()) {
      widget = switch (selection.selection) {
        'Expression' => const TransformedVariableEditor(),
        'Marks,Prices,Historical' => const MarksHistoricalView(),
        _ => const Text(''),
      };
    }

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const VariableSelectionUi(),
            widget,
          ],
        ),
      ),
    );
  }
}
