// library test.models.historical_gas_test;

// import 'dart:io';

// import 'package:date/date.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_quiver/models/historical_gas_model.dart';
// import 'package:flutter_quiver/screens/common/signal/multiselect.dart';
// import 'package:flutter_test/flutter_test.dart';
// import 'package:signals_flutter/signals_flutter.dart';
// import 'package:timezone/data/latest.dart';
// import 'package:timezone/timezone.dart';

// Future<void> tests(String rootUrl) async {
//   registerEffects();

//   group('Historical gas test', () {
//     test('add/remove rows when regions change', () {
//       expect(rows.value.length, 1);
//       // add one region
//       regions.value = {'NorthEast'};
//       expect(rows.value.length, 5);
//       // add another region
//       regions.value = {'NorthEast', 'Appalachia'};
//       expect(rows.value.length, 8);
//       // remove one region
//       regions.value = {'Appalachia'};
//       expect(rows.value.length, 3);
//     });

//     test('add/remove/modify individual rows', () {
//       rows.value = getDefaultRows();
//       expect(rows.value.length, 1);
//       // insert a row
//       insertRowAtIndex.value = 0;
//       expect(rows.value.length, 2);
//       expect(rows.value.map((e) => e.location).toList(),
//           ['Algonquin, CG', 'Algonquin, CG']);
//       // modify the contents of the inserted row
//       modifyLocationAtIndex.value = (1, 'Tetco, M3');
//       modifyGasIndexAtIndex.value = (1, 'IFerc');
//       expect(rows.value[1], (location: 'Tetco, M3', index: 'IFerc'));
//       // insert another row
//       insertRowAtIndex.value = 1;
//       expect(rows.value.length, 3);
//       modifyGasIndexAtIndex.value = (2, 'Gas Daily');
//       expect(rows.value[2].index, 'Gas Daily');
//       expect(rows.value.length, 3);
//       // remove row
//       removeRowAtIndex.value = 1;
//       expect(rows.value.length, 2);
//       expect(rows.value.map((e) => e.index).toSet(), {'Gas Daily'});
//     });
//   });
// }

// Future<void> main() async {
//   initializeTimeZones();
//   dotenv.testLoad(fileInput: File('.env').readAsStringSync());
//   final rootUrl = dotenv.env['ROOT_URL'] as String;

//   await tests(rootUrl);

// }







//   // final xs = <int>[].toSignal();
//   // final indexAdd = signal(-1);
//   // final indexRemove = signal(-1);
//   // final bunch = setSignal<int>({});

//   // effect(() {
//   //   print('in 1st effect');
//   //   if (indexAdd.value >= 0) {
//   //     xs.value.insert(indexAdd.value, xs[indexAdd.value]);
//   //     indexAdd.value = -1;
//   //   }
//   // });

//   // effect(() {
//   //   print('remove');
//   //   if (indexRemove.value >= 0) {
//   //     xs.removeAt(indexRemove.value);
//   //     indexRemove.value = -1;
//   //   }
//   // });

//   // xs.value = [0, 1, 2];
//   // indexAdd.value = 0;
//   // print(xs.value); // [0, 0, 1, 2]
//   // indexAdd.value = 0;
//   // print(xs.value); // [0, 0, 0, 1, 2]

//   // indexRemove.value = 4;
//   // print(xs.value);
//   // indexRemove.value = 3;
//   // print(xs.value);
//   // indexRemove.value = 2;
//   // print(xs.value);
//   // indexRemove.value = 1;
//   //   print(xs.value);


