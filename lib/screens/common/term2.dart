library screens.common.term2;

import 'package:flutter/material.dart';
import 'package:date/date.dart' as date;
import 'package:flutter_quiver/providers/term_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart';

class TermUi2 extends ConsumerStatefulWidget {
  const TermUi2({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TermUi2State();
}

class _TermUi2State extends ConsumerState<TermUi2> {
  _TermUi2State();

  final controller = TextEditingController();
  final focusNode = FocusNode();
  String? _error;

  @override
  void initState() {
    super.initState();
    final model = ref.read(providerOfTerm.notifier);
    // controller.text = model.term.toString();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        /// validate when you lose focus (Tab out of the field)
        setState(() {
          try {
            model.term = date.Term.parse(controller.text, UTC);
            _error = null; // all good
          } on ArgumentError catch (e) {
            print(e);
            _error = 'Parsing error';
          } catch (e) {
            print(e);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final model = ref.watch(providerOfTerm);

    return TextFormField(
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: 'Term',
        labelStyle: TextStyle(color: Theme.of(context).primaryColor),
        helperText: '',
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        errorText: _error,
      ),
      controller: controller,

      /// validate when Enter is pressed
      onEditingComplete: () {
        setState(() {
          try {
            ref.read(providerOfTerm.notifier).term =
                date.Term.parse(controller.text, UTC);
            _error = null; // all good
          } on ArgumentError catch (e) {
            print(e);
            _error = 'Parsing error';
          } catch (e) {
            print(e);
          }
        });
      },
    );
  }
}
