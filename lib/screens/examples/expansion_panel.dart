import 'package:flutter/material.dart';
import 'package:signals/signals_flutter.dart';

/// NOTES: Use signals 🤷‍♂️
/// The easiest implementation!  Uses a StatelessWidget!
/// You don't need setState(){}!  Need to wrap it in a Watch()!

final cities = <String>{
  'Atlanta',
  'Baltimore',
  'Boston',
  'Chicago',
  'Denver',
  'Houston',
  'Los Angeles',
  'Philadelphia',
  'San Francisco',
  'Washington, DC',
};

class ExpansionPanelExample extends StatefulWidget {
  const ExpansionPanelExample({super.key});
  static const route = '/expansion_panel_example';

  @override
  State<ExpansionPanelExample> createState() => _ExpansionPanelExampleState();
}

class _ExpansionPanelExampleState extends State<ExpansionPanelExample> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    width: 326,
                    decoration: BoxDecoration(
                      color: Colors.amber.shade500,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Watch((_) => ExpansionPanelList(
                          expandedHeaderPadding: EdgeInsets.zero,
                          materialGapSize: 0.0,
                          expansionCallback: (int index, bool isExpanded) {
                            setState(() {
                              expanded = isExpanded;
                            });
                          },
                          children: [
                            ExpansionPanel(
                                backgroundColor: Colors.green.shade50,
                                canTapOnHeader: true,
                                headerBuilder: (_, __) {
                                  return const Center(child: Text('Cities'));
                                },
                                body: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: expanded
                                      ? Column(
                                          children: [
                                            for (var e in cities) Text(e)
                                          ],
                                        )
                                      : const SizedBox.shrink(),
                                ),
                                isExpanded: expanded),
                          ],
                        ))),

                ///
                ///
                ///
                const SizedBox(
                  height: 200,
                ),
                // Watch((context) => Text(
                //     'Currently selected cities: ${model.currentSelection.value.join(', ')}')),
                // Watch((context) => Text(
                //     'Selected cities: ${model.selection.value.join(', ')}')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
