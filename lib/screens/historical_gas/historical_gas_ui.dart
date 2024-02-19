library screens.historical_lmp.historical_gas_ui;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/screens/historical_gas/tab1_historical_gas.dart';
import 'package:signals_flutter/signals_flutter.dart';

class HistoricalGas extends StatefulWidget {
  const HistoricalGas({super.key});
  static const route = '/historical_gas';
  @override
  State<HistoricalGas> createState() => _State();
}

class _State extends State<HistoricalGas> {
  int activeTabIndex = 0;
  final scrollControllerV = ScrollController();
  final scrollControllerH = ScrollController();

  @override
  void dispose() {
    scrollControllerV.dispose();
    scrollControllerH.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      controller: scrollControllerV,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 12.0),
            child: Watch(
              (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: () {
                          setState(() {
                            activeTabIndex = 0;
                          });
                        },
                        child: Container(
                            width: 240,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    width: 2,
                                    color: activeTabIndex == 0
                                        ? Colors.deepOrange
                                        : Colors.grey[300]!),
                              ),
                            ),
                            child: const Center(
                                child: Text(
                              'Multiple locations',
                              style: TextStyle(fontSize: 18),
                            ))),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(padding: EdgeInsets.zero),
                        onPressed: () {
                          setState(() {
                            activeTabIndex = 1;
                          });
                        },
                        child: Container(
                            width: 240,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                    width: 2,
                                    color: activeTabIndex == 1
                                        ? Colors.deepOrange
                                        : Colors.grey[300]!),
                              ),
                            ),
                            child: const Center(
                                child: Text(
                              'Price vs. Temperature',
                              style: TextStyle(fontSize: 18),
                            ))),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  if (activeTabIndex == 0) const Tab1HistoricalGas(),
                ],
              ),
            )),
      ),
    ));
  }
}
