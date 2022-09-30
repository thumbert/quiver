library screens.pool_load_stats.pool_load_stats;

import 'package:date/date.dart';
import 'package:elec_server/utils.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/pool_load_stats/pool_load_stats_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart';

class PoolLoadStats extends ConsumerStatefulWidget {
  const PoolLoadStats({Key? key}) : super(key: key);

  static const route = '/pool_load_stats';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PoolLoadStatsState();
}

class _PoolLoadStatsState extends ConsumerState<PoolLoadStats> {

  final controllerTerm = TextEditingController();
  final controllerYears = TextEditingController();
  final controllerMonths = TextEditingController();

  final focusNodeTerm = FocusNode();
  final focusNodeYears = FocusNode();
  final focusNodeMonths = FocusNode();

  String? _errorTerm;
  String? errorYears;
  String? errorMonths;

  @override
  void initState() {
    super.initState();
    controllerTerm.text = ref.read(providerOfPoolLoadStats).term.toString();

    focusNodeTerm.addListener(() {
      if (!focusNodeTerm.hasFocus) {
        /// validate when you lose focus
        setState(() {
          try {
            ref
                .read(providerOfPoolLoadStats.notifier)
                .term = Term.parse(controllerTerm.text, UTC);
            _errorTerm = null; // all good
          } catch (e) {
            debugPrint(e.toString());
            _errorTerm = 'Parsing error';
          }
        });
      }
    });
    focusNodeYears.addListener(() {
      if (!focusNodeYears.hasFocus) {
        setState(() {
          validateYears(ref.read(providerOfPoolLoadStats));
        });
      }
    });

    focusNodeMonths.addListener(() {
      if (!focusNodeMonths.hasFocus) {
        setState(() {
          validateMonths(ref.read(providerOfPoolLoadStats));
        });
      }
    });
  }

  void validateYears(PoolLoadStatsState state) {
    errorYears = null;
    try {
      var years = unpackIntegerList(controllerYears.text,
          minValue: 2000, maxValue: 3000);
      ref.read(providerOfPoolLoadStats.notifier).years = years;
    } catch (_) {
      errorYears = 'Incorrect year list';
      ref.read(providerOfPoolLoadStats.notifier).years = <int>[];
    }
  }

  void validateMonths(PoolLoadStatsState state) {
    errorMonths = null;
    try {
      var months =
      unpackIntegerList(controllerMonths.text, minValue: 1, maxValue: 12);
      ref.read(providerOfPoolLoadStats.notifier).months = months;
    } catch (_) {
      errorMonths = 'Incorrect months list';
      ref.read(providerOfPoolLoadStats.notifier).months = <int>[];
    }
  }


  @override
  void dispose() {
    controllerTerm.dispose();
    focusNodeTerm.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final state = ref.watch(providerOfPoolLoadStats);
    // print(state.region);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pool load statistics'),
      ),
      body: Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 8.0),
          child: Column(
            children: [
              Row(
                children: [
                  /// Term
                  SizedBox(width: 140, child:
                    TextFormField(
                    focusNode: focusNodeTerm,
                    decoration: InputDecoration(
                      labelText: 'Term',
                      labelStyle: TextStyle(color: Theme.of(context).primaryColor),
                      helperText: '',
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      errorText: _errorTerm,
                    ),
                    controller: controllerTerm,

                    /// validate when Enter is pressed
                    onEditingComplete: () {
                      setState(() {
                        try {
                          ref
                              .read(providerOfPoolLoadStats.notifier)
                              .term = Term.parse(controllerTerm.text, UTC);
                          _errorTerm = null; // all good
                        } catch (e) {
                          debugPrint(e.toString());
                          _errorTerm = 'Parsing error';
                        }
                      });
                    },
                  )),
                  const SizedBox(width: 36,),


                  /// Region
                  ///
                  const Text(
                    'Region',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8,),
                  Container(
                    color: MyApp.background,
                    width: 100,
                    child: DropdownButtonFormField(
                      value: state.region,
                      icon: const Icon(Icons.expand_more),
                      hint: const Text('Filter'),
                      decoration: const InputDecoration(
                        isDense: true,
                          contentPadding: EdgeInsets.only(left: 12, right: 2, top: 8, bottom: 8),
                          enabledBorder: InputBorder.none),
                      elevation: 16,
                      onChanged: (String? newValue) {
                        ref
                            .read(providerOfPoolLoadStats.notifier)
                            .region = newValue!;
                      },
                      items: PoolLoadStatsState.allRegions.keys
                          .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                    ),
                  ),
                  const SizedBox(width: 36,),


                  /// Zone
                  ///
                  const Text(
                    'Zone',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8,),
                  Container(
                    color: MyApp.background,
                    width: 100,
                    child: DropdownButtonFormField(
                      value: state.zone,
                      icon: const Icon(Icons.expand_more),
                      hint: const Text('Filter'),
                      decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.only(left: 12, right: 2, top: 8, bottom: 8),
                          enabledBorder: InputBorder.none),
                      elevation: 16,
                      onChanged: (newValue) {
                        ref
                            .read(providerOfPoolLoadStats.notifier)
                            .zone = newValue as String;
                      },
                      items: ['(All)', ...PoolLoadStatsState.allRegions[state.region]!['zoneNames']]
                          .map((e) =>
                          DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                    ),
                  ),
      ]),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ///
                      /// Filters
                      ///
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Filters',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
                          ),
                          const SizedBox(
                            height: 4,
                          ),

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
                                width: 170,
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
                                width: 170,
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
                                width: 170,
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
                                      ref.read(providerOfPoolLoadStats.notifier).dayType =
                                      newValue!;
                                    });
                                  },
                                  items: PoolLoadStatsState.allDayTypes
                                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                      .toList(),
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
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.normal),
                          ),
                          const SizedBox(
                            height: 4,
                          ),

                          /// X variable, Y variable, colorBy.
                          Row(
                            children: [
                              const Text(
                                'X variable',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Container(
                                color: MyApp.background,
                                padding: const EdgeInsetsDirectional.only(start: 6, end: 6),
                                width: 140,
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
                                      ref.read(providerOfPoolLoadStats.notifier).xVariable =
                                      newValue!;
                                    });
                                  },
                                  items: ['Temperature', 'Date', 'Month']
                                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Container(
                                color: MyApp.background,
                                padding: const EdgeInsetsDirectional.only(start: 6, end: 6),
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
                                  // alignment: AlignmentDirectional.bottomCenter,
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      ref.read(providerOfPoolLoadStats.notifier).yVariable =
                                      newValue!;
                                    });
                                  },
                                  items: ['Energy', 'Max Hourly Value', 'Min Hourly Value']
                                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
                              ),
                              const SizedBox(
                                width: 8,
                              ),
                              Container(
                                color: MyApp.background,
                                padding: const EdgeInsetsDirectional.only(start: 6, end: 6),
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
                                      ref.read(providerOfPoolLoadStats.notifier).colorBy =
                                      newValue!;
                                    });
                                  },
                                  items: ['', 'Year', 'Month']
                                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                                      .toList(),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          // const LoadStatsPlot(),
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
