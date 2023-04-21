library screens.polygraph.editors.editor_line_horizontal;

import 'package:flutter/material.dart' hide Interval, Transform;
import 'package:flutter/scheduler.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/polygraph/editors/horizontal_line.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
import 'package:flutter_quiver/models/polygraph/transforms/transform.dart';
import 'package:flutter_quiver/screens/polygraph/editors/editor_time_aggregation.dart';
import 'package:flutter_quiver/screens/polygraph/editors/editor_time_filter.dart';
import 'package:flutter_quiver/screens/polygraph/utils/autocomplete_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final providerOfHorizontalLine =
    StateNotifierProvider<HorizontalLineNotifier, HorizontalLine>(
        (ref) => HorizontalLineNotifier(ref));

class HorizontalLineEditor extends ConsumerStatefulWidget {
  const HorizontalLineEditor({Key? key}) : super(key: key);

  @override
  ConsumerState<HorizontalLineEditor> createState() =>
      _EditorLineHorizontalState();
}

class _EditorLineHorizontalState extends ConsumerState<HorizontalLineEditor> {
  final controllerYValue = TextEditingController();
  final controllerLabel = TextEditingController();

  final focusYValue = FocusNode();
  final focusLabel = FocusNode();

  String? _errorYValue;
  int activeTab = 0;

  @override
  void initState() {
    super.initState();
    controllerYValue.text = '0.0';
    controllerLabel.text = '';

    focusYValue.addListener(() {
      if (!focusYValue.hasFocus) {
        setState(() {
          try {
            var value = num.parse(controllerYValue.text);
            ref.read(providerOfHorizontalLine.notifier).yIntercept = value;
            ref.read(providerOfHorizontalLine.notifier).label = 'h=$value';
          } catch (_) {
            _errorYValue = 'Field needs to be a number';
            ref.read(providerOfHorizontalLine.notifier).yIntercept = 0.0;
          }
        });
      }
    });
    focusLabel.addListener(() {
      if (!focusLabel.hasFocus) {
        setState(() {
            ref.read(providerOfHorizontalLine.notifier).label = controllerLabel.text;
        });
      }
    });
  }

  @override
  void dispose() {
    controllerYValue.dispose();
    controllerLabel.dispose();

    focusYValue.dispose();
    focusLabel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var state = ref.watch(providerOfHorizontalLine);
    controllerYValue.text = state.yIntercept.toString();
    controllerLabel.text = state.label;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ///
            /// Tabs
            ///
            Wrap(
              children: [
                TextButton(
                  style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () {
                      setState(() {
                        activeTab = 0;
                      });
                    },
                    child: Container(
                        width: 140,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 2,
                                color: activeTab == 0
                                    ? Colors.blueGrey[700]!
                                    : Colors.grey[300]!),
                          ),
                        ),
                        child: const Center(child: Text('Main')))),

                ///
                ///
                TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () {
                      setState(() {
                        activeTab = 1;
                      });
                    },
                    child: Container(
                        width: 140,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 2,
                                color: activeTab == 1
                                    ? Colors.blueGrey[700]!
                                    : Colors.grey[300]!),
                          ),
                        ),
                        child: const Center(child: Text('Time Filter')))),

                ///
                ///
                TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () {
                      setState(() {
                        activeTab = 2;
                      });
                    },
                    child: Container(
                        width: 140,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                                width: 2,
                                color: activeTab == 2
                                    ? Colors.blueGrey[700]!
                                    : Colors.grey[300]!),
                          ),
                        ),
                        child: const Center(child: Text('Time Aggregation')))),
              ],
            ),
            const SizedBox(height: 16,),
            if (activeTab == 0) SizedBox(
              height: 240,
              child: Column(children: [
                Row(
                  children: [
                    Container(
                      width: 120,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 8),
                      child: const Text(
                        'Y intercept',
                      ),
                    ),
                    Container(
                      color: MyApp.background,
                      width: 120,
                      child: TextField(
                        controller: controllerYValue,
                        focusNode: focusYValue,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.all(8),
                          enabledBorder: InputBorder.none,
                        ),
                        onEditingComplete: () {
                          setState(() {
                            try {
                              var value = num.parse(controllerYValue.text);
                              ref.read(providerOfHorizontalLine.notifier).yIntercept = value;
                              ref.read(providerOfHorizontalLine.notifier).label = 'h=$value';
                            } catch (_) {
                              _errorYValue = 'Field needs to be a number';
                              ref.read(providerOfHorizontalLine.notifier).yIntercept = 0.0;
                            }
                          });
                        },
                      ),
                    ),
                    Text(
                      _errorYValue ?? '',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
                Row(
                  children: [
                    Container(
                      width: 120,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 8),
                      child: const Text(
                        'Label',
                      ),
                    ),
                    Container(
                      color: MyApp.background,
                      width: 120,
                      child: TextField(
                        controller: controllerLabel,
                        focusNode: focusLabel,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.all(8),
                          enabledBorder: InputBorder.none,
                        ),
                        onEditingComplete: () {
                          setState(() {
                              ref.read(providerOfHorizontalLine.notifier).label = controllerLabel.text;
                          });
                        },
                      ),
                    ),
                    Text(
                      _errorYValue ?? '',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 4,
                ),
              ],),
            ),
            if (activeTab == 1) const SizedBox(
                height: 240,
                child: TimeFilterEditor()),
            if (activeTab == 2) const SizedBox(
              height: 240,
                child: TimeAggregationEditor()),
          ],
        ),
        // ElevatedButton(
        //   onPressed: () {
        //     setState(() {
        //       /// blah
        //     });
        //   },
        //   child: const Text('OK'),
        // ),
      ],
    );
  }
}
