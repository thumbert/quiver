library models.polygraph.polygraph_tab;

import 'package:date/date.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_window.dart';
import 'package:flutter_quiver/models/polygraph/transforms/time_aggregation.dart';
import 'package:flutter_quiver/models/polygraph/variables/realized_electricity_variable.dart'
    as rev;
import 'package:flutter_quiver/models/polygraph/variables/forward_electricity_variable.dart'
    as fev;
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeseries/timeseries.dart';
import 'package:timezone/timezone.dart';


class WindowLayout {
  /// The window layout for this tab, number of rows and columns.
  /// maybe even custom size at some time ...
  WindowLayout({required this.rows, required this.cols});
  final int rows;
  final int cols;

  static WindowLayout getDefault() => WindowLayout(rows: 1, cols: 1);
}

class PolygraphTab {
  /// A workbook can have several tabs.  A tab can have several windows.
  PolygraphTab({
    required this.name,
    required this.windowLayout,
    required this.windows,
    required this.activeWindowIndex,
  });

  // final int tab;
  final String name;
  final WindowLayout windowLayout;
  final List<PolygraphWindow> windows;
  final int activeWindowIndex;

  PolygraphTab fromMap(Map<String, dynamic> x) {
    /// TODO: implement serialization
    return PolygraphTab.getDefault();
  }

  /// What gets serialized to Mongo
  Map<String, dynamic> toMap() {
    return {
      // 'tab': tab,
      'name': name,
      'grid': {
        'rows': windowLayout.rows,
        'cols': windowLayout.cols,
      },
      'windows': [for (var window in windows) window.toMap()],
    };
  }

  static PolygraphTab empty({required String name}) {
    return PolygraphTab(
      name: name,
      windowLayout: WindowLayout(rows: 1, cols: 1),
      windows: [PolygraphWindow.empty()],
      activeWindowIndex: 1,
    );
  }

  static PolygraphTab getDefault() {
    return PolygraphTab(
      name: 'Tab 1',
      windowLayout: WindowLayout(rows: 1, cols: 1),
      windows: [
        // PolygraphWindow.getDefault(),
        PolygraphWindow.getLmpWindow(),
      ],
      activeWindowIndex: 0,
    );
  }



  PolygraphTab copyWith({
    int? tab,
    String? name,
    WindowLayout? windowLayout,
    List<PolygraphWindow>? windows,
    int? activeWindowIndex,
  }) {
    return PolygraphTab(
      name: name ?? this.name,
      windowLayout: windowLayout ?? this.windowLayout,
      windows: windows ?? this.windows,
      activeWindowIndex: activeWindowIndex ?? this.activeWindowIndex,
    );
  }
}

class PolygraphTabNotifier extends StateNotifier<PolygraphTab> {
  PolygraphTabNotifier(this.ref) : super(PolygraphTab.getDefault());

  final Ref ref;

  set name(String value) {
    state = state.copyWith(name: value);
  }

  set windowLayout(WindowLayout value) {
    state = state.copyWith(windowLayout: value);
  }

  set windows(List<PolygraphWindow> values) {
    state = state.copyWith(windows: values);
  }

  set activeWindowIndex(int value) {
    state = state.copyWith(activeWindowIndex: value);
  }
}
