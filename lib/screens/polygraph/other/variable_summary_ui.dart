library lib.screens.polygraph.other.variable_summary_ui;

import 'package:flutter_quiver/models/polygraph/polygraph_window.dart';
import 'package:flutter_quiver/models/polygraph/display/variable_display_config.dart';
import 'package:flutter/material.dart' hide Interval;

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



