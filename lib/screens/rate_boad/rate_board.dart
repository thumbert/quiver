library screens.pool_load_stats.rate_board;

import 'dart:math';

import 'package:date/date.dart';
import 'package:elec_server/client/utilities/retail_offers/retail_supply_offer.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter/services.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/rate_board/rate_board_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:timezone/timezone.dart';
import 'package:table/table_base.dart' as table;
import 'package:flutter_quiver/utils/empty_download.dart'
    if (dart.library.html) '../../utils/download.dart';

class RateBoard extends ConsumerStatefulWidget {
  const RateBoard({Key? key}) : super(key: key);

  static const route = '/rate_board';

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RateBoardState();
}

class _RateBoardState extends ConsumerState<RateBoard> {
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
    _scrollControllerH.dispose();
    _scrollControllerV.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(providerOfRateBoard);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Retail offers rate board'),
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
                                  'Display retail competitive offers in ISONE.  '
                                  'CT data is '
                                  'scraped daily from the energize CT website.  '
                                  'MA data comes from massenergyrates.com.  '
                                  'As of now, only Residential data in MA is scraped daily.  '
                                  'The offers collected daily are saved to an internal '
                                  'database for further competitive analysis.'
                                  '\n'),
                              Text(
                                  'Other zones will be added over time.  Contact '
                                  'Adrian Dragulescu for questions/ideas on how to '
                                  'use this data.'),
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
            // child: LayoutBuilder(
            //   builder: (context, constraints) => ConstrainedBox(
            //     constraints: BoxConstraints(minWidth: constraints.minWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 8,
                ),

                /// Region, State, Zone, Utility widgets
                Row(children: [
                  /// Term
                  // SizedBox(
                  //     width: 140,
                  //     child: TextFormField(
                  //       focusNode: focusNodeTerm,
                  //       decoration: InputDecoration(
                  //         labelText: 'Term',
                  //         labelStyle:
                  //         TextStyle(color: Theme.of(context).primaryColor),
                  //         helperText: '',
                  //         enabledBorder: UnderlineInputBorder(
                  //           borderSide:
                  //           BorderSide(color: Theme.of(context).primaryColor),
                  //         ),
                  //         errorText: _errorTerm,
                  //       ),
                  //       controller: controllerTerm,
                  //
                  //       /// validate when Enter is pressed
                  //       onEditingComplete: () {
                  //         setState(() {
                  //           try {
                  //             ref.read(providerOfRateBoard.notifier).term =
                  //                 Term.parse(controllerTerm.text, UTC);
                  //             _errorTerm = null; // all good
                  //           } catch (e) {
                  //             debugPrint(e.toString());
                  //             _errorTerm = 'Parsing error';
                  //           }
                  //         });
                  //       },
                  //     )),
                  // const SizedBox(
                  //   width: 36,
                  // ),

                  ///
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
                      items: state
                          .getAllRegions()
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                    ),
                  ),
                  const SizedBox(
                    width: 36,
                  ),

                  ///
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
                      items: state
                          .getAllStates()
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                    ),
                  ),
                  const SizedBox(
                    width: 36,
                  ),

                  ///
                  /// Load zone
                  ///
                  const Text(
                    'Load Zone',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Container(
                    color: MyApp.background,
                    width: 100,
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
                      items: state
                          .getAllZones()
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
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
                    width: 200,
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
                      onChanged: (String? newValue) {
                        ref.read(providerOfRateBoard.notifier).utility =
                            newValue!;
                      },
                      items: state
                          .getAllUtilities()
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                    ),
                  ),
                  const SizedBox(
                    width: 36,
                  ),

                  ///
                  /// Billing cycles
                  ///
                  const Text(
                    'Billing cycles',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Container(
                    color: MyApp.background,
                    width: 100,
                    child: DropdownButtonFormField(
                      value: state.billingCycles,
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
                          ref.read(providerOfRateBoard.notifier).billingCycle =
                              newValue!;
                        });
                      },
                      items: state
                          .getAllBillingCycles()
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                    ),
                  ),
                ]),

                const SizedBox(
                  height: 12,
                ),

                /// Account Type
                Row(
                  children: [
                    ///
                    /// Account type
                    ///
                    const Text(
                      'Account Type',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.normal),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    SizedBox(
                      width: 160,
                      child: CheckboxListTile(
                          title: const Text(
                            'Business',
                            style: TextStyle(fontSize: 16),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                          value: state.accountType.contains('Business'),
                          onChanged: (bool? value) {
                            setState(() {
                              ref
                                  .read(providerOfRateBoard.notifier)
                                  .checkboxBusiness = value!;
                            });
                          }),
                    ),
                    SizedBox(
                      width: 180,
                      child: CheckboxListTile(
                          title: const Text(
                            'Residential',
                            style: TextStyle(fontSize: 16),
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                          value: state.accountType.contains('Residential'),
                          onChanged: (bool? value) {
                            setState(() {
                              ref
                                  .read(providerOfRateBoard.notifier)
                                  .checkboxResidential = value!;
                            });
                          }),
                    ),

                    const SizedBox(
                      width: 16,
                    ),
                  ],
                ),

                FutureBuilder(
                  future:
                      RateBoardState.getOffers(state.region, state.stateName),
                  builder: (context, snapshot) {
                    List<Widget> children;
                    if (snapshot.hasData) {
                      var columns = _makeColumns(state);
                      var tbl = state.makeOfferTable(
                          asOfDate: Date.today(location: UTC).previous);
                      // print(tbl.take(2).map((e) => e.toMap()));
                      if (tbl.isEmpty) {
                        children = [const Text('')];
                      } else {
                        children = [
                          SizedBox(
                            width: 1000,
                            child: PaginatedDataTable(
                              dataRowHeight: 64,
                              columnSpacing: 24,
                              columns: columns,
                              source: _DataTableSource(tbl),
                              rowsPerPage: min(20, tbl.length),
                              showFirstLastButtons: true,
                              header: const Text('Current offers'),
                              actions: [
                                IconButton(
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(
                                          text: table.Table.from(
                                                  tbl.map((e) => e.toMap()))
                                              .toCsv()));
                                    },
                                    tooltip: 'Copy',
                                    icon: const Icon(Icons.content_copy)),
                                IconButton(
                                    onPressed: () => downloadTableToCsv(
                                        tbl.map((e) => e.toMap()).toList()),
                                    tooltip: 'Download',
                                    icon: const Icon(Icons.download_outlined))
                              ],
                              // )
                            ),
                          ),
                          if (state.stateName == 'MA')
                            const Text('*A mention of 100% in plan Features indicates '
                                'that the plan is supplied with 100% green power. '
                              , style: TextStyle(fontStyle: FontStyle.italic),),
                        ];
                      }
                    } else if (snapshot.hasError) {
                      children = [
                        const Icon(Icons.error_outline, color: Colors.red),
                        Text(
                          snapshot.error.toString(),
                          style: const TextStyle(fontSize: 16),
                        )
                      ];
                    } else {
                      children = [
                        const SizedBox(
                            height: 40,
                            width: 40,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ))
                      ];
                    }
                    return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // mainAxisSize: MainAxisSize.min,
                        children: children);
                  },
                ),
              ],
            ),
          ),
          // ),
        ),
      ),
    );
  }

  List<DataColumn> _makeColumns(RateBoardState state) {
    return <DataColumn>[
      _makeSortableColumn('Supplier', state),
      _makeSortableColumn('Months', state),
      if (state.stateName == 'CT') _makeSortableColumn('Recs', state),
      if (state.stateName == 'MA') const DataColumn(label: Text('Features')),
      const DataColumn(label: Text('Rate')),
      _makeSortableColumn('Posted Date', state),
    ];
  }

  DataColumn _makeSortableColumn(String name, RateBoardState state) {
    return DataColumn(
        label: TextButton(
            onPressed: () {
              setState(() {
                state.sortAscending = !state.sortAscending;
                state.sortColumn = name;
              });
            },
            child: Row(
              children: [
                if (state.sortColumn == name)
                  state.sortAscending
                      ? const Icon(Icons.arrow_upward)
                      : const Icon(Icons.arrow_downward),
                Text(name),
              ],
            )));
  }
}

class _DataTableSource extends DataTableSource {
  _DataTableSource(this.data);

  final List<RetailSupplyOffer> data;
  final _fmt = NumberFormat.currency(decimalDigits: 1, symbol: '\$');
  final _fmt2 = NumberFormat.currency(decimalDigits: 2, symbol: '');

  @override
  DataRow? getRow(int index) {
    var x = data[index];
    return DataRow(
        color: MaterialStateProperty.resolveWith((states) {
          if (x.supplierName.startsWith('Constellation')) {
            return Colors.pink.withOpacity(0.15);
          }
          return null;
        }),
        cells: [
          DataCell(Text(x.supplierName)),
          DataCell(Text(x.countOfBillingCycles.toString())),
          if (x.state == 'CT') DataCell(Text(_fmt2.format(x.minimumRecs))),
          if (x.state == 'MA')
            DataCell(SizedBox(
                width: 300,
                child: Text(
                  x.planFeatures.join('. '),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ))),
          DataCell(Text(_fmt.format(x.rate))),
          DataCell(Text(x.offerPostedOnDate.toString())),
        ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => data.length;

  @override
  int get selectedRowCount => 0;
}

Future<void> downloadTableToCsv(List<Map<String, dynamic>> data) async {
  var tbl = table.Table.from(data);
  download(tbl.toCsv().codeUnits, downloadName: 'monthly_asset_ncpc_data.csv');
}
