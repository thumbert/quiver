library models.polygraph.display.plotly_notifiers;

import 'package:flutter_quiver/models/polygraph/display/plotly_layout.dart';
import 'package:flutter_quiver/models/polygraph/display/plotly_title.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class PlotlyLayoutNotifier extends StateNotifier<PlotlyLayout> {
  PlotlyLayoutNotifier(this.ref) : super(PlotlyLayout.getDefault());

  final Ref ref;

  void dimensions({required num width, required num height}) {
    state = state.copyWith(width: width, height: height);
  }

  set title(PlotlyTitle value) {
    state = state.copyWith(title: value);
  }

  set xAxis(PlotlyXAxis value) {
    state = state.copyWith(xAxis: value);
  }

  set yAxis(PlotlyYAxis value) {
    state = state.copyWith(yAxis: value);
  }

  set legend(PlotlyLegend value) {
    state = state.copyWith(legend: value);
  }

  set showLegend(bool value) {
    state = state.copyWith(showLegend: value);
  }

  set hoverMode(HoverMode value) {
    state = state.copyWith(hoverMode: value);
  }
}
