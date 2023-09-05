library models.polygraph.polygraph_tab;

import 'package:dama/dama.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_window.dart';

sealed class WindowNode {
  num width();
  num height();

  static WindowNode fromJson(Map<String, dynamic> x) {
    if (x
    case {
    'node': String nodeType,
    }) {
      return switch (nodeType) {
        'Single' => SingleNode.fromJson(x),
        'Column' => ColumnNode.fromJson(x),
        'Row' => RowNode.fromJson(x),
        _ => throw ArgumentError('Unsupported nodeType $nodeType'),
      };
    } else {
      throw ArgumentError('Can\'t parse $x as a Layout Tree');
    }
  }

  /// Flatten the tree structure
  List<SingleNode> flatten();

  WindowNode resize(num width, num height);

  Map<String, dynamic> toJson();
}

class SingleNode extends WindowNode {
  SingleNode(num width, num height) {
    _width = width;
    _height = height;
  }
  late final num _width;
  late final num _height;

  @override
  List<SingleNode> flatten() {
    return [this];
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'node': 'Single',
      'size': {'width': _width, 'height': _height},
    };
  }

  static SingleNode fromJson(Map<String, dynamic> x) {
    if (x
    case {
    'node': 'Single',
    'size': {'width': num width, 'height': num height}
    }) {
      return SingleNode(width, height);
    } else {
      throw ArgumentError('Can\'t parse $x as a Single');
    }
  }

  /// Vertically split a single window into n equal parts
  RowNode splitVertically(int n) {
    assert(n > 1);
    var width = _width / n;
    var children = List<WindowNode>.generate(n, (index) => SingleNode(width, _height));
    return RowNode(children);
  }

  /// Horizontally split a single window into [n] equal parts
  ColumnNode splitHorizontally(int n) {
    assert(n > 1);
    var height = _height / n;
    var children = List<WindowNode>.generate(n, (index) => SingleNode(_width, height));
    return ColumnNode(children);
  }

  @override
  num height() => _height;

  @override
  num width() => _width;

  @override
  SingleNode resize(num width, num height) {
    return SingleNode(width, height);
  }
}

class ColumnNode extends WindowNode {
  ColumnNode(this.children) {
    assert(children.length > 1);
  }
  List<WindowNode> children;

  @override
  List<SingleNode> flatten() {
    return children.expand((child) => child.flatten()).toList();
  }

  static ColumnNode fromJson(Map<String, dynamic> x) {
    if (x
    case {
    'node': 'Column',
    'children': List<Map<String, dynamic>> children,
    }) {
      var nodes = [for (var child in children) WindowNode.fromJson(child)];
      return ColumnNode(nodes);
    } else {
      throw ArgumentError('Can\'t parse $x as a Column node');
    }
  }

  @override
  num height() => sum(children.map((e) => e.height()));

  @override
  num width() => children.first.width();

  /// Remove the i^th Single node, resize the remaining children.
  ///
  /// Note: different from the [removeAt] method for Dart's List, this method
  /// returns the modified tree (not the removed element.)
  WindowNode removeAt(int i) {
    var originalWidth = width();
    var originalHeight = height();
    var cs = flatten();
    if (cs.length == 2) {
      /// always collapse a Row and a Column with only one element
      return SingleNode(originalWidth, originalHeight);
    } else {
      /// need to remove the correct node from the children ...
      var sizes =
      children.map((e) => e.flatten().length).cumSum().toList().cast<int>();
      var indexChild = sizes.indexWhere((e) => e > i);

      switch (children[indexChild]) {
        case (RowNode node):
          children[indexChild] = node.removeAt(sizes[indexChild] - i - 1);
        case (ColumnNode node):
          children[indexChild] = node.removeAt(sizes[indexChild] - i - 1);
        case SingleNode():
          children.removeAt(indexChild);
          resize(originalWidth, originalHeight);
      }

      return this;
    }
  }

  /// Vertically split the [i]^th Single node into [n] windows.
  ///
  WindowNode splitHorizontally(int i, {int n = 2}) {
    assert(i >= 0);
    /// need to find the correct node from the children ...
    var sizes =
    children.map((e) => e.flatten().length).cumSum().toList().cast<int>();
    var indexChild = sizes.indexWhere((e) => e > i);

    switch (children[indexChild]) {
      case (RowNode node):
        children[indexChild] =
            node.splitHorizontally(i - sizes[indexChild - 1], n: n);
      case (ColumnNode node):
        children[indexChild] =
            node.splitHorizontally(i - sizes[indexChild - 1], n: n);
      case (SingleNode node):
        children[indexChild] = node.splitHorizontally(n);
    }

    return this;
  }

  /// Vertically split the [i]^th Single node into [n] windows.
  ///
  WindowNode splitVertically(int i, {int n = 2}) {
    assert(i >= 0);
    /// need to find the correct node from the children ...
    var sizes =
    children.map((e) => e.flatten().length).cumSum().toList().cast<int>();
    var indexChild = sizes.indexWhere((e) => e > i);

    switch (children[indexChild]) {
      case (RowNode node):
        children[indexChild] =
            node.splitVertically(i - sizes[indexChild - 1], n: n);
      case (ColumnNode node):
        children[indexChild] =
            node.splitVertically(i - sizes[indexChild - 1], n: n);
      case (SingleNode node):
        children[indexChild] = node.splitVertically(n);
    }

    return this;
  }

  /// Spread the missing height (from the deposed widget) equitably across the
  /// remaining widgets.
  @override
  WindowNode resize(num width, num height) {
    var adjHeight =
        (height - children.map((e) => e.height()).sum()) / children.length;
    for (var i = 0; i < children.length; i++) {
      children[i] = children[i].resize(width, children[i].height() + adjHeight);
    }
    return this;
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'node': 'Column',
      'children': [for (var child in children) child.toJson()],
    };
  }
}

class RowNode extends WindowNode {
  RowNode(this.children) {
    assert(children.length > 1);
  }
  List<WindowNode> children;

  /// Remove the i^th Single node and resize the remaining children
  ///
  /// Note: different from the [removeAt] method for Dart's List, this method
  /// returns the modified tree (not the removed element.)
  WindowNode removeAt(int i) {
    var originalWidth = width();
    var originalHeight = height();
    var cs = flatten();
    if (cs.length == 2) {
      /// always collapse a Row and a Column with only one element
      return SingleNode(originalWidth, originalHeight);
    } else {
      /// need to remove the correct node from the children ...
      var sizes =
      children.map((e) => e.flatten().length).cumSum().toList().cast<int>();
      var indexChild = sizes.indexWhere((e) => e > i);

      switch (children[indexChild]) {
        case (RowNode node):
          children[indexChild] = node.removeAt(sizes[indexChild] - i - 1);
        case (ColumnNode node):
          children[indexChild] = node.removeAt(sizes[indexChild] - i - 1);
        case SingleNode():
          children.removeAt(indexChild);
          resize(originalWidth, originalHeight);
      }
      return this;
    }
  }

  /// Horizontally split the [i]^th Single node into [n] windows.
  ///
  WindowNode splitHorizontally(int i, {int n = 2}) {
    assert(i >= 0);
    /// need to find the correct node from the children ...
    var sizes =
    children.map((e) => e.flatten().length).cumSum().toList().cast<int>();
    var indexChild = sizes.indexWhere((e) => e > i);

    switch (children[indexChild]) {
      case (RowNode node):
        children[indexChild] =
            node.splitHorizontally(i - sizes[indexChild - 1], n: n);
      case (ColumnNode node):
        children[indexChild] =
            node.splitHorizontally(i - sizes[indexChild - 1], n: n);
      case (SingleNode node):
        children[indexChild] = node.splitHorizontally(n);
    }

    return this;
  }

  /// Vertically split the [i]^th Single node into [n] windows.
  ///
  WindowNode splitVertically(int i, {int n = 2}) {
    assert(i >= 0);
    /// need to find the correct node from the children ...
    var sizes =
    children.map((e) => e.flatten().length).cumSum().toList().cast<int>();
    var indexChild = sizes.indexWhere((e) => e > i);

    switch (children[indexChild]) {
      case (RowNode node):
        children[indexChild] =
            node.splitHorizontally(i - sizes[indexChild - 1], n: n);
      case (ColumnNode node):
        children[indexChild] =
            node.splitVertically(i - sizes[indexChild - 1], n: n);
      case (SingleNode node):
        children[indexChild] = node.splitVertically(n);
    }

    return this;
  }

  @override
  List<SingleNode> flatten() {
    return children.expand((child) => child.flatten()).toList();
  }

  static RowNode fromJson(Map<String, dynamic> x) {
    if (x
    case {
    'node': 'Row',
    'children': List<Map<String, dynamic>> children,
    }) {
      var nodes = [for (var child in children) WindowNode.fromJson(child)];
      return RowNode(nodes);
    } else {
      throw ArgumentError('Can\'t parse $x as a Row node');
    }
  }

  @override
  num height() => children.first.height();

  @override
  num width() => sum(children.map((e) => e.width()));

  /// Spread the missing width (from the deposed widget) equitably across the
  /// remaining widgets.
  @override
  WindowNode resize(num width, num height) {
    var adjWidth =
        (width - children.map((e) => e.width()).sum()) / children.length;
    for (var i = 0; i < children.length; i++) {
      children[i] = children[i].resize(children[i].width() + adjWidth, height);
    }
    return this;
  }

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'node': 'Row',
      'children': [for (var child in children) child.toJson()],
    };
  }
}

class PolygraphTab {
  /// A workbook can have several tabs.  A tab can have several windows.
  PolygraphTab({
    required this.name,
    required this.rootNode,
    required this.windows,
    required this.activeWindowIndex,
  });

  final String name;
  final WindowNode rootNode;
  final List<PolygraphWindow> windows;
  final int activeWindowIndex;


  static const borderHeight = 30.0;
  static const borderWidth = 1.0;


  /// Use this variable to communicate if a window was added or removed,
  /// so I can modify the list of plotly in the UI.
  var tabAction = <String, dynamic>{};

  static PolygraphTab empty({required String name}) {
    var root = SingleNode(900, 600);
    return PolygraphTab(
      name: name,
      rootNode: root,
      windows: [
        PolygraphWindow.empty(
            size: Size(root.width().toDouble(), root.height().toDouble()))
      ],
      activeWindowIndex: 0,
    );
  }

  static PolygraphTab tab2({required String name}) {
    var root = SingleNode(900, 600);
    return PolygraphTab(
      name: name,
      rootNode: root,
      windows: [
        PolygraphWindow.getExpressionWindow(
            size: Size(root.width().toDouble(), root.height().toDouble()))
      ],
      activeWindowIndex: 0,
    );
  }

  static PolygraphTab getDefault() {
    var root = SingleNode(900, 600);
    return PolygraphTab(
      name: 'Tab 1',
      rootNode: root,
      windows: [
        // PolygraphWindow.getDefault(),
        PolygraphWindow.getLmpWindow(
            size: Size(root.width().toDouble(), root.height().toDouble())),
      ],
      activeWindowIndex: 0,
    );
  }


  /// The original window is split into two windows stacked on top of each other.
  /// The height of each new window equals one half of the height of the
  /// original window.  The original window is squeezed in the top window, and
  /// a new empty window is created at the bottom of the two element column.
  ///
  PolygraphTab splitWindowHorizontally(int i) {
    var newRoot = switch (rootNode) {
      (SingleNode node) => node.splitHorizontally(2),
      (RowNode node) => node.splitHorizontally(i, n: 2),
      (ColumnNode node) => node.splitHorizontally(i, n: 2),
    };
    var fs = newRoot.flatten();

    var newWindows = <PolygraphWindow>[...windows];
    // the +1 below is such that the new window comes after the original one
    newWindows.insert(i+1, PolygraphWindow.empty(size: const Size(0, 0)));
    for (var i = 0; i < newWindows.length; i++) {
      newWindows[i] = newWindows[i].copyWith(
          layout: newWindows[i]
              .layout
              .copyWith(width: fs[i].width(), height: fs[i].height()));
    }

    var tab = copyWith(
      rootNode: newRoot,
      windows: newWindows,
    )..tabAction = {
      'windowAdded': {'index': i}
    };

    return tab;
  }


  PolygraphTab splitWindowVertically(int i) {
    var newRoot = switch (rootNode) {
      (SingleNode node) => node.splitVertically(2),
      (RowNode node) => node.splitVertically(i, n: 2),
      (ColumnNode node) => node.splitVertically(i, n: 2),
    };
    var fs = newRoot.flatten();

    var newWindows = <PolygraphWindow>[...windows];
    // the +1 below is such that the new window comes after the original one
    newWindows.insert(i+1, PolygraphWindow.empty(size: const Size(0, 0)));
    for (var i = 0; i < newWindows.length; i++) {
      newWindows[i] = newWindows[i].copyWith(
          layout: newWindows[i]
              .layout
              .copyWith(width: fs[i].width(), height: fs[i].height()));
    }

    var tab = copyWith(
      rootNode: newRoot,
      windows: newWindows,
    )..tabAction = {
      'windowAdded': {'index': i},
    };

    return tab;
  }


  PolygraphTab removeWindow(int i) {
    if (rootNode is SingleNode) return this;

    var newRoot = switch (rootNode) {
      (SingleNode node) => node,
      (RowNode node) => node.removeAt(i),
      (ColumnNode node) => node.removeAt(i),
    };
    var fs = newRoot.flatten();

    // all the windows need to be resized
    var newWindows = [...windows];
    newWindows.removeAt(i);
    for (var i = 0; i < newWindows.length; i++) {
      newWindows[i] = newWindows[i].copyWith(
          layout: newWindows[i]
              .layout
              .copyWith(width: fs[i].width(), height: fs[i].height()));
    }

    final tab = copyWith(
      rootNode: newRoot,
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
    WindowNode? rootNode,
    List<PolygraphWindow>? windows,
    int? activeWindowIndex,
    bool resetTabAction = false,
  }) {
    var tab = PolygraphTab(
      name: name ?? this.name,
      rootNode: rootNode ?? this.rootNode,
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
    'tabLayout': Map _layout,
    'windows': List _windows,
    }) {
      var root = WindowNode.fromJson(_layout.cast<String,dynamic>());
      var windows = [for (Map<String,dynamic> e in _windows) PolygraphWindow.fromJson(e)];

      return PolygraphTab(
          name: name,
          rootNode: root,
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
      'tabLayout': rootNode.toJson(),
      'windows': [for (var window in windows) window.toJson()],
    };
  }
}

/// I don't need a notifier for the tab.  Everything goes through poly.