library screens.polygraph.other.variable_selection_ui;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_selection.dart';
import 'package:flutter_quiver/screens/polygraph/editors/transformed_variable_editor.dart';

class VariableSelectionUi extends StatefulWidget {
  const VariableSelectionUi({Key? key}) : super(key: key);

  @override
  State<VariableSelectionUi> createState() => _VariableSelectionUiState();
}

class _VariableSelectionUiState extends State<VariableSelectionUi> {

  final variableSelection = VariableSelection();

  @override
  Widget build(BuildContext context) {
    var categories = variableSelection.getCategoriesForNextLevel();

    Widget widget = const Text('');
    if (variableSelection.isSelectionDone()) {
      var path = variableSelection.categories.join(',');
      if (path == 'Expression') {
        widget = const TransformedVariableEditor();
      } else {
        print('Variable selection for $path is not yet implemented!');
        print('See other/variable_selection_ui.dart');
      }
    }

    return SizedBox(
      width: 500,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!variableSelection.isSelectionDone())
            const Text('Choose a category'),
          const SizedBox(
            height: 8,
          ),
          if (!variableSelection.isSelectionDone())
            Wrap(
              spacing: 5.0,
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
      ),
    );
  }
}
