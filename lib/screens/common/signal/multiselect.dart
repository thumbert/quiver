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
  SelectionModel(
      {required Set<String> initialSelection, required this.choices}) {
    currentSelection = SetSignal({...initialSelection});
    selection = SetSignal({...initialSelection});
  }

  // don't make it final, allow for updates after a call to db is made
  Set<String> choices;

  /// Contains the partial selection when the dropdown is still open.
  /// Allows you to react to changes in the app as they happen.
  late final SetSignal<String> currentSelection;

  /// Contains the final selection when the dropdown closes.
  /// Allows you to update the state only when the selection is finished!
  /// Use this field, if any selection triggers a time consuming update,
  /// for example a network request.
  late final SetSignal<String> selection;

  SelectionState get selectionState {
    if (currentSelection.value.isEmpty) return SelectionState.none;
    if (choices.difference(currentSelection.value).isNotEmpty) {
      return SelectionState.some;
    } else {
      return SelectionState.all;
    }
  }

  void add(String value) {
    currentSelection.value = {...currentSelection.value, value};
  }

  void remove(String value) {
    var aux = {...currentSelection.value};
    aux.remove(value);
    currentSelection.value = aux;
  }

  void selectAll() {
    currentSelection.value = {...choices};
  }

  void selectNone() {
    currentSelection.value = <String>{};
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
      onClose: () {
        widget.model.selection.value = widget.model.currentSelection.value;
      },
      builder: (context, controller, child) {
        return TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0)),
          ),
          onPressed: () {
            setState(() {
              if (controller.isOpen) {
                widget.model.selection.value =
                    widget.model.currentSelection.value;
                controller.close();
              } else {
                controller.open();
              }
            });
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
        style: ButtonStyle(padding: WidgetStateProperty.all(EdgeInsets.zero)),
        child: Watch(
          (context) => SizedBox(
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
                  setState(() {});
                },
              ),
            ),
          ),
        )));

    for (final value in widget.model.choices) {
      out.add(MenuItemButton(
          style: ButtonStyle(padding: WidgetStateProperty.all(EdgeInsets.zero)),
          child: Watch((_) => SizedBox(
                width: widget.width,
                child: PointerInterceptor(
                  child: CheckboxListTile(
                    dense: true,
                    value: widget.model.currentSelection.value.contains(value),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(value),
                    onChanged: (bool? checked) {
                      if (checked!) {
                        widget.model.add(value);
                      } else {
                        widget.model.remove(value);
                      }
                      setState(() {});
                    },
                  ),
                ),
              ))));
    }
    return out;
  }
}
