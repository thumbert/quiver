library screens.ftr_path.ftr_path_ui;

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_quiver/screens/common/term.dart';
import 'package:flutter_quiver/screens/ftr_path/region_source_sink.dart';
import 'package:provider/provider.dart';

class FtrPathUi extends StatefulWidget {
  const FtrPathUi({Key? key}) : super(key: key);

  @override
  _FtrPathUiState createState() => _FtrPathUiState();
}

class _FtrPathUiState extends State<FtrPathUi> {
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

  @override
  Widget build(BuildContext context) {
    // final chartModel = context.watch<CongestionChartModel>();

    return Padding(
      padding: const EdgeInsets.only(left: 48.0),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('FTR path analysis'),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return SimpleDialog(
                        children: [
                          SizedBox(
                            width: 500,
                            child: Column(
                              children: const [
                                Text(
                                    'Visualize ALL the nodes in the pool at once, '
                                    'select constraints to see when they bind '
                                    '\nto find the nodes that are affected the most.\n'),
                                Text(
                                    'Because a lot of the nodes have the same prices '
                                    'for the term, a simple reduction algorithm is applied '
                                    'to reduce the numbers of curves displayed.  This keeps '
                                    'the UI responsive without taking any of the visual information '
                                    'away.  By default, at most 100 curves are displayed. '
                                    'The accuracy of the reduction algorithm is quantified '
                                    'by its resolution, measured in \$.  The resolution '
                                    'is a threshold value such that curves closer to one '
                                    'another below this threshold are not displayed.  '
                                    'Therefore, a resolution of \$0 displays all the curves, '
                                    'and a lower resolution means better curve details '
                                    'are visible.\n'),
                                Text('By using the zone filter, you reduce '
                                    'the universe of curves to display and the '
                                    'reduction algorithm '
                                    'is applied to the curves from this zone only.')
                              ],
                            ),
                          )
                        ],
                        contentPadding: const EdgeInsets.all(12),
                      );
                    });
              },
              icon: const Icon(Icons.info_outline),
              tooltip: 'Info',
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.only(left: 12, top: 12.0),
          child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              controller: _scrollController,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  RegionSourceSink(),
                  SizedBox(width: 150, child: TermUi()),
                  SizedBox(
                    height: 4,
                  ),
                  // SingleChildScrollView(
                  //   scrollDirection: Axis.horizontal,
                  //   child: Row(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: const [
                  //       SizedBox(
                  //           width: 900, height: 700, child: CongestionChart()),
                  //       ConstraintTable(),
                  //     ],
                  //   ),
                  // ),
                ],
              )),
        ),
      ),
    );
  }
}
