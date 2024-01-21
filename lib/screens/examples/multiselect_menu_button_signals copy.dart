import 'package:flutter/material.dart';
import 'package:flutter_quiver/main.dart';
import 'package:signals/signals_flutter.dart';

/// NOTES: Use signals 🤷‍♂️
/// The easiest implementation! 
/// 

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

final model = SelectionModel(selection: cities.toSignal(), choices: cities);

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

  late final Signal<Set<String>> selection;
  final Set<String> choices;

  SelectionState get selectionState {
    if (selection.value.isEmpty) return SelectionState.none;
    if (choices.difference(selection.value).isNotEmpty) {
      return SelectionState.some;
    } else {
      return SelectionState.all;
    }
  }

  void add(String value) {
    selection.value = {...selection.value, value};
  }

  void remove(String value) {
    selection.value.remove(value);
  }

  void selectAll() {
    selection.value = {...choices};
  }

  void selectNone() {
    selection.value = <String>{};
  }
}

class MultiSelectMenuButtonExample extends StatefulWidget {
  const MultiSelectMenuButtonExample({super.key});
  static const route = '/multiselect_menu_button_example';
  @override
  State<MultiSelectMenuButtonExample> createState() => _DropdownExampleState();
}

class _DropdownExampleState extends State<MultiSelectMenuButtonExample> {
  List<PopupMenuItem<String>> getList() {
    var out = <PopupMenuItem<String>>[];
    out.add(PopupMenuItem<String>(
        padding: EdgeInsets.zero,
        value: '(All)',
        child: Watch(
          (_) => CheckboxListTile(
            value: model.selectionState == SelectionState.all,
            controlAffinity: ListTileControlAffinity.leading,
            title: const Text('(All)'),
            onChanged: (bool? checked) {
              setState(() {
                if (checked!) {
                  model.selectAll();
                } else {
                  model.selectNone();
                }
              });
            },
          ),
        )));

    for (final value in model.choices) {
      out.add(PopupMenuItem<String>(
          padding: EdgeInsets.zero,
          value: value,
          child: Watch((_) => CheckboxListTile(
                value: model.selection.value.contains(value),
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(value),
                onChanged: (bool? checked) {
                  if (checked!) {
                    model.add(value);
                  } else {
                    model.remove(value);
                  }
                },
              ))));
    }
    return out;
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
                      child: PopupMenuButton<String>(
                        constraints: const BoxConstraints(maxHeight: 400),
                        position: PopupMenuPosition.under,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Watch((context) =>
                                  Text(model.selectionState.toString())),
                              const Spacer(),
                              const Icon(Icons.keyboard_arrow_down_outlined),
                            ],
                          ),
                        ),
                        itemBuilder: (context) {
                          return getList();
                        },
                        onCanceled: () {
                          setState(() {
                            // selection = {...model.selection};
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
                height: 400,
              ),
              Watch((context) =>
                  Text('Selected cities: ${model.selection.value.join(', ')}')),
            ],
          ),
        ),
      ),
    );
  }
}
