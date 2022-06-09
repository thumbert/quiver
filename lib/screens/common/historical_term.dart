library screens.common.historical_term;

import 'package:flutter/material.dart';
import 'package:date/date.dart' as date;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart';

final providerOfHistoricalTerm =
    StateNotifierProvider<HistoricalTermNotifier, date.Term>(
        (ref) => HistoricalTermNotifier(ref));

class HistoricalTermNotifier extends StateNotifier<date.Term> {
  HistoricalTermNotifier(this.ref) : super(date.Term.parse('Jan22', UTC)) {
    var now = TZDateTime.now(UTC);
    term = date.Term.fromInterval(date.Interval(TZDateTime.utc(now.year - 1),
        TZDateTime.utc(now.year, now.month, now.day)));
  }
  final Ref ref;
  set term(date.Term value) {
    state = value;
  }
}

class HistoricalTermUi extends ConsumerStatefulWidget {
  const HistoricalTermUi({Key? key}) : super(key: key);
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ForwardTermUiState();
}

class _ForwardTermUiState extends ConsumerState<HistoricalTermUi> {
  _ForwardTermUiState();

  final controller = TextEditingController();
  final focusNode = FocusNode();
  String? _error;

  @override
  void initState() {
    super.initState();
    final term = ref.read(providerOfHistoricalTerm);
    controller.text = term.toString();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        /// validate when you lose focus (Tab out of the field)
        setState(() {
          validate();
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

  void validate() {
    try {
      ref.read(providerOfHistoricalTerm.notifier).term =
          date.Term.parse(controller.text, UTC);
      _error = null; // all good
    } catch (e) {
      _error = 'Error parsing historical term';
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: 'Historical Term',
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
          validate();
        });
      },
    );
  }
}

// return TextField(
//   focusNode: focusNode,
//   controller: controller,
//   decoration: InputDecoration(
//     // fillColor: Colors.orange[100]!,
//     // filled: true,
//     isDense: true,
//     contentPadding: const EdgeInsets.all(12),
//     errorText: _error,
//     enabledBorder: InputBorder.none,
//   ),
//   onSubmitted: (String value) {
//     setState(() {
//       validate();
//     });
//   },
// );
