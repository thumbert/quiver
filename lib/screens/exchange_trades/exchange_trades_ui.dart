library screens.exchange_trades.exchange_trades_ui;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/screens/exchange_trades/tab_ice_exchange.dart';
import 'package:flutter_quiver/screens/exchange_trades/tab_nodal_exchange.dart';

class ExchangeTradesUi extends StatefulWidget {
  const ExchangeTradesUi({super.key});
  static const route = '/exchange_trades';
  @override
  State<ExchangeTradesUi> createState() => _State();
}

class _State extends State<ExchangeTradesUi> {
  int activeTabIndex = 1;
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
          child: Column(
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
                          'ICE',
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
                          'Nodal',
                          style: TextStyle(fontSize: 18),
                        ))),
                  )
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              if (activeTabIndex == 0) const TabIceExchange(),
              if (activeTabIndex == 1) const TabNodalExchange(),
            ],
          ),
        ),
      ),
    ));
  }
}
