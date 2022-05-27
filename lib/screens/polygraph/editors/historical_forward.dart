library screens.polygraph.editors.historical_forward;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/market_model.dart';
import 'package:provider/provider.dart';

/// A widget to select between a historical of forward view of the data
class HistoricalForward extends StatefulWidget {
  const HistoricalForward({Key? key}) : super(key: key);

  @override
  _HistoricalForwardState createState() => _HistoricalForwardState();
}

class _HistoricalForwardState extends State<HistoricalForward> {
  final _background = Colors.orange[100]!;

  String selectedTab = 'Realized';

  @override
  Widget build(BuildContext context) {
    // final model = context.watch<MarketModel>();

    return Row(
      children: [
        Container(
          width: 160,
          decoration: BoxDecoration(
              border: Border(
            bottom: BorderSide(
                width: 3,
                color:
                    selectedTab == 'Realized' ? Colors.blueGrey : Colors.white),
          )),
          child: TextButton(
              onPressed: () {
                setState(() {
                  selectedTab = 'Realized';
                });
              },
              child: const Text(
                'Realized',
                style: TextStyle(fontSize: 16, color: Colors.black),
              )),
        ),
        // const SizedBox(
        //   width: 12,
        // ),
        //
        //
        Container(
          width: 160,
          decoration: BoxDecoration(
              border: Border(
            bottom: BorderSide(
                width: 3,
                color: selectedTab == 'Forward, as of'
                    ? Colors.blueGrey
                    : Colors.white),
          )),
          child: TextButton(
              onPressed: () {
                setState(() {
                  selectedTab = 'Forward, as of';
                });
              },
              child: const Text(
                'Forward, as of',
                style: TextStyle(fontSize: 16, color: Colors.black),
              )),
        ),
        //
        //
        Container(
          width: 160,
          decoration: BoxDecoration(
              border: Border(
            bottom: BorderSide(
                width: 3,
                color: selectedTab == 'Forward strip'
                    ? Colors.blueGrey
                    : Colors.white),
          )),
          child: TextButton(
              onPressed: () {
                setState(() {
                  selectedTab = 'Forward strip';
                });
              },
              child: const Text(
                'Forward strip',
                style: TextStyle(fontSize: 16, color: Colors.black),
              )),
        ),
      ],
    );
  }
}
