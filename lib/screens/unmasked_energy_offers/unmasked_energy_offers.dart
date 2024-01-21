library screens.unmasked_energy_offers.unmasked_energy_offers;

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/unmasked_energy_offers/unmasked_energy_offers_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:intl/intl.dart';

class UnmaskedEnergyOffers extends ConsumerStatefulWidget {
  const UnmaskedEnergyOffers({super.key});

  static const route = '/unmasked_energy_offers';

  @override
  ConsumerState<UnmaskedEnergyOffers> createState() =>
      _UnmaskedEnergyOffersState();
}

class _UnmaskedEnergyOffersState extends ConsumerState<UnmaskedEnergyOffers> {
  var fmt = NumberFormat.currency(decimalDigits: 0, symbol: '\$');
  late ScrollController _scrollController;
  late Plotly plotly;

  final controllerTerm = TextEditingController();
  final controllerAssets = <TextEditingController>[
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];
  final focusNodeTerm = FocusNode();
  String? _errorTerm;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    final model = ref.read(providerOfUnmaskedEnergyOffersModel);
    controllerTerm.text = model.term.toString();
    for (var i = 0; i < model.selectedAssets.length; i++) {
      if (model.selectedAssets[i] != null) {
        controllerAssets[i].text = model.selectedAssets[i]!;
      }
    }

    focusNodeTerm.addListener(() {
      if (!focusNodeTerm.hasFocus) {
        /// validate when you lose focus (Tab out of the field)
        setState(() {
          try {
            var term = Term.parse(controllerTerm.text, IsoNewEngland.location);
            ref.read(providerOfUnmaskedEnergyOffersModel.notifier).term = term;
            _errorTerm = null; // all good
          } catch (e) {
            _errorTerm = 'Parsing error';
          }
        });
      }
    });

    setState(() {
      UnmaskedEnergyOffersModel.cache.clear();
      var aux = DateTime.now().hashCode;
      plotly = Plotly(
        viewId: 'plotly-unmasked-energy-offers-$aux',
        data: const [],
        layout: model.layout,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    controllerTerm.dispose();
    focusNodeTerm.dispose();
    for (var i = 0; i < controllerAssets.length; i++) {
      controllerAssets[i].dispose();
    }
    super.dispose();
  }

  List<Widget> getSearchMenus() {
    final model = ref.read(providerOfUnmaskedEnergyOffersModel);
    var out = <Widget>[];
    for (var i = 0; i < controllerAssets.length; i++) {
      out.add(
        DropdownMenu<Map<String, dynamic>>(
          width: 300.0,
          menuHeight: 600.0,
          trailingIcon: const Icon(Icons.keyboard_arrow_down),
          controller: controllerAssets[i],
          enableFilter: true,
          leadingIcon: const Icon(Icons.search),
          label: const Text('Name'),
          dropdownMenuEntries: [
            for (var asset in UnmaskedEnergyOffersModel.assetData)
              DropdownMenuEntry(
                  value: asset,
                  label: asset['name'],
                  style: const ButtonStyle(
                      padding:
                          MaterialStatePropertyAll(EdgeInsets.only(left: 8)),
                      visualDensity: VisualDensity.compact))
          ],
          inputDecorationTheme: InputDecorationTheme(
            isDense: true,
            isCollapsed: true,
            filled: true,
            fillColor: Colors.blueGrey.shade50,
            contentPadding: const EdgeInsets.symmetric(vertical: 4.0),
            border: const OutlineInputBorder(borderSide: BorderSide.none),
            enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
          ),
          onSelected: (Map<String, dynamic>? asset) {
            setState(() {
              var sAssets = [...model.selectedAssets];
              sAssets[i] = controllerAssets[i].text;
              ref
                  .read(providerOfUnmaskedEnergyOffersModel.notifier)
                  .selectedAssets = sAssets;
            });
          },
        ),
      );
      out.add(const SizedBox(
        height: 24,
      ));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(providerOfUnmaskedEnergyOffersModel);
    ref.watch(providerOfUnmaskedAssets(model.iso));

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
                      contentPadding: EdgeInsets.all(12),
                      children: [
                        Text('Historical energy offers for all assets in '
                            'ISONE and NYISO.  Unmasking has been done in a different '
                            'process.'
                            '\n\nClick on an asset name to select it '
                            'and see it\'s energy offers.'
                            '\n\nBest to select the term one month at a time.'
                            '\n\nData is provided on a 4 month lag.'),
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
        padding: const EdgeInsets.only(left: 12.0, top: 0.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    color: MyApp.background,
                    width: 100,
                    child: DropdownButtonFormField<Iso>(
                      value: model.iso,
                      icon: const Icon(Icons.expand_more),
                      hint: const Text('Filter'),
                      decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.only(
                              left: 12, right: 2, top: 8, bottom: 8),
                          enabledBorder: InputBorder.none),
                      elevation: 16,
                      onChanged: (Iso? newValue) {
                        ref
                            .read(providerOfUnmaskedEnergyOffersModel.notifier)
                            .iso = newValue!;
                      },
                      items: UnmaskedEnergyOffersModel.defaultAssets.keys
                          .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e.name)))
                          .toList(),
                    ),
                  ),
                  const SizedBox(
                    width: 36,
                  ),
                  SizedBox(
                      width: 120,
                      child: TextFormField(
                        focusNode: focusNodeTerm,
                        decoration: InputDecoration(
                          labelText: 'Term',
                          labelStyle:
                              TextStyle(color: Theme.of(context).primaryColor),
                          helperText: '',
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).primaryColor),
                          ),
                          errorText: _errorTerm,
                        ),
                        controller: controllerTerm,

                        /// validate when Enter is pressed
                        onEditingComplete: () {
                          setState(() {
                            try {
                              var term = Term.parse(
                                  controllerTerm.text, IsoNewEngland.location);
                              ref
                                  .read(providerOfUnmaskedEnergyOffersModel
                                      .notifier)
                                  .term = term;
                              _errorTerm = null; // all good
                            } catch (e) {
                              _errorTerm = 'Parsing error';
                              print(e);
                            }
                          });
                        },
                      )),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...getSearchMenus(),
                        const Text(
                          'To remove a unit, clear the field and press Enter',
                          style: TextStyle(
                              fontStyle: FontStyle.italic, fontSize: 10),
                        )
                      ],
                    ),
                    const SizedBox(width: 15),
                    FutureBuilder(
                        future: model.makeTraces(),
                        builder: (context, snapshot) {
                          List<Widget> children;
                          if (snapshot.hasData) {
                            var traces = snapshot.data!;
                            var layout = model.layout;
                            if (traces.length == 1) {
                              layout['title'] =
                                  'MW weighted Energy Offer price';
                            }
                            plotly.plot
                                .react(traces, layout, displaylogo: false);
                            children = [
                              SizedBox(width: 900, height: 600, child: plotly),
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
