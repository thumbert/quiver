library lib.screens.polygraph.polygraph_window_ui;

import 'package:date/date.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_window.dart';
import 'package:flutter_quiver/models/polygraph/variables/time_variable.dart';
import 'package:flutter_quiver/models/polygraph/display/variable_display_config.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_selection.dart';
import 'package:flutter_quiver/screens/polygraph/other/variable_selection_ui.dart';
import 'package:flutter_quiver/screens/polygraph/other/variable_summary_ui.dart';
import 'package:flutter_quiver/screens/polygraph/polygraph.dart';
import 'package:flutter_quiver/screens/polygraph/utils/autocomplete_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:timezone/timezone.dart';

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

