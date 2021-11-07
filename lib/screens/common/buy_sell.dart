library screens.common.buy_sell;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/market_model.dart';
import 'package:provider/provider.dart';

class BuySell extends StatefulWidget {
  const BuySell({Key? key}) : super(key: key);

  @override
  _BuySellState createState() => _BuySellState();
}

class _BuySellState extends State<BuySell> {
  String? _buySell;

  @override
  void initState() {
    final model = context.read<MarketModel>();
    _buySell = model.market;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MarketModel>();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 110,
          child: RadioListTile(
              title: const Text('DA'),
              value: 'DA',
              groupValue: _buySell,
              onChanged: (String? value) {
                setState(() {
                  model.market = value!;
                  _buySell = value;
                });
              }),
        ),
        SizedBox(
          width: 110,
          child: RadioListTile(
              title: const Text('RT'),
              value: 'RT',
              groupValue: model.market,
              onChanged: (String? value) {
                setState(() {
                  model.market = value!;
                  _buySell = value;
                });
              }),
        ),
      ],
    );
  }
}
