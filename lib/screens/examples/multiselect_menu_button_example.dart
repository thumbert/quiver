import 'package:flutter/material.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final providerOfCitySelection =
    StateNotifierProvider<SelectionNotifier, SelectionModel>(
        (ref) => SelectionNotifier(ref));

final providerOfCities = FutureProvider((ref) async {
  if (SelectionModel.allValues.length == 1) {
    await SelectionModel.getData();
  }
  return SelectionModel.allValues;
});

class SelectionModel {
  SelectionModel(this.selection);

  Set<String> selection = <String>{
    '(All)',
  };
  // String title = 'Select';

  static Set<String> allValues = <String>{'(All)'};

  String getTitle() {
    if (selection.isEmpty) return '(None)';
    if (!selection.contains('(All)')) {
      return '(Some)';
    } else {
      return '(All)';
    }

  }

  void add(String value) {
    if (value == '(All)') {
      selection = {...SelectionModel.allValues};
    } else {
      selection.add(value);
    }
  }

  void remove(String value) {
    if (value == '(All)') {
      selection.clear();
    } else {
      selection.remove(value);
      selection.remove('(All)');
    }
  }

  static Future<void> getData() async {
    await Future.delayed(const Duration(seconds: 1));
    allValues = {
      '(All)',
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
  }

  SelectionModel copyWith(Set<String>? selection) {
    return SelectionModel(selection ?? this.selection);
  }
}

class SelectionNotifier extends StateNotifier<SelectionModel> {
  SelectionNotifier(this.ref) : super(SelectionModel({'(All)'}));

  final Ref ref;

  set add(String value) {
    state = state.copyWith(state.selection);
    state.add(value);
  }

  set remove(String value) {
    state = state.copyWith(state.selection);
    state.remove(value);
  }
}

class MultiSelectMenuButtonExample extends ConsumerStatefulWidget {
  const MultiSelectMenuButtonExample({super.key});
  static const route = '/multiselect_menu_button_example';
  @override
  ConsumerState<MultiSelectMenuButtonExample> createState() =>
      _DropdownExampleState();
}

final class Item {
  Item({required this.name, required this.checked});
  bool checked;
  String name;
}

class _DropdownExampleState extends ConsumerState<MultiSelectMenuButtonExample> {

  Set<String> selection = {'(All)'};
  bool clickedAll = false;
  List<Item> items = [Item(name: '(All)', checked: true)];

  /// With PopupMenuItem
  List<PopupMenuItem<String>> getList2() {
    var model = ref.watch(providerOfCitySelection);
    var out = <PopupMenuItem<String>>[];
    if (model.selection.contains('(All)')) {
      setState(() {
        ref.read(providerOfCitySelection.notifier).add = '(All)';
      });
    }
    for (final value in SelectionModel.allValues) {
      out.add(PopupMenuItem<String>(
        padding: EdgeInsets.zero,
        value: value,
        child: Consumer(
          builder: (context, ref, child) {
            var model = ref.watch(providerOfCitySelection);
            return CheckboxListTile(
              value: model.selection.contains(value),
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(value),
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
    var asyncData = ref.watch(providerOfCities);
    var model = ref.watch(providerOfCitySelection);

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
                        child: asyncData.when(
                            data: (cities) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(model.getTitle()),
                              );
                            },
                            error: (err, stack) => const Text('Oops'),
                            loading: () => const Row(
                                  children: [
                                    CircularProgressIndicator(),
                                    Text('    Fetching ...'),
                                  ],
                                )),
                        itemBuilder: (context) => getList2(),
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
              Text('Selected cities: ${model.selection.join(', ')}'),
            ],
          ),
        ),
      ),
    );
  }
}
