library screens.grim_spreader.grim_spreader_ui;

import 'package:elec/risk_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/experimental/select_variable_model.dart';
import 'package:flutter_quiver/models/common/region_model.dart';
import 'package:flutter_quiver/models/common/term_model.dart';
import 'package:flutter_quiver/models/grim_spreader/grim_spreader_model.dart';
import 'package:flutter_quiver/models/unmasked_energy_offers.dart';
import 'package:flutter_quiver/models/weather/airport_model.dart';
import 'package:flutter_quiver/models/weather/month_range_model.dart';
import 'package:flutter_quiver/models/weather/weather_model.dart';
import 'package:flutter_quiver/screens/common/region.dart';
import 'package:flutter_quiver/screens/common/term.dart';
import 'package:flutter_quiver/screens/weather/airport.dart';
import 'package:flutter_quiver/screens/weather/instrument_rows.dart';
import 'package:flutter_quiver/screens/weather/month_range.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class GrimSpreaderUi extends StatefulWidget {
  const GrimSpreaderUi({Key? key}) : super(key: key);

  @override
  _GrimSpreaderUiState createState() => _GrimSpreaderUiState();
}

class _GrimSpreaderUiState extends State<GrimSpreaderUi> {
  var fmt = NumberFormat.currency(decimalDigits: 0, symbol: '\$');
  late ScrollController _scrollController;
  late Plotly plotly;

  int _tabSelection = 1;

  @override
  void initState() {
    _scrollController = ScrollController();
    final model = context.read<SelectVariableModel>();
    model.init();
    setState(() {
      var aux = DateTime.now().hashCode;
      plotly = Plotly(
        viewId: 'plotly-grim-spreader-$aux',
        data: const [],
        layout: GrimSpreaderModel.layout,
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
    // final termModel = context.watch<TermModel>();
    // final model = context.watch<UnmaskedEnergyOffersModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grim Spreader'),
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
        padding: const EdgeInsets.only(left: 12.0, top: 8.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Region(),
                  SizedBox(
                    width: 36,
                  ),
                  SizedBox(width: 120, child: TermUi()),
                ],
              ),
              Wrap(
                direction: Axis.horizontal,
                spacing: 36,
                children: [
                  Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            setState(() {
                              _tabSelection = 0;
                            });
                          },
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                                border: _tabSelection == 0
                                    ? const Border(
                                        bottom: BorderSide(
                                        color: Colors.blueGrey,
                                        width: 3,
                                      ))
                                    : const Border()),
                            child: Text(
                              'X axis',
                              style: TextStyle(
                                  color: _tabSelection == 0
                                      ? Colors.black
                                      : Colors.blueGrey,
                                  fontSize: 16),
                            ),
                          )),
                      OutlinedButton(
                          onPressed: () {},
                          child: Text(variableModel.valueXaxis)),
                    ],
                  ),
                  Column(
                    children: [
                      TextButton(
                          onPressed: () {
                            setState(() {
                              _tabSelection = 1;
                            });
                          },
                          child: Container(
                            width: 200,
                            decoration: BoxDecoration(
                                border: _tabSelection == 1
                                    ? const Border(
                                        bottom: BorderSide(
                                        color: Colors.blueGrey,
                                        width: 3,
                                      ))
                                    : const Border()),
                            child: Text(
                              'Y axis 1',
                              style: TextStyle(
                                  color: _tabSelection == 1
                                      ? Colors.black
                                      : Colors.blueGrey,
                                  fontSize: 16),
                            ),
                          )),
                      OutlinedButton(
                          onPressed: () {},
                          child: Text(variableModel.valueYaxis1(0))),
                    ],
                  ),
                  TextButton(
                      onPressed: () {
                        setState(() {
                          _tabSelection = 2;
                        });
                      },
                      child: Container(
                        width: 200,
                        decoration: BoxDecoration(
                            border: _tabSelection == 2
                                ? const Border(
                                    bottom: BorderSide(
                                    color: Colors.blueGrey,
                                    width: 3,
                                  ))
                                : const Border()),
                        child: Text(
                          'Y axis 2',
                          style: TextStyle(
                              color: _tabSelection == 2
                                  ? Colors.black
                                  : Colors.blueGrey,
                              fontSize: 16),
                        ),
                      )),
                ],
              ),

              // Expanded(
              //   child: Row(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       SizedBox(
              //         width: 300,
              //         child: ListView.builder(
              //           // shrinkWrap: true,
              //           controller: _scrollController,
              //           itemCount: model.assetData.length,
              //           itemBuilder: (BuildContext context, int index) {
              //             return CheckboxListTile(
              //               title: Text(_assets[index]),
              //               dense: true,
              //               onChanged: (bool? value) =>
              //                   model.clickCheckbox(index),
              //               value: model.checkboxes[index],
              //             );
              //           },
              //         ),
              //       ),
              //       const SizedBox(width: 15),
              //       FutureBuilder(
              //           future: model.makeTraces(termModel.term),
              //           builder: (context, snapshot) {
              //             List<Widget> children;
              //             if (snapshot.hasData) {
              //               var traces = snapshot.data! as List;
              //               var layout = model.layout;
              //               if (traces.length == 1) {
              //                 layout['title'] =
              //                     'MW weighted Energy Offer price';
              //               }
              //               plotly.plot
              //                   .react(traces, layout, displaylogo: false);
              //               children = [
              //                 SizedBox(width: 750, height: 550, child: plotly),
              //               ];
              //             } else if (snapshot.hasError) {
              //               children = [
              //                 const Icon(Icons.error_outline,
              //                     color: Colors.red),
              //                 Text(
              //                   snapshot.error.toString(),
              //                   style: const TextStyle(fontSize: 16),
              //                 )
              //               ];
              //             } else {
              //               children = [
              //                 const SizedBox(
              //                     height: 50,
              //                     width: 50,
              //                     child: CircularProgressIndicator(
              //                       strokeWidth: 4,
              //                     )),
              //               ];
              //               // the only way I found to keep the progress indicator centered
              //               return Row(
              //                   mainAxisAlignment: MainAxisAlignment.center,
              //                   children: children);
              //             }
              //             return Row(children: children);
              //           }),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
