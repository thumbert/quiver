library screens.test_page.test_page;

import 'package:date/date.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/widgets.dart' hide Interval;
import 'package:flutter_quiver/models/common/date_with_checkbox_model.dart';
import 'package:flutter_quiver/models/common/load_zone_model.dart';
import 'package:flutter_quiver/models/common/month_model.dart';
import 'package:flutter_quiver/models/common/term_model.dart';
import 'package:flutter_quiver/models/monthly_asset_ncpc/asset_autocomplete_model.dart';
import 'package:flutter_quiver/models/monthly_asset_ncpc/monthly_asset_ncpc.dart';
import 'package:flutter_quiver/screens/monthly_asset_ncpc/monthly_asset_ncpc_ui.dart';
import 'package:flutter_quiver/screens/monthly_lmp/monthly_lmp_ui.dart';
import 'package:flutter_quiver/screens/test_page/test_page_ui.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    var month = Month.utc(2021, 12);
    return MultiProvider(providers: [
      ChangeNotifierProvider(create: (context) => MonthModel(month: month)),
      ChangeNotifierProvider(
          create: (context) =>
              DateWithCheckboxModel(date: '(All)', allowedDates: month.days())),
    ], child: const TestPageUi());
  }
}
