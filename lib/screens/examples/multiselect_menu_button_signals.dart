import 'package:flutter/material.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/screens/common/signal/multiselect.dart';
import 'package:signals/signals_flutter.dart';

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

/// Just use my custom multiselect widget.
///
class MultiSelectMenuButtonExample extends StatelessWidget {
  const MultiSelectMenuButtonExample({super.key});
  static const route = '/multiselect_menu_button_example';
  static final model =
      SelectionModel(initialSelection: cities.toSignal(), choices: cities);

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
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

                ///
                ///
                ///
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
        ),
      ),
    );
  }
}

// enum SelectionState {
//   all('(All)'),
//   none('(None)'),
//   some('(Some)');

//   const SelectionState(this._value);
//   final String _value;

//   @override
//   String toString() => _value;

//   SelectionState parse(String value) {
//     return switch (value) {
//       '(All)' => SelectionState.all,
//       '(None)' => SelectionState.none,
//       '(Some)' => SelectionState.some,
//       _ => throw ArgumentError('Invalid SelectionState $value'),
//     };
//   }
// }

// class SelectionModel {
//   SelectionModel({required this.selection, required this.choices});

//   late final Signal<Set<String>> selection;
//   final Set<String> choices;

//   SelectionState get selectionState {
//     if (selection.value.isEmpty) return SelectionState.none;
//     if (choices.difference(selection.value).isNotEmpty) {
//       return SelectionState.some;
//     } else {
//       return SelectionState.all;
//     }
//   }

//   void add(String value) {
//     selection.value = {...selection.value, value};
//   }

//   void remove(String value) {
//     selection.value.remove(value);
//     selection.value = {...selection.value};
//   }

//   void selectAll() {
//     selection.value = {...choices};
//   }

//   void selectNone() {
//     selection.value = <String>{};
//   }
// }

// class MultiSelectMenuButtonExample extends StatelessWidget {
//   const MultiSelectMenuButtonExample({super.key});
//   static const route = '/multiselect_menu_button_example';
//   static SelectionModel model =
//       SelectionModel(selection: cities.toSignal(), choices: cities);

//   List<PopupMenuItem<String>> getList() {
//     var out = <PopupMenuItem<String>>[];
//     out.add(PopupMenuItem<String>(
//         padding: EdgeInsets.zero,
//         value: '(All)',
//         child: Watch(
//           (_) => CheckboxListTile(
//             value: model.selectionState == SelectionState.all,
//             controlAffinity: ListTileControlAffinity.leading,
//             title: const Text('(All)'),
//             onChanged: (bool? checked) {
//               if (checked!) {
//                 model.selectAll();
//               } else {
//                 model.selectNone();
//               }
//             },
//           ),
//         )));

//     for (final value in model.choices) {
//       out.add(PopupMenuItem<String>(
//           padding: EdgeInsets.zero,
//           value: value,
//           child: Watch((_) => CheckboxListTile(
//                 value: model.selection.value.contains(value),
//                 controlAffinity: ListTileControlAffinity.leading,
//                 title: Text(value),
//                 onChanged: (bool? checked) {
//                   if (checked!) {
//                     model.add(value);
//                   } else {
//                     model.remove(value);
//                   }
//                 },
//               ))));
//     }
//     return out;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         useMaterial3: true,
//       ),
//       home: Scaffold(
//         body: SafeArea(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Row(
//                 children: [
//                   ///
//                   /// With PopupMenuButton
//                   ///
//                   const SizedBox(
//                     width: 36,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(20.0),
//                     child: Container(
//                       width: 250,
//                       color: MyApp.background,
//                       child: PopupMenuButton<String>(
//                         constraints: const BoxConstraints(maxHeight: 400),
//                         position: PopupMenuPosition.under,
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Row(
//                             children: [
//                               Watch((context) =>
//                                   Text(model.selectionState.toString())),
//                               const Spacer(),
//                               const Icon(Icons.keyboard_arrow_down_outlined),
//                             ],
//                           ),
//                         ),
//                         itemBuilder: (context) {
//                           return getList();
//                         },
//                       ),
//                     ),
//                   ),
//                 ],
//               ),

//               ///
//               ///
//               ///
//               const SizedBox(
//                 height: 400,
//               ),
//               Watch((context) =>
//                   Text('Selected cities: ${model.selection.value.join(', ')}')),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
