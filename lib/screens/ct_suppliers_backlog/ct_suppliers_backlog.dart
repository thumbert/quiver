library screens.unmasked_energy_offers.unmasked_energy_offers;

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:elec_server/client/utilities/ct_supplier_backlog_rates.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/ct_suppliers_backlog/ct_suppliers_backlog_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:intl/intl.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:url_launcher/url_launcher.dart';

class CtSuppliersBacklog extends ConsumerStatefulWidget {
  const CtSuppliersBacklog({Key? key}) : super(key: key);

  static const route = '/ct_suppliers_backlog';

  @override
  ConsumerState<CtSuppliersBacklog> createState() =>
      _UnmaskedEnergyOffersState();
}

class _UnmaskedEnergyOffersState extends ConsumerState<CtSuppliersBacklog> {
  var fmt = NumberFormat.currency(decimalDigits: 0, symbol: '\$');
  late Plotly plotly;

  final controllerTerm = TextEditingController();
  final controllerSupplierName = TextEditingController();

  final focusNodeTerm = FocusNode();
  String? _errorTerm;
  final scrollControllerV = ScrollController();
  final scrollControllerH = ScrollController();

  @override
  void initState() {
    super.initState();
    final model = ref.read(providerOfCtSuppliersBacklogModel);
    controllerTerm.text = model.term.toString();
    controllerSupplierName.text = model.getSupplierDropdownLabel();

    focusNodeTerm.addListener(() {
      if (!focusNodeTerm.hasFocus) {
        /// validate when you lose focus (Tab out of the field)
        setState(() {
          try {
            var term = Term.parse(controllerTerm.text, IsoNewEngland.location);
            ref.read(providerOfCtSuppliersBacklogModel.notifier).term = term;
            _errorTerm = null; // all good
          } catch (e) {
            _errorTerm = 'Parsing error';
          }
        });
      }
    });

    setState(() {
      var aux = DateTime.now().hashCode;
      plotly = Plotly(
        viewId: 'plotly-ct-supplier-backlog-$aux',
        data: const [],
        layout: model.getLayout(),
      );
    });
  }

  @override
  void dispose() {
    scrollControllerV.dispose();
    scrollControllerH.dispose();
    controllerTerm.dispose();
    controllerSupplierName.dispose();
    focusNodeTerm.dispose();
    super.dispose();
  }

  List<PopupMenuItem<String>> makeSupplierList() {
    var model = ref.watch(providerOfCtSuppliersBacklogModel);
    var out = <PopupMenuItem<String>>[];
    if (model.selectedSuppliers.contains('(All)')) {
      setState(() {
        ref.read(providerOfCtSuppliersBacklogModel.notifier).addSupplier =
            '(All)';
      });
    }
    for (final value in model.getAllSupplierNames()) {
      out.add(PopupMenuItem<String>(
        padding: EdgeInsets.zero,
        value: value,
        child: Consumer(
          builder: (context, ref, child) {
            var model = ref.watch(providerOfCtSuppliersBacklogModel);
            return PointerInterceptor(
              child: CheckboxListTile(
                value: model.selectedSuppliers.contains(value),
                controlAffinity: ListTileControlAffinity.leading,
                title: Text(
                  value,
                  style: const TextStyle(fontSize: 12),
                ),
                onChanged: (bool? checked) {
                  setState(() {
                    if (checked!) {
                      ref
                          .read(providerOfCtSuppliersBacklogModel.notifier)
                          .addSupplier = value;
                    } else {
                      ref
                          .read(providerOfCtSuppliersBacklogModel.notifier)
                          .removeSupplier = value;
                    }
                  });
                },
              ),
            );
          },
        ),
      ));
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(providerOfCtSuppliersBacklogModel);
    final asyncData = ref.watch(providerOfCtSuppliersBacklogData(model.term));

    return Scaffold(
      appBar: AppBar(
        title: const Text('CT suppliers backlog'),
        actions: [
          IconButton(
            onPressed: () {
              const _url = 'https://energizect.com/rate-board-residential-standard-service-generation-rates';
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return SimpleDialog(
                      children: [
                        PointerInterceptor(
                          child: RichText(
                              text: TextSpan(
                            children: [
                              const TextSpan(
                                  text:
                                      'Historical data on retail competitive suppliers in CT '
                                      'from Jan22 forward. \n\n'
                                      'Data is published on '),
                              TextSpan(text: _url,
                                style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                              recognizer: TapGestureRecognizer()..onTap = () async {
                                final url = Uri.parse(_url);
                                if (!await launchUrl(url)) {
                                  throw 'Could not launch $url';
                                }
                              }),
                              const TextSpan(text: '\nwith a 4 months lag.')
                            ],
                          )),
                        ),
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
        padding: const EdgeInsets.only(left: 12.0, top: 0.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          controller: scrollControllerV,
          child:
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// Term
                      SizedBox(
                          width: 120,
                          child: TextFormField(
                            focusNode: focusNodeTerm,
                            decoration: InputDecoration(
                              labelText: 'Term',
                              labelStyle: TextStyle(
                                  color: Theme.of(context).primaryColor),
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
                                  var term = Term.parse(controllerTerm.text,
                                      IsoNewEngland.location);
                                  ref
                                      .read(providerOfCtSuppliersBacklogModel
                                          .notifier)
                                      .term = term;
                                  _errorTerm = null; // all good
                                } catch (e) {
                                  _errorTerm = 'Parsing error';
                                }
                              });
                            },
                          )),
                      const SizedBox(
                        width: 12,
                      ),

                      /// Utility
                      Row(
                        children: [
                          Container(
                              width: 140,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 12),
                              child: const Text('Utility')),
                          Container(
                            color: MyApp.background,
                            width: 120,
                            child: DropdownButtonFormField<Utility>(
                              value: model.utility,
                              style: const TextStyle(
                                  fontSize: 14, fontFamily: 'Ubuntu'),
                              icon: const Icon(Icons.expand_more),
                              hint: const Text('Filter'),
                              decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 12, right: 2, top: 8, bottom: 8),
                                  enabledBorder: InputBorder.none),
                              elevation: 16,
                              onChanged: (Utility? newValue) {
                                ref
                                    .read(providerOfCtSuppliersBacklogModel
                                        .notifier)
                                    .utility = newValue!;
                              },
                              items: Utility.values
                                  .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e.toString(),
                                      )))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 12,
                      ),

                      /// Customer class
                      Row(
                        children: [
                          Container(
                              width: 140,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 12),
                              child: const Text('Customer Class')),
                          Container(
                            color: MyApp.background,
                            width: 200,
                            child: DropdownButtonFormField<String>(
                              value: model.customerClass,
                              style: const TextStyle(
                                  fontSize: 14, fontFamily: 'Ubuntu'),
                              icon: const Icon(Icons.expand_more),
                              hint: const Text('Filter'),
                              decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 12, right: 2, top: 8, bottom: 8),
                                  enabledBorder: InputBorder.none),
                              elevation: 16,
                              onChanged: (String? newValue) {
                                ref
                                    .read(providerOfCtSuppliersBacklogModel
                                        .notifier)
                                    .customerClass = newValue!;
                              },
                              items: model
                                  .getCustomerClasses()
                                  .map((e) =>
                                      DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),

                      /// Variable
                      Row(
                        children: [
                          Container(
                              width: 140,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 12),
                              child: const Text('Variable')),
                          Container(
                            color: MyApp.background,
                            width: 360,
                            child: DropdownButtonFormField<String>(
                              value: model.variableName,
                              style: const TextStyle(
                                  fontSize: 14, fontFamily: 'Ubuntu'),
                              icon: const Icon(Icons.expand_more),
                              hint: const Text('Filter'),
                              decoration: const InputDecoration(
                                  isDense: true,
                                  contentPadding: EdgeInsets.only(
                                      left: 12, right: 2, top: 8, bottom: 8),
                                  enabledBorder: InputBorder.none),
                              elevation: 16,
                              onChanged: (String? newValue) {
                                ref
                                    .read(providerOfCtSuppliersBacklogModel
                                        .notifier)
                                    .variableName = newValue!;
                              },
                              items: model.variableNames.keys
                                  .map((e) =>
                                      DropdownMenuItem(value: e, child: Text(e)))
                                  .toList(),
                            ),
                          ),
                          const SizedBox(
                            width: 12,
                          ),
                          SizedBox(
                            width: 180,
                            child: Tooltip(
                              message: 'Aggregate all selected suppliers',
                              child: CheckboxListTile(
                                  visualDensity: VisualDensity.compact,
                                  dense: true,
                                  value: model.aggregate,
                                  controlAffinity: ListTileControlAffinity.leading,
                                  title: const Text('Aggregate?'),
                                  onChanged: (bool? checked) {
                                    setState(() {
                                      ref
                                          .read(providerOfCtSuppliersBacklogModel
                                              .notifier)
                                          .aggregate = checked!;
                                    });
                                  }),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),

                      /// Supplier
                      Row(
                        children: [
                          Container(
                              width: 140,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 12),
                              child: const Text('Supplier')),
                          Container(
                            width: 250,
                            color: MyApp.background,
                            child: PopupMenuButton<String>(
                              constraints: const BoxConstraints(maxHeight: 600),
                              position: PopupMenuPosition.under,
                              child: asyncData.when(
                                  data: (cities) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                          left: 10.0, top: 6.0, bottom: 6.0),
                                      child: Text(model.getSupplierDropdownLabel()),
                                    );
                                  },
                                  error: (err, stack) =>
                                      Text('Oops. ${err.toString()}'),
                                  loading: () => const Row(
                                        children: [
                                          CircularProgressIndicator(),
                                          Text('    Fetching ...'),
                                        ],
                                      )),
                              itemBuilder: (context) => makeSupplierList(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
            ),
            const SizedBox(
                height: 12,
            ),

            FutureBuilder(
                  future: model.makeTraces(),
                  builder: (context, snapshot) {
                    List<Widget> children;
                    if (snapshot.hasData) {
                      var traces = snapshot.data!;
                      var layout = model.getLayout();
                      plotly.plot.react(traces, layout, displaylogo: false);
                      children = [
                        SizedBox(width: 1200, height: 700, child: plotly),
                      ];
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
            const SizedBox(
                width: 1500,
            ),
          ]),
              ),
        ),
      ),
    );
  }
}
