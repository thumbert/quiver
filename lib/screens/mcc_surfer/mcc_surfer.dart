import 'package:date/date.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_quiver/models/mcc_surfer/mcc_surfer_model.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:quiver_core/quiver_core.dart';
import 'package:signals_flutter/signals_flutter.dart';

import 'constraint_table.dart';

class MccSurfer extends StatefulWidget {
  const MccSurfer({super.key});

  static const route = '/mcc_surfer';

  @override
  State<StatefulWidget> createState() => _MccSurferState();
}

class _MccSurferState extends State<MccSurfer> {
  late ScrollController _scrollController;
  late ScrollController _scrollControllerH;
  late Plotly plotlyMcc;
  late Plotly plotlyConstraint;
  late EffectCleanup _clearCacheEffect;
  late EffectCleanup _onRegionChangeEffect;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollControllerH = ScrollController();
    var aux = DateTime.now().hashCode;
    plotlyMcc = Plotly(
      viewId: 'plotly-mcc-surfer-$aux',
      traces: const [],
      layout: layoutMcc.value,
    );
    plotlyConstraint = Plotly(
      viewId: 'plotly-constraint-$aux',
      traces: const [],
      layout: layoutConstraint,
    );
    _clearCacheEffect = effect(() {
      term.value; // subscribe
      cacheTraces.clear();
    });
    _onRegionChangeEffect = effect(() {
      region.value; // subscribe
      if (region.value == 'NYISO') {
        focusNodeMcc.value = null;
        focusNodeConstraint.value = 'NINE_MILE_1, ptid: 23575';
        focusConstraint.value = 'SCRIBA   345 VOLNEY   345 1';
      } else if (region.value == 'ISONE') {
        focusNodeMcc.value = null;
        focusNodeConstraint.value = '.Z.MAINE, ptid: 4001';
        focusConstraint.value = 'MENH';
      }
      cacheTraces.clear();
      zones.value = getAllZoneNames();
    });

    super.initState();
  }

  @override
  void dispose() {
    _clearCacheEffect();
    _onRegionChangeEffect();
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
                  width: 3600,
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
                          switch (traces.value) {
                            // ignore: unused_local_variable
                            case AsyncData data:
                              plotlyMcc.react(traces.requireValue,
                                  layoutMcc.value, plotlyMcc.config);
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                      width: layoutMcc.value['width'],
                                      height: layoutMcc.value['height'],
                                      child: plotlyMcc),
                                  Text(
                                      'Curve resolution: \$${resolution.value}.  Curves displayed: ${displayedCurvesCount.value} out of ${filteredTracesCount.value}.'),
                                  SizedBox(height: 12),
                                  ...nodeMccVsConstraintCost(),
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
                                width: layoutMcc.value['width'],
                                height: layoutMcc.value['height'],
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(),
                                      Text('    Loading ...'),
                                    ]),
                              );
                          }
                        }),
                        ConstraintTable(),
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
        /// Load Zones
        ///
        Text(
          'Load Zone',
          style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600),
        ),
        SignalBuilder(
            builder: (context) => Container(
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
                )),
        SizedBox(
          width: 12,
        ),

        ///
        /// Focus node
        ///
        Text(
          'Focus Node',
          style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600),
        ),
        SignalBuilder(builder: (context) {
          return Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: AutocompleteUi(
              model: focusNodeMcc,
              setSelection: (value) => focusNodeMcc.value = value,
              getSelection: (model) => focusNodeMcc.value,
              clearSelection: () => focusNodeMcc.value = null,
              choices: nodeNameChoices.value,
              width: 350,
            ),
          );
        }),
      ],
    );
  }

  /// Node MCC price vs. Constraint cost controls + plot
  List<Widget> nodeMccVsConstraintCost() {
    var tracesConstraint = makeTracesConstraintCost();
    plotlyConstraint.react(
        tracesConstraint, layoutConstraint, plotlyConstraint.config);
    return [
      Row(spacing: 12, children: [
        Text(
          'Focus Node',
          style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600),
        ),
        SignalBuilder(builder: (context) {
          return Container(
            width: 350,
            decoration: BoxDecoration(
              color: Colors.blueGrey.shade50,
              borderRadius: BorderRadius.circular(4.0),
            ),
            child: AutocompleteUi(
              model: focusNodeConstraint,
              setSelection: (value) => focusNodeConstraint.value = value,
              getSelection: (model) => focusNodeConstraint.value,
              clearSelection: () => focusNodeConstraint.value = null,
              choices: nodeNameChoices.value,
              width: 350,
            ),
          );
        }),
        //
        Text(
          'Constraint',
          style: TextStyle(fontSize: 14, color: Colors.blueGrey.shade600),
        ),
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade50,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: AutocompleteUi(
            model: focusConstraint,
            setSelection: (value) => focusConstraint.value = value,
            getSelection: (model) => focusConstraint.value,
            clearSelection: () => focusConstraint.value = null,
            choices: cacheConstraintsNy.map((e) => e.limitingFacility).toSet(),
            width: 300,
          ),
        ),
      ]),
      SizedBox(height: 12),
      SizedBox(
        width: layoutConstraint['width'],
        height: layoutConstraint['height'],
        child: plotlyConstraint,
      ),
    ];
  }
}
