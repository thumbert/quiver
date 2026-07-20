import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/eod_settlement/eod_settlement_model.dart';
import 'package:flutter_quiver/screens/eod_settlements/endur_section.dart';
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:quiver_core/quiver_core.dart';
import 'package:signals_flutter/signals_flutter.dart';

class EodSettlements extends StatefulWidget {
  const EodSettlements({super.key});
  static const route = '/eod_settlements_ui';
  @override
  State<EodSettlements> createState() => _State();
}

class _State extends State<EodSettlements> {
  late Plotly plotly;
  final scrollControllerV = ScrollController();
  final scrollControllerH = ScrollController();

  @override
  void initState() {
    model; // initialize the model and its effects!
    super.initState();
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
          title: const Text('End of day settlement prices'),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const SimpleDialog(
                        contentPadding: EdgeInsets.all(12),
                        children: [
                          Text('Compare various sources for eod prices.'),
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
                  child: SignalBuilder(
                    builder: (context) => Column(
                      spacing: 6,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// user id + view name row
                        rowUserView(),
                        const EndurSection(),
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

  Widget rowUserView() {
    return Row(
      spacing: 12,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            'User Id',
            style: TextStyle(fontSize: 14, color: Colors.purple),
            textAlign: TextAlign.right,
          ),
        ),
        Container(
          width: 200,
          decoration: BoxDecoration(
            color: Colors.blueGrey.shade50,
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: switch (uniqueUsersViews.value) {
            AsyncData() => AutocompleteUi(
                model: userName,
                setSelection: (value) {
                  userName.value = value;
                },
                clearSelection: () {
                  userName.value = null;
                },
                getSelection: (model) => userName.value,
                choices: cacheUsersViews.map((e) => e.userId).toSet(),
                height: 400,
                width: 200),
            AsyncError(:final error) => Text('Error: $error'),
            AsyncLoading() => const Center(child: CircularProgressIndicator()),
          },
        ),
        SizedBox(
          width: 150,
          child: Text(
            'View name',
            style: TextStyle(fontSize: 14, color: Colors.purple),
            textAlign: TextAlign.right,
          ),
        ),
        GestureDetector(
            onTap: userName.value == null
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Please select a User Id first.'),
                      duration: Duration(seconds: 2),
                    ));
                  }
                : null,
            child: AbsorbPointer(
              absorbing: userName.value == null,
              child: Container(
                width: 300,
                decoration: BoxDecoration(
                  color: userName.value == null
                      ? Colors.grey.shade200
                      : Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: switch (uniqueUsersViews.value) {
                  AsyncData() => AutocompleteUi(
                      key: ValueKey(userName.value),
                      model: viewName,
                      setSelection: (value) => viewName.value = value,
                      getSelection: (model) => viewName.value,
                      clearSelection: () => viewName.value = null,
                      choices: cacheUsersViews
                          .where((e) => e.userId == userName.value)
                          .map((e) => e.viewName)
                          .toSet(),
                      height: 400,
                      width: 300),
                  AsyncError(:final error) => Text('Error: $error'),
                  AsyncLoading() =>
                    const Center(child: CircularProgressIndicator()),
                },
              ),
            )),
      ],
    );
  }
}
