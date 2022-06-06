library models.polygraph.editors.view_model;

import 'package:date/date.dart';
import 'package:flutter_quiver/screens/common/asof_date.dart';
import 'package:flutter_quiver/screens/common/bucket2.dart';
import 'package:flutter_quiver/screens/common/forward_term.dart';
import 'package:flutter_quiver/screens/polygraph/editors/editor_power/editor_power.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart';
import 'package:flutter/material.dart';

final tabProvider =
    StateNotifierProvider<_TabNotifier, int>((ref) => _TabNotifier(0));

final providerOfRealizedView =
    StateNotifierProvider<RealizedViewNotifier, RealizedView>(
        (ref) => RealizedViewNotifier(ref));

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

class RealizedView extends Object with ViewEditor {
  RealizedView({required this.term, this.timeFilter, this.timeAggregation}) {
    name = 'Realized';
  }

  late final Term term;

  ///```
  ///{
  ///  'time': {
  ///    'bucket': '5x16',
  ///   },
  ///}
  ///```
  Map<String, dynamic>? timeFilter;

  /// ```
  /// {
  ///   'time': {
  ///     'frequency': {
  ///        'day',
  ///     },
  ///     'function': 'mean',
  ///   },
  /// }
  /// ```
  Map<String, dynamic>? timeAggregation;

  RealizedView copyWith({Term? term}) {
    return RealizedView(term: term ?? this.term);
  }

  @override
  RealizedView fromJson(Map<String, dynamic> json) {
    return RealizedView(
      term: Term.parse(json['term'], UTC),
      timeFilter: json['filter'],
      timeAggregation: json['aggregate'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': 'Forward, as of',
      'term': term.toString(),
      if (timeFilter != null) 'filter': timeFilter,
      if (timeAggregation != null) 'filter': timeAggregation,
    };
  }
}

class RealizedViewNotifier extends StateNotifier<RealizedView> {
  RealizedViewNotifier(this.ref)
      : super(RealizedView(term: Term.parse('Jan22', UTC)));
  final Ref ref;
  set term(Term value) {
    state = state.copyWith(term: value);
  }
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
                      ref.read(tabProvider.notifier).setValue(0);
                    });
                  },
                  child: Text(
                    'Realized prices',
                    style: TextStyle(
                        fontSize: 16,
                        color: ref.read(tabProvider) == 0
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
                      ref.read(tabProvider.notifier).setValue(1);
                    });
                  },
                  child: Text(
                    'Forward curve, as of',
                    style: TextStyle(
                        fontSize: 16,
                        color: ref.read(tabProvider) == 1
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
                      ref.read(tabProvider.notifier).setValue(2);
                    });
                  },
                  child: Text(
                    'Historical forward strip',
                    style: TextStyle(
                        fontSize: 16,
                        color: ref.read(tabProvider) == 2
                            ? Colors.black
                            : Colors.grey),
                  )),
            ),
          ],
        ),
        if (ref.read(tabProvider) == 1)
          Row(
            children: const [
              SizedBox(width: 120, child: AsOfDateUi()),
              SizedBox(
                width: 24,
              ),
              SizedBox(width: 120, child: ForwardTermUi()),
              SizedBox(
                width: 24,
              ),
              Text(
                'Bucket',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(
                width: 6,
              ),
              BucketUi(),
            ],
          )
      ],
    );
  }
}
