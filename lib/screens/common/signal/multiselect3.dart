import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

/// The recommended version to use for a dropdown widget with multi-selection!
/// May rename the filename in the future.
///
class MultiselectUi extends StatefulWidget {
  const MultiselectUi(
      {required this.allValues,
      required this.selectedValues,
      required this.label,
      required this.temporarySelection,
      required this.width,
      super.key});

  final Computed<Set<String>> allValues;
  final SetSignal<String> selectedValues;
  final Computed<String> label;
  final SetSignal<String> temporarySelection;
  final double width;

  @override
  State<MultiselectUi> createState() => _MultiselectUiState();
}

class _MultiselectUiState extends State<MultiselectUi> {
  _MultiselectUiState();

  @override
  void initState() {
    widget.temporarySelection.value = widget.selectedValues.value;
    super.initState();
  }

  bool isAll() {
    return widget.temporarySelection.value.length ==
        widget.allValues.value.length;
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: getList(),
      onClose: () {
        widget.selectedValues.value = {...widget.temporarySelection.value};
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
            if (controller.isOpen) {
              widget.selectedValues.value = {
                ...widget.temporarySelection.value
              };
              controller.close();
            } else {
              controller.open();
            }
          },
          child: Row(
            children: [
              Text(widget.label.value),
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
        child: SignalBuilder(
          builder: (context) => SizedBox(
            width: widget.width,
            child: PointerInterceptor(
              child: CheckboxListTile(
                dense: true,
                value: isAll(),
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('(All)'),
                onChanged: (bool? checked) {
                  if (checked!) {
                    widget.temporarySelection.value = {
                      ...widget.allValues.value
                    };
                  } else {
                    widget.temporarySelection.value = {};
                  }
                },
              ),
            ),
          ),
        )));

    for (final value in widget.allValues.value) {
      out.add(MenuItemButton(
          style:
              ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
          child: SignalBuilder(builder: (_) => SizedBox(
                width: widget.width,
                child: PointerInterceptor(
                  child: CheckboxListTile(
                    dense: true,
                    value: widget.temporarySelection.value.contains(value),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(value),
                    onChanged: (bool? checked) {
                      var aux = widget.temporarySelection.value;
                      if (checked!) {
                        aux.add(value);
                      } else {
                        aux.remove(value);
                      }
                      widget.temporarySelection.value = {...aux};
                    },
                  ),
                ),
              ))));
    }
    return out;
  }
}
