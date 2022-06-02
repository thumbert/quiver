library screens.polygraph.polygraph_ui;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/experimental/power_deliverypoint_model.dart';
import 'package:flutter_quiver/models/common/experimental/select_variable_model.dart';
import 'package:flutter_quiver/models/common/market_model.dart';
import 'package:flutter_quiver/models/common/region_model.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/screens/common/region.dart';
import 'package:flutter_quiver/screens/common/term.dart';
import 'package:flutter_quiver/screens/polygraph/editor_main.dart';
import 'package:flutter_quiver/screens/polygraph/editors/power_deliverypoint.dart';
import 'package:flutter_quiver/screens/polygraph/editors/power_location2.dart';
import 'package:flutter_quiver/screens/polygraph/editors/power_market.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PolygraphUi extends StatefulWidget {
  const PolygraphUi({Key? key}) : super(key: key);

  @override
  _PolygraphUiState createState() => _PolygraphUiState();
}

class _PolygraphUiState extends State<PolygraphUi> {
  var fmt = NumberFormat.currency(decimalDigits: 0, symbol: '\$');
  late ScrollController _scrollController;
  late Plotly plotly;

  @override
  void initState() {
    _scrollController = ScrollController();
    final model = context.read<SelectVariableModel>();
    model.init();
    final deliveryPointModel = context.read<PowerDeliveryPointModel>();
    deliveryPointModel.currentRegion = 'ISONE';

    setState(() {
      var aux = DateTime.now().hashCode;
      plotly = Plotly(
        viewId: 'plotly-polygraph-$aux',
        data: const [],
        layout: PolygraphModel.layout,
      );
    });
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final variableModel = context.watch<SelectVariableModel>();

    var ys = variableModel.yAxisVariables();
    // variableModel.editedIndex = 1;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Polygraph'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const SimpleDialog(
                      children: [
                        Text('Historical energy offers for all assets in '
                            'ISONE and NYISO.  Unmasking has been done in a different '
                            'process.'
                            '\n\nClick on an asset name to select it '
                            'and see it\'s energy offers.'
                            '\n\nBest to select the term one month at a time.'
                            '\n\nData is provided on a 4 month lag.'),
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
        padding: const EdgeInsets.only(left: 24.0, top: 8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  SizedBox(width: 120, child: TermUi()),
                  SizedBox(
                    width: 36,
                  ),
                ],
              ),
              Wrap(
                direction: Axis.horizontal,
                spacing: 36,
                children: [
                  // X axis
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 0, bottom: 0),
                        child: Text(
                          'X axis',
                          style:
                              TextStyle(color: Colors.blueGrey, fontSize: 16),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          variableModel.xAxisLabel(),
                          style: const TextStyle(
                              color: Colors.black, fontSize: 16),
                        ),
                        style: TextButton.styleFrom(
                          padding:
                              const EdgeInsets.only(left: 0, top: 0, bottom: 0),
                          alignment: Alignment.centerLeft,
                          // backgroundColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  // Y axis
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Y axis',
                        style: TextStyle(color: Colors.blueGrey, fontSize: 16),
                      ),
                      //
                      //
                      // Add all the y variables
                      //
                      //
                      ...[
                        for (var i = 0; i < ys.length; i++)
                          MouseRegion(
                            onEnter: (_) {
                              setState(() {
                                variableModel.yVariablesHighlightStatus[i] =
                                    true;
                              });
                            },
                            onExit: (_) {
                              setState(() {
                                variableModel.yVariablesHighlightStatus[i] =
                                    false;
                              });
                            },
                            child: Stack(
                              alignment: AlignmentDirectional.centerEnd,
                              children: [
                                TextButton(
                                  onPressed: () {},
                                  child: Text(
                                    variableModel.yAxisLabel(i),
                                    style: const TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.only(
                                        left: 0, right: 90),
                                    // minimumSize: Size(200, 24),
                                  ),
                                ),

                                /// show the icons only on hover ...
                                if (variableModel.yVariablesHighlightStatus[i])
                                  Row(
                                    children: [
                                      IconButton(
                                        tooltip: 'Edit',
                                        onPressed: () async {
                                          setState(() {
                                            variableModel.editedIndex = i + 1;
                                          });
                                          await showDialog(
                                              barrierDismissible: false,
                                              context: context,
                                              builder: (context) {
                                                return ChangeNotifierProvider
                                                    .value(
                                                        value: variableModel,
                                                        builder:
                                                            (context, _) =>
                                                                AlertDialog(
                                                                  elevation:
                                                                      24.0,
                                                                  title: const Text(
                                                                      'Select'),
                                                                  content:
                                                                      Column(
                                                                    mainAxisSize:
                                                                        MainAxisSize
                                                                            .min,
                                                                    children: const [
                                                                      EditorMain(),
                                                                    ],
                                                                  ),
                                                                  actions: [
                                                                    TextButton(
                                                                        child: const Text(
                                                                            'CANCEL'),
                                                                        onPressed:
                                                                            () {
                                                                          /// ignore changes the changes
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        }),
                                                                    ElevatedButton(
                                                                        child: const Text(
                                                                            'OK'),
                                                                        onPressed:
                                                                            () {
                                                                          /// harvest the values
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        }),
                                                                  ],
                                                                ));
                                              });
                                          print(variableModel.yAxisVariables());
                                        },
                                        visualDensity: VisualDensity.compact,
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.only(
                                            left: 8, right: 0),
                                        icon: Icon(
                                          Icons.edit_outlined,
                                          color: Colors.blueGrey[300],
                                          size: 20,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Remove',
                                        onPressed: () {
                                          setState(() {
                                            variableModel.removeVariableAt(i);
                                          });
                                        }, // delete the sucker
                                        visualDensity: VisualDensity.compact,
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.only(
                                            left: 0, right: 0),
                                        icon: Icon(
                                          Icons.delete_forever,
                                          color: Colors.blueGrey[300],
                                          size: 20,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Copy',
                                        onPressed: () {
                                          setState(() {
                                            variableModel.copy(i);
                                          });
                                        }, // delete the sucker
                                        visualDensity: VisualDensity.compact,
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.only(
                                            left: 0, right: 8),
                                        icon: Icon(
                                          Icons.copy,
                                          color: Colors.blueGrey[300],
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  )
                              ],
                            ),
                          ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(
                height: 24,
              ),
              // ElevatedButton(
              //     child: const Text('Edit Power location'),
              //     onPressed: () async {
              //       variableModel.editedIndex = 1;
              //       var y = variableModel.getEditedVariable();
              //       var region = y['region'];
              //       var deliveryPoint = y['deliveryPoint'];
              //       var res = await showDialog(
              //           barrierDismissible: false,
              //           context: context,
              //           builder: (context) {
              //             return MultiProvider(
              //                 providers: [
              //                   ChangeNotifierProvider(
              //                       create: (context) => RegionModel(region)),
              //                   ChangeNotifierProvider(
              //                       create: (context) =>
              //                           PowerDeliveryPointModel(deliveryPoint)),
              //                 ],
              //                 builder: (context, _) => AlertDialog(
              //                       elevation: 24.0,
              //                       title: const Text('Select'),
              //                       content: const PowerLocation2(),
              //                       actions: [
              //                         TextButton(
              //                             child: const Text('CANCEL'),
              //                             onPressed: () {
              //                               /// ignore changes and pop
              //                               Navigator.of(context).pop();
              //                             }),
              //                         ElevatedButton(
              //                             child: const Text('OK'),
              //                             onPressed: () {
              //                               /// harvest the values
              //                               final regionModel =
              //                                   context.read<RegionModel>();
              //                               final deliveryPointModel =
              //                                   context.read<
              //                                       PowerDeliveryPointModel>();
              //                               Navigator.of(context).pop({
              //                                 'region': regionModel.region,
              //                                 'deliveryPoint':
              //                                     deliveryPointModel
              //                                         .deliveryPointName,
              //                               });
              //                             }),
              //                       ],
              //                     ));
              //           });
              //       print(res);
              //
              //       // Navigator.pushNamed(context, '/editor_power');
              //       // context.go(context.namedLocation(
              //       //   'power_editor',
              //       //   params: <String, String>{
              //       //     'region': y['region'],
              //       //     'deliveryPoint': y['deliveryPoint'],
              //       //   },
              //       // ));
              //     },
              //     ),
            ],
          ),
        ),
      ),
    );
  }
}
