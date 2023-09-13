library models.polygraph.display.plotly_legend_group_title;

import 'package:flutter_quiver/models/polygraph/display/plotly_layout.dart';

class PlotlyLegendGroupTitle {

  PlotlyFont? font;
  String text = '';

  static PlotlyLegendGroupTitle fromJson(Map<String,dynamic> x) {
    var out = PlotlyLegendGroupTitle();
    if (x.containsKey('font')) out.font = PlotlyFont.fromJson(x['font']);
    if (x.containsKey('text')) out.text = x['text'];
    return out;
  }

  Map<String,dynamic> toJson() {
    return <String,dynamic>{
      if (font != null) 'font': font!.toJson(),
      if (text != '') 'text': text,
    };
  }

}