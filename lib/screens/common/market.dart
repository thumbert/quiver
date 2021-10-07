library screens.common.dart_radio;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/market_model.dart';
import 'package:provider/provider.dart';

class Market extends StatefulWidget {
  const Market({Key? key}) : super(key: key);

  @override
  _MarketState createState() => _MarketState();
}

class _MarketState extends State<Market> {
  String? _market;

  @override
  void initState() {
    final model = context.read<MarketModel>();
    _market = model.market;
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
              groupValue: _market,
              onChanged: (String? value) {
                setState(() {
                  model.market = value!;
                  _market = value;
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
                  _market = value;
                });
              }),
        ),
      ],
    );
  }
}
