import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/masked_demand_bids/masked_demand_bids.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:quiver_core/quiver_core.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:timeseries/timeseries.dart';

class MaskedDemandBidsUi extends StatefulWidget {
  const MaskedDemandBidsUi({super.key});
  static const route = '/masked_demand_bids_ui';
  @override
  State<MaskedDemandBidsUi> createState() => _State();
}

class _State extends State<MaskedDemandBidsUi> {
  late Plotly plotly;
  final scrollControllerV = ScrollController();
  final scrollControllerH = ScrollController();

  @override
  void initState() {
    super.initState();

    var aux = DateTime.now().hashCode;
    plotly = Plotly(
      viewId: 'plotly-masked-demand-bids-$aux',
      traces: const [],
      layout: layout,
    );
  }

  @override
  void dispose() {
    scrollControllerV.dispose();
    scrollControllerH.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Masked Demand Bids'),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const SimpleDialog(
                        contentPadding: EdgeInsets.all(12),
                        children: [
                          Text(
                              'Investigate the masked demand bids data from ISONE.'
                              'Data is aggregated daily.\n\n'),
                        ],
                      );
                    });
              },
              icon: const Icon(Icons.info_outline),
              tooltip: 'Info',
            )
          ],
        ),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: scrollControllerV,
          child: SizedBox(
            width: 3000.0,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                  padding: const EdgeInsets.only(top: 12.0, left: 12.0),
                  child: Watch(
                    (context) => Column(
                      spacing: 6,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// historical term
                        Row(
                          spacing: 12,
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text(
                                'Historical Term',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.purple),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Container(
                              width: 150,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade50,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: TermUi(
                                model: term,
                                setTerm: (value) {
                                  term.value = value!;
                                  cache.clear();
                                },
                                getTerm: (model) => model,
                              ),
                            ),
                          ],
                        ),

                        /// participant row
                        Row(
                          spacing: 12,
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text(
                                'Participant',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.purple),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Container(
                              width: 400,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade50,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: switch (allParticipants.value) {
                                AsyncData() => AutocompleteUi(
                                    model: participant,
                                    setSelection: (value) =>
                                        participant.value = value,
                                    getSelection: (model) => participant.value,
                                    clearSelection: () =>
                                        participant.value = '(All)',
                                    choices: allParticipants.value.value ?? {},
                                    width: 400,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                AsyncError() => Text(
                                    'Error loading participants',
                                  ),
                                AsyncLoading() => Center(
                                    child: CircularProgressIndicator(),
                                  ),
                              },
                            ),
                          ],
                        ),

                        /// zone row
                        Row(
                          spacing: 12,
                          children: [
                            SizedBox(
                              width: 110,
                              child: Text(
                                'Load Zone',
                                style: TextStyle(
                                    fontSize: 14, color: Colors.purple),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Container(
                              width: 100,
                              decoration: BoxDecoration(
                                color: Colors.blueGrey.shade50,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: DropdownUi(
                                model: zoneName,
                                setSelection: (value) => zoneName.value = value,
                                getSelection: (model) => zoneName.value,
                                choices: allZones.keys.toSet(),
                                width: 100,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                            // add checkbox to split by zone, only if participant is not '(All)'
                            Tooltip(
                              message:
                                  'Split by load zone (only available when a specific participant is selected)',
                              child: Checkbox(
                                value: participant.value == '(All)'
                                    ? false
                                    : byZone.value,
                                onChanged: participant.value == '(All)'
                                    ? null
                                    : (value) => byZone.value = value!,
                              ),
                            ),
                          ],
                        ),

                        /// plot
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 12,
                            ),
                            Watch((context) {
                              switch (data.value) {
                                // ignore: unused_local_variable
                                case AsyncData():
                                  return updatePlot(data.value.value!);
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircularProgressIndicator(),
                                          Text('    Loading ...'),
                                        ]),
                                  );
                              }
                            }),
                          ],
                        ),

                        const SizedBox(
                          height: 24,
                        ),
                      ],
                    ),
                  )),
            ),
          ),
        ));
  }

  Widget updatePlot(
      Map<({int maskedParticipantId, String zoneName}), TimeSeries<num>> ts) {
    var traces = switch (participant.value) {
      '(All)' => makeTracesByParticipant(ts),
      _ => makeTracesByZone(ts),
    };
    plotly.react(traces, layout, plotly.config);
    return Column(
      spacing: 6,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const SizedBox(height: 16),
        Text(
            'There are ${ts.length} total participants.  Showing data for the top 30 participants by volume.'),
        if (traces.isNotEmpty)
          SizedBox(width: 1000, height: 600, child: plotly),
        const SizedBox(height: 16),
      ],
    );
  }
}
