library screens.signal.multiselect;

import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

enum SelectionState {
  all('(All)'),
  none('(None)'),
  some('(Some)');

  const SelectionState(this._value);
  final String _value;

  @override
  String toString() => _value;

  SelectionState parse(String value) {
    return switch (value) {
      '(All)' => SelectionState.all,
      '(None)' => SelectionState.none,
      '(Some)' => SelectionState.some,
      _ => throw ArgumentError('Invalid SelectionState $value'),
    };
  }
}

class SelectionModel {
  SelectionModel({required this.selection, required this.choices});

  late final Signal<Set<String>> selection;
  final Set<String> choices;

  SelectionState get selectionState {
    if (selection.value.isEmpty) return SelectionState.none;
    if (choices.difference(selection.value).isNotEmpty) {
      return SelectionState.some;
    } else {
      return SelectionState.all;
    }
  }

  void add(String value) {
    selection.value = {...selection.value, value};
  }

  void remove(String value) {
    selection.value.remove(value);
    selection.value = {...selection.value};
  }

  void selectAll() {
    selection.value = {...choices};
  }

  void selectNone() {
    selection.value = <String>{};
  }
}

class MultiselectUi extends StatefulWidget {
  const MultiselectUi({required this.model, super.key});

  final Signal<SelectionModel> model;

  @override
  State<MultiselectUi> createState() => _MultiselectUiState();
}

class _MultiselectUiState extends State<MultiselectUi> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      constraints: const BoxConstraints(maxHeight: 400),
      position: PopupMenuPosition.under,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Watch((context) =>
                Text(widget.model.value.selectionState.toString())),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_down_outlined),
          ],
        ),
      ),
      itemBuilder: (context) => getList(),
    );
  }

  /// create the list of checkboxes + dropdown values
  List<PopupMenuItem<String>> getList() {
    var out = <PopupMenuItem<String>>[];
    out.add(PopupMenuItem<String>(
        padding: EdgeInsets.zero,
        value: '(All)',
        child: Watch(
          (_) => CheckboxListTile(
            value: widget.model.value.selectionState == SelectionState.all,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('(All)'),
            onChanged: (bool? checked) {
              if (checked!) {
                widget.model.value.selectAll();
              } else {
                widget.model.value.selectNone();
              }
            },
          ),
        )));

    for (final value in widget.model.value.choices) {
      out.add(PopupMenuItem<String>(
          padding: EdgeInsets.zero,
          value: value,
          child: Watch((_) => CheckboxListTile(
                value: widget.model.value.selection.value.contains(value),
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(value),
                onChanged: (bool? checked) {
                  if (checked!) {
                    widget.model.value.add(value);
                  } else {
                    widget.model.value.remove(value);
                  }
                },
              ))));
    }
    return out;
  }
}
