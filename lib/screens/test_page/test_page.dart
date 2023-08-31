library screens.test_page.test_page;

import 'package:date/date.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/widgets.dart' hide Interval;
import 'package:flutter_quiver/models/common/date_with_checkbox_model.dart';
import 'package:flutter_quiver/models/common/month_model.dart';
import 'package:flutter_quiver/screens/test_page/test_page_ui.dart';
import 'package:provider/provider.dart';

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
