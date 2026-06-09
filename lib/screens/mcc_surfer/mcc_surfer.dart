import 'package:date/date.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_quiver/models/mcc_surfer/mcc_surfer_model.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:quiver_core/quiver_core.dart';
import 'package:signals_flutter/signals_flutter.dart';

class MccSurfer extends StatefulWidget {
  const MccSurfer({super.key});

  static const route = '/mcc_surfer';

  @override
  State<StatefulWidget> createState() => _MccSurferState();
}

class _MccSurferState extends State<MccSurfer> {
  late ScrollController _scrollController;
  late ScrollController _scrollControllerH;
  late Plotly plotly;
  late EffectCleanup _termEffect;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollControllerH = ScrollController();
    var aux = DateTime.now().hashCode;
    plotly = Plotly(
      viewId: 'plotly-mcc-surfer-$aux',
      traces: const [],
      layout: layout,
    );
    _termEffect = effect(() {
      term.value; // subscribe
      cacheTs.clear();
    });

    super.initState();
  }

  @override
  void dispose() {
    _termEffect();
    _scrollController.dispose();
    _scrollControllerH.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MCC surfer'),
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
                                  'Visualize ALL the nodes in the pool at once, '
                                  'select constraints to see when they bind '
                                  '\nto find the nodes that are affected the most.\n'),
                              Text(
                                  'NOTE: For NYISO, the values shown are (-1)*congestion component!\n'),
                              Text(
                                  'Because a lot of the nodes have the same prices '
                                  'for the term, a simple reduction algorithm is applied '
                                  'to reduce the numbers of curves displayed.  This keeps '
                                  'the UI responsive without taking any of the visual information '
                                  'away.  By default, at most 100 curves are displayed. '
                                  'The accuracy of the reduction algorithm is quantified '
                                  'by its resolution, measured in \$.  The resolution '
                                  'is a threshold value such that curves closer to one '
                                  'another below this threshold are not displayed.  '
                                  'Therefore, a resolution of \$0 displays all the curves, '
                                  'and a lower resolution means better curve details '
                                  'are visible.\n'),
                              Text('By using the zone filter, you reduce '
                                  'the universe of curves to display and the '
                                  'reduction algorithm '
                                  'is applied to the curves from this zone only.')
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
                      children: [
                        Watch((context) {
                          switch (traces.value) {
                            // ignore: unused_local_variable
                            case AsyncData data:
                              plotly.react(
                                  traces.requireValue, layout, plotly.config);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children: [
                                    SizedBox(
                                        width: 900, height: 600, child: plotly),
                                  ]),
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

                        // SizedBox(
                        //     width: 900, height: 700, child: CongestionChart()),
                        // ConstraintTable(),
                      ],
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }

  ///
  Widget controlWidgets() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      children: [
        Text(
          'Term',
          style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600),
        ),
        Container(
          width: 150,
          color: Colors.amber.shade50,
          child: Center(
              child: TermUi(
            model: term,
            setTerm: (Term? value) {
              term.value = value!;
            },
            getTerm: (model) => term.value,
          )),
        ),
        const SizedBox(
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
        const SizedBox(
          width: 12,
        ),

        ///
        /// Load Zone
        ///
        Text(
          'Load Zone',
          style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600),
        ),
        Container(
          width: 140,
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade50,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: MultiSelectAutocompleteUi(
            model: zones,
            setSelection: (value) => zones.value = [...value],
            getSelection: (model) => zones.value,
            choices: getAllZoneNames().toSet(),
            hintTextBuilder: () {
              final count = zones.value.length;
              if (count == 0) return '(None)';
              if (count == getAllZoneNames().length) return '(All)';
              return '$count zone${count == 1 ? '' : 's'} selected';
            },
            width: 140,
          ),
        ),
      ],
    );
  }
}
