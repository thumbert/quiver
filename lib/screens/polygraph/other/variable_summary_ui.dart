library lib.screens.polygraph.other.variable_summary_ui;

import 'package:date/date.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_quiver/main.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_model.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_window.dart';
import 'package:flutter_quiver/models/polygraph/variables/time_variable.dart';
import 'package:flutter_quiver/models/polygraph/display/variable_display_config.dart';
import 'package:flutter_quiver/screens/polygraph/polygraph_window_ui.dart';
import 'package:flutter_quiver/screens/polygraph/utils/autocomplete_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart' hide Interval;
import 'package:flutter_web_plotly/flutter_web_plotly.dart';
import 'package:timezone/timezone.dart';

class VariableSummaryUi extends StatelessWidget {
  const VariableSummaryUi(this.window, {Key? key}) : super(key: key);

  final PolygraphWindow window;

  @override
  Widget build(BuildContext context) {
    var ys = window.yVariables;
    var cards = <Card>[];
    for (var i = 0; i < ys.length; i++) {
      var content = window.makeSummary(i);
      if (content.isNotEmpty) {
        cards.add(Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ys[i].label,
                  style: TextStyle(
                      fontSize: 18,
                      color:
                          ys[i].color ?? VariableDisplayConfig.defaultColors[i]),
                ),
                const SizedBox(height: 8,),
                ...[for (var r = 0; r < content.length; r++) Text(content[r])]
              ],
            ),
          ),
        ));
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: cards,
    );
  }

}



