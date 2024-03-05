library screens.connect4;

import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';

class Connect4 extends StatefulWidget {
  const Connect4({super.key});
  static const route = '/connect4';
  @override
  State<Connect4> createState() => _State();
}

class _State extends State<Connect4> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 12.0),
            child: Watch(
              (context) => Row(
                children: [
                  Container(
                    width: 100,
                    height: 700,
                    color: Colors.blueGrey.shade50,
                  )
                ],
              ),
            )));
  }
}
