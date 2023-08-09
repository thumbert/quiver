library models.polygraph.polygraph_tab;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_window.dart';

class TabLayout {
  /// The window layout for this tab, number of rows and columns.
  /// maybe even custom size at some time ...
  TabLayout({required this.rows, required this.cols, required this.canvasSize});
  final int rows;
  final int cols;
  final Size canvasSize;

  static TabLayout getDefault() =>
      TabLayout(rows: 1, cols: 1, canvasSize: const Size(900.0, 600.0));

  static TabLayout fromMap(Map<String, dynamic> x) {
    if (x
        case {
          'rows': int rows,
          'cols': int cols,
          'canvasSize': {'width': num width, 'height': num height}
        }) {
      return TabLayout(
          rows: rows,
          cols: cols,
          canvasSize: Size(width.toDouble(), height.toDouble()));
    } else {
      throw StateError('Can\'t parse input $x into a TabLayout');
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'rows': rows,
      'cols': cols,
      'canvasSize': {
        'width': canvasSize.width,
        'height': canvasSize.height,
      }
    };
  }

  /// Allow up to 8 max windows per tab, split in 2 columns if the number of
  /// windows is even, except for the case of 2 windows.
  TabLayout addWindow() {
    if (rows * cols < 3) {
      return copyWith(rows: rows + 1);
    } else if (rows * cols == 3) {
      return copyWith(rows: 2, cols: 2);
    } else if (rows * cols == 4) {
      return copyWith(rows: 5, cols: 1);
    } else if (rows * cols == 5) {
      return copyWith(rows: 3, cols: 2);
    } else if (rows * cols == 6) {
      return copyWith(rows: 7, cols: 1);
    } else if (rows * cols == 7) {
      return copyWith(rows: 4, cols: 2);
    }
    return this;
  }

  /// Don't remove the last window.
  TabLayout removeWindow() {
    if (rows * cols == 1) {
      return this;
    } else if ((rows * cols) % 2 == 0) {
      return copyWith(rows: rows * cols - 1, cols: 1);
    } else if (rows * cols == 3) {
      return copyWith(rows: 2, cols: 1);
    } else {
      return copyWith(rows: rows * cols ~/ 2, cols: 2);
    }
  }

  /// All windows have the same size.  Calculate that size.
  Size windowSize() {
    return Size(canvasSize.width / cols, canvasSize.height / rows);
  }

  TabLayout copyWith({int? rows, int? cols, Size? canvasSize}) => TabLayout(
      rows: rows ?? this.rows,
      cols: cols ?? this.cols,
      canvasSize: canvasSize ?? this.canvasSize);
}

class PolygraphTab {
  /// A workbook can have several tabs.  A tab can have several windows.
  PolygraphTab({
    required this.name,
    required this.layout,
    required this.windows,
    required this.activeWindowIndex,
  });

  final String name;
  final TabLayout layout;
  final List<PolygraphWindow> windows;
  final int activeWindowIndex;

  /// Use this variable to communicate if a window was added or removed,
  /// so I can modify the list of plotly in the UI.
  var tabAction = <String, dynamic>{};

  static PolygraphTab empty({required String name}) {
    var layout = TabLayout.getDefault();
    return PolygraphTab(
      name: name,
      layout: layout,
      windows: [PolygraphWindow.empty(size: layout.canvasSize)],
      activeWindowIndex: 0,
    );
  }

  static PolygraphTab tab2({required String name}) {
    var layout = TabLayout.getDefault();
    return PolygraphTab(
      name: name,
      layout: layout,
      windows: [PolygraphWindow.getExpressionWindow(size: layout.canvasSize)],
      activeWindowIndex: 0,
    );
  }

  static PolygraphTab getDefault() {
    var tabLayout = TabLayout.getDefault();
    return PolygraphTab(
      name: 'Tab 1',
      layout: tabLayout,
      windows: [
        // PolygraphWindow.getDefault(),
        PolygraphWindow.getLmpWindow(size: tabLayout.canvasSize),
      ],
      activeWindowIndex: 0,
    );
  }

  /// Add an empty window
  PolygraphTab addWindow() {
    // all the windows need to be resized
    var newLayout = layout.addWindow();
    var size = newLayout.windowSize();

    var newWindows = <PolygraphWindow>[];
    for (var window in windows) {
      newWindows.add(window.copyWith(
          layout:
              window.layout.copyWith(width: size.width, height: size.height)));
    }
    newWindows.add(PolygraphWindow.empty(size: size));

    var tab = copyWith(
      layout: newLayout,
      windows: newWindows,
    )..tabAction = {
        'windowAdded': true,
      };

    return tab;
  }

  PolygraphTab removeWindow(int i) {
    if (layout.rows * layout.cols == 1) {
      return this;
    }
    // all the windows need to be resized
    var newTabLayout = layout.removeWindow();
    var newSize = newTabLayout.windowSize();

    var newWindows = [...windows];
    newWindows.removeAt(i);

    for (var i = 0; i < newWindows.length; i++) {
      newWindows[i] = newWindows[i].copyWith(
          layout: newWindows[i]
              .layout
              .copyWith(width: newSize.width, height: newSize.height));
    }

    var tab = copyWith(
      layout: newTabLayout,
      windows: newWindows,
      activeWindowIndex: 0,
    )..tabAction = {
        'windowRemoved': {'index': i},
      };
    return tab;
  }

  PolygraphTab copyWith({
    int? tab,
    String? name,
    TabLayout? layout,
    List<PolygraphWindow>? windows,
    int? activeWindowIndex,
    bool resetTabAction = false,
  }) {
    var tab = PolygraphTab(
      name: name ?? this.name,
      layout: layout ?? this.layout,
      windows: windows ?? this.windows,
      activeWindowIndex: activeWindowIndex ?? this.activeWindowIndex,
    );
    if (resetTabAction) {
      tab.tabAction = <String, dynamic>{};
    }
    return tab;
  }

  static PolygraphTab fromJson(Map<String, dynamic> x) {
    if (x
        case {
          'name': String name,
          'tabLayout': Map<String, dynamic> _layout,
          'windows': List<Map<String, dynamic>> _windows,
        }) {
      var tabLayout = TabLayout.fromMap(_layout);
      var windows = [for (var e in _windows) PolygraphWindow.fromJson(e)];

      return PolygraphTab(
          name: name,
          layout: tabLayout,
          windows: windows,
          activeWindowIndex: 0);
    } else {
      throw StateError('Can\'t parse input $x into a PolygraphTab');
    }
  }

  /// What gets serialized to the database
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'tabLayout': layout.toJson(),
      'windows': [for (var window in windows) window.toJson()],
    };
  }
}

/// I don't need a notifier for the tab.  Everything goes through poly.
