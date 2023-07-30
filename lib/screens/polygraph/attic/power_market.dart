library screens.polygraph.editors.power_market;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/market_model.dart';
import 'package:provider/provider.dart';

class PowerMarket extends StatefulWidget {
  const PowerMarket({Key? key}) : super(key: key);

  @override
  _PowerMarketState createState() => _PowerMarketState();
}

class _PowerMarketState extends State<PowerMarket> {
  @override
  Widget build(BuildContext context) {
    final model = context.watch<MarketModel>();

    return DropdownButtonFormField(
      value: model.market,
      icon: const Icon(Icons.expand_more),
      hint: const Text('Filter'),
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.only(left: 12, right: 2, top: 9, bottom: 9),
        enabledBorder: InputBorder.none,
      ),
      elevation: 16,
      onChanged: (String? newValue) {
        setState(() {
          model.market = newValue!;
        });
      },
      items: MarketMixin.allowedValues
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
    );
  }
}
