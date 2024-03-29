library screens.unmasked_energy_offers.unmasked_energy_offers_ui;

import 'package:elec/risk_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/common/region_model.dart';
import 'package:flutter_quiver/models/common/term_model.dart';
import 'package:flutter_quiver/models/unmasked_energy_offers.dart';
import 'package:flutter_quiver/screens/common/region.dart';
import 'package:flutter_quiver/screens/common/term.dart';
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
  late Plotly plotly;

  @override
  void initState() {
    _scrollController = ScrollController();
    final model = context.read<UnmaskedEnergyOffersModel>();
    model.getMaskedAssetIds();
    setState(() {
      model.cache.clear();
      var aux = DateTime.now().hashCode;
      plotly = Plotly(
        viewId: 'plotly-unmasked-energy-offers-$aux',
        data: const [],
        layout: model.layout,
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
    final regionModel = context.watch<RegionModel>();
    final termModel = context.watch<TermModel>();
    final model = context.watch<UnmaskedEnergyOffersModel>();

    setState(() {
      if (regionModel.iso != model.iso) {
        model.iso = regionModel.iso;
      }
    });

    var _assets = model.assetData.map((e) => e['name'] as String).toList();

    return Scaffold(
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
                      ),
                    ),
                    const SizedBox(width: 15),
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
                            plotly.plot
                                .react(traces, layout, displaylogo: false);
                            children = [
                              SizedBox(width: 750, height: 550, child: plotly),
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
}
