import 'package:flutter/material.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/examples/linked_multiselects_model.dart';
import 'package:signals/signals_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

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
              Watch(
                (context) => Row(
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
                        child: Watch((context) => Multiselect2Ui(
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
                        child: Watch((context) => Multiselect2Ui(
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
                        child: Watch((context) => Multiselect2Ui(
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
              Watch((context) => Text('All ISOs: ${allIsos.value.join(', ')}')),
              Watch((context) =>
                  Text('ISO selection: ${selectedIsos.value.join(', ')}')),
              Watch((context) =>
                  Text('All locations: ${allLocations.value.join(', ')}')),
              Watch((context) => Text(
                  'Location selection: ${selectedLocations.value.join(', ')}')),
              Watch((context) =>
                  Text('All strips: ${allStrips.value.join(', ')}')),
              Watch((context) =>
                  Text('Strip selection: ${selectedStrips.value.join(', ')}')),
            ],
          ),
        ),
      ),
    );
  }
}

class Multiselect2Ui extends StatefulWidget {
  const Multiselect2Ui(
      {required this.allValues,
      required this.selectedValues,
      required this.label,
      required this.temporarySelection,
      required this.width,
      super.key});

  final Computed<Set<String>> allValues;
  final SetSignal<String> selectedValues;
  final Computed<String> label;
  final SetSignal<String> temporarySelection;
  final double width;

  @override
  State<Multiselect2Ui> createState() => _Multiselect2UiState();
}

class _Multiselect2UiState extends State<Multiselect2Ui> {
  _Multiselect2UiState();

  @override
  void initState() {
    widget.temporarySelection.value = widget.selectedValues.value;
    super.initState();
  }

  bool isAll() {
    return widget.temporarySelection.value.length ==
        widget.allValues.value.length;
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      menuChildren: getList(),
      onClose: () {
        widget.selectedValues.value = {...widget.temporarySelection.value};
      },
      builder: (context, controller, child) {
        return TextButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.0)),
          ),
          onPressed: () {
            if (controller.isOpen) {
              widget.selectedValues.value = {
                ...widget.temporarySelection.value
              };
              controller.close();
            } else {
              controller.open();
            }
          },
          child: Row(
            children: [
              Text(widget.label.value),
              const Spacer(),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 18,
              ),
            ],
          ),
        );
      },
    );
  }

  /// create the list of checkboxes + dropdown values
  List<MenuItemButton> getList() {
    var out = <MenuItemButton>[];
    out.add(MenuItemButton(
        style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
        child: Watch(
          (context) => SizedBox(
            width: widget.width,
            child: PointerInterceptor(
              child: CheckboxListTile(
                dense: true,
                value: isAll(),
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('(All)'),
                onChanged: (bool? checked) {
                  if (checked!) {
                    widget.temporarySelection.value = {
                      ...widget.allValues.value
                    };
                  } else {
                    widget.temporarySelection.value = {};
                  }
                },
              ),
            ),
          ),
        )));

    for (final value in widget.allValues.value) {
      out.add(MenuItemButton(
          style:
              ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
          child: Watch((_) => SizedBox(
                width: widget.width,
                child: PointerInterceptor(
                  child: CheckboxListTile(
                    dense: true,
                    value: widget.temporarySelection.value.contains(value),
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(value),
                    onChanged: (bool? checked) {
                      var aux = widget.temporarySelection.value;
                      if (checked!) {
                        aux.add(value);
                      } else {
                        aux.remove(value);
                      }
                      widget.temporarySelection.value = {...aux};
                    },
                  ),
                ),
              ))));
    }
    return out;
  }
}
