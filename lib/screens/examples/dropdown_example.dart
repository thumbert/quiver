import 'package:flutter/material.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as rp;
import 'package:signals/signals_flutter.dart';

final selection = 'State'.toSignal();

final choices = futureSignal(() async {
  await Future.delayed(const Duration(seconds: 2));
  if (selection.value == 'State') {
    return ['CA', 'MA', 'MD', 'NY'];
  } else {
    return ['Atlanta', 'Boston', 'Chicago', 'Denver'];
  }
}, dependencies: [selection]);

final providerOfExampleData = rp.FutureProvider((ref) async {
  return getData();
});

Future<List<Map<String, String>>> getData() async {
  // a long network call
  await Future.delayed(const Duration(seconds: 3));
  return [
    {'country': 'USA', 'city': 'Baltimore'},
    {'country': 'USA', 'city': 'Boston'},
    {'country': 'USA', 'city': 'Denver'},
    {'country': 'USA', 'city': 'Philadelphia'},
    {'country': 'USA', 'city': 'Washington, DC'},
    {'country': 'Belgium', 'city': 'Bruxelles'},
    {'country': 'Canada', 'city': 'Montreal'},
    {'country': 'Canada', 'city': 'Quebec'},
    {'country': 'Canada', 'city': 'Toronto'},
    {'country': 'France', 'city': 'Paris'},
    {'country': 'Germany', 'city': 'Paris'},
    {'country': 'Italy', 'city': 'Rome'},
  ];
}

List<String> getCountries(List<Map<String, String>> data) {
  if (data.isEmpty) return ['(All)'];
  return data.map((e) => e['country'] as String).toSet().toList();
}

List<String> getCity(List<Map<String, String>> data, String country) {
  if (data.isEmpty) return ['(All)'];
  return data
      .where((e) => e['country'] == country)
      .map((e) => e['city'] as String)
      .toSet()
      .toList();
}

class DropdownExample extends rp.ConsumerStatefulWidget {
  const DropdownExample({super.key});

  static const route = '/dropdown_example';

  @override
  rp.ConsumerState<DropdownExample> createState() => _DropdownExampleState();
}

class _DropdownExampleState extends rp.ConsumerState<DropdownExample> {
  final TextEditingController colorController = TextEditingController();
  final TextEditingController iconController = TextEditingController();
  ColorLabel? selectedColor;
  IconLabel? selectedIcon;
  final FocusNode _buttonFocusNode = FocusNode(debugLabel: 'Push me!');

  @override
  Widget build(BuildContext context) {
    final List<DropdownMenuEntry<ColorLabel>> colorEntries =
        <DropdownMenuEntry<ColorLabel>>[];
    for (final ColorLabel color in ColorLabel.values) {
      colorEntries.add(
        DropdownMenuEntry<ColorLabel>(
            value: color, label: color.label, enabled: color.label != 'Grey'),
      );
    }

    final List<DropdownMenuEntry<IconLabel>> iconEntries =
        <DropdownMenuEntry<IconLabel>>[];
    for (final IconLabel icon in IconLabel.values) {
      iconEntries
          .add(DropdownMenuEntry<IconLabel>(value: icon, label: icon.label));
    }

    // var asyncData = ref.watch(providerOfExampleData);

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    DropdownMenu<ColorLabel>(
                      initialSelection: ColorLabel.green,
                      controller: colorController,
                      label: const Text('Color'),
                      dropdownMenuEntries: colorEntries,
                      onSelected: (ColorLabel? color) {
                        setState(() {
                          selectedColor = color;
                        });
                      },
                    ),
                    const SizedBox(width: 20),
                    DropdownMenu<IconLabel>(
                      controller: iconController,
                      enableFilter: true,
                      leadingIcon: const Icon(Icons.search),
                      label: const Text('Icon'),
                      dropdownMenuEntries: iconEntries,
                      inputDecorationTheme: const InputDecorationTheme(
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                      ),
                      onSelected: (IconLabel? icon) {
                        setState(() {
                          selectedIcon = icon;
                        });
                      },
                    ),
                    const SizedBox(
                      width: 12,
                    ),
                    DropdownMenu<IconLabel>(
                      controller: iconController,
                      enableFilter: true,
                      leadingIcon: const Icon(Icons.search),
                      label: const Text('Icon'),
                      dropdownMenuEntries: iconEntries,
                      inputDecorationTheme: const InputDecorationTheme(
                        isDense: true,
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 5.0),
                      ),
                      onSelected: (IconLabel? icon) {
                        setState(() {
                          selectedIcon = icon;
                        });
                      },
                    ),
                  ],
                ),
              ),
              if (selectedColor != null && selectedIcon != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                        'You selected a ${selectedColor?.label} ${selectedIcon?.label}'),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(
                        selectedIcon?.icon,
                        color: selectedColor?.color,
                      ),
                    )
                  ],
                )
              else
                const Text('Please select a color and an icon.'),
              const SizedBox(
                height: 48,
              ),

              ///
              ///
              /// A Signals example .......
              ///
              ///
              const Text(
                  'With Signals:  A dropdown that changes depending on the button you press!'),
              const SizedBox(
                height: 8,
              ),

              SizedBox(
                width: 500,
                child: Row(
                  children: [
                    SegmentedButton(
                      segments: const [
                        ButtonSegment(value: 'State', label: Text('State')),
                        ButtonSegment(value: 'City', label: Text('City')),
                      ],
                      selected: {selection.value},
                      onSelectionChanged: (Set<String> newSelection) {
                        selection.value = newSelection.first;
                        setState(() {});
                      },
                    ),
                    const SizedBox(
                      width: 24,
                    ),
                    Watch((context) => MenuAnchor(
                            menuChildren: [
                              for (var e in choices.value.value ?? [])
                                MenuItemButton(child: Text(e))
                            ],
                            builder: (BuildContext context,
                                MenuController controller, Widget? child) {
                              return TextButton(
                                  focusNode: _buttonFocusNode,
                                  onPressed: () {
                                    if (controller.isOpen) {
                                      controller.close();
                                    } else {
                                      controller.open();
                                    }
                                  },
                                  child: switch (choices.value) {
                                    AsyncLoading() => const Text('Loading...'),
                                    _ => const Text('PUSH ME'),
                                  });
                            })),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExampleHeader extends rp.ConsumerStatefulWidget {
  const ExampleHeader(this.data, {super.key});

  final List<Map<String, String>> data;

  @override
  rp.ConsumerState<ExampleHeader> createState() => _ExampleHeaderState();
}

class _ExampleHeaderState extends rp.ConsumerState<ExampleHeader> {
  final controllerCountry = TextEditingController();

  @override
  void initState() {
    super.initState();
    controllerCountry.text = 'USA';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DropdownMenu(
          width: 160,
          enableFilter: true,
          controller: controllerCountry,
          // label: const Text('Country'),
          inputDecorationTheme: InputDecorationTheme(
            isDense: true,
            isCollapsed: true,
            filled: true,
            fillColor: MyApp.background,
            contentPadding: const EdgeInsets.only(left: 8.0),
          ),
          dropdownMenuEntries: getCountries(widget.data)
              .map((e) => DropdownMenuEntry(value: e, label: e))
              .toList(),
          onSelected: (String? value) {
            print('Boo');
          },
        ),
      ],
    );
  }
}

enum ColorLabel {
  blue('Blue', Colors.blue),
  pink('Pink', Colors.pink),
  green('Green', Colors.green),
  yellow('Yellow', Colors.yellow),
  grey('Grey', Colors.grey);

  const ColorLabel(this.label, this.color);
  final String label;
  final Color color;
}

enum IconLabel {
  smile('Smile', Icons.sentiment_satisfied_outlined),
  cloud(
    'Cloud',
    Icons.cloud_outlined,
  ),
  brush('Brush', Icons.brush_outlined),
  heart('Heart', Icons.favorite);

  const IconLabel(this.label, this.icon);
  final String label;
  final IconData icon;
}


              ///
              /// An example with Riverpod
              ///
              // const SizedBox(
              //   height: 48,
              // ),
              // const Text('With Riverpod:  A dropdown with async values, and progress indicator next to it'),
              // const SizedBox(
              //   height: 8,
              // ),
              // asyncData.when(
              //   data: (data) => ExampleHeader(data),
              //   error: (e, trace) => const Text('Boo'),
              //   loading: () => const Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       ExampleHeader([]),
              //       CircularProgressIndicator(),
              //     ],
              //   ),
              // ),
              // const SizedBox(
              //   height: 48,
              // ),
