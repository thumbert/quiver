import 'package:flutter/material.dart';
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
        path: '/ftr_path_analysis',
        builder: (context, state) => const FtrPath()),
    GoRoute(
        path: '/mcc_surfer', builder: (context, state) => const MccSurfer()),
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
