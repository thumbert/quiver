import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:signals/signals_flutter.dart';

/// A performant autocomplete widget.
///
/// It only shows a scrollable window of choices instead of trying to dump
/// everything on the screen like `multiselect_search.dart` does.
///
/// Prefer this over `autocomplete.dart` because it uses get/set on a model
/// allowing for higher abstraction.
///
class AutocompleteUi<T> extends StatefulWidget {
  AutocompleteUi(
      {required this.model,
      required this.choices,
      required this.setSelection,
      required this.getSelection,
      ListSignal<String>? accumulatedSelection,
      required this.width,
      this.height = 500.0,
      super.key}) {
    this.accumulatedSelection = accumulatedSelection ?? <String>[].toSignal();
  }

  // what gets selected
  // final Signal<String> selection;
  final Signal<T> model;
  final void Function(String value) setSelection;
  final String? Function(T model) getSelection;

  final Set<String> choices;
  late final ListSignal<String> accumulatedSelection;
  final double width;
  // height of the dropdown
  final double height;

  @override
  State<AutocompleteUi<T>> createState() => _AutocompleteUiState<T>();
}

class _AutocompleteUiState<T> extends State<AutocompleteUi<T>> {
  final focusNode = FocusNode();
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = widget.getSelection(widget.model.value) ?? '';
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    controller.text = widget.getSelection(widget.model.value) ?? '';
    return Watch((_) => RawAutocomplete(
        focusNode: focusNode,
        textEditingController: controller,
        fieldViewBuilder: (BuildContext context,
                TextEditingController textEditingController,
                FocusNode focusNode,
                VoidCallback onFieldSubmitted) =>
            _AutocompleteField(
              focusNode: focusNode,
              textEditingController: textEditingController,
              onFieldSubmitted: onFieldSubmitted,
              options: widget.choices,
            ),
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (textEditingValue == TextEditingValue.empty) {
            return const Iterable<String>.empty();
          }
          final value = textEditingValue.text.toLowerCase();
          var items = widget.choices
              .where((e) => e.toLowerCase().contains(value))
              .toList();
          if (value != '') {
            // sort them to show the entries that give the best match
            items.sort((a, b) =>
                a.toLowerCase().length.compareTo(b.toLowerCase().length));
          }
          return items;
        },
        onSelected: (String selection) {
          widget.setSelection(selection);
          var aux = widget.accumulatedSelection.value.toSet();
          aux.add(selection);
          widget.accumulatedSelection.value = aux.toList();
        },
        optionsViewBuilder: (BuildContext context,
            void Function(String) onSelected, Iterable<String> options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              child: ConstrainedBox(
                constraints:
                    BoxConstraints(maxHeight: 400, maxWidth: widget.width),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final option = options.elementAt(index);
                    return InkWell(
                      onTap: () {
                        onSelected(option);
                      },
                      child: Builder(builder: (BuildContext context) {
                        final bool highlight =
                            AutocompleteHighlightedOption.of(context) == index;
                        if (highlight) {
                          SchedulerBinding.instance
                              .addPostFrameCallback((Duration timeStamp) {
                            Scrollable.ensureVisible(context, alignment: 0.5);
                          });
                        }
                        // each element of the dropdown
                        return PointerInterceptor(
                          child: Container(
                            width: widget.width,
                            color:
                                highlight ? Theme.of(context).focusColor : null,
                            padding: const EdgeInsets.only(
                                left: 8.0, top: 2, bottom: 2),
                            child: Text(
                              option,
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
          );
        }));
  }
}

class _AutocompleteField extends StatelessWidget {
  const _AutocompleteField({
    required this.focusNode,
    required this.textEditingController,
    required this.onFieldSubmitted,
    required this.options,
  });

  final FocusNode focusNode;

  final VoidCallback onFieldSubmitted;

  final TextEditingController textEditingController;

  final Iterable<String> options;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(fontSize: 13.0),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        // border: InputBorder.none,
        enabledBorder: InputBorder.none,
      ),
      controller: textEditingController,
      focusNode: focusNode,
      onFieldSubmitted: (String value) {
        onFieldSubmitted();
      },
    );
  }
}
