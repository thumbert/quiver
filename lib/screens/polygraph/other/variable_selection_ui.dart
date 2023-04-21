library screens.polygraph.other.variable_selection_ui;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_selection.dart';
import 'package:flutter_quiver/screens/polygraph/editors/horizontal_line_editor.dart';
import 'package:flutter_quiver/screens/polygraph/editors/transformed_variable_editor.dart';
import 'package:flutter_quiver/screens/polygraph/polygraph_window_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final providerOfVariableSelection = Provider<VariableSelection>(
        (ref) => VariableSelection());


class VariableSelectionUi extends ConsumerStatefulWidget {
  const VariableSelectionUi({Key? key}) : super(key: key);

  @override
  ConsumerState<VariableSelectionUi> createState() => _VariableSelectionUiState();
}

class _VariableSelectionUiState extends ConsumerState<VariableSelectionUi> {

  // final variableSelection = VariableSelection();

  @override
  Widget build(BuildContext context) {
    final variableSelection = ref.watch(providerOfVariableSelection);
    var categories = variableSelection.getCategoriesForNextLevel();

    Widget widget = const Text('');
    if (variableSelection.isSelectionDone()) {
      var path = variableSelection.selection;
      if (path == 'Expression') {
        widget = const TransformedVariableEditor();
      } else if (path == 'Line,Horizontal') {
        widget = const HorizontalLineEditor();
      } else {
        print('Variable selection for $path is not yet implemented!');
        print('See other/variable_selection_ui.dart');
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!variableSelection.isSelectionDone())
          const Text('Choose a category'),
        const SizedBox(
          height: 8,
        ),
        if (!variableSelection.isSelectionDone())
          // Wrap(
          //   spacing: 5.0,
          Row(
            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List<Widget>.generate(
              categories.length,
                  (int index) {
                return ChoiceChip(
                  selectedColor: MyApp.background,
                  label: Text(categories[index]),
                  selected: false,
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        variableSelection
                            .selectCategory(categories[index]);
                      }
                    });
                  },
                );
              },
            ).toList(),
          ),
        const SizedBox(
          height: 16,
        ),
        if (variableSelection.categories.isNotEmpty)
          Wrap(
            spacing: 5.0,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Selection '),
              ...List.generate(variableSelection.categories.length,
                      (index) {
                    return InputChip(
                      label: Text(
                        variableSelection.categories[index],
                      ),
                      onDeleted: () {
                        setState(() {
                          variableSelection.removeFromLevel(index);
                        });
                      },
                      deleteIcon: const Icon(Icons.close),
                      backgroundColor: MyApp.background,
                    );
                  })
            ],
          ),
        const SizedBox(
          height: 8,
        ),
        widget,
      ],
    );
  }
}
