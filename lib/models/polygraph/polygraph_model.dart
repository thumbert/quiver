library models.polygraph.polygraph_model;

import 'package:flutter_quiver/models/polygraph/data_service/data_service.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service_local.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_tab.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_window.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeseries/timeseries.dart';

class PolygraphConfig {
  PolygraphConfig();
  static PolygraphConfig getDefault() => PolygraphConfig();
}

class PolygraphState {
  PolygraphState({
    required this.config,
    required this.tabs,
    required this.activeTabIndex,
  });

  final PolygraphConfig config;

  /// Each sheet has at least one tab, can have multiple tabs.
  /// Each tab has at least one window, can have multiple windows.
  /// Each window has its own variables to plot.
  final List<PolygraphTab> tabs;

  /// Keep track of which tab is active and needs to be underlined in orange
  /// on the screen.  Variables and the chart associated with this tab get
  /// displayed.
  final int activeTabIndex;

  static DataService service = DataServiceLocal();

  PolygraphWindow get activeWindow =>
      tabs[activeTabIndex].windows[activeTabIndex];

  /// Add tab at the end
  void addTab() {
    var tab = PolygraphTab.empty(name: _getNextDefaultTabName());
    tabs.add(tab);
  }

  /// No opportunity to ask 'Are you sure?'.  Just delete it.
  void deleteTab(int index) {
    tabs.removeAt(index);
  }

  ///
  PolygraphState fromMap(Map<String, dynamic> x) {
    return PolygraphState.getDefault();
  }

  static final cache = <String, TimeSeries<num>>{};

  /// What gets serialized to Mongo
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'tabs': [for (var tab in tabs) tab.toMap()],
    };
  }

  /// An empty state containing one tab with an empty window.
  static PolygraphState empty() {
    return PolygraphState(
      config: PolygraphConfig.getDefault(),
      tabs: [PolygraphTab.empty(name: 'Tab 1')],
      activeTabIndex: 0,
    );
  }

  static PolygraphState getDefault() {
    return PolygraphState(
      config: PolygraphConfig.getDefault(),
      tabs: [
        PolygraphTab.getDefault(),
        PolygraphTab.tab2(name: 'Tab 2'),
        PolygraphTab.empty(name: 'Tab 3'),
      ],
      activeTabIndex: 0,
    );
  }

  /// Return a valid tab name for tab at position [tabIndex].
  /// If you pass in a [suggestedName] that is not allowed ('' or an already
  /// existing tab name at a different location), it will
  /// generate a new name.  This is used in the [addTab] method.
  ///
  String getValidTabName(
      {required int tabIndex, required String suggestedName}) {
    if (tabs[tabIndex].name == suggestedName) {
      return suggestedName;
    }
    // match existing name in different position
    bool matchExistingName = false;
    for (var i = 0; i < tabs.length; i++) {
      if (i != tabIndex && tabs[i].name == suggestedName) {
        matchExistingName = true;
        break;
      }
    }

    if (suggestedName == '' || matchExistingName) {
      var names = tabs.map((e) => e.name).toList();
      names.removeAt(tabIndex);
      var i = 1;
      while (names.any((e) => e == 'Tab $i')) {
        i = i + 1;
      }
      return 'Tab $i';
    }
    return suggestedName;
  }

  String _getNextDefaultTabName() {
    var i = 1;
    while (tabs.any((e) => e.name == 'Tab $i')) {
      i = i + 1;
    }
    return 'Tab $i';
  }

  PolygraphState copyWith({
    List<PolygraphTab>? tabs,
    PolygraphConfig? config,
    int? activeTabIndex,
  }) {
    return PolygraphState(
      tabs: tabs ?? this.tabs,
      config: config ?? this.config,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
    );
  }
}

class PolygraphNotifier extends StateNotifier<PolygraphState> {
  PolygraphNotifier(this.ref) : super(PolygraphState.getDefault());

  final Ref ref;

  set tabs(List<PolygraphTab> values) {
    state = state.copyWith(tabs: values);
  }

  set config(PolygraphConfig value) {
    state = state.copyWith(config: value);
  }

  set activeTabIndex(int value) {
    state = state.copyWith(activeTabIndex: value);
  }

  set activeTab(PolygraphTab value) {
    var tabs = [...state.tabs];
    tabs[state.activeTabIndex] = value;
    state = state.copyWith(tabs: tabs);
  }

  set activeWindow(PolygraphWindow value) {
    var activeTab = state.tabs[state.activeTabIndex];
    var windows = [...activeTab.windows];
    windows[activeTab.activeWindowIndex] = value;
    activeTab = activeTab.copyWith(windows: windows);
    // print('in polygraph_model, set activeWindow, ${value.cache.keys}');
    this.activeTab = activeTab;
  }

  set refreshActiveWindow(bool value) {
    var activeTab = state.tabs[state.activeTabIndex];
    var windows = [...activeTab.windows];
    windows[activeTab.activeWindowIndex].refreshDataFromDb = value;
    activeTab = activeTab.copyWith(windows: windows);
    // print('in polygraph_model, set activeWindow, ${value.cache.keys}');
    this.activeTab = activeTab;
  }

}
