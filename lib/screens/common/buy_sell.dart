library screens.common.multiple.buy_sell;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/multiple/buysell_model.dart';
import 'package:provider/provider.dart';

class BuySell extends StatefulWidget {
  const BuySell({this.index = 0, Key? key}) : super(key: key);

  final int index;

  @override
  _BuySellState createState() => _BuySellState();
}

class _BuySellState extends State<BuySell> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BuySellModel>();

    return DropdownButtonFormField(
      value: model[widget.index],
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
          model[widget.index] = newValue!;
        });
      },
      items: BuySellModel.values
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
    );
  }
}
