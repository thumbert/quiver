library screens.historical_option_pricing_ui;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/screens/common/signal/dropdown.dart';
import 'package:flutter_quiver/models/historical_option_pricing_model.dart';
import 'package:flutter_quiver/screens/common/signal/multiselect.dart';
import 'package:flutter_quiver/screens/common/signal/multiselect2.dart';
import 'package:flutter_quiver/screens/common/signal/number_field.dart';
import 'package:flutter_quiver/screens/common/signal/term.dart';
import 'package:flutter_quiver/screens/historical_option_pricing/table_option_value.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:signals_flutter/signals_flutter.dart';

class HistoricalOptionPricing extends StatefulWidget {
  const HistoricalOptionPricing({super.key});
  static const route = '/historical_option_pricing';
  @override
  State<HistoricalOptionPricing> createState() => _State();
}

class _State extends State<HistoricalOptionPricing> {
  late Plotly plotly;
  final scrollControllerV = ScrollController();
  final scrollControllerH = ScrollController();

  @override
  void initState() {
    var aux = DateTime.now().hashCode;
    plotly = Plotly(
      viewId: 'plotly-hist-opt-pricing-$aux',
      data: const [],
      layout: layout,
    );
    super.initState();
  }

  @override
  void dispose() {
    scrollControllerV.dispose();
    scrollControllerH.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      scrollDirection: Axis.vertical,
      controller: scrollControllerV,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Padding(
            padding: const EdgeInsets.only(top: 12.0, left: 12.0),
            child: Watch(
              (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// column header
                  const Row(
                    children: [
                      SizedBox(
                        width: 162,
                        child: Text(
                          'Term',
                          style: TextStyle(fontSize: 14, color: Colors.purple),
                        ),
                      ),
                      SizedBox(
                        width: 172,
                        child: Text(
                          'Location',
                          style: TextStyle(fontSize: 14, color: Colors.purple),
                        ),
                      ),
                      SizedBox(
                        width: 82,
                        child: Text(
                          'Market',
                          style: TextStyle(fontSize: 14, color: Colors.purple),
                        ),
                      ),
                      SizedBox(
                        width: 112,
                        child: Text(
                          'Bucket',
                          style: TextStyle(fontSize: 14, color: Colors.purple),
                        ),
                      ),
                      SizedBox(
                        width: 72,
                        child: Text(
                          'Strike',
                          style: TextStyle(fontSize: 14, color: Colors.purple),
                        ),
                      ),
                      SizedBox(
                        width: 112,
                        child: Text(
                          'Call/Put',
                          style: TextStyle(fontSize: 14, color: Colors.purple),
                        ),
                      ),
                      SizedBox(
                        width: 112,
                        child: Text(
                          'Type',
                          style: TextStyle(fontSize: 14, color: Colors.purple),
                        ),
                      ),
                    ],
                  ),
                  const OptionRow(),
                  const SizedBox(
                    height: 24,
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ///
                          /// Settings
                          ///

                          Container(
                            width: 504,
                            color: Colors.purple.shade50,
                            padding: const EdgeInsets.all(8.0),
                            child: const Text(
                              'Settings',
                              style: TextStyle(color: Colors.purple),
                            ),
                          ),
                          Row(
                            children: [
                              ///
                              /// Term
                              ///
                              Column(
                                children: [
                                  Container(
                                      width: 150,
                                      alignment: Alignment.centerLeft,
                                      padding:
                                          const EdgeInsets.only(right: 12.0),
                                      child: const Text('Historical term')),
                                  Container(
                                    width: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.blueGrey.shade50,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    child: TermUi(
                                      term: historicalTerm,
                                      error: historicalTermError,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                width: 12,
                              ),

                              ///
                              /// Rescaling method
                              ///
                              Column(
                                children: [
                                  Container(
                                      width: 160,
                                      alignment: Alignment.centerLeft,
                                      padding:
                                          const EdgeInsets.only(right: 12.0),
                                      child: const Text('Rescaling method')),
                                  Container(
                                      width: 160,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      child: DropdownUi<String>(
                                          model: rescalingModelD, width: 160)),
                                ],
                              ),
                              const SizedBox(
                                width: 12,
                              ),

                              ///
                              /// Show
                              ///
                              Column(
                                children: [
                                  Container(
                                      width: 170,
                                      alignment: Alignment.centerLeft,
                                      padding:
                                          const EdgeInsets.only(right: 12.0),
                                      child: const Text('')),
                                  Container(
                                      width: 170,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.shade50,
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      // color: Colors.blueGrey.shade50,
                                      child: Multiselect2Ui(
                                        model: showD.value,
                                        label: const Text('Show'),
                                        width: 170,
                                      )),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          Container(
                            width: 504,
                            color: Colors.amber.shade50,
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Results',
                              style: TextStyle(color: Colors.amber.shade900),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child:
                                Watch((context) => const SummaryTableOption()),
                          ),
                        ],
                      ),

                      ///
                      /// plot
                      ///
                      Watch((context) {
                        switch (traces.value) {
                          // ignore: unused_local_variable
                          case AsyncData data:
                            return updatePlot();
                          case AsyncError error:
                            return Row(children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red),
                              Text(
                                error.error.toString(),
                                style: const TextStyle(fontSize: 16),
                              )
                            ]);
                          case AsyncLoading():
                            return const SizedBox(
                              width: 900,
                              height: 600,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircularProgressIndicator(),
                                    Text('    Loading ...'),
                                  ]),
                            );
                        }
                      }),
                    ],
                  ),
                ],
              ),
            )),
      ),
    ));
  }

  Widget updatePlot() {
    plotly.plot.react(traces.requireValue, layout, displaylogo: false);
    return Row(children: [
      SizedBox(width: 900, height: 600, child: plotly),
    ]);
  }
}

class OptionRow extends StatefulWidget {
  const OptionRow({super.key});
  @override
  State<OptionRow> createState() => _OptionRowState();
}

class _OptionRowState extends State<OptionRow> {
  @override
  Widget build(BuildContext context) {
    return Watch(
      (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ///
              /// Term
              ///
              Container(
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Center(
                    child: TermUi(
                  term: term,
                  error: termError,
                )),
              ),
              const SizedBox(
                width: 12,
              ),

              ///
              /// Location
              ///
              Container(
                  width: 160,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: DropdownUi<Location>(model: locationD, width: 160)),
              const SizedBox(
                width: 12,
              ),

              ///
              /// Market
              ///
              Container(
                  width: 70,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: DropdownUi(model: marketD, width: 70)),
              const SizedBox(
                width: 12,
              ),

              ///
              /// Bucket
              ///
              Container(
                  width: 100,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: DropdownUi(model: bucketD, width: 100)),
              const SizedBox(
                width: 12,
              ),

              ///
              /// Strike
              ///
              Container(
                  width: 60,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: NumberFieldUi(
                    number: strike,
                    error: strikeError,
                  )),
              const SizedBox(
                width: 12,
              ),

              ///
              /// Call/Put
              ///
              Container(
                  width: 100,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: DropdownUi(model: callPutD, width: 100)),
              const SizedBox(
                width: 12,
              ),

              ///
              /// Option type
              ///
              Container(
                  width: 140,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: DropdownUi(model: optionTypeD, width: 140)),
            ],
          ),
          Row(
            children: [
              if (termError.value != null)
                Text(
                  termError.value!,
                  style: const TextStyle(
                      color: Colors.red, fontFamily: 'Italic', fontSize: 11),
                ),
              if (strikeError.value != null)
                Padding(
                  padding: const EdgeInsets.only(left: 528.0),
                  child: Text(
                    strikeError.value!,
                    style: const TextStyle(
                        color: Colors.red, fontFamily: 'Italic', fontSize: 11),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
