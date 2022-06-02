library screens.polygraph.editors.historical_forward;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/market_model.dart';
import 'package:flutter_quiver/screens/common/term.dart';
import 'package:provider/provider.dart';

/// A widget to select between a historical of forward view of the data
class HistoricalOrForward extends StatefulWidget {
  const HistoricalOrForward({Key? key}) : super(key: key);

  @override
  _HistoricalOrForwardState createState() => _HistoricalOrForwardState();
}

class _HistoricalOrForwardState extends State<HistoricalOrForward> {
  final _background = Colors.orange[100]!;

  String selectedTab = 'Realized';

  @override
  Widget build(BuildContext context) {
    // final model = context.watch<MarketModel>();

    return Column(
      children: [
        Row(
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
        ),
        if (selectedTab == 'Forward, as of') Column(children: [
          Row(children: [
            Text('Forward Term', style: TextStyle(fontSize: 16),),
            TermUi(),
          ],)
        ],),
      ],
    );
  }
}
