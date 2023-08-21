library screens.homepage.homepage;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/screens/homepage/app_group.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  static const String route = '/';

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quiver',
          style: TextStyle(
              fontFamily: 'Tangerine',
              fontSize: 48,
              fontWeight: FontWeight.w600),
        ),
        actions: [
          SvgPicture.asset(
            'assets/images/quiver.svg',
            semanticsLabel: 'Quiver',
            color: Colors.black,
            height: 48,
            width: 48,
          )
        ],
      ),
      body: const Wrap(direction: Axis.horizontal, children: [
        AppGroup('Load'),
        AppGroup('Reports'),
        AppGroup('Other'),
        AppGroup('Examples'),
      ]),
    );
  }
}
