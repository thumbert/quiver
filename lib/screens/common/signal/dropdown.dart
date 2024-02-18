library screens.signal.dropdown;

import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:signals/signals_flutter.dart';

class DropdownModel {
  DropdownModel({required this.selection, required this.choices});
  late final Signal<String> selection;
  final Set<String> choices;
}

class DropdownUi extends StatefulWidget {
  const DropdownUi({required this.model, required this.width, super.key});

  final DropdownModel model;
  final double width;

  @override
  State<DropdownUi> createState() => _DropdownUiState();
}

class _DropdownUiState extends State<DropdownUi> {
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
              Watch((context) => Text(widget.model.selection.value)),
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

  /// create the list of dropdown values
  List<MenuItemButton> getList() {
    var out = <MenuItemButton>[];
    for (final value in widget.model.choices) {
      out.add(MenuItemButton(
          onPressed: () {
            widget.model.selection.value = value;
          },
          style: ButtonStyle(
            /// Can't make this button with a smaller height!!!
            // backgroundColor: MaterialStateProperty.all(Colors.green),
            // fixedSize: MaterialStateProperty.all(const Size.fromHeight(16)),
            visualDensity: const VisualDensity(vertical: -4.0),
            padding: MaterialStateProperty.all(const EdgeInsets.all(0.0)),
          ),
          // child: Text(value),
          child: Watch((_) => SizedBox(
              width: widget.width,
              child: PointerInterceptor(
                  child: ListTile(
                title: Text(value),
                contentPadding: const EdgeInsets.only(left: 12),
                dense: true,
              ))))));
    }
    return out;
  }
}
