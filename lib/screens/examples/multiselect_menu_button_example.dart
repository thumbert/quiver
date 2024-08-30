import 'package:flutter/material.dart';
import 'package:flutter_quiver/screens/common/signal/multiselect.dart';
import 'package:flutter_quiver/screens/common/signal/autocomplete.dart';
import 'package:flutter_quiver/screens/common/signal/multiselect_search.dart';
import 'package:signals/signals_flutter.dart';
import '../../data/locations.dart';

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

class MultiSelectMenuButtonExample extends StatefulWidget {
  const MultiSelectMenuButtonExample({super.key});
  static const route = '/multiselect_menu_button_example';

  @override
  State<StatefulWidget> createState() => _MultiSelectExampleState();
}

class _MultiSelectExampleState extends State<MultiSelectMenuButtonExample> {
  static final model =
      SelectionModel(initialSelection: cities, choices: cities);
  static final location = Signal<String>('', debugLabel: 'location');
  static final hubs = ['PJM WH RT', 'NI Hub RT', 'AD Hub DA'].toSignal();

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
                ///
                /// Simple selection (no search)
                ///
                SizedBox(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('Simple multi selection'),
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
                const SizedBox(
                  width: 48,
                ),

                ///
                /// Multiselect with search (small number of items)
                ///
                SizedBox(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('Multiple selection with search'),
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
                /// Select one item with Autocomplete search
                ///
                SizedBox(
                  width: 380,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('Selection with search'),
                      Row(
                        children: [
                          Container(
                            width: 300,
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.shade50,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Watch((_) => AutocompleteUi(
                                  selection: location,
                                  choices: locations.toSet(),
                                  width: 300,
                                  key: ValueKey(location
                                      .value), // needed to wipe the textfield on icon clear
                                )),
                          ),
                          IconButton(
                              onPressed: () {
                                location.value = '';
                                setState(() {}); // need to force a build
                              },
                              icon: const Icon(Icons.clear)),
                        ],
                      ),
                      const SizedBox(
                        height: 500,
                      ),
                      Watch((context) => Text(
                          'Currently selected location: ${location.value}')),
                    ],
                  ),
                ),

                ///
                /// Select several items with search
                ///
                SizedBox(
                  width: 300,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('Accumulating selection'),
                      Container(
                        width: 300,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade50,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Watch(
                          (_) => AutocompleteUi(
                            selection: location,
                            choices: locations.toSet(),
                            accumulatedSelection: hubs,
                            width: 300,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 32,
                      ),
                      Watch((context) {
                        return Wrap(
                          direction: Axis.vertical,
                          spacing: 5.0,
                          children: List.generate(hubs.value.length, (index) {
                            return InputChip(
                              label: Text(hubs.value[index]),
                              backgroundColor: Colors.purple.shade50,
                              side: BorderSide.none,
                              onDeleted: () {
                                var aux = [...hubs.value];
                                aux.removeAt(index);
                                hubs.value = aux;
                              },
                            );
                          }),
                        );
                      }),
                      const SizedBox(
                        height: 400,
                      ),
                      Watch((context) => Text(
                          'Currently selected locations: ${hubs.value.join(', ')}')),
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
