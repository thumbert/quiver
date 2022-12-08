library screens.pool_load_stats.rate_board;

import 'package:date/date.dart';
import 'package:elec_server/utils.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/rate_board/rate_board_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart';


class RateBoard extends ConsumerStatefulWidget {
  const RateBoard({Key? key}) : super(key: key);

  static const route = '/rate_board';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RateBoardState();
}

class _RateBoardState extends ConsumerState<RateBoard> {
  final controllerTerm = TextEditingController();

  final focusNodeTerm = FocusNode();

  String? _errorTerm;

  @override
  void initState() {
    super.initState();
    controllerTerm.text = ref.read(providerOfRateBoard).term.toString();

    focusNodeTerm.addListener(() {
      if (!focusNodeTerm.hasFocus) {
        /// validate when you lose focus
        setState(() {
          try {
            ref.read(providerOfRateBoard.notifier).term =
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(providerOfRateBoard);
    // print(state.region);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Retail offers board'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 8.0),
        child: Column(
          children: [

            /// Region, State, Zone, Utility widgets
            Row(children: [
              /// Term
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
                          ref.read(providerOfRateBoard.notifier).term =
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
                width: 36,
              ),

              /// Region
              ///
              const Text(
                'Region',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(
                width: 8,
              ),
              Container(
                color: MyApp.background,
                width: 100,
                child: DropdownButtonFormField(
                  value: state.region,
                  icon: const Icon(Icons.expand_more),
                  hint: const Text('Filter'),
                  decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.only(
                          left: 12, right: 2, top: 8, bottom: 8),
                      enabledBorder: InputBorder.none),
                  elevation: 16,
                  onChanged: (String? newValue) {
                    ref.read(providerOfRateBoard.notifier).region =
                    newValue!;
                  },
                  items: state.getAllRegions()
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
              ),
              const SizedBox(
                width: 36,
              ),

              /// State
              ///
              const Text(
                'State',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(
                width: 8,
              ),
              Container(
                color: MyApp.background,
                width: 100,
                child: DropdownButtonFormField(
                  value: state.stateName,
                  icon: const Icon(Icons.expand_more),
                  hint: const Text('Filter'),
                  decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.only(
                          left: 12, right: 2, top: 8, bottom: 8),
                      enabledBorder: InputBorder.none),
                  elevation: 16,
                  onChanged: (String? newValue) {
                    ref.read(providerOfRateBoard.notifier).stateName =
                    newValue!;
                  },
                  items: state.getAllStates()
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
              ),
              const SizedBox(
                width: 36,
              ),

              /// Zone
              ///
              const Text(
                'Zone',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(
                width: 8,
              ),
              Container(
                color: MyApp.background,
                width: 140,
                child: DropdownButtonFormField(
                  value: state.loadZone,
                  icon: const Icon(Icons.expand_more),
                  hint: const Text('Filter'),
                  decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.only(
                          left: 12, right: 2, top: 8, bottom: 8),
                      enabledBorder: InputBorder.none),
                  elevation: 16,
                  onChanged: (newValue) {
                    ref.read(providerOfRateBoard.notifier).loadZone =
                    newValue as String;
                  },
                  items: state.getAllZones()
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
              ),
              const SizedBox(
                width: 36,
              ),

              /// Utility
              ///
              const Text(
                'Utility',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(
                width: 8,
              ),
              Container(
                color: MyApp.background,
                width: 140,
                child: DropdownButtonFormField(
                  value: state.utility,
                  icon: const Icon(Icons.expand_more),
                  hint: const Text('Filter'),
                  decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.only(
                          left: 12, right: 2, top: 8, bottom: 8),
                      enabledBorder: InputBorder.none),
                  elevation: 16,
                  onChanged: (newValue) {
                    ref.read(providerOfRateBoard.notifier).loadZone =
                    newValue as String;
                  },
                  items: state.getAllUtilities()
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                ),
              ),
            ]
            ),


            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ///
                /// Account type
                ///
                const Text(
                  'Account Type',
                  style: TextStyle(
                      fontSize: 24, fontWeight: FontWeight.normal),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Check

                    const SizedBox(
                      height: 4,
                    ),

                    ///
                    /// Aggregation
                    ///
                    // Row(
                    //   children: [
                    //     Container(
                    //       width: 120,
                    //       padding: const EdgeInsets.all(8),
                    //       alignment: AlignmentDirectional.centerEnd,
                    //       child: const Text(
                    //         'Aggregation',
                    //         style: TextStyle(fontSize: 16),
                    //       ),
                    //     ),
                    //     const SizedBox(
                    //       width: 8,
                    //     ),
                    //     Container(
                    //       color: MyApp.background,
                    //       width: 130,
                    //       child: DropdownButtonFormField(
                    //         value: state.aggregation,
                    //         icon: const Icon(Icons.expand_more),
                    //         hint: const Text('Filter'),
                    //         decoration: const InputDecoration(
                    //           isDense: true,
                    //           contentPadding: EdgeInsets.only(
                    //               left: 12, right: 2, top: 9, bottom: 9),
                    //           enabledBorder: InputBorder.none,
                    //         ),
                    //         elevation: 16,
                    //         onChanged: (String? newValue) {
                    //           setState(() {
                    //             ref
                    //                 .read(providerOfPoolLoadStats.notifier)
                    //                 .aggregation = newValue!;
                    //           });
                    //         },
                    //         items: PoolLoadStatsState.allAggregations
                    //             .map((e) =>
                    //             DropdownMenuItem(value: e, child: Text(e)))
                    //             .toList(),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(
                    //   height: 8,
                    // ),

                    ///
                    /// Years
                    ///
                    Row(
                      children: [
                        Container(
                          // color: Colors.green,
                          height: 34,
                          width: 80,
                          padding: const EdgeInsets.all(8),
                          alignment: AlignmentDirectional.centerEnd,
                          child: const Tooltip(
                            message: 'e.g. 2017-2019, 2022',
                            child: Text(
                              'Years',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Container(
                          color: MyApp.background,
                          width: 180,
                          child: TextField(
                            controller: controllerYears,
                            focusNode: focusNodeYears,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(12),
                              enabledBorder: InputBorder.none,
                              errorText: errorYears,
                            ),
                            onEditingComplete: () {
                              setState(() {
                                validateYears(state);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),

                    ///
                    /// Months
                    ///
                    Row(
                      children: [
                        Container(
                          height: 34,
                          width: 80,
                          padding: const EdgeInsets.all(8),
                          alignment: AlignmentDirectional.centerEnd,
                          child: const Tooltip(
                            message: 'e.g. 1-3, 6, 11-12',
                            child: Text(
                              'Months',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Container(
                          color: MyApp.background,
                          width: 180,
                          child: TextField(
                            controller: controllerMonths,
                            focusNode: focusNodeMonths,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(12),
                              enabledBorder: InputBorder.none,
                              errorText: errorMonths,
                            ),
                            onEditingComplete: () {
                              setState(() {
                                validateMonths(state);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),

                    ///
                    /// Day type
                    ///
                    Row(
                      children: [
                        Container(
                          width: 80,
                          padding: const EdgeInsets.all(8),
                          alignment: AlignmentDirectional.centerEnd,
                          child: const Text(
                            'Day type',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Container(
                          color: MyApp.background,
                          width: 180,
                          child: DropdownButtonFormField(
                            value: state.dayType,
                            icon: const Icon(Icons.expand_more),
                            hint: const Text('Filter'),
                            decoration: const InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.only(
                                  left: 12, right: 2, top: 9, bottom: 9),
                              enabledBorder: InputBorder.none,
                            ),
                            elevation: 16,
                            onChanged: (String? newValue) {
                              setState(() {
                                ref
                                    .read(providerOfPoolLoadStats.notifier)
                                    .dayType = newValue!;
                              });
                            },
                            items: PoolLoadStatsState.allDayTypes
                                .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),

                    ///
                    /// Temperature
                    ///
                    Row(
                      children: [
                        Container(
                          // color: Colors.green,
                          height: 34,
                          width: 140,
                          padding: const EdgeInsets.all(8),
                          alignment: AlignmentDirectional.centerEnd,
                          child: const Tooltip(
                            message: 'Airport name, i.e. LGA',
                            child: Text(
                              'Temperature',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Container(
                          color: MyApp.background,
                          width: 120,
                          child: TextField(
                            controller: controllerAirport,
                            focusNode: focusNodeAirport,
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.all(12),
                              enabledBorder: InputBorder.none,
                              errorText: errorAirport,
                            ),
                            onEditingComplete: () {
                              setState(() {
                                validateAirport(state);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(
                  width: 16,
                ),

                ///
                /// Display
                ///
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Display',
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.normal),
                    ),
                    const SizedBox(
                      height: 4,
                    ),

                    /// X variable, Y variable, colorBy.
                    Row(
                      children: [
                        const Text(
                          'X variable',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.normal),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Container(
                          color: MyApp.background,
                          padding: const EdgeInsetsDirectional.only(
                              start: 6, end: 6),
                          width: 160,
                          child: DropdownButtonFormField(
                            value: state.xVariable,
                            icon: const Icon(Icons.expand_more),
                            hint: const Text('Filter'),
                            decoration: const InputDecoration(
                              isDense: true,
                              enabledBorder: InputBorder.none,
                            ),
                            elevation: 16,
                            // alignment: AlignmentDirectional.bottomCenter,
                            onChanged: (String? newValue) {
                              setState(() {
                                ref
                                    .read(providerOfPoolLoadStats.notifier)
                                    .xVariable = newValue!;
                              });
                            },
                            items: PoolLoadStatsState.allXVariables
                                .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                          ),
                        ),
                        const SizedBox(
                          width: 36,
                        ),

                        ///
                        ///
                        ///
                        const Text(
                          'Y variable',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.normal),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Container(
                          color: MyApp.background,
                          padding: const EdgeInsetsDirectional.only(
                              start: 6, end: 6),
                          width: 200,
                          child: DropdownButtonFormField(
                            value: state.yVariable,
                            icon: const Icon(Icons.expand_more),
                            hint: const Text('Filter'),
                            decoration: const InputDecoration(
                              isDense: true,
                              enabledBorder: InputBorder.none,
                            ),
                            elevation: 16,
                            onChanged: (String? newValue) {
                              setState(() {
                                ref
                                    .read(providerOfPoolLoadStats.notifier)
                                    .yVariable = newValue!;
                              });
                            },
                            items: PoolLoadStatsState.allYVariables
                                .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                          ),
                        ),
                        const SizedBox(
                          width: 36,
                        ),

                        ///
                        ///
                        ///
                        const Text(
                          'Color by',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.normal),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Container(
                          color: MyApp.background,
                          padding: const EdgeInsetsDirectional.only(
                              start: 6, end: 6),
                          width: 100,
                          child: DropdownButtonFormField(
                            value: state.colorBy,
                            icon: const Icon(Icons.expand_more),
                            hint: const Text('Filter'),
                            decoration: const InputDecoration(
                              isDense: true,
                              enabledBorder: InputBorder.none,
                            ),
                            elevation: 16,
                            // alignment: AlignmentDirectional.bottomCenter,
                            onChanged: (String? newValue) {
                              setState(() {
                                ref
                                    .read(providerOfPoolLoadStats.notifier)
                                    .colorBy = newValue!;
                              });
                            },
                            items: ['', 'Year', 'Month']
                                .map((e) =>
                                DropdownMenuItem(value: e, child: Text(e)))
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 8,
                    ),

                    PoolLoadStatsState.needsData
                        ? FutureBuilder(
                        future: state.getData(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.done) {
                            if (snapshot.hasError) {
                              print(snapshot.error);
                              return const Text(
                                'Error retrieving data from the database',
                                style: TextStyle(color: Colors.red),
                              );
                            }
                            return const Text('Hi');
                          } else {
                            return Row(
                              children: const [
                                CircularProgressIndicator(),
                                SizedBox(
                                  width: 12,
                                ),
                                Text(
                                    'Getting the data from Shooju...  Go get a coffee')
                              ],
                            );
                          }
                        })
                        : Text('Hi'),//const LoadStatsPlot(),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
