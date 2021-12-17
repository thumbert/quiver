library screens.mcc_surfer.mcc_surfer;

import 'package:date/date.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_quiver/models/common/term_model.dart';
import 'package:flutter_quiver/models/mcc_surfer/congestion_chart_model.dart';
import 'package:flutter_quiver/models/mcc_surfer/constraint_table_model.dart';
import 'package:flutter_quiver/screens/common/term.dart';
import 'package:flutter_quiver/screens/mcc_surfer/congestion_chart.dart';
import 'package:flutter_quiver/screens/mcc_surfer/constraint_table.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart';

class MccSurfer extends StatefulWidget {
  const MccSurfer({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CongestionViewerState();
}

class _CongestionViewerState extends State<MccSurfer> {
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Term initialTerm() {
    var dt = TZDateTime.now(UTC);
    return Term.fromInterval(Month.utc(dt.year, dt.month));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
              create: (context) => TermModel(term: initialTerm())),
          ChangeNotifierProvider(create: (context) => ConstraintTableModel()),
          ChangeNotifierProvider(create: (context) => CongestionChartModel())
        ],
        child: Padding(
          padding: const EdgeInsets.only(left: 48.0),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('MCC surfer'),
              actions: [
                IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return const SimpleDialog(
                            children: [
                              Text(
                                  'Visualize all the nodes in the pool at once, '
                                  'select constraints to see when they bind '
                                  '\nto find the nodes that are affected the most.'),
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
              padding: const EdgeInsets.only(left: 12, top: 8.0),
              child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  controller: _scrollController,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(width: 120, child: TermUi()),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            SizedBox(
                                width: 1000,
                                height: 700,
                                child: CongestionChart()),
                            ConstraintTable(),
                          ],
                        ),
                      )
                    ],
                  )),
            ),
          ),
        ));
  }
}
