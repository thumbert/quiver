import 'package:date/date.dart';
import 'package:flutter/material.dart' hide Interval;
// import 'package:flutter_quiver/models/mcc_surfer/mcc_surfer_model.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:quiver_core/quiver_core.dart';
import 'package:signals_flutter/signals_flutter.dart';

import '../../models/masked_monthly_capacity/masked_monthly_capacity.dart';

class MaskedMonthlyCapacity extends StatefulWidget {
  const MaskedMonthlyCapacity({super.key});

  static const route = '/masked_monthly_capacity';

  @override
  State<StatefulWidget> createState() => _MaskedMonthlyCapacityState();
}

class _MaskedMonthlyCapacityState extends State<MaskedMonthlyCapacity> {
  late ScrollController _scrollController;
  late ScrollController _scrollControllerH;
  late Plotly plotlyBidsOffers;
  late EffectCleanup _clearCacheEffect;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollControllerH = ScrollController();
    var aux = DateTime.now().hashCode;
    plotlyBidsOffers = Plotly(
      viewId: 'plotly-masked-capacity-$aux',
      traces: const [],
      layout: layout.value,
    );
    // _clearCacheEffect = effect(() {
    //   month.value; // subscribe
    //   region.value; // subscribe
    //   cacheTraces.clear();
    //   cacheConstraints.clear();
    // });

    super.initState();
  }

  @override
  void dispose() {
    _clearCacheEffect();
    _scrollController.dispose();
    _scrollControllerH.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Masked Monthly Capacity'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      contentPadding: const EdgeInsets.all(12),
                      children: [
                        SizedBox(
                          width: 500,
                          child: Column(
                            children: const [
                              Text(
                                  'Visualize bids/offers for the monthly capacity market. '
                                  '\n'),
                            ],
                          ),
                        )
                      ],
                    );
                  });
            },
            icon: const Icon(Icons.info_outline),
            tooltip: 'Info',
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(left: 12, top: 8.0),
        child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            controller: _scrollController,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                controlWidgets(),
                const SizedBox(
                  height: 16,
                ),
                Scrollbar(
                  controller: _scrollControllerH,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollControllerH,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        SignalBuilder(builder: (context) {
                          switch (getData.value) {
                            // ignore: unused_local_variable
                            case AsyncData data:
                              final tracesV = traces.value;
                              plotlyBidsOffers.react(tracesV, layout.value,
                                  plotlyBidsOffers.config);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      width: layout.value['width'] as double,
                                      height: layout.value['height'] as double,
                                      child: plotlyBidsOffers),
                                  SizedBox(height: 12),
                                ],
                              );
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
                              return SizedBox(
                                width: layout.value['width'] as double,
                                height: layout.value['height'] as double,
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
                  ),
                ),
              ],
            )),
      ),
    );
  }

  /// Top control widgets: term, region, load zones
  Widget controlWidgets() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      children: [
        Text(
          'Month',
          style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600),
        ),
        Container(
          width: 150,
          color: Colors.amber.shade50,
          child: Center(
              child: MonthUi(
            model: month,
            setMonth: (Month? value) {
              month.value = value!;
            },
            getMonth: (model) => month.value,
          )),
        ),
        SizedBox(
          width: 12,
        ),

        ///
        /// Region
        ///
        Text(
          'Region',
          style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600),
        ),
        Container(
          width: 100,
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade50,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: DropdownUi(
            model: region,
            setSelection: (value) {
              region.value = value;
            },
            getSelection: (model) => region.value,
            choices: allRegions.toSet(),
            width: 100,
          ),
        ),
        SizedBox(
          width: 12,
        ),

        ///
        /// Capacity Zones
        ///
        Text(
          'Capacity Zone',
          style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600),
        ),
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade50,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: AutocompleteUi(
            model: zoneName,
            setSelection: (value) => zoneName.value = value,
            getSelection: (model) => zoneName.value,
            choices: allZonesIsone.keys.toSet(),
            width: 300,
          ),
        ),
        SizedBox(
          width: 12,
        ),
      ],
    );
  }
}
