library models.polygraph.polygraph_tab;

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_window.dart';

class WindowLayout {
  WindowLayout({required this.topLeftCorner, required this.size});
  final Size size;
  final Point topLeftCorner;

  static WindowLayout fromJson(Map<String, dynamic> x) {
    if (x
        case {
          'size': {'width': num width, 'height': num height},
          'topLeftCorner': {'x': num x, 'y': num y},
        }) {
      return WindowLayout(
          topLeftCorner: Point(x, y),
          size: Size(width.toDouble(), height.toDouble()));
    } else {
      throw StateError('Can\'t parse input $x into a WindowLayout');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'size': {'width': size.width, 'height': size.height},
      'topLeftCorner': {'x': topLeftCorner.x, 'y': topLeftCorner.y},
    };
  }
}

class TabLayout {
  /// The window layout for this tab, number of rows and columns.
  /// maybe even custom size at some time ...
  TabLayout({required this.canvasSize, required this.windows});
  final Size canvasSize;
  final List<WindowLayout> windows;

  static TabLayout getDefault() =>
      TabLayout(canvasSize: const Size(900.0, 600.0), windows: [
        WindowLayout(
            topLeftCorner: const Point(0, 0), size: const Size(900.0, 600.0))
      ]);

  static TabLayout fromJson(Map<String, dynamic> x) {
    if (x
        case {
          'canvasSize': {'width': num width, 'height': num height},
          'windows': List<Map<String, dynamic>> xs,
        }) {
      var windows = xs.map((e) => WindowLayout.fromJson(e)).toList();
      return TabLayout(
          canvasSize: Size(width.toDouble(), height.toDouble()),
          windows: windows);
    } else {
      throw StateError('Can\'t parse input $x into a TabLayout');
    }
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'canvasSize': {
        'width': canvasSize.width,
        'height': canvasSize.height,
      },
      'windows': [for (var e in windows) e.toJson()],
    };
  }

  TabLayout splitHorizontally(int i) {
    /// TODO
    return TabLayout(canvasSize: canvasSize, windows: windows);
  }

  TabLayout splitVertically(int i) {
    /// TODO
    return TabLayout(canvasSize: canvasSize, windows: windows);
  }

  /// Don't remove the last window
  TabLayout removeWindow(int i) {
    if (windows.length == 1) return this;

    /// TODO
    return TabLayout(canvasSize: canvasSize, windows: windows);
  }

  TabLayout copyWith({Size? canvasSize, List<WindowLayout>? windows}) =>
      TabLayout(
        canvasSize: canvasSize ?? this.canvasSize,
        windows: windows ?? this.windows,
      );
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

  PolygraphTab splitWindowHorizontally(int i) {
    var newLayout = layout.splitHorizontally(i);

    var newWindows = [...windows];
    newWindows.insert(i, newWindows[i]);
    var size = newLayout
    newWindows[i].copyWith(layout: newWindows[i].layout.copyWith(width: ));

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
      var tabLayout = TabLayout.fromJson(_layout);
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
