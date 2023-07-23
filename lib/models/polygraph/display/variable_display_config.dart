library models.polygraph.variables.variable_display_config;

import 'package:flutter/material.dart';
import 'package:flutter_quiver/models/polygraph/display/plotly_layout.dart';

class VariableDisplayConfig {

  static VariableDisplayConfig fromMongo(Map<String,dynamic> x) {
    var config = VariableDisplayConfig();
    if (x.containsKey('mode')) {
      config.mode = x['mode'];
    }
    if (x.containsKey('color')) {
      config.color = x['color'];
    }
    if (x.containsKey('width')) {
      config.width = x['width'];
    }
    if (x.containsKey('dash')) {
      config.dash = DashStyle.parse(x['dash']);
    }
    if (x.containsKey('connectGaps')) {
      config.connectGaps = x['connectGaps'];
    }
    return config;
  }

  String mode = 'lines'; // 'lines+markers',
  String? color; // what format?
  int? width; // default is 1
  DashStyle? dash;
  bool? connectGaps;
  String visible = 'true';

  static final allModes = ['lines', 'lines+markers', ''];
  static final allShapes = ['linear', 'spline', 'hv', 'vh', 'hvh', 'vhv'];
  static final allVisible = ['true', 'false', 'legendonly'];

  /// taken from plotly
  static final defaultColors = <Color>[
    const Color(0xFF1f77b4), // muted blue
    const Color(0xFFff7f0e), // safety orange
    const Color(0xFF2ca02c), // cooked asparagus green
    const Color(0xFFd62728), // brick red
    const Color(0xFF9467bd), // muted purple
    const Color(0xFF8c564b), // chestnut brown
    const Color(0xFFe377c2), // raspberry yogurt pink
    const Color(0xFF7f7f7f), // middle gray
    const Color(0xFFbcbd22), // curry yellow-green
    const Color(0xFF17becf), // blue-teal
    //
    const Color(0xFF636EFA),
    const Color(0xFFEF553B),
    const Color(0xFF00CC96),
    const Color(0xFFAB63FA),
    const Color(0xFFFFA15A),
    const Color(0xFF19D3F3),
    const Color(0xFFFF6692),
    const Color(0xFFB6E880),
    const Color(0xFFFF97FF),
    const Color(0xFFFECB52),
  ];


  /// From [Color(0xFF1f77b4)] return '#1f77b4'.
  static String colorToHex(Color color) {
    return '#${(0x00ffffff & color.value).toRadixString(16)}';
  }

  /// TODO:  Maybe set line['shape'] = 'hv' for period beginning, and 'vh' for
  /// period ending.
  Map<String, dynamic>? line;

  Map<String, dynamic> toJson() {
    var out = <String, dynamic>{
      'mode': mode,
    };
    if (color != null) out['color'] = color;
    if (width != null) out['width'] = width;
    if (dash != null) out['dash'] = dash;
    if (connectGaps != null) out['connectgaps'] = connectGaps;

    return out;
  }
}
