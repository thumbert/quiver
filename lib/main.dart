import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_variable.dart';
import 'package:flutter_quiver/screens/demand_bids/demand_bids.dart';
import 'package:flutter_quiver/screens/examples/dropdown_example.dart';
import 'package:flutter_quiver/screens/polygraph/other/add_variable_ui.dart';
import 'package:flutter_quiver/screens/polygraph/other/edit_variable_ui.dart';
import 'package:flutter_quiver/screens/polygraph/polygraph.dart';
import 'package:flutter_quiver/screens/historical_plc/historical_plc.dart';
import 'package:flutter_quiver/screens/monthly_asset_ncpc/monthly_asset_ncpc.dart';
import 'package:flutter_quiver/screens/monthly_lmp/monthly_lmp.dart';
import 'package:flutter_quiver/screens/pool_load_stats/pool_load_stats.dart';
import 'package:flutter_quiver/screens/rate_boad/rate_board.dart';
import 'package:flutter_quiver/screens/unmasked_energy_offers/unmasked_energy_offers.dart';
import 'package:flutter_quiver/screens/weather/weather.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_quiver/screens/error404.dart';
import 'package:flutter_quiver/screens/ftr_path/ftr_path.dart';
import 'package:flutter_quiver/screens/homepage/homepage.dart';
import 'package:flutter_quiver/screens/mcc_surfer/mcc_surfer.dart';
import 'package:timezone/data/latest.dart';

void main() async {
  initializeTimeZones();
  // setPathUrlStrategy();  // doesn't allow me to navigate to the absolute url
  await dotenv.load(fileName: '.env');
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  static final background = Colors.orange[100]!;
  static final background2 = Colors.green[100]!;

  final _router = GoRouter(routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
        path: DemandBids.route,
        builder: (context, state) => const DemandBids()),
    GoRoute(
        path: DropdownExample.route,
        builder: (context, state) => const DropdownExample()),
    GoRoute(path: FtrPath.route, builder: (context, state) => const FtrPath()),
    GoRoute(
        path: HistoricalPlc.route,
        builder: (context, state) => const HistoricalPlc()),
    GoRoute(
        path: MccSurfer.route, builder: (context, state) => const MccSurfer()),
    GoRoute(
        path: MonthlyAssetNcpc.route,
        builder: (context, state) => const MonthlyAssetNcpc()),
    GoRoute(
        path: MonthlyLmp.route,
        builder: (context, state) => const MonthlyLmp()),
    GoRoute(
      path: Polygraph.route,
      builder: (context, state) => const Polygraph(),
      routes: [
        GoRoute(path: 'add',
          builder: (context, state) {
          return const AddVariableUi();}),
        GoRoute(path: 'edit',
          builder: (context, state) {
          return EditVariableUi(variable: state.extra as PolygraphVariable);}),
      ],
    ),
    GoRoute(
      path: PoolLoadStats.route,
      builder: (context, state) => const ProviderScope(child: PoolLoadStats()),
    ),
    GoRoute(
      path: RateBoard.route,
      builder: (context, state) => const ProviderScope(child: RateBoard()),
    ),
    GoRoute(
        path: UnmaskedEnergyOffers.route,
        builder: (context, state) => const UnmaskedEnergyOffers()),
    // GoRoute(
    //     path: VlrStage2.route, builder: (context, state) => const VlrStage2()),
    GoRoute(path: Weather.route, builder: (context, state) => const Weather()),
  ], errorBuilder: (context, state) => const Error404());

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Quiver',
      routerConfig: _router,
      theme: ThemeData(
        useMaterial3: true,
        appBarTheme: AppBarTheme(
            backgroundColor: Colors.blueGrey.shade300,
            foregroundColor: Colors.black),
        fontFamily: 'Ubuntu', //'Raleway',
        primarySwatch: Colors.blueGrey,
        // primaryColor: Colors.blueGrey.shade300,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          foregroundColor: Colors.black,
              backgroundColor: Colors.blueGrey.shade100, minimumSize: const Size(140, 40),
        )),
        inputDecorationTheme: InputDecorationTheme(
          labelStyle: TextStyle(color: Colors.blueGrey.shade300),
          enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.blueGrey.shade300)),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black, minimumSize: const Size(140, 40),
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
