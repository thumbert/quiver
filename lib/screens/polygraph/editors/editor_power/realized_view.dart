library screens.polygraph.editors.editor_power.realized_view;

import 'package:date/date.dart';
import 'package:elec/elec.dart';
import 'package:flutter_quiver/screens/polygraph/editors/view_editor.dart';
import 'package:flutter_quiver/screens/common/time_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart';

final providerOfRealizedView =
    StateNotifierProvider<RealizedViewNotifier, RealizedView>(
        (ref) => RealizedViewNotifier(ref));

class RealizedView extends Object with ViewEditor {
  RealizedView(
      {required this.term, required this.timeFilter, this.timeAggregation}) {
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
  TimeFilter timeFilter;

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

  RealizedView copyWith({Term? term, TimeFilter? timeFilter}) {
    return RealizedView(
        term: term ?? this.term, timeFilter: timeFilter ?? this.timeFilter);
  }

  @override
  RealizedView fromJson(Map<String, dynamic> json) {
    return RealizedView(
      term: Term.parse(json['term'], UTC),
      timeFilter: TimeFilter.fromJson(json['filter']),
      timeAggregation: json['aggregate'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': name,
      'term': term.toString(),
      'filter': timeFilter,
      if (timeAggregation != null) 'filter': timeAggregation,
    };
  }
}

class RealizedViewNotifier extends StateNotifier<RealizedView> {
  RealizedViewNotifier(this.ref)
      : super(RealizedView(
            term: Term.parse('Jan22', UTC), timeFilter: TimeFilter()));
  final Ref ref;

  set term(Term value) {
    state = state.copyWith(term: value);
  }

  set timeFilter(TimeFilter value) {
    state = state.copyWith(timeFilter: value);
  }
}
