import 'package:flutter/material.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// NOTE: Implementation done with Riverpod.
///
/// No issues
///

final providerOfCitySelection = StateNotifierProvider<
    MultipleSelectionNotifier<String>,
    MultipleSelectionModel<String>>((ref) => MultipleSelectionNotifier(ref));

final providerOfCities = FutureProvider((ref) async {
  await Future.delayed(const Duration(seconds: 1));
  var choices = <String>{
    'Atlanta',
    'Austin',
    'Baltimore',
    'Boston',
    'Chicago',
    'Dallas',
    'Denver',
    'Houston',
    'Los Angeles',
    'Minneapolis',
    'Philadelphia',
    'Portland',
    'San Francisco',
    'Washington, DC',
  };
  ref.read(providerOfCitySelection.notifier).init({...choices}, {...choices});
  return choices;
});

enum MultipleSelectionState {
  all('(All)'),
  none('(None)'),
  some('(Some)');

  const MultipleSelectionState(this._value);
  final String _value;

  @override
  String toString() => _value;

  MultipleSelectionState parse(String value) {
    return switch (value) {
      '(All)' => MultipleSelectionState.all,
      '(None)' => MultipleSelectionState.none,
      '(Some)' => MultipleSelectionState.some,
      _ => throw ArgumentError('Invalid SelectionState $value'),
    };
  }
}

class MultipleSelectionModel<K> {
  MultipleSelectionModel({required this.selection, required this.choices});

  late final Set<K> selection;
  final Set<K> choices;

  MultipleSelectionState get selectionState {
    if (selection.isEmpty) return MultipleSelectionState.none;
    if (choices.difference(selection).isNotEmpty) {
      return MultipleSelectionState.some;
    } else {
      return MultipleSelectionState.all;
    }
  }

  MultipleSelectionModel<K> add(K value) {
    return MultipleSelectionModel(
        selection: selection..add(value), choices: choices);
  }

  MultipleSelectionModel<K> remove(K value) {
    selection.remove(value);
    return MultipleSelectionModel(selection: selection, choices: choices);
  }

  MultipleSelectionModel<K> selectAll() {
    return MultipleSelectionModel(selection: {...choices}, choices: choices);
  }

  MultipleSelectionModel<K> selectNone() {
    return MultipleSelectionModel(selection: <K>{}, choices: choices);
  }

  MultipleSelectionModel<K> clone() => MultipleSelectionModel(
      selection: <K>{...selection}, choices: <K>{...choices});

  MultipleSelectionModel<K> copyWith({Set<K>? selection, Set<K>? choices}) {
    return MultipleSelectionModel(
        selection: selection ?? this.selection,
        choices: choices ?? this.choices);
  }
}

class MultipleSelectionNotifier<K>
    extends StateNotifier<MultipleSelectionModel<K>> {
  MultipleSelectionNotifier(this.ref)
      : super(MultipleSelectionModel(selection: <K>{}, choices: <K>{}));
  final Ref ref;
  set add(K value) {
    state = state.add(value);
  }

  void selectAll() {
    state = state.selectAll();
  }

  set remove(K value) {
    state = state.remove(value);
  }

  void selectNone() {
    state = state.selectNone();
  }

  void init(Set<K> selection, Set<K> choices) {
    state = state.copyWith(selection: selection, choices: choices);
  }
}

class MultiSelectMenuButtonExample extends ConsumerStatefulWidget {
  const MultiSelectMenuButtonExample({super.key});
  static const route = '/multiselect_menu_button_example';
  @override
  ConsumerState<MultiSelectMenuButtonExample> createState() =>
      _DropdownExampleState();
}

class _DropdownExampleState
    extends ConsumerState<MultiSelectMenuButtonExample> {
  Set<String> selection = <String>{};

  List<PopupMenuItem<String>> getList() {
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
    var cityChoices = ref.watch(providerOfCities);
    var model = ref.watch(providerOfCitySelection);
    if (selection.isEmpty) {
      /// sync the selection to the model.selection after data is acquired
      selection = {...model.selection};
    }

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    width: 36,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      width: 250,
                      color: MyApp.background,
                      child: PopupMenuButton<String>(
                        constraints: const BoxConstraints(maxHeight: 400),
                        position: PopupMenuPosition.under,
                        child: cityChoices.when(
                            data: (data) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      model.selectionState.toString(),
                                      style: const TextStyle(
                                          fontFamily: 'Ubuntu', fontSize: 16),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.keyboard_arrow_down_outlined,
                                      color: Colors.blueGrey,
                                    ),
                                  ],
                                ),
                              );
                            },
                            error: (err, stack) => const Text('Oops'),
                            loading: () => const Row(
                              children: [
                                CircularProgressIndicator(),
                                Text('    Fetching ...'),
                              ],
                            )),
                        itemBuilder: (context) {
                          return getList();
                        },
                        onCanceled: () {
                          setState(() {
                            selection = {...model.selection};
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
              Text('model.selection cities: ${model.selection.join(', ')}'),
              Text('selection cities: ${selection.join(', ')}'),
            ],
          ),
        ),
      ),
    );
  }
}