library screens.polygraph.other.variable_selection_ui;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_selection.dart';
import 'package:flutter_quiver/screens/polygraph/editors/horizontal_line_editor.dart';
import 'package:flutter_quiver/screens/polygraph/editors/editor_transformed_variable.dart';
import 'package:flutter_quiver/screens/polygraph/editors/marks_historical_view.dart';
import 'package:flutter_quiver/screens/polygraph/polygraph_window_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final providerOfVariableSelection =
    StateNotifierProvider<VariableSelectionNotifier, VariableSelection>(
        (ref) => VariableSelectionNotifier(ref));

class VariableSelectionUi extends ConsumerStatefulWidget {
  const VariableSelectionUi({Key? key}) : super(key: key);

  @override
  ConsumerState<VariableSelectionUi> createState() =>
      _VariableSelectionUiState();
}

class _VariableSelectionUiState extends ConsumerState<VariableSelectionUi> {
  @override
  Widget build(BuildContext context) {
    final variableSelection = ref.watch(providerOfVariableSelection);
    var choices = variableSelection.getCategoriesForNextLevel();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Add a variable',
          style: TextStyle(fontSize: 24),
        ),
        if (!variableSelection.isSelectionDone())
          const SizedBox(
            height: 12,
          ),
        if (!variableSelection.isSelectionDone())
          const Text('Choose a category'),
        if (!variableSelection.isSelectionDone())
          const SizedBox(
            height: 16,
          ),
        if (!variableSelection.isSelectionDone())
          Row(
            children: List<Widget>.generate(
              choices.length,
              (int index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4.0),
                  child: ChoiceChip(
                    selectedColor: MyApp.background,
                    label: Text(choices[index]),
                    selected: false,
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          ref
                              .read(providerOfVariableSelection.notifier)
                              .categories = [
                            ...variableSelection.categories,
                            choices[index]
                          ];
                          // variableSelection.selectCategory(choices[index]);
                        }
                      });
                    },
                  ),
                );
              },
            ).toList(),
          ),
        const SizedBox(
          height: 16,
        ),
        // if (variableSelection.categories.isNotEmpty)
        Row(
          children: [
            const Text('Selection '),
            ...List.generate(variableSelection.categories.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: InputChip(
                  label: Text(
                    variableSelection.categories[index],
                  ),
                  onDeleted: () {
                    setState(() {
                      ref
                              .read(providerOfVariableSelection.notifier)
                              .categories =
                          variableSelection.categories.sublist(0, index);
                      // variableSelection.removeFromLevel(index);
                    });
                  },
                  deleteIcon: const Icon(Icons.close),
                  backgroundColor: MyApp.background2,
                ),
              );
            })
          ],
        ),
        const SizedBox(
          height: 12,
        ),
        // widget,
      ],
    );
  }
}
