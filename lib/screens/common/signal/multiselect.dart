library screens.signal.multiselect;

import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
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
  const MultiselectUi({required this.model, required this.width, super.key});

  final SelectionModel model;
  final double width;

  @override
  State<MultiselectUi> createState() => _MultiselectUiState();
}

class _MultiselectUiState extends State<MultiselectUi> {
  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: getList(),
      builder: (context, controller, child) {
        return TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0)),
          ),
          onPressed: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
          child: Row(
            children: [
              Watch((context) => Text(widget.model.selectionState.toString())),
              const Spacer(),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 18,
              ),
            ],
          ),
        );
      },
    );
  }

  /// create the list of checkboxes + dropdown values
  List<MenuItemButton> getList() {
    var out = <MenuItemButton>[];
    out.add(MenuItemButton(
      style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
      child: SizedBox(
        width: widget.width,
        child: PointerInterceptor(
          child: CheckboxListTile(
            dense: true,
            value: widget.model.selectionState == SelectionState.all,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('(All)'),
            onChanged: (bool? checked) {
              if (checked!) {
                widget.model.selectAll();
              } else {
                widget.model.selectNone();
              }
            },
          ),
        ),
      ),
    ));

    for (final value in widget.model.choices) {
      out.add(MenuItemButton(
          style:
              ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
          child: Watch((_) => SizedBox(
                width: widget.width,
                child: PointerInterceptor(
                  child: CheckboxListTile(
                    dense: true,
                    value: widget.model.selection.value.contains(value),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(value),
                    onChanged: (bool? checked) {
                      if (checked!) {
                        widget.model.add(value);
                      } else {
                        widget.model.remove(value);
                      }
                    },
                  ),
                ),
              ))));
    }
    return out;
  }
}
