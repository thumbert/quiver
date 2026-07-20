import 'package:flutter/material.dart';
import 'package:flutter_quiver/screens/common/signal/multiselect.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:signals_flutter/signals_flutter.dart';

class MultiselectSearchUi extends StatefulWidget {
  const MultiselectSearchUi(
      {required this.model, required this.width, super.key});

  final SelectionModel model;
  final double width;

  @override
  State<MultiselectSearchUi> createState() => _MultiselectSearchUiState();
}

class _MultiselectSearchUiState extends State<MultiselectSearchUi> {
  late TextEditingController _controller;
  String content = '';

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
                // Don't clear out the filter on open.  Remember it for better
                // user experience.
                // _controller.text = '';
                // content = '';
                controller.open();
              }
            });
          },
          child: Row(
            children: [
              SignalBuilder(builder: (context) {
                if (widget.model.selection.value.length == 1) {
                  return Text(widget.model.selection.value.first);
                } else {
                  return Text(widget.model.selectionState.toString());
                }
              }),
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

  /// Create the list of checkboxes + dropdown values
  List<Widget> getList() {
    var out = <Widget>[];
    out.add(SizedBox(
      width: widget.width,
      child: TextField(
        controller: _controller,
        onChanged: (value) {
          setState(() {
            content = value.toLowerCase();
          });
        },
        style: const TextStyle(fontSize: 14),
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.only(top: 12.0),
          prefixIcon: Icon(
            Icons.search,
          ),
        ),
      ),
    ));
    if (_controller.text == '') {
      // only show the (All) checkbox when there is nothing in the search box
      out.add(MenuItemButton(
          style: ButtonStyle(padding: WidgetStateProperty.all(EdgeInsets.zero)),
          child: SignalBuilder(
            builder: (context) => SizedBox(
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
    }

    for (final value in widget.model.choices) {
      if (value.toLowerCase().contains(content)) {
        out.add(MenuItemButton(
          style: ButtonStyle(padding: WidgetStateProperty.all(EdgeInsets.zero)),
          key: UniqueKey(), // need this to display the correct values
          child: SignalBuilder(builder: (_) => SizedBox(
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
              )),
        ));
      }
    }
    return out;
  }
}
