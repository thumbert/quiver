library models.polygraph.display.plotly_title;

import 'package:flutter_quiver/models/polygraph/display/plotly_layout.dart';


class PlotlyTitle {
  PlotlyTitle();
  
  String? text;
  bool autoMargin = true;
  PlotlyFont? font;
  num x = 0.5;
  AnchorXTitle? anchorX;
  RefPosition? xRef;
  num? y;
  AnchorYTitle? anchorY;
  RefPosition? yRef;

  static PlotlyTitle getDefault() {
    return PlotlyTitle();
  }
  
  static PlotlyTitle fromMap(Map<String,dynamic> x) {
    var title = PlotlyTitle();
    if (x.containsKey('text')) title.text = x['text'];
    if (x.containsKey('automargin')) title.autoMargin = x['automargin'];
    if (x.containsKey('font')) title.font = PlotlyFont.fromMap(x['font']);
    if (x.containsKey('x')) title.x = x['x'];
    /// TODO: continue me

    return title;
  }

  Map<String,dynamic> toMap() {
    return <String,dynamic>{
      if (text != '') 'text': text,
      if (!autoMargin) 'automargin': autoMargin,
      if (font != null) 'font': font!.toMap(),
      if (x != 0.5) 'x': x,
      if (anchorX != AnchorXTitle.auto) 'xanchor': anchorX.toString(),
      if (xRef != RefPosition.container) 'xref': xRef.toString(),
      if (y != null) 'y' : y,
      if (anchorY != AnchorYTitle.auto) 'yanchor': anchorY.toString(),
      if (yRef != RefPosition.container) 'yref': xRef.toString(),
    };
  }


}