library screens.common.asof_date;

import 'package:flutter/material.dart';
import 'package:date/date.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';

final providerOfAsOfDate = StateNotifierProvider<AsOfDateNotifier, Date>(
    (ref) => AsOfDateNotifier(ref));

class AsOfDateNotifier extends StateNotifier<Date> {
  AsOfDateNotifier(this.ref) : super(Date.today(location: UTC));
  final Ref ref;
  set date(Date value) {
    state = value;
  }
}

class AsOfDateUi extends ConsumerStatefulWidget {
  const AsOfDateUi({Key? key}) : super(key: key);
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AsOfDateUiState();
}

class _AsOfDateUiState extends ConsumerState<AsOfDateUi> {
  _AsOfDateUiState();

  final controller = TextEditingController();
  final focusNode = FocusNode();
  String? _error;

  @override
  void initState() {
    super.initState();
    final fmt = DateFormat('dMMMyy');
    controller.text = ref.read(providerOfAsOfDate).toString(fmt);
    final model = ref.read(providerOfAsOfDate.notifier);
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        /// validate when you lose focus (Tab out of the field)
        setState(() {
          try {
            model.date = Date.parse(controller.text, location: UTC);
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
        labelText: 'As of date',
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
            ref.read(providerOfAsOfDate.notifier).date =
                Date.parse(controller.text, location: UTC);
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
