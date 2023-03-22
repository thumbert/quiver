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

final providerOfPolygraphTab =
    StateNotifierProvider<PolygraphTabNotifier, PolygraphTab>(
        (ref) => PolygraphTabNotifier(ref));

class WindowLayout {
  WindowLayout({required this.rows, required this.cols});
  final int rows;
  final int cols;
}

class PolygraphTab {

  /// A workbook can have several tabs.  A tab can have several windows.
  PolygraphTab({
    required this.tab,
    required this.name,
    required this.windowLayout,
    required this.windows,
  });

  final int tab;
  final String name;
  final WindowLayout windowLayout;
  final List<PolygraphWindow> windows;

  PolygraphTab fromMongo(Map<String, dynamic> x) {
    /// TODO: implement serialization
    return PolygraphTab.getDefault();
  }

  /// What gets serialized to Mongo
  Map<String, dynamic> toMongo() {
    return {
      'tab': tab,
      'name': name,
      'grid': {
        'rows': windowLayout.rows,
        'cols': windowLayout.cols,
      },
      'windows': [for (var window in windows) window.toMongo()],
    };
  }

  static PolygraphTab getDefault() {
    return PolygraphTab(
      tab: 0,
      name: 'Tab 1',
      windowLayout: WindowLayout(rows: 1, cols: 1),
      windows: [PolygraphWindow.getDefault()],
    );
  }

  PolygraphTab copyWith({
    int? tab,
    String? name,
    WindowLayout? windowLayout,
    List<PolygraphWindow>? windows,
  }) {
    return PolygraphTab(
      tab: tab ?? this.tab,
      name: name ?? this.name,
      windowLayout: windowLayout ?? this.windowLayout,
      windows: windows ?? this.windows,
    );
  }
}

class PolygraphTabNotifier extends StateNotifier<PolygraphTab> {
  PolygraphTabNotifier(this.ref) : super(PolygraphTab.getDefault());

  final Ref ref;

  set name(String value) {
    state = state.copyWith(name: value);
  }

}
