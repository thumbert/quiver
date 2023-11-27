import 'package:flutter/material.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/common/multiple_selection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// NOTE: Implementation done with Riverpod.
///
/// No issues
///

const data = <String, List<String>>{
  'California': ['Los Angeles', 'San Francisco'],
  'Georgia': ['Atlanta', 'Savannah'],
  'Maryland': ['Baltimore', 'Rockville'],
  'New York': ['Albany', 'Buffalo', 'NYC'],
  'Texas': ['Dallas', 'Houston'],
};

final providerOfStateSelection = StateNotifierProvider<
    MultipleSelectionNotifier<String>, MultipleSelectionModel<String>>((ref) {
  var out = MultipleSelectionNotifier<String>(ref);
  out.init({...data.keys}, {...data.keys});
  return out;
});

final providerOfCitySelection = StateNotifierProvider<
    MultipleSelectionNotifier<String>, MultipleSelectionModel<String>>((ref) {
  var out = MultipleSelectionNotifier<String>(ref);
  var allCities = data.values.expand((e) => e).toList();
  allCities.sort();
  out.init({...allCities}, {...allCities});
  return out;
});

class TwoLinkedMultiSelectsExample extends ConsumerStatefulWidget {
  const TwoLinkedMultiSelectsExample({super.key});
  static const route = '/two_linked_multiselects_example';
  @override
  ConsumerState<TwoLinkedMultiSelectsExample> createState() =>
      _DropdownExampleState();
}

class _DropdownExampleState
    extends ConsumerState<TwoLinkedMultiSelectsExample> {
  Set<String> states = <String>{};
  Set<String> cities = <String>{};

  List<PopupMenuItem<String>> getStateList() {
    var model = ref.watch(providerOfStateSelection);
    var out = <PopupMenuItem<String>>[];
    if (model.selectionState == MultipleSelectionState.all) {
      setState(() {
        ref.read(providerOfStateSelection.notifier).selectAll();
      });
    } else if (model.selectionState == MultipleSelectionState.none) {
      setState(() {
        ref.read(providerOfStateSelection.notifier).selectNone();
      });
    }
    out.add(PopupMenuItem<String>(
      padding: EdgeInsets.zero,
      value: '(All)',
      child: Consumer(
        builder: (context, ref, child) {
          var model = ref.watch(providerOfStateSelection);
          return CheckboxListTile(
            value: model.selectionState == MultipleSelectionState.all,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              '(All)',
              style: TextStyle(fontFamily: 'Ubuntu'),
            ),
            onChanged: (bool? checked) {
              setState(() {
                if (checked!) {
                  ref.read(providerOfStateSelection.notifier).selectAll();
                } else {
                  ref.read(providerOfStateSelection.notifier).selectNone();
                }
              });
            },
          );
        },
      ),
    ));

    for (final value in model.choices) {
      out.add(PopupMenuItem<String>(
        padding: EdgeInsets.zero,
        value: value,
        child: Consumer(
          builder: (context, ref, child) {
            var model = ref.watch(providerOfStateSelection);
            return CheckboxListTile(
              value: model.selection.contains(value),
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(value, style: const TextStyle(fontFamily: 'Ubuntu')),
              onChanged: (bool? checked) {
                setState(() {
                  if (checked!) {
                    ref.read(providerOfStateSelection.notifier).add = value;
                  } else {
                    ref.read(providerOfStateSelection.notifier).remove = value;
                  }
                });
              },
            );
          },
        ),
      ));
    }
    return out;
  }

  List<PopupMenuItem<String>> getCityList() {
    var model = ref.watch(providerOfCitySelection);
    var out = <PopupMenuItem<String>>[];
    if (model.selectionState == MultipleSelectionState.all) {
      setState(() {
        ref.read(providerOfCitySelection.notifier).selectAll();
      });
    } else if (model.selectionState == MultipleSelectionState.none) {
      setState(() {
        ref.read(providerOfCitySelection.notifier).selectNone();
      });
    }
    out.add(PopupMenuItem<String>(
      padding: EdgeInsets.zero,
      value: '(All)',
      child: Consumer(
        builder: (context, ref, child) {
          var model = ref.watch(providerOfCitySelection);
          return CheckboxListTile(
            value: model.selectionState == MultipleSelectionState.all,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text(
              '(All)',
              style: TextStyle(fontFamily: 'Ubuntu'),
            ),
            onChanged: (bool? checked) {
              setState(() {
                if (checked!) {
                  ref.read(providerOfCitySelection.notifier).selectAll();
                } else {
                  ref.read(providerOfCitySelection.notifier).selectNone();
                }
              });
            },
          );
        },
      ),
    ));

    for (final value in model.choices) {
      out.add(PopupMenuItem<String>(
        padding: EdgeInsets.zero,
        value: value,
        child: Consumer(
          builder: (context, ref, child) {
            var model = ref.watch(providerOfCitySelection);
            return CheckboxListTile(
              value: model.selection.contains(value),
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(value, style: const TextStyle(fontFamily: 'Ubuntu')),
              onChanged: (bool? checked) {
                setState(() {
                  if (checked!) {
                    ref.read(providerOfCitySelection.notifier).add = value;
                  } else {
                    ref.read(providerOfCitySelection.notifier).remove = value;
                  }
                });
              },
            );
          },
        ),
      ));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    var stateSelection = ref.watch(providerOfStateSelection);
    var citySelection = ref.watch(providerOfCitySelection);

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
                  'Two linked dropdowns.  Select a US state in the first one '
                  'to see a narrow the list of cities in the second dropdown.'),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///
                  /// State
                  ///
                  const SizedBox(
                    width: 36,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      width: 250,
                      color: MyApp.background,
                      child: PopupMenuButton<String>(
                        constraints:
                            const BoxConstraints(minWidth: 250, maxHeight: 400),
                        position: PopupMenuPosition.under,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(
                                stateSelection.selectionState.toString(),
                                style: const TextStyle(
                                    fontFamily: 'Ubuntu', fontSize: 16),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.keyboard_arrow_down_outlined,
                                color: Colors.grey[700],
                              ),
                            ],
                          ),
                        ),
                        itemBuilder: (context) {
                          return getStateList();
                        },
                        onCanceled: () {
                          setState(() {
                            states = {...stateSelection.selection};
                            var cityChoices = stateSelection.selection
                                .expand((stateName) => data[stateName]!)
                                .toList();
                            cityChoices.sort();
                            ref
                                .read(providerOfCitySelection.notifier)
                                .init({...cityChoices}, {...cityChoices});
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 36,
                  ),

                  ///
                  /// City
                  ///
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      width: 250,
                      color: MyApp.background,
                      child: PopupMenuButton<String>(
                        constraints:
                            const BoxConstraints(minWidth: 250, maxHeight: 400),
                        position: PopupMenuPosition.under,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(
                                citySelection.selectionState.toString(),
                                style: const TextStyle(
                                    fontFamily: 'Ubuntu', fontSize: 16),
                              ),
                              const Spacer(),
                              Icon(
                                Icons.keyboard_arrow_down_outlined,
                                color: Colors.grey[700],
                              ),
                            ],
                          ),
                        ),
                        itemBuilder: (context) {
                          return getCityList();
                        },
                        onCanceled: () {
                          setState(() {
                            cities = {...citySelection.selection};
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),

              ///
              ///
              ///
              const SizedBox(
                height: 600,
              ),
              Text('State selection: ${stateSelection.selection.join(', ')}'),
              Text('City selection: ${citySelection.selection.join(', ')}'),
            ],
          ),
        ),
      ),
    );
  }
}
