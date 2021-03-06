library screens.monthly_lmp.monthly_lmp;

import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/widgets.dart' hide Interval;
import 'package:flutter_quiver/models/common/bucket_model.dart';
import 'package:flutter_quiver/models/common/market_model.dart';
import 'package:flutter_quiver/screens/monthly_lmp/monthly_lmp_ui.dart';
import 'package:provider/provider.dart';

class MonthlyLmp extends StatefulWidget {
  const MonthlyLmp({Key? key}) : super(key: key);

  static const route = '/monthly_lmp';

  @override
  _MonthlyLmpState createState() => _MonthlyLmpState();
}

class _MonthlyLmpState extends State<MonthlyLmp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(providers: [
      // ChangeNotifierProvider(create: (context) => MarketModel()),
      ChangeNotifierProvider(create: (context) => BucketModel()),
    ], child: const MonthlyLmpUi());
  }
}
