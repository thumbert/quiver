library screens.unmasked_energy_offers.unmasked_energy_offers_ui;

import 'package:elec/risk_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/term_model.dart';
import 'package:flutter_quiver/models/unmasked_energy_offers.dart';
import 'package:flutter_quiver/models/weather/airport_model.dart';
import 'package:flutter_quiver/models/weather/month_range_model.dart';
import 'package:flutter_quiver/models/weather/weather_model.dart';
import 'package:flutter_quiver/screens/common/term.dart';
import 'package:flutter_quiver/screens/weather/airport.dart';
import 'package:flutter_quiver/screens/weather/instrument_rows.dart';
import 'package:flutter_quiver/screens/weather/month_range.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UnmaskedEnergyOffersUi extends StatefulWidget {
  const UnmaskedEnergyOffersUi({Key? key}) : super(key: key);

  @override
  _UnmaskedEnergyOffersUiState createState() => _UnmaskedEnergyOffersUiState();
}

class _UnmaskedEnergyOffersUiState extends State<UnmaskedEnergyOffersUi> {
  var fmt = NumberFormat.currency(decimalDigits: 0, symbol: '\$');
  late ScrollController _scrollController;

  @override
  void initState() {
    _scrollController = ScrollController();
    final model = context.read<UnmaskedEnergyOffersModel>();
    model.getMaskedAssetIds().then((value) {
      // Select Kleen
      model
          .clickCheckbox(model.assetData.indexWhere((e) => e['ptid'] == 14614));
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
    final termModel = context.watch<TermModel>();
    final model = context.watch<UnmaskedEnergyOffersModel>();
    var _assets = model.assetData.map((e) => e['name'] as String).toList();

    return Padding(
      padding: const EdgeInsets.only(left: 48),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Unmasked Energy Offers'),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const SimpleDialog(
                        children: [
                          Text('Historical energy offers for all assets in '
                              'ISONE.  Unmasking has been done in a different '
                              'process.'
                              '\n\nClick on an asset name to select it'
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  SizedBox(width: 120, child: TermUi()),
                ],
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 300,
                      child: ListView.builder(
                        // shrinkWrap: true,
                        controller: _scrollController,
                        itemCount: model.assetData.length,
                        itemBuilder: (BuildContext context, int index) {
                          return CheckboxListTile(
                            title: Text(_assets[index]),
                            dense: true,
                            onChanged: (bool? value) =>
                                model.clickCheckbox(index),
                            value: model.checkboxes[index],
                          );
                        },
                        // children: [
                        // ],
                      ),
                    ),
                    const SizedBox(width: 15),
                    // Flexible(
                    //   child: Container(
                    //     width: 700,
                    //     height: 500,
                    //     color: Colors.greenAccent,
                    //   ),
                    // ),
                    FutureBuilder(
                        future: model.makeTraces(termModel.term),
                        builder: (context, snapshot) {
                          List<Widget> children;
                          if (snapshot.hasData) {
                            var traces = snapshot.data! as List;
                            var layout = model.layout;
                            if (traces.length == 1) {
                              layout['title'] =
                                  'MW weighted Energy Offer price';
                            }
                            children = [
                              SizedBox(
                                  width: model.layout['width'] as double,
                                  height: model.layout['height'] as double,
                                  child: Plotly(
                                    viewId: 'plotly-unmasked-energy-offers',
                                    data: traces,
                                    layout: layout,
                                  )),
                            ];
                          } else if (snapshot.hasError) {
                            children = [
                              const Icon(Icons.error_outline,
                                  color: Colors.red),
                              Text(
                                snapshot.error.toString(),
                                style: const TextStyle(fontSize: 16),
                              )
                            ];
                          } else {
                            children = [
                              const SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 4,
                                  )),
                            ];
                            // the only way I found to keep the progress indicator centered
                            return Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: children);
                          }
                          return Row(children: children);
                        }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
