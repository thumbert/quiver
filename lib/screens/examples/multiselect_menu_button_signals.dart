import 'package:flutter/material.dart';
import 'package:flutter_quiver/screens/common/signal/multiselect.dart';
import 'package:flutter_quiver/screens/common/signal/multiselect_search.dart';
import 'package:signals/signals_flutter.dart';

/// NOTES: Use signals 🤷‍♂️
/// The easiest implementation!  Uses a StatelessWidget!
/// You don't need setState(){}!  Need to wrap it in a Watch()!

final cities = <String>{
  'Atlanta',
  'Baltimore',
  'Boston',
  'Chicago',
  'Denver',
  'Houston',
  'Los Angeles',
  'Philadelphia',
  'San Francisco',
  'Washington, DC',
};

/// Just use my custom multiselect widget.
///
class MultiSelectMenuButtonExample extends StatelessWidget {
  const MultiSelectMenuButtonExample({super.key});
  static const route = '/multiselect_menu_button_example';
  static final model =
      SelectionModel(initialSelection: cities.toSignal(), choices: cities);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                SizedBox(
                  width: 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('Simple selection'),
                      Container(
                          width: 226,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade50,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Watch(
                            (_) => MultiselectUi(
                              model: model,
                              width: 226,
                            ),
                          )),
                      const SizedBox(
                        height: 500,
                      ),
                      Watch((context) => Text(
                          'Currently selected cities: ${model.currentSelection.value.join(', ')}')),
                      Watch((context) => Text(
                          'Selected cities: ${model.selection.value.join(', ')}')),
                    ],
                  ),
                ),
                ///
                ///
                ///
                const SizedBox(
                  width: 48,
                ),
                ///
                ///
                ///
                SizedBox(
                  width: 400,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('Selection with search'),

                      Container(
                          width: 226,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey.shade50,
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          child: Watch(
                            (_) => MultiselectSearchUi(
                              model: model,
                              width: 226,
                            ),
                          )),

                      ///
                      ///
                      ///
                      const SizedBox(
                        height: 500,
                      ),
                      Watch((context) => Text(
                          'Currently selected cities: ${model.currentSelection.value.join(', ')}')),
                      Watch((context) => Text(
                          'Selected cities: ${model.selection.value.join(', ')}')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
