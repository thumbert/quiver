import 'package:flutter/material.dart';

class AutocompleteField extends StatelessWidget {
  const AutocompleteField({
    super.key,
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
      style: const TextStyle(fontSize: 12),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.fromLTRB(6, 10, 6, 10),
        // errorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red),),
        // focusedErrorBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.red),),
      ),
      controller: textEditingController,
      focusNode: focusNode,
      onFieldSubmitted: (String value) {
        onFieldSubmitted();
      },
    );
  }
}
