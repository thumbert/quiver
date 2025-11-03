import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

class DateFieldUi extends StatefulWidget {
  const DateFieldUi(
      {required this.date, required this.error, this.restorationId, super.key});

  final Signal<Date> date;
  final Signal<String?> error;
  final String? restorationId;

  @override
  State<StatefulWidget> createState() => _DateFieldUiState();
}

class _DateFieldUiState extends State<DateFieldUi> with RestorationMixin {
  _DateFieldUiState();

  final controller = TextEditingController();
  final focusNode = FocusNode();

  late RestorableDateTime _selectedDate;
  late final RestorableRouteFuture<DateTime?> _restorableDatePickerRouteFuture =
      RestorableRouteFuture<DateTime?>(
    onComplete: _selectDate,
    onPresent: (NavigatorState navigator, Object? arguments) {
      return navigator.restorablePush(
        _datePickerRoute,
        arguments: _selectedDate.value.millisecondsSinceEpoch,
      );
    },
  );

  @override
  void initState() {
    super.initState();
    controller.text = widget.date.value.toString();
    final start = widget.date.value.start;
    _selectedDate =
        RestorableDateTime(DateTime(start.year, start.month, start.day));
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        setState(() {
          validateInput();
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          child: TextField(
            focusNode: focusNode,
            style: const TextStyle(fontSize: 14),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            ),
            controller: controller,

            /// validate when Enter is pressed
            onEditingComplete: () {
              setState(() {
                validateInput();
              });
            },
          ),
        ),
        IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: () {
              _restorableDatePickerRouteFuture.present();
            },
            icon: const Icon(
              Icons.calendar_month,
              // size: 8,
            ))
      ],
    );
  }

  void validateInput() {
    try {
      var aux = Date.parse(controller.text);
      widget.date.value = aux;
      widget.error.value = null; // all good
      final start = widget.date.value.start;
      _selectedDate.value = DateTime(start.year, start.month, start.day);
    } catch (e) {
      widget.error.value = 'Error parsing ${controller.text}';
    }
  }

  @pragma('vm:entry-point')
  static Route<DateTime> _datePickerRoute(
    BuildContext context,
    Object? arguments,
  ) {
    return DialogRoute<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return DatePickerDialog(
          restorationId: 'date_picker_dialog',
          initialEntryMode: DatePickerEntryMode.calendarOnly,
          initialDate: DateTime.fromMillisecondsSinceEpoch(arguments! as int),
          firstDate: DateTime(2018),
          lastDate: DateTime(2028),
        );
      },
    );
  }

  @override
  String? get restorationId => widget.restorationId;

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_selectedDate, 'selected_date');
    registerForRestoration(
        _restorableDatePickerRouteFuture, 'date_picker_route_future');
  }

  void _selectDate(DateTime? newSelectedDate) {
    if (newSelectedDate != null) {
      setState(() {
        widget.date.value = Date.utc(
            newSelectedDate.year, newSelectedDate.month, newSelectedDate.day);
        controller.text = newSelectedDate.toIso8601String().substring(0, 10);
        _selectedDate.value = newSelectedDate;
      });
    }
  }
}
