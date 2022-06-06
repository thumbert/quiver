library screens.polygraph.polygraph_ui;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/providers/term_provider.dart';
import 'package:flutter_quiver/screens/common/term2.dart';
import 'package:flutter_quiver/screens/polygraph/editors/editor_power/editor_power.dart';
import 'package:flutter_quiver/screens/polygraph/editors/power_location.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PolygraphUi extends ConsumerStatefulWidget {
  const PolygraphUi({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PolygraphUiState();
}

class _PolygraphUiState extends ConsumerState<PolygraphUi> {
  @override
  Widget build(BuildContext context) {
    final term = ref.watch(providerOfTerm);
    final deliveryPoint = ref.watch(providerOfPowerLocation);
    final editorPower = ref.watch(providerOfEditorPower);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Polygraph'),
        actions: [
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const SimpleDialog(
                      contentPadding: EdgeInsets.all(12),
                      children: [
                        Text('Historical energy offers for all assets in '),
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
          padding: const EdgeInsets.only(left: 24.0, top: 8.0),
          child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        SizedBox(width: 120, child: TermUi2()),
                        SizedBox(
                          width: 36,
                        ),
                      ],
                    ),
                    const EditorPowerUi(),
                    const SizedBox(
                      height: 64,
                    ),
                    Text('Term is: ${term.toString()}'),
                    Text('Selected region: ${deliveryPoint.region}'),
                    Text(
                        'Selected deliveryPoint: ${deliveryPoint.deliveryPoint}'),
                    Text('Selected market: ${deliveryPoint.market}'),
                    Text('Selected component: ${deliveryPoint.component}'),
                    Text('Selected tab: ${editorPower.viewEditor.name}'),
                  ]))),
    );
  }
}
