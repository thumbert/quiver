library screens.ftr_path.ftr_path_ui;

import 'package:flutter/material.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_quiver/models/ftr_path/data_model.dart';
import 'package:flutter_quiver/models/ftr_path/region_source_sink_model.dart';
import 'package:flutter_quiver/screens/common/term.dart';
import 'package:flutter_quiver/screens/ftr_path/congestion_chart.dart';
import 'package:flutter_quiver/screens/ftr_path/region_source_sink.dart';
import 'package:flutter_quiver/screens/ftr_path/table_cpsp.dart';
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
    final pathModel = context.watch<RegionSourceSinkModel>();
    final dataModel = context.watch<DataModel>();

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
                                    'Visualize the congestion associated with an '
                                    'FTR path, display the clearing prices and the settled prices '
                                    'for a recent set of auctions, and the relevant binding constraints.\n'),
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
                children: [
                  const RegionSourceSink(),
                  const SizedBox(
                    height: 4,
                  ),
                  if (pathModel.isValid())
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SizedBox(
                              width: 900,
                              height: 600,
                              child: CongestionChart()),
                          // ConstraintTable(),
                        ],
                      ),
                    ),
                  // checkboxes
                  if (pathModel.isValid())
                    Wrap(
                      spacing: 10,
                      alignment: WrapAlignment.start,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        const Text(
                          'Auction term',
                          style: TextStyle(fontSize: 16),
                        ),
                        ...[
                          for (var term in dataModel.checkboxesTerm.keys)
                            SizedBox(
                              width: 120,
                              child: CheckboxListTile(
                                  title: Text(term),
                                  controlAffinity:
                                      ListTileControlAffinity.leading,
                                  contentPadding: const EdgeInsets.all(0),
                                  value: dataModel.checkboxesTerm[term],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      dataModel.checkboxesTerm[term] = value!;
                                      dataModel.checkboxModified();
                                    });
                                  }),
                            )
                        ],
                      ],
                    ),
                  // table with cp and sp
                  if (pathModel.isValid()) const TableCpsp(),
                ],
              )),
        ),
      ),
    );
  }
}
