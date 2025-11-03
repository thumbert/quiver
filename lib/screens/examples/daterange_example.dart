import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/screens/common/signal/date_field.dart';
import 'package:signals/signals_flutter.dart';
import 'package:timezone/timezone.dart';

/// NOTE: Implementation done with signals.

final startDate = signal(Date.today(location: UTC).subtract(10));
final startError = signal<String?>(null);
final endDate = signal(Date.today(location: UTC));
final endError = signal<String?>(null);

class DateRangePickerExample extends StatefulWidget {
  const DateRangePickerExample({super.key});
  static const route = '/daterange_example';

  @override
  State<DateRangePickerExample> createState() => _DateRangePickerExampleState();
}

class _DateRangePickerExampleState extends State<DateRangePickerExample> {
  late void Function() checkEnd;

  @override
  void initState() {
    super.initState();

    /// NOTE: Need to register this effect here!
    checkEnd = effect(() {
      if (endDate.value.isBefore(startDate.value)) {
        endError.value = 'End has to be after Start';
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    checkEnd();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text('A date range picker'),
              Watch(
                (context) => Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    // crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ///
                      /// Start
                      ///
                      const SizedBox(
                        width: 36,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Text('Start'),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: MyApp.background,
                            child:
                                DateFieldUi(date: startDate, error: startError),
                          ),
                          if (startError.value != null)
                            Text(
                              startError.value!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 11),
                            )
                        ],
                      ),
                      const SizedBox(
                        width: 36,
                      ),

                      ///
                      /// End
                      ///
                      const SizedBox(
                        width: 36,
                      ),
                      const Padding(
                        padding: EdgeInsets.only(right: 8.0),
                        child: Text('End'),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            color: MyApp.background,
                            child: DateFieldUi(date: endDate, error: endError),
                          ),
                          if (endError.value != null)
                            Text(
                              endError.value!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 11),
                            )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Text(
                  'Row after the date range input.  It\'s good to see how it moves on input errors'),

              ///
              ///
              ///
              const SizedBox(
                height: 400,
              ),
              Watch((context) => Text('Start ${startDate.value.toString()}')),
              Watch((context) => Text('End ${endDate.value.toString()}')),
            ],
          ),
        ),
      ),
    );
  }
}
