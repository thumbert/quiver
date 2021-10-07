library screens.monthly_lmp.monthly_lmp_ui;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/bucket_model.dart';
import 'package:flutter_quiver/models/common/market_model.dart';
import 'package:flutter_quiver/screens/common/bucket.dart';
import 'package:flutter_quiver/screens/common/market.dart';
import 'package:provider/provider.dart';

class MonthlyLmpUi extends StatefulWidget {
  const MonthlyLmpUi({Key? key}) : super(key: key);

  @override
  _MonthlyLmpUiState createState() => _MonthlyLmpUiState();
}

class _MonthlyLmpUiState extends State<MonthlyLmpUi> {
  @override
  Widget build(BuildContext context) {
    final bucket = context.watch<BucketModel>();
    final market = context.watch<MarketModel>();
    return Padding(
        padding: const EdgeInsets.only(left: 48),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Historical monthly LMP'),
          ),
          body: Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      'Market',
                      style: TextStyle(fontSize: 16),
                    ),
                    Market(),
                  ],
                ),
                const Bucket(),
                const SizedBox(
                  height: 24,
                ),
                Text('Selected: ${getSelection(market, bucket)}'),
              ],
            ),
          ),
        ));
  }

  String getSelection(MarketModel market, BucketModel bucket) {
    var selection = '';
    selection += 'Bucket: ${bucket.bucket}';
    selection += ', Market: ${market.market}';
    return selection;
  }
}
