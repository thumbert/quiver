import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

final providerOfCities = FutureProvider((ref) async {
  return getData();
});

Future<Set<String>> getData() async {
  // a long network call
  await Future.delayed(const Duration(seconds: 3));
  return {
    'Atlanta',
    'Baltimore',
    'Boston',
    'Chicago',
    'Philadelphia',
    'Washington, DC',
  };
}

/// See https://github.com/ubuntu/yaru_widgets.dart/blob/main/example/lib/pages/popup_page.dart
class YaruPopupMenuButtonExample extends ConsumerStatefulWidget {
  const YaruPopupMenuButtonExample({super.key});

  static const route = '/yaru_popup_menu_button_example';

  @override
  ConsumerState<YaruPopupMenuButtonExample> createState() =>
      _DropdownExampleState();
}

class _DropdownExampleState extends ConsumerState<YaruPopupMenuButtonExample> {
  Set<MyEnum> enumSet = {MyEnum.option1, MyEnum.option3};
  var allCities = <String>{};
  var selection = <String>{};

  @override
  Widget build(BuildContext context) {
    var asyncData = ref.watch(providerOfCities);

    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        // colorSchemeSeed: Colors.green,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: YaruPopupMenuButton<MyEnum>(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.blue,
                  ),
                  child: const Text('Multi Select'),
                  itemBuilder: (context) {
                    return [
                      for (final value in MyEnum.values)
                        YaruMultiSelectPopupMenuItem<MyEnum>(
                          value: value,
                          checked: enumSet.contains(value),
                          onChanged: (checked) {
                            // Handle model changes here
                            setState(() {
                              checked
                                  ? enumSet.add(value)
                                  : enumSet.remove(value);
                            });
                          },
                          child: Text(value.name),
                        ),
                    ];
                  },
                ),
              ),

              OutlinedButton(
                  style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      backgroundColor: Colors.orange,
                      side: const BorderSide(width: 2, color: Colors.orange)
                  ),

                  onPressed: () {},
                  child: const Text('Push it')),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: YaruPopupMenuButton<String>(
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.green,
                      backgroundColor: Colors.orange),
                  // style: ButtonStyle(
                  //   textStyle: MaterialStateProperty.all(TextStyle(backgroundColor: Colors.pink)),
                  //   backgroundColor: MaterialStatePropertyAll<Color>(Colors.orange),
                  //   foregroundColor:
                  //       MaterialStateColor.resolveWith((e) => Colors.blue),
                  // ),
                  child: asyncData.when(
                      data: (cities) {
                        setState(() {
                          allCities = {...cities};
                        });
                        return const Text('Select city');
                      },
                      error: (err, stack) => const Text('Oops'),
                      loading: () => const CircularProgressIndicator()),
                  itemBuilder: (context) {
                    return [
                      for (final value in allCities)
                        YaruMultiSelectPopupMenuItem<String>(
                          value: value,
                          checked: selection.contains(value),
                          onChanged: (checked) {
                            // Handle model changes here
                            setState(() {
                              checked
                                  ? selection.add(value)
                                  : selection.remove(value);
                            });
                          },
                          child: Text(value),
                        ),
                    ];
                  },
                ),
              ),

              ///
              ///
              ///
              const SizedBox(
                height: 48,
              ),
              Text('Selected: ${enumSet.join(', ')}'),
              const SizedBox(
                height: 20,
              ),
              Text('Selected cities: ${selection.join(', ')}'),
            ],
          ),
        ),
      ),
    );
  }
}

enum MyEnum {
  option1,
  option2,
  option3,
  option4,
}
