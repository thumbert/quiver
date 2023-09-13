library models.polygraph.display.plotly_colorbar;

import 'package:flutter_quiver/models/polygraph/display/plotly_enums.dart';
import 'package:flutter_quiver/models/polygraph/display/plotly_layout.dart';

class PlotlyColorbar {
  /// Default: "rgba(0,0,0,0)"
  /// Sets the color of padded area.
  String? bgColor;

  /// Default: "#444"
  /// Sets the axis line color.
  String? borderColor;

  /// Type: number greater than or equal to 0
  /// Default: 0
  /// Sets the width (in px) or the border enclosing this color bar.
  num? borderWidth;

  /// Type: number or categorical coordinate string
  /// Sets the step in-between ticks on this axis. Use with `tick0`. Must be a
  /// positive number, or special strings available to "log" and "date" axes.
  /// If the axis `type` is "log", then ticks are set every 10^(n"dtick) where n
  /// is the tick number. For example, to set a tick mark at 1, 10, 100, 1000,
  /// ... set dtick to 1. To set tick marks at 1, 100, 10000, ... set dtick to
  /// 2. To set tick marks at 1, 5, 25, 125, 625, 3125, ... set dtick to
  /// log_10(5), or 0.69897000433. "log" has several special values; "L<f>",
  /// where `f` is a positive number, gives ticks linearly spaced in value
  /// (but not position). For example `tick0` = 0.1, `dtick` = "L0.5" will put
  /// ticks at 0.1, 0.6, 1.1, 1.6 etc. To show powers of 10 plus small digits
  /// between, use "D1" (all digits) or "D2" (only 2 and 5). `tick0` is ignored
  /// for "D1" and "D2". If the axis `type` is "date", then you must convert the
  /// time to milliseconds. For example, to set the interval between ticks to
  /// one day, set `dtick` to 86400000.0. "date" also has special values "M<n>"
  /// gives ticks spaced by a number of months. `n` must be a positive integer.
  /// To set ticks on the 15th of every third month, set `tick0` to "2000-01-15"
  /// and `dtick` to "M3". To set ticks every 4 years, set `dtick` to "M48".
  Object? dTick;

  PlotlyExponentFormat? exponentFormat;

  /// Replacement text for specific tick or hover labels. For example using
  /// {US: 'USA', CA: 'Canada'} changes US to USA and CA to Canada. The labels
  /// we would have shown must match the keys exactly, after adding any
  /// tickprefix or ticksuffix. For negative numbers the minus sign symbol used
  /// (U+2212) is wider than the regular ascii dash. That means you need to
  /// use −1 instead of -1. labelalias can be used with any axis type, and both
  /// keys (if needed) and values (if desired) can include html-like tags or
  /// MathJax.
  Object? labelAlias;

  /// Type: number greater than or equal to 0
  /// Default: 1
  /// Sets the length of the color bar This measure excludes the padding of both
  /// ends. That is, the color bar length is this length minus the padding on
  /// both ends.
  num? len;

  /// Default: "fraction"
  /// Determines whether this color bar's length (i.e. the measure in the color
  /// variation direction) is set in units of plot "fraction" or in "pixels.
  /// Use `len` to set the value.
  PlotlyLenMode? lenMode;

  /// number greater than or equal to 0
  /// Default: 3
  /// Hide SI prefix for 10^n if |n| is below this number. This only has an
  /// effect when `tickformat` is "SI" or "B".
  num? minExponent;

  num? nTicks;

  /// Sets the orientation of the colorbar.
  PlotlyOrientation? orientation;

  /// Default: "#444"
  /// Sets the axis line color.
  String? outlineColor;

  /// number greater than or equal to 0
  /// Default: 1
  /// Sets the width (in px) of the axis line.
  num? outlineWidth;

  /// If "true", even 4-digit integers are separated
  bool? separateThousands;




  static PlotlyColorbar fromJson(Map<String, dynamic> x) {
    var out = PlotlyColorbar();
    if (x.containsKey('bgcolor')) out.bgColor = x['bgcolor'];
    if (x.containsKey('bordercolor')) out.borderColor = x['bordercolor'];
    if (x.containsKey('borderwidth')) out.borderWidth = x['borderwidth'];
    if (x.containsKey('dtick')) out.dTick = x['dtick'];
    if (x.containsKey('exponentformat')) {
      out.exponentFormat = PlotlyExponentFormat.parse(x['exponentformat']);
    }
    if (x.containsKey('len')) out.len = x['len'];
    if (x.containsKey('lenmode')) {
      out.lenMode = PlotlyLenMode.parse(x['lenmode']);
    }
    if (x.containsKey('minexponent')) out.minExponent = x['minexponent'];

    return out;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (bgColor != null) 'bgcolor': bgColor,
      if (borderColor != null) 'bordercolor': borderColor,
      if (borderWidth != null) 'borderwidth': borderWidth,
      if (dTick != null) 'dtick': dTick,
      if (exponentFormat != null) 'exponentformat': exponentFormat.toString(),
      if (len != null) 'len': len,
      if (lenMode != null) 'lenmode': lenMode.toString(),
      if (minExponent != null) 'minexponent': minExponent,

    };
  }
}
