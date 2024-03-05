library screens.historical_option_pricing.table_option_value;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quiver/models/historical_option_pricing_model.dart';
import 'package:intl/intl.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:timeseries/timeseries.dart';

class SummaryTableOption extends StatefulWidget {
  const SummaryTableOption({super.key});

  // final List<Map<String, dynamic>> data;

  @override
  State<SummaryTableOption> createState() => _SummaryTableOptionState();
}

class _SummaryTableOptionState extends State<SummaryTableOption> {
  static final fmt = NumberFormat.currency(decimalDigits: 2, symbol: '');
  final isMouseOverRow = signal(-1);
  late final Computed<List<Widget>> _rows;

  @override
  void initState() {
    _rows = computed(() {
      final rows = <Widget>[
        const Row(
          children: [
            SizedBox(
              width: 110,
              child: Text(
                'Term',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              width: 104,
              child: Text(
                'Value, \$/MWh',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ];

      for (var i = 0; i < tableData.value.length; i++) {
        rows.add(MouseRegion(
          onEnter: (_) {
            setState(() {
              isMouseOverRow.value = i;
            });
          },
          onExit: (_) {
            setState(() {
              isMouseOverRow.value = -1;
            });
          },
          child: SizedBox(
            width: 250,
            child: Row(
              children: [
                Container(
                  width: 100,
                  height: 24,
                  alignment: Alignment.centerLeft,
                  child: Text(tableData.value[i]['Term'].toString()),
                ),
                Container(
                  width: 100,
                  height: 24,
                  alignment: Alignment.centerRight,
                  child: Text(
                      fmt.format(tableData.value[i]['Value, \$/MWh'] as num)),
                ),
                if (isMouseOverRow.value == i)
                  Container(
                    height: 24,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.only(left: 8.0),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Data table',
                          onPressed: () {
                            var ts = tableData.value[i]['dailyPrice']
                                as TimeSeries<num>;
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return SimpleDialog(
                                    contentPadding: const EdgeInsets.all(12),
                                    children: [
                                      SizedBox(
                                        width: 500,
                                        height: 500,
                                        child: ListView.builder(
                                            itemCount: ts.length,
                                            itemBuilder: (_, int index) {
                                              final out =
                                                  '{date: ${ts[index].interval}, price: ${ts[index].value.toStringAsFixed(2)}}';
                                              return Text(out);
                                            }),
                                      )
                                    ],
                                  );
                                });
                          }, // delete the sucker
                          visualDensity: VisualDensity.compact,
                          constraints: const BoxConstraints(),
                          padding: const EdgeInsets.only(left: 0, right: 0),
                          icon: Icon(
                            Icons.table_view,
                            color: Colors.green.shade800,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ));
      }
      return rows;
    });
    super.initState();
  }

  Widget tableDailyOption() {
    return Watch((context) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _rows.value,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return switch (optionType.value) {
      'Daily' => tableDailyOption(),
      _ => const Placeholder(),
    };
  }
}
