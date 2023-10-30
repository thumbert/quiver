import 'package:flutter/material.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// NOTES: Correct implementation with ValueNotifier.
/// Use only a FutureProvider to get the data.
/// Keep all the state inside the widget.  This is a cleaner design.
///
///

final providerOfCities = FutureProvider.autoDispose((ref) async {
  await Future.delayed(const Duration(seconds: 3));
  return <String>{
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
});

enum SelectionState {
  all('(All)'),
  none('(None)'),
  some('(Some)');

  const SelectionState(this._value);
  final String _value;

  @override
  String toString() => _value;

  SelectionState parse(String value) {
    return switch (value) {
      '(All)' => SelectionState.all,
      '(None)' => SelectionState.none,
      '(Some)' => SelectionState.some,
      _ => throw ArgumentError('Invalid SelectionState $value'),
    };
  }
}

class SelectionModel {
  SelectionModel({required this.selection, required this.choices});

  late final Set<String> selection;
  final Set<String> choices;

  SelectionState get selectionState {
    if (selection.isEmpty) return SelectionState.none;
    if (choices.difference(selection).isNotEmpty) {
      return SelectionState.some;
    } else {
      return SelectionState.all;
    }
  }

  SelectionModel add(String value) {
    return SelectionModel(selection: selection..add(value), choices: choices);
  }

  SelectionModel remove(String value) {
    selection.remove(value);
    return SelectionModel(selection: selection, choices: choices);
  }

  SelectionModel selectAll() {
    return SelectionModel(selection: {...choices}, choices: choices);
  }

  SelectionModel selectNone() {
    return SelectionModel(selection: <String>{}, choices: choices);
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
  ValueNotifier<SelectionModel> model =
  ValueNotifier(SelectionModel(selection: <String>{}, choices: <String>{}));


  List<PopupMenuItem<String>> getList(
      void Function(void Function()) setStateLocal) {
    var out = <PopupMenuItem<String>>[];
    out.add(PopupMenuItem<String>(
        padding: EdgeInsets.zero,
        value: '(All)',
        child: ValueListenableBuilder(
            valueListenable: model,
            builder: (context, _, child) {
              return CheckboxListTile(
                value: model.value.selectionState == SelectionState.all,
                controlAffinity: ListTileControlAffinity.leading,
                title: const Text('(All)'),
                onChanged: (bool? checked) {
                  setState(() {
                    if (checked!) {
                      model.value = model.value.selectAll();
                    } else {
                      model.value = model.value.selectNone();
                    }
                    setStateLocal(() {}); // trigger a rebuild
                  });
                },
              );
            })));

    for (final value in model.value.choices) {
      out.add(PopupMenuItem<String>(
          padding: EdgeInsets.zero,
          value: value,
          child: ValueListenableBuilder(
              valueListenable: model,
              builder: (context, _, child) {
                return CheckboxListTile(
                  value: model.value.selection.contains(value),
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text(value),
                  onChanged: (bool? checked) {
                    setStateLocal(() {
                      if (checked!) {
                        model.value = model.value.add(value);
                      } else {
                        model.value = model.value.remove(value);
                      }
                    });
                  },
                );
              })));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    var asyncData = ref.watch(providerOfCities);
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
                children: [
                  ///
                  /// With PopupMenuButton
                  ///
                  const SizedBox(
                    width: 36,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      width: 250,
                      color: MyApp.background,
                      child: StatefulBuilder(builder: (context, setStateLocal) {
                        return PopupMenuButton<String>(
                          constraints: const BoxConstraints(maxHeight: 400),
                          position: PopupMenuPosition.under,
                          child: asyncData.when(
                              data: (data) {
                                setStateLocal(() {
                                  if (model.value.choices.isEmpty) {
                                    /// need to initialize with the correct choice list
                                    model.value = SelectionModel(
                                        selection: {...data},
                                        choices: {...data});
                                  }
                                });
                                return Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Text(model.value.selectionState
                                          .toString()),
                                      const Spacer(),
                                      const Icon(
                                          Icons.keyboard_arrow_down_outlined),
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
                            return getList(setStateLocal);
                          },
                          onCanceled: () {
                            setState(() {
                              model.value = SelectionModel(
                                  selection: model.value.selection,
                                  choices: model.value.choices);
                            });
                          },
                        );
                      }),
                    ),
                  ),
                ],
              ),

              ///
              ///
              ///
              const SizedBox(
                height: 400,
              ),
              Text('Selected cities: ${model.value.selection.join(', ')}'),
            ],
          ),
        ),
      ),
    );
  }
}
