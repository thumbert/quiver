import 'package:flutter/material.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:signals_flutter/signals_flutter.dart';

class DropdownUi2<T> extends StatefulWidget {
  const DropdownUi2(
      {required this.model,
      required this.choices,
      required this.width,
      required this.setSelection,
      required this.getSelection,
      super.key});

  final Signal<T> model;
  final void Function(String value) setSelection;
  final String? Function(T model) getSelection;
  final Set<String> choices;
  final double width;

  @override
  State<DropdownUi2<T>> createState() => _DropdownUi2State<T>();
}

class _DropdownUi2State<T> extends State<DropdownUi2<T>> {
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
              SignalBuilder(builder: (context) => Text(widget.getSelection(widget.model.value) ?? '')),
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
    for (final value in widget.choices) {
      out.add(MenuItemButton(
          onPressed: () {
            widget.setSelection(value);
          },
          style: ButtonStyle(
            /// Can't make this button with a smaller height!!!
            // backgroundColor: MaterialStateProperty.all(Colors.green),
            // fixedSize: MaterialStateProperty.all(const Size.fromHeight(16)),
            visualDensity: const VisualDensity(vertical: -4.0),
            padding: WidgetStateProperty.all(const EdgeInsets.all(0.0)),
          ),
          child: SignalBuilder(builder: (_) => SizedBox(
              width: widget.width,
              child: PointerInterceptor(
                  child: ListTile(
                title: Text(value.toString()),
                contentPadding: const EdgeInsets.only(left: 12),
                dense: true,
              ))))));
    }
    return out;
  }
}
