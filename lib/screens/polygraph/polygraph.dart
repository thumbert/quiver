library screens.polygraph.polygraph;

import 'package:date/date.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/widgets.dart' hide Interval;
import 'package:flutter_quiver/models/common/experimental/power_deliverypoint_model.dart';
import 'package:flutter_quiver/models/common/experimental/select_variable_model.dart';
import 'package:flutter_quiver/models/common/market_model.dart';
import 'package:flutter_quiver/models/common/region_model.dart';
import 'package:flutter_quiver/models/common/term_model.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/screens/polygraph/polygraph_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart';

class Polygraph extends ConsumerStatefulWidget {
  const Polygraph({Key? key}) : super(key: key);

  static const route = '/polygraph';

  @override
  _PolygraphState createState() => _PolygraphState();
}

class _PolygraphState extends ConsumerState<Polygraph> {
  final controllerTerm = TextEditingController();
  final focusNodeTerm = FocusNode();
  late ScrollController _scrollControllerV;
  late ScrollController _scrollControllerH;

  String? _errorTerm;

  @override
  void initState() {
    super.initState();
    _scrollControllerH = ScrollController();
    _scrollControllerV = ScrollController();

    controllerTerm.text = ref.read(providerOfPolygraph).term.toString();
    focusNodeTerm.addListener(() {
      if (!focusNodeTerm.hasFocus) {
        /// validate when you lose focus
        setState(() {
          try {
            ref.read(providerOfPolygraph.notifier).term =
                Term.parse(controllerTerm.text, UTC);
            _errorTerm = null; // all good
          } catch (e) {
            debugPrint(e.toString());
            _errorTerm = 'Parsing error';
          }
        });
      }
    });
  }

  @override
  void dispose() {
    controllerTerm.dispose();
    focusNodeTerm.dispose();
    _scrollControllerH.dispose();
    _scrollControllerV.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Polygraph'),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                  'Experimental UI for curve visualization.'
                                      '\n'),
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
        padding: const EdgeInsets.only(left: 16.0, top: 12.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: _scrollControllerV,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: _scrollControllerH,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 8,
                ),
                /// Historical term
                SizedBox(
                    width: 140,
                    child: TextFormField(
                      focusNode: focusNodeTerm,
                      decoration: InputDecoration(
                        labelText: 'Term',
                        labelStyle:
                        TextStyle(color: Theme.of(context).primaryColor),
                        helperText: '',
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                          BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        errorText: _errorTerm,
                      ),
                      controller: controllerTerm,

                      /// validate when Enter is pressed
                      onEditingComplete: () {
                        setState(() {
                          try {
                            ref.read(providerOfPolygraph.notifier).term =
                                Term.parse(controllerTerm.text, UTC);
                            _errorTerm = null; // all good
                          } catch (e) {
                            debugPrint(e.toString());
                            _errorTerm = 'Parsing error';
                          }
                        });
                      },
                    )),
                const SizedBox(
                  height: 8,
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
                  height: 12,
                ),



                // FutureBuilder(
                //   future:
                //   RateBoardState.getOffers(state.region, state.stateName),
                //   builder: (context, snapshot) {
                //     List<Widget> children;
                //     if (snapshot.hasData) {
                //       var columns = _makeColumns(state);
                //       var tbl = state.makeOfferTable(
                //           asOfDate: Date.today(location: UTC).previous);
                //       // print(tbl.take(2).map((e) => e.toMap()));
                //       if (tbl.isEmpty) {
                //         children = [const Text('')];
                //       } else {
                //         children = [
                //           SizedBox(
                //             width: 1000,
                //             child: PaginatedDataTable(
                //               dataRowHeight: 64,
                //               columnSpacing: 24,
                //               columns: columns,
                //               source: _DataTableSource(tbl),
                //               rowsPerPage: min(20, tbl.length),
                //               showFirstLastButtons: true,
                //               header: const Text('Current offers'),
                //               actions: [
                //                 IconButton(
                //                     onPressed: () {
                //                       Clipboard.setData(ClipboardData(
                //                           text: table.Table.from(
                //                               tbl.map((e) => e.toMap()))
                //                               .toCsv()));
                //                     },
                //                     tooltip: 'Copy',
                //                     icon: const Icon(Icons.content_copy)),
                //                 IconButton(
                //                     onPressed: () => downloadTableToCsv(
                //                         tbl.map((e) => e.toMap()).toList()),
                //                     tooltip: 'Download',
                //                     icon: const Icon(Icons.download_outlined))
                //               ],
                //               // )
                //             ),
                //           ),
                //           if (state.stateName == 'MA')
                //             const Text('*A mention of 100% in plan Features indicates '
                //                 'that the plan is supplied with 100% green power. '
                //               , style: TextStyle(fontStyle: FontStyle.italic),),
                //         ];
                //       }
                //     } else if (snapshot.hasError) {
                //       children = [
                //         const Icon(Icons.error_outline, color: Colors.red),
                //         Text(
                //           snapshot.error.toString(),
                //           style: const TextStyle(fontSize: 16),
                //         )
                //       ];
                //     } else {
                //       children = [
                //         const SizedBox(
                //             height: 40,
                //             width: 40,
                //             child: CircularProgressIndicator(
                //               strokeWidth: 2,
                //             ))
                //       ];
                //     }
                //     return Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         // mainAxisSize: MainAxisSize.min,
                //         children: children);
                //   },
                // ),
              ],
            ),
          ),
          // ),
        ),
      ),
    );


  }
}
