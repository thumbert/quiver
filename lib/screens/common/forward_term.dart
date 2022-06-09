library screens.common.forward_term;

import 'package:flutter/material.dart';
import 'package:date/date.dart' as date;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart';

final providerOfForwardTerm =
    StateNotifierProvider<ForwardTermNotifier, date.Term>(
        (ref) => ForwardTermNotifier(ref));

class ForwardTermNotifier extends StateNotifier<date.Term> {
  ForwardTermNotifier(this.ref) : super(date.Term.parse('Jan22', UTC)) {
    var nextMonth = date.Month.fromTZDateTime(TZDateTime.now(UTC)).next;
    var year = nextMonth.year;
    term = date.Term.fromInterval(
        date.Interval(nextMonth.start, TZDateTime.utc(year + 7, 1)));
  }
  final Ref ref;
  set term(date.Term value) {
    state = value;
  }
}

class ForwardTermUi extends ConsumerStatefulWidget {
  const ForwardTermUi({Key? key}) : super(key: key);
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ForwardTermUiState();
}

class _ForwardTermUiState extends ConsumerState<ForwardTermUi> {
  _ForwardTermUiState();

  final controller = TextEditingController();
  final focusNode = FocusNode();
  String? _error;

  @override
  void initState() {
    super.initState();
    final term = ref.read(providerOfForwardTerm);
    controller.text = term.toString();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        /// validate when you lose focus (Tab out of the field)
        setState(() {
          try {
            ref.read(providerOfForwardTerm.notifier).term =
                date.Term.parse(controller.text, UTC);
            _error = null; // all good
          } on ArgumentError catch (e) {
            print(e);
            _error = 'Error parsing forward term';
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
    return TextFormField(
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: 'Forward Term',
        labelStyle: TextStyle(color: Theme.of(context).primaryColor),
        // fillColor: Colors.orange[100]!,
        // filled: true,
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
            ref.read(providerOfForwardTerm.notifier).term =
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
