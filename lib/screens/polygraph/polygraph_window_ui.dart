library lib.screens.polygraph.polygraph_window_ui;

import 'package:flutter_quiver/models/polygraph/polygraph_window.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// final providerOfPolygraphWindow =
//     StateNotifierProvider<PolygraphWindowNotifier, PolygraphWindow>(
//         (ref) => PolygraphWindowNotifier(ref));

// final providerOfActivePolygraphWindow =
//   StateProvider<PolygraphWindow>((ref) {
//     var poly = ref.watch(providerOfPolygraph);
//     var tab = poly.tabs[poly.activeTabIndex];
//     return tab.windows[tab.activeWindowIndex];
//   });


/// Used in polygraph_tab_ui in _makePlotWindows()

final providerOfPolygraphWindowCache =
    FutureProvider.family<Map<String, dynamic>, PolygraphWindow>(
        (ref, window) async {
  await window.updateCache();
  return window.cache;
});

/// Don't need to have a window ui as all the windows are part of a tab.
/// Keep all the logic in polygraph_tab_ui.

