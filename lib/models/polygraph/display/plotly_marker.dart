library models.polygraph.display.plotly_markers;

import 'package:flutter_quiver/models/polygraph/display/plotly_enums.dart';

class PlotlyMarker {

  /// Default: 0
  /// Sets the marker angle in respect to `angleref`.
  num? angle;

  /// Sets the reference for marker angle. With "previous", angle 0 points along
  /// the line from the previous point to this one. With "up", angle 0 points
  /// toward the top of the screen.
  PlotlyAngleRef? angleRef;

  /// Determines whether the colorscale is a default palette
  /// (`autocolorscale: true`) or the palette determined by `marker.colorscale`.
  /// Has an effect only if in `marker.color` is set to a numerical array.
  /// In case `colorscale` is unspecified or `autocolorscale` is true, the
  /// default palette will be chosen according to whether numbers in the `color`
  /// array are all positive, all negative or mixed.
  bool autoColorScale = true;

  /// Determines whether or not the color domain is computed with respect to the
  /// input data (here in `marker.color`) or the bounds set in `marker.cmin` and
  /// `marker.cmax` Has an effect only if in `marker.color` is set to a
  /// numerical array. Defaults to `false` when `marker.cmin` and `marker.cmax`
  /// are set by the user.
  bool cAuto = true;

  /// Sets the upper bound of the color domain. Has an effect only if in
  /// `marker.color` is set to a numerical array. Value should have the same
  /// units as in `marker.color` and if set, `marker.cmin` must be set as well.
  num? cMax;

  /// Sets the mid-point of the color domain by scaling `marker.cmin` and/or
  /// `marker.cmax` to be equidistant to this point. Has an effect only if in
  /// `marker.color` is set to a numerical array. Value should have the same
  /// units as in `marker.color`. Has no effect when `marker.cauto` is `false`.
  num? cMid;

  /// Sets the lower bound of the color domain. Has an effect only if in
  /// `marker.color` is set to a numerical array. Value should have the same
  /// units as in `marker.color` and if set, `marker.cmax` must be set as well.
  num? cMin;

  /// Type: color or array of colors
  /// Sets the marker color. It accepts either a specific color or an array of
  /// numbers that are mapped to the colorscale relative to the max and min
  /// values of the array or relative to `marker.cmin` and `marker.cmax` if set.
  Object? color;

  /// Sets a reference to a shared color axis. References to these shared color
  /// axes are "coloraxis", "coloraxis2", "coloraxis3", etc. Settings for these
  /// shared color axes are set in the layout, under `layout.coloraxis`,
  /// `layout.coloraxis2`, etc. Note that multiple color scales can be linked to
  /// the same color axis.
  String? colorAxis;


  static PlotlyMarker fromJson(Map<String,dynamic> x) {
    var out = PlotlyMarker();
    if (x.containsKey('angle')) out.angle = x['angle'];
    if (x.containsKey('angleref')) {
      out.angleRef = PlotlyAngleRef.parse(x['angleref']);
    }
    if (x.containsKey('autocolorscale')) {
      out.autoColorScale = x['autocolorscale'];
    }




    return out;
  }


  Map<String,dynamic> toJson() {
    return <String,dynamic>{
      if (angle != null) 'angle': angle,
      if (angleRef != null) 'angleref': angleRef.toString(),
      if (!autoColorScale) 'autocolorscale': autoColorScale,
    };
  }

}