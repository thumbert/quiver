library models.common.multiple_selection;

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MultipleSelectionState {
  all('(All)'),
  none('(None)'),
  some('(Some)');

  const MultipleSelectionState(this._value);
  final String _value;

  @override
  String toString() => _value;

  MultipleSelectionState parse(String value) {
    return switch (value) {
      '(All)' => MultipleSelectionState.all,
      '(None)' => MultipleSelectionState.none,
      '(Some)' => MultipleSelectionState.some,
      _ => throw ArgumentError('Invalid SelectionState $value'),
    };
  }
}

class MultipleSelectionModel<K> {
  MultipleSelectionModel({required this.selection, required this.choices});

  late final Set<K> selection;
  final Set<K> choices;

  MultipleSelectionState get selectionState {
    if (selection.isEmpty) return MultipleSelectionState.none;
    if (choices.difference(selection).isNotEmpty) {
      return MultipleSelectionState.some;
    } else {
      return MultipleSelectionState.all;
    }
  }

  MultipleSelectionModel<K> add(K value) {
    return MultipleSelectionModel(
        selection: selection..add(value), choices: choices);
  }

  MultipleSelectionModel<K> remove(K value) {
    selection.remove(value);
    return MultipleSelectionModel(selection: selection, choices: choices);
  }

  MultipleSelectionModel<K> selectAll() {
    return MultipleSelectionModel(selection: {...choices}, choices: choices);
  }

  MultipleSelectionModel<K> selectNone() {
    return MultipleSelectionModel(selection: <K>{}, choices: choices);
  }

  MultipleSelectionModel<K> clone() => MultipleSelectionModel(
      selection: <K>{...selection}, choices: <K>{...choices});

  MultipleSelectionModel<K> copyWith({Set<K>? selection, Set<K>? choices}) {
    return MultipleSelectionModel(
        selection: selection ?? this.selection,
        choices: choices ?? this.choices);
  }
}

class MultipleSelectionNotifier<K>
    extends StateNotifier<MultipleSelectionModel<K>> {
  MultipleSelectionNotifier(this.ref)
      : super(MultipleSelectionModel(selection: <K>{}, choices: <K>{}));
  final Ref ref;
  set add(K value) {
    state = state.add(value);
  }

  void selectAll() {
    state = state.selectAll();
  }

  set remove(K value) {
    state = state.remove(value);
  }

  void selectNone() {
    state = state.selectNone();
  }

  void init(Set<K> selection, Set<K> choices) {
    state = state.copyWith(selection: selection, choices: choices);
  }
}
