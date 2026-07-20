import 'package:flutter/material.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/examples/linked_multiselects_model.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:flutter_quiver/screens/common/signal/multiselect3.dart';


/// NOTE: Implementation done with signals.

class LinkedMultiSelectsExample extends StatefulWidget {
  const LinkedMultiSelectsExample({super.key});
  static const route = '/linked_multiselects_example';

  @override
  State<LinkedMultiSelectsExample> createState() =>
      _LinkedMultiSelectsExampleState();
}

class _LinkedMultiSelectsExampleState extends State<LinkedMultiSelectsExample> {
  late void Function() updateLocations;
  late void Function() updateStrips;

  @override
  void initState() {
    super.initState();

    /// NOTE: Need to register this effect here!
    /// After [allLocations] change, reset [selectedLocations] and [tempSelectionLocation]
    updateLocations = effect(() {
      selectedLocations.value = {...allLocations.value};
      tempSelectionLocation.value = {...allLocations.value};
      // Need to setState below to update the location dropdown!
      setState(() {});
    });
    updateStrips = effect(() {
      selectedStrips.value = {...allStrips.value};
      tempSelectionStrip.value = {...allStrips.value};
      // Need to setState below to update the strip dropdown!
      setState(() {});
    });
  }

  @override
  void dispose() {
    updateLocations();
    updateStrips();
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
              const Text(
                  'Three linked dropdowns.  Select an ISO in the first one '
                  'to see a narrow the list of locations in the second dropdown, etc.'),
              SignalBuilder(
                builder: (context) => Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ///
                    /// ISO
                    ///
                    const SizedBox(
                      width: 36,
                    ),
                    const Text('ISO'),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 160,
                        color: MyApp.background,
                        child: SignalBuilder(builder: (context) => MultiselectUi(
                            allValues: allIsos,
                            selectedValues: selectedIsos,
                            label: labelIsos,
                            temporarySelection: tempSelectionIso,
                            width: 160)),
                      ),
                    ),
                    const SizedBox(
                      width: 36,
                    ),

                    ///
                    /// Location
                    ///
                    const Text('Location'),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 200,
                        color: MyApp.background,
                        child: SignalBuilder(builder: (context) => MultiselectUi(
                            allValues: allLocations,
                            selectedValues: selectedLocations,
                            label: labelLocations,
                            temporarySelection: tempSelectionLocation,
                            width: 200)),
                      ),
                    ),
                    const SizedBox(
                      width: 36,
                    ),

                    ///
                    /// Strip
                    ///
                    const Text('Strip'),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 200,
                        color: MyApp.background,
                        child: SignalBuilder(builder: (context) => MultiselectUi(
                            allValues: allStrips,
                            selectedValues: selectedStrips,
                            label: labelStrips,
                            temporarySelection: tempSelectionStrip,
                            width: 200)),
                      ),
                    ),
                  ],
                ),
              ),

              ///
              ///
              ///
              const SizedBox(
                height: 400,
              ),
              SignalBuilder(builder: (context) => Text('All ISOs: ${allIsos.value.join(', ')}')),
              SignalBuilder(builder: (context) =>
                  Text('ISO selection: ${selectedIsos.value.join(', ')}')),
              SignalBuilder(builder: (context) =>
                  Text('All locations: ${allLocations.value.join(', ')}')),
              SignalBuilder(builder: (context) => Text(
                  'Location selection: ${selectedLocations.value.join(', ')}')),
              SignalBuilder(builder: (context) =>
                  Text('All strips: ${allStrips.value.join(', ')}')),
              SignalBuilder(builder: (context) =>
                  Text('Strip selection: ${selectedStrips.value.join(', ')}')),
            ],
          ),
        ),
      ),
    );
  }
}

