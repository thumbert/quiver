library models.polygraph.editors.view_model;

import 'package:flutter_quiver/screens/common/asof_date.dart';
import 'package:flutter_quiver/screens/common/bucket2.dart';
import 'package:flutter_quiver/screens/common/forward_term.dart';
import 'package:flutter_quiver/screens/common/historical_term.dart';
import 'package:flutter_quiver/screens/common/time_filter.dart';
import 'package:flutter_quiver/screens/polygraph/editors/editor_power/editor_power.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

final providerOfTabIndexView =
    StateNotifierProvider<_TabNotifier, int>((ref) => _TabNotifier(0));

class _TabNotifier extends StateNotifier<int> {
  _TabNotifier(this.index) : super(0);
  late int index;
  void setValue(int value) {
    state = value;
  }
}

abstract class ViewEditor {
  late final String name;
  ViewEditor fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

/// A widget to select between a historical of forward view of the data
class ViewEditorUi extends ConsumerStatefulWidget {
  const ViewEditorUi({Key? key}) : super(key: key);

  @override
  ConsumerState<ViewEditorUi> createState() => _ViewEditorUiState();
}

class _ViewEditorUiState extends ConsumerState<ViewEditorUi> {
  final _background = Colors.orange[100]!;

  @override
  Widget build(BuildContext context) {
    final model = ref.watch(providerOfEditorPower);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 200,
              decoration: BoxDecoration(
                  border: Border(
                bottom: BorderSide(
                    width: 3,
                    color: model.viewEditor.name == 'Realized'
                        ? Colors.blueGrey
                        : Colors.white),
              )),
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      ref.read(providerOfTabIndexView.notifier).setValue(0);
                    });
                  },
                  child: Text(
                    'Realized prices',
                    style: TextStyle(
                        fontSize: 16,
                        color: ref.read(providerOfTabIndexView) == 0
                            ? Colors.black
                            : Colors.grey),
                  )),
            ),
            //
            //
            Container(
              width: 200,
              decoration: BoxDecoration(
                  border: Border(
                bottom: BorderSide(
                    width: 3,
                    color: model.viewEditor.name == 'Forward, as of'
                        ? Colors.blueGrey
                        : Colors.white),
              )),
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      ref.read(providerOfTabIndexView.notifier).setValue(1);
                    });
                  },
                  child: Text(
                    'Forward curve, as of',
                    style: TextStyle(
                        fontSize: 16,
                        color: ref.read(providerOfTabIndexView) == 1
                            ? Colors.black
                            : Colors.grey),
                  )),
            ),
            //
            //
            Container(
              width: 200,
              decoration: BoxDecoration(
                  border: Border(
                bottom: BorderSide(
                    width: 3,
                    color: model.viewEditor.name == 'Forward strip'
                        ? Colors.blueGrey
                        : Colors.white),
              )),
              child: TextButton(
                  onPressed: () {
                    setState(() {
                      ref.read(providerOfTabIndexView.notifier).setValue(2);
                    });
                  },
                  child: Text(
                    'Historical forward strip',
                    style: TextStyle(
                        fontSize: 16,
                        color: ref.read(providerOfTabIndexView) == 2
                            ? Colors.black
                            : Colors.grey),
                  )),
            ),
          ],
        ),
        tabContents(ref.read(providerOfTabIndexView)),
      ],
    );
  }

  Widget tabContents(int index) {
    if (index == 0) {
      /// Realized view
      ///
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 8,
          ),
          const SizedBox(width: 150, child: HistoricalTermUi()),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Time Filter',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.normal),
                  ),
                  Row(
                    children: const [
                      SizedBox(
                        width: 16,
                      ),
                      TimeFilterUi(),
                    ],
                  ),
                ],
              ),
              const SizedBox(
                width: 36,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text(
                    'Aggregation',
                    style: TextStyle(
                        fontSize: 16,
                        color: Colors.blueGrey,
                        fontWeight: FontWeight.normal),
                  ),
                  const Text('Bla-bla'),
                  // Row(
                  //   children: const [
                  //     SizedBox(
                  //       width: 16,
                  //     ),
                  //     TimeFilterUi(),
                  //   ],
                  // ),
                ],
              ),
            ],
          ),
        ],
      );
    } else if (index == 1) {
      /// Forward curve, as of view
      ///
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 8,
          ),
          Row(
            children: [
              const SizedBox(width: 120, child: AsOfDateUi()),
              const SizedBox(
                width: 24,
              ),
              const SizedBox(width: 120, child: ForwardTermUi()),
              const SizedBox(
                width: 24,
              ),
              const Text(
                'Bucket',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(
                width: 6,
              ),
              Container(
                  color: _background, width: 100, child: const BucketUi()),
            ],
          ),
        ],
      );
    } else {
      throw ArgumentError('Tab index $index is not supported');
    }
  }
}
