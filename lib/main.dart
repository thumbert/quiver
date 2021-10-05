import 'package:flutter/material.dart';
import 'package:flutter_quiver/screens/demand_bids/demand_bids.dart';
import 'package:flutter_quiver/screens/historical_plc/historical_plc.dart';
import 'package:flutter_quiver/screens/quiver.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final menu = _createMenu();

    return MaterialApp(
      title: 'Quiver',
      theme: ThemeData(
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.blueGrey.shade300,
            foregroundColor: Colors.black),
        fontFamily: 'Ubuntu', //'Raleway',
        primarySwatch: Colors.blueGrey,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          minimumSize: const Size(140, 40),
          primary: Colors.blueGrey.shade100,
          onPrimary: Colors.black,
        )),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(140, 40),
            primary: Colors.black,
            backgroundColor: Colors.blueGrey.shade50,
            // onSurface: Colors.white,
            // shadowColor: Colors.white,
          ),
        ),
      ),
      home: QuiverScreen(
          menu: menu, initialActiveMenuItem: menu.first.items.first),
    );
  }

  List<DemoMenuGroup> _createMenu() {
    return [
      DemoMenuGroup(
        title: 'Load',
        items: [
          DemoMenuItem(
              title: 'Demand bids', pageBuilder: (_) => const DemandBids()),
          DemoMenuItem(
              title: 'Load settlements',
              pageBuilder: (_) => Center(child: Text('Settle'))),
          DemoMenuItem(
              title: 'Historical PLC',
              pageBuilder: (_) => const HistoricalPlc()),
          DemoMenuItem(title: 'VLR Stage 2', pageBuilder: (_) => Text('TODO')),
        ],
      ),
      DemoMenuGroup(
        title: 'Reports',
        items: [
          DemoMenuItem(
              title: 'Realized ancillaries', pageBuilder: (_) => Text('TODO')),
          DemoMenuItem(title: 'Monthly LMPs', pageBuilder: (_) => Text('TODO')),
        ],
      ),
      DemoMenuGroup(
        title: 'Other',
        items: [
          DemoMenuItem(title: 'Weather', pageBuilder: (_) => Text('TODO')),
          DemoMenuItem(title: 'EMT', pageBuilder: (_) => Text('TODO')),
          DemoMenuItem(
              title: 'Peaking option calls', pageBuilder: (_) => Text('TODO')),
        ],
      ),
    ];
  }
}
