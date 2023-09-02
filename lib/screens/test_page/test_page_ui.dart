library screens.monthly_asset_ncpc.monthly_asset_ncpc_ui;

import 'package:date/date.dart';

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/date_with_checkbox_model.dart';
import 'package:flutter_quiver/models/common/month_model.dart';
import 'package:flutter_quiver/screens/common/date_with_checkbox.dart';
import 'package:flutter_quiver/screens/common/month.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TestPageUi extends StatefulWidget {
  const TestPageUi({Key? key}) : super(key: key);

  @override
  _TestPageUiState createState() => _TestPageUiState();
}

class _TestPageUiState extends State<TestPageUi> {
  var fmt = NumberFormat.currency(decimalDigits: 0, symbol: '\$');
  late ScrollController _controller;

  @override
  void initState() {
    _controller = ScrollController();
    final monthModel = context.read<MonthModel>();
    _month = monthModel.month;
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  late Month _month;

  @override
  Widget build(BuildContext context) {
    final monthModel = context.watch<MonthModel>();
    final dateModel = context.watch<DateWithCheckboxModel>();
    if (_month != monthModel.month) {
      setState(() {
        _month = monthModel.month;
        dateModel.allowedDates = monthModel.month.days();
      });
    }

    return Padding(
        padding: const EdgeInsets.only(left: 48),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Widget test page'),
            actions: [
              IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const SimpleDialog(
                          children: [
                            Text('Test your ideas easily ...'),
                          ],
                          contentPadding: EdgeInsets.all(12),
                        );
                      });
                },
                icon: const Icon(Icons.info_outline),
                tooltip: 'Info',
              )
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 8.0),
            child: Scrollbar(
              controller: _controller,
              thumbVisibility: true,
              child: ListView(
                controller: _controller,
                children: [
                  const Row(
                    children: [
                      SizedBox(width: 140, child: MonthUi()),
                    ],
                  ),
                  const DateWithCheckbox(),
                  const SizedBox(
                    height: 24,
                  ),
                  Text(
                      'Selected: ${monthModel.month}, date: ${dateModel.date}, clicked: ${dateModel.checkbox}'),
                ],
              ),
            ),
          ),
        ));
  }
}
