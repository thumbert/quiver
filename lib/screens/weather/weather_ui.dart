library screens.weather.weather_ui;

import 'package:elec/risk_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/weather/airport_model.dart';
import 'package:flutter_quiver/models/weather/weather_model.dart';
import 'package:flutter_quiver/screens/weather/airport.dart';
import 'package:flutter_quiver/screens/weather/month_range.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class WeatherUi extends StatefulWidget {
  const WeatherUi({Key? key}) : super(key: key);

  @override
  _WeatherUiState createState() => _WeatherUiState();
}

class _WeatherUiState extends State<WeatherUi> {
  var fmt = NumberFormat.currency(decimalDigits: 0, symbol: '\$');
  late ScrollController _scrollController;
  final notionalController = TextEditingController();
  final maxPayoffController = TextEditingController();
  final strikeController = TextEditingController();
  final focusAirport = FocusNode();

  String? errorNotional;
  String? errorMaxPayoff;
  String? errorStrike;

  @override
  void initState() {
    final model = context.read<WeatherModel>();
    _scrollController = ScrollController();
    notionalController.text = model.notional.toString();
    maxPayoffController.text = model.maxPayoff.toString();
    strikeController.text = model.strike.toString();

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    notionalController.dispose();
    maxPayoffController.dispose();
    strikeController.dispose();
    focusAirport.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final airportModel = context.watch<AirportModel>();
    final model = context.watch<WeatherModel>();

    return Padding(
        padding: const EdgeInsets.only(left: 48),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Weather UI'),
            actions: [
              IconButton(
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return const SimpleDialog(
                          children: [
                            Text('Screen to get quick stats on weather indices '
                                'and to price weather instruments.'),
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
            child: Scrollbar(
              controller: _scrollController,
              isAlwaysShown: true,
              child: ListView(
                controller: _scrollController,
                children: [
                  Row(
                    children: const [
                      SizedBox(width: 120, child: Airport()),
                    ],
                  ),
                  Row(
                    children: const [
                      SizedBox(
                        width: 80,
                        child: Text('Term', style: TextStyle(fontSize: 16)),
                      ),
                      SizedBox(width: 120, child: MonthRange()),
                    ],
                  ),

                  // Row(
                  //   children: [
                  //     Checkbox(
                  //         value: tableModel.byZone,
                  //         onChanged: (bool? value) {
                  //           setState(() {
                  //             tableModel.byZone = value!;
                  //           });
                  //         }),
                  //     const SizedBox(
                  //       width: 20,
                  //     ),
                  //     const SizedBox(
                  //       width: 80,
                  //       child: Text('Zone', style: TextStyle(fontSize: 16)),
                  //     ),
                  //     const LoadZone(),
                  //   ],
                  // ),
                  // Row(
                  //   children: [
                  //     Checkbox(
                  //         value: tableModel.byMarket,
                  //         onChanged: (bool? value) {
                  //           setState(() {
                  //             tableModel.byMarket = value!;
                  //           });
                  //         }),
                  //     const SizedBox(
                  //       width: 20,
                  //     ),
                  //     const SizedBox(
                  //       width: 80,
                  //       child: Text('Market', style: TextStyle(fontSize: 16)),
                  //     ),
                  //     SizedBox(
                  //       width: 150,
                  //       child: DropdownButtonFormField(
                  //         value: tableModel.market,
                  //         icon: const Icon(Icons.expand_more),
                  //         hint: const Text('Filter'),
                  //         decoration: InputDecoration(
                  //             enabledBorder: UnderlineInputBorder(
                  //                 borderSide: BorderSide(
                  //                     color: Theme.of(context).primaryColor))),
                  //         elevation: 16,
                  //         onChanged: (String? newValue) {
                  //           setState(() {
                  //             tableModel.market = newValue!;
                  //           });
                  //         },
                  //         items: ['(All)', 'DA', 'RT']
                  //             .map((e) =>
                  //                 DropdownMenuItem(value: e, child: Text(e)))
                  //             .toList(),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // Row(
                  //   children: [
                  //     Checkbox(
                  //         value: tableModel.byAsset,
                  //         onChanged: (bool? value) {
                  //           setState(() {
                  //             tableModel.byAsset = value!;
                  //           });
                  //         }),
                  //     const SizedBox(
                  //       width: 20,
                  //     ),
                  //     const SizedBox(
                  //       width: 80,
                  //       child: Text('Asset', style: TextStyle(fontSize: 16)),
                  //     ),
                  //     SizedBox(
                  //       width: 150,
                  //       child: DropdownButtonFormField(
                  //         value: tableModel.assetName,
                  //         icon: const Icon(Icons.expand_more),
                  //         hint: const Text('Filter'),
                  //         decoration: InputDecoration(
                  //             enabledBorder: UnderlineInputBorder(
                  //                 borderSide: BorderSide(
                  //                     color: Theme.of(context).primaryColor))),
                  //         elevation: 16,
                  //         onChanged: (String? newValue) {
                  //           setState(() {
                  //             tableModel.assetName = newValue!;
                  //           });
                  //         },
                  //         items: [
                  //           '(All)',
                  //           'DA',
                  //           'RT'
                  //         ] // FIXME: replace with the correct list of assets!
                  //             .map((e) =>
                  //                 DropdownMenuItem(value: e, child: Text(e)))
                  //             .toList(),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(
                  //   width: 150,
                  //   child: CheckboxListTile(
                  //     title: const Text('Month'),
                  //     controlAffinity: ListTileControlAffinity.leading,
                  //     contentPadding: const EdgeInsets.all(0),
                  //     value: tableModel.byMonth,
                  //     onChanged: (bool? value) {
                  //       setState(() {
                  //         tableModel.byMonth = value!;
                  //       });
                  //     },
                  //   ),
                  // ),
                  //
                  // FutureBuilder(
                  //   future: tableModel.getData(termModel.term),
                  //   builder: (context, snapshot) {
                  //     List<Widget> children;
                  //     if (snapshot.hasData) {
                  //       // aggregate the data first
                  //       var aggData = tableModel.client.summary(
                  //         snapshot.data! as Iterable<Map<String, dynamic>>,
                  //         zoneId: zoneModel.zoneId,
                  //         byZoneId: tableModel.byZone,
                  //         market: tableModel.market == '(All)'
                  //             ? null
                  //             : Market.parse(tableModel.market),
                  //         byMarket: tableModel.byMarket,
                  //         assetName: tableModel.assetName == '(All)'
                  //             ? null
                  //             : tableModel.assetName,
                  //         byAssetName: tableModel.byAsset,
                  //         byMonth: tableModel.byMonth,
                  //       );
                  //       children = [_makeDataTable(aggData)];
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
                  //     return Row(children: children);
                  //   },
                  // ),

                  const SizedBox(
                    height: 24,
                  ),
                  // Text('Selected: ${getSelection(market, bucket)}'),
                ],
              ),
            ),
          ),
        ));
  }

  /// The data table with a download/copy to clipboard widget.
  /// Table is sortable by value column
  DataTable _makeDataTable(Iterable<Map<String, dynamic>> data) {
    data.forEach(print);
    var names = data.first.keys.toSet();
    var columns = [
      if (names.contains('zone')) const DataColumn(label: Text('Zone Id')),
      if (names.contains('market')) const DataColumn(label: Text('Market')),
      if (names.contains('name')) const DataColumn(label: Text('Asset Name')),
      if (names.contains('month')) const DataColumn(label: Text('Month')),
      if (names.contains('value'))
        const DataColumn(
            label: Text('NCPC'), tooltip: '\$ Credits', numeric: true),
    ];
    var rows = <DataRow>[
      for (var x in data)
        DataRow(cells: [
          if (names.contains('zone')) DataCell(Text(x['zone'].toString())),
          if (names.contains('market'))
            DataCell(Text((x['market'] as Market).name)),
          if (names.contains('name')) DataCell(Text(x['name'])),
          if (names.contains('month')) DataCell(Text(x['month'])),
          DataCell(Text(fmt.format(x['value']))),
        ])
    ];

    _sortingIndex() {
      if (names.contains('month')) {
        return names.length - 2;
      }
      return 0;
    }

    return DataTable(
      sortColumnIndex: _sortingIndex(),
      columns: columns,
      rows: rows,
    );
  }
}
