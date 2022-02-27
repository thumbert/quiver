import 'package:flutter/material.dart';
import 'package:flutter_quiver/screens/demand_bids/demand_bids.dart';
import 'package:flutter_quiver/screens/historical_plc/historical_plc.dart';
import 'package:flutter_quiver/screens/monthly_asset_ncpc/monthly_asset_ncpc.dart';
import 'package:flutter_quiver/screens/monthly_lmp/monthly_lmp.dart';
import 'package:flutter_quiver/screens/unmasked_energy_offers/unmasked_energy_offers.dart';
import 'package:flutter_quiver/screens/vlr_stage2/vlr_stage2.dart';
import 'package:flutter_quiver/screens/weather/weather.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/screens/error404.dart';
import 'package:flutter_quiver/screens/ftr_path/ftr_path.dart';
import 'package:flutter_quiver/screens/homepage/homepage.dart';
import 'package:flutter_quiver/screens/mcc_surfer/mcc_surfer.dart';
import 'package:timezone/data/latest.dart';
import 'package:url_strategy/url_strategy.dart';

void main() async {
  initializeTimeZones();
  setPathUrlStrategy();
  await dotenv.load(fileName: '.env');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final _router = GoRouter(routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
        path: DemandBids.route,
        builder: (context, state) => const DemandBids()),
    GoRoute(
        path: FtrPath.route,
        builder: (context, state) => const FtrPath()),
    GoRoute(
        path: HistoricalPlc.route, builder: (context, state) => const HistoricalPlc()),
    GoRoute(
        path: MccSurfer.route, builder: (context, state) => const MccSurfer()),
    GoRoute(
        path: MccSurfer.route, builder: (context, state) => const MonthlyAssetNcpc()),
    GoRoute(
        path: MccSurfer.route, builder: (context, state) => const MonthlyLmp()),
    GoRoute(
        path: MccSurfer.route, builder: (context, state) => const UnmaskedEnergyOffers()),
    GoRoute(
        path: MccSurfer.route, builder: (context, state) => const VlrStage2()),
    GoRoute(
        path: Weather.route, builder: (context, state) => const Weather()),
  ], errorBuilder: (context, state) => const Error404());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Quiver',
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.blueGrey.shade300,
            foregroundColor: Colors.black),
        fontFamily: 'Ubuntu', //'Raleway',
        primarySwatch: Colors.blueGrey,
        // primaryColor: Colors.blueGrey.shade300,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          minimumSize: const Size(140, 40),
          primary: Colors.blueGrey.shade100,
          onPrimary: Colors.black,
        )),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.blueGrey.shade300),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey.shade300)),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(140, 40),
            primary: Colors.black,
            backgroundColor: Colors.blueGrey.shade50,
            // onSurface: Colors.white,
            // shadowColor: Colors.white,
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.all(Colors.blueGrey.shade300),
          // overlayColor: MaterialStateProperty.all(Colors.green),
        ),
      ),
    );
  }
}
