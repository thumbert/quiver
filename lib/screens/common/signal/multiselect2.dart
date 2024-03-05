library screens.signal.multiselect2;

import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:signals/signals_flutter.dart';

/// A variation on multiselect.dart without the summary (All), (Some), (None).

class Selection2Model {
  Selection2Model(
      {required Set<String> initialSelection, required this.choices}) {
    currentSelection = initialSelection.toSignal();
    selection = {...initialSelection}.toSignal();
  }

  /// What values to appear in the dropdown.  A signal, so it can depend
  /// on other signals.
  final Set<String> choices;

  /// Contains the partial selection when the dropdown is still open.
  /// Allows you to react to changes in the app as they happen.
  late final Signal<Set<String>> currentSelection;

  /// Contains the final selection when the dropdown closes.
  /// Allows you to update the state only when the selection is finished!
  /// Use this field, if any selection triggers a time consuming update,
  /// for example a network request.
  late final Signal<Set<String>> selection;

  void add(String value) {
    currentSelection.value = {...currentSelection.value, value};
  }

  void remove(String value) {
    currentSelection.value.remove(value);
    currentSelection.value = {...currentSelection.value};
  }
}

class Multiselect2Ui extends StatefulWidget {
  const Multiselect2Ui(
      {required this.model,
      required this.label,
      required this.width,
      super.key});

  final Selection2Model model;
  final Widget label;
  final double width;

  @override
  State<Multiselect2Ui> createState() => _MultiselectUiState();
}

class _MultiselectUiState extends State<Multiselect2Ui> {
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
              Watch((context) => widget.label),
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
    for (final value in widget.model.choices) {
      out.add(MenuItemButton(
          style:
              ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
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
