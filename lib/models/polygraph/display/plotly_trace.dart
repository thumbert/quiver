library models.polygraph.display.plotly_trace;

import 'package:flutter_quiver/models/polygraph/display/plotly_layout.dart';
import 'package:flutter_quiver/models/polygraph/display/plotly_legend_group_title.dart';
import 'package:flutter_quiver/models/polygraph/display/plotly_text_position.dart';

class ScatterTrace {
  /// See https://plotly.com/javascript/reference/scatter/
  ScatterTrace({
    required this.x,
    required this.y,
    this.name,
    this.text,
    this.mode,
  }) {
    assert(x.length == y.length);
  }

  List<dynamic> x;
  List<num> y;

  String? name;
  TraceVisibility visible = TraceVisibility.on;

  String legend = 'legend';
  int legendRank = 1000;
  String legendGroup = '';
  PlotlyLegendGroupTitle? legendGroupTitle;
  num? legendWidth;

  num opacity = 1;

  /// Any combination of "lines", "markers", "text" joined with a "+" OR "none".
  /// Examples: "lines", "markers", "lines+markers", "lines+markers+text", "none"
  /// Determines the drawing mode for this scatter trace. If the provided `mode`
  /// includes "text" then the `text` elements appear at the coordinates.
  /// Otherwise, the `text` elements appear on hover.  If there are less than
  /// 20 points and the trace is not stacked then the default is "lines+markers".
  /// Otherwise, "lines".
  String? mode;

  /// Assigns id labels to each datum. These ids for object constancy of data
  /// points during animation. Should be an array of strings, not numbers or
  /// any other type.
  List<String>? ids;

  bool showLegend = true;

  /// Alternate to `x`. Builds a linear space of x coordinates. Use with `dx`
  /// where `x0` is the starting coordinate and `dx` the step.
  num x0 = 0;

  /// Sets the x coordinate step. See `x0` for more info.
  num dx = 1;

  /// Alternate to `y`. Builds a linear space of y coordinates. Use with `dy`
  /// where `y0` is the starting coordinate and `dy` the step.
  num y0 = 0;

  /// Sets the y coordinate step. See `y0` for more info.
  num dy = 1;

  /// A list with only one element means that the value applies to all
  /// elements of the trace.
  List<String>? text;

  /// Sets the positions of the `text` elements with respects to the (x,y)
  /// coordinates.
  /// A list with only one element means that the value applies to all
  /// elements of the trace.
  List<PlotlyTextPosition>? textPosition;

  /// Template string used for rendering the information text that appear on
  /// points. Note that this will override `textinfo`. Variables are inserted
  /// using %{variable}, for example "y: %{y}". Numbers are formatted using
  /// d3-format's syntax %{variable:d3-format}, for example "Price: %{y:$.2f}".
  /// https://github.com/d3/d3-format/tree/v1.4.5#d3-format for details on the
  /// formatting syntax. Dates are formatted using d3-time-format's
  /// syntax %{variable|d3-time-format}, for example "Day: %{2019-01-01|%A}".
  /// https://github.com/d3/d3-time-format/tree/v2.2.3#locale_format for
  /// details on the date formatting syntax. Every attributes that can be
  /// specified per-point (the ones that are `arrayOk: true`) are available.
  ///
  /// Use a list of one element if the same value is to be applied for all
  /// points.
  List<String>? textTemplate;

  /// Sets hover text elements associated with each (x,y) pair. If a List of
  /// one element, the same string appears over all the data points. If a List
  /// of elements, the items are mapped in order to the this trace's (x,y)
  /// coordinates. To be seen, trace `hoverinfo` must contain a "text" flag.
  List<String>? hoverText;

  /// Any combination of "x", "y", "z", "text", "name" joined with a "+" OR
  /// "all" or "none" or "skip".
  /// Examples: "x", "y", "x+y", "x+y+z", "all"
  String hoverInfo = 'all';

  /// Template string used for rendering the information that appear on hover
  /// box. Note that this will override `hoverinfo`. Variables are inserted
  /// using %{variable}, for example "y: %{y}" as well as %{xother}, {%_xother},
  /// {%_xother_}, {%xother_}. When showing info for several points, "xother"
  /// will be added to those with different x positions from the first point.
  /// An underscore before or after "(x|y)other" will add a space on that side,
  /// only when this field is shown. Numbers are formatted using d3-format's
  /// syntax %{variable:d3-format}, for example "Price: %{y:$.2f}".
  /// https://github.com/d3/d3-format/tree/v1.4.5#d3-format for details on the
  /// formatting syntax. Dates are formatted using d3-time-format's syntax
  /// %{variable|d3-time-format}, for example "Day: %{2019-01-01|%A}".
  /// https://github.com/d3/d3-time-format/tree/v2.2.3#locale_format for
  /// details on the date formatting syntax. The variables available in
  /// `hovertemplate` are the ones emitted as event data described at this
  /// link https://plotly.com/javascript/plotlyjs-events/#event-data.
  /// Additionally, every attributes that can be specified per-point (the ones
  /// that are `arrayOk: true`) are available. Anything contained in tag
  /// `<extra>` is displayed in the secondary box, for example
  /// "<extra>{fullData.name}</extra>". To hide the secondary box completely,
  /// use an empty tag `<extra></extra>`.
  List<String>? hoverTemplate;

  /// Sets the hover text formatting rulefor `x` using d3 formatting
  /// mini-languages which are very similar to those in Python. For numbers,
  /// see: https://github.com/d3/d3-format/tree/v1.4.5#d3-format. And for dates
  /// see: https://github.com/d3/d3-time-format/tree/v2.2.3#locale_format. We
  /// add two items to d3's date formatter: "%h" for half of the year as a
  /// decimal number as well as "%{n}f" for fractional seconds with n digits.
  /// For example, "2016-10-13 09:15:23.456" with tickformat "%H~%M~%S.%2f"
  /// would display "09~15~23.46"By default the values are formatted using
  /// `xaxis.hoverformat`.
  String? xHoverFormat;

  /// Sets the hover text formatting rulefor `y` using d3 formatting
  /// mini-languages which are very similar to those in Python. For numbers,
  /// see: https://github.com/d3/d3-format/tree/v1.4.5#d3-format. And for dates
  /// see: https://github.com/d3/d3-time-format/tree/v2.2.3#locale_format. We
  /// add two items to d3's date formatter: "%h" for half of the year as a
  /// decimal number as well as "%{n}f" for fractional seconds with n digits.
  /// For example, "2016-10-13 09:15:23.456" with tickformat "%H~%M~%S.%2f"
  /// would display "09~15~23.46"By default the values are formatted using
  /// `yaxis.hoverformat`.
  String? yHoverFormat;

  /// Assigns extra meta information associated with this trace that can be
  /// used in various text attributes. Attributes such as trace `name`, graph,
  /// axis and colorbar `title.text`, annotation `text` `rangeselector`,
  /// `updatemenues` and `sliders` `label` text all support `meta`. To access
  /// the trace `meta` values in an attribute in the same trace, simply use
  /// `%{meta[i]}` where `i` is the index or key of the `meta` item in question.
  /// To access trace `meta` in layout attributes, use `%{data[n[.meta[i]}`
  /// where `i` is the index or key of the `meta` and `n` is the trace index.
  String? meta;

  /// Assigns extra data each datum. This may be useful when listening to hover,
  /// click and selection events. Note that, "scatter" traces also appends
  /// customdata items in the markers DOM elements.
  List? customData;

  /// Sets a reference between this trace's x coordinates and a 2D cartesian x
  /// axis. If "x" (the default value), the x coordinates refer to
  /// `layout.xaxis`. If "x2", the x coordinates refer to `layout.xaxis2`,
  /// and so on.
  String xAxis = 'x';

  /// Sets a reference between this trace's y coordinates and a 2D cartesian y
  /// axis. If "y" (the default value), the y coordinates refer to
  /// `layout.yaxis`. If "y2", the y coordinates refer to `layout.yaxis2`,
  /// and so on.
  String yAxis = 'y';

  /// Only relevant in the following cases: 1. when `scattermode` is set to
  /// "group". 2. when `stackgroup` is used, and only the first `orientation`
  /// found in the `stackgroup` will be used - including if `visible` is
  /// "legendonly" but not if it is `false`. Sets the stacking direction.
  /// With "v" ("h"), the y (x) values of subsequent traces are added. Also
  /// affects the default value of `fill`.
  PlotlyOrientation? orientation;

  /// Only relevant when `stackgroup` is used, and only the first `groupnorm`
  /// found in the `stackgroup` will be used - including if `visible` is
  /// "legendonly" but not if it is `false`. Sets the normalization for the
  /// sum of this `stackgroup`. With "fraction", the value of each trace at
  /// each location is divided by the sum of all trace values at that location.
  /// "percent" is the same but multiplied by 100 to show percentages. If there
  /// are multiple subplots, or multiple `stackgroup`s on one subplot, each will
  /// be normalized within its own set.
  PlotlyGroupNorm? groupNorm;

  /// Set several traces linked to the same position axis or matching axes to
  /// the same alignmentgroup. This controls whether bars compute their
  /// positional range dependently or independently.
  String? alignmentGroup;

  /// Set several traces linked to the same position axis or matching axes to
  /// the same offsetgroup where bars of the same position coordinate will
  /// line up.
  String? offsetGroup;

  /// Set several scatter traces (on the same subplot) to the same stackgroup in
  /// order to add their y values (or their x values if `orientation` is "h").
  /// If blank or omitted this trace will not be stacked. Stacking also turns
  /// `fill` on by default, using "tonexty" ("tonextx") if `orientation` is "h"
  /// ("v") and sets the default `mode` to "lines" irrespective of point count.
  /// You can only stack on a numeric (linear or log) axis. Traces in a
  /// `stackgroup` will only fill to (or be filled to) other traces in the same
  /// group. With multiple `stackgroup`s or some traces stacked and some not,
  /// if fill-linked traces are not already consecutive, the later ones will be
  /// pushed down in the drawing order.
  String? stackGroup;

  /// Type: number or categorical coordinate string
  /// Only relevant when the axis `type` is "date". Sets the period positioning
  /// in milliseconds or "M<n>" on the x axis. Special values in the form of
  /// "M<n>" could be used to declare the number of months. In this case `n`
  /// must be a positive integer.
  Object? xPeriod;

  /// Only relevant when the axis `type` is "date". Sets the alignment of data
  /// points on the x axis.
  PlotlyAlignment? xPeriodAlignment;

  /// Type: number or categorical coordinate string
  /// Only relevant when the axis `type` is "date". Sets the base for period
  /// positioning in milliseconds or date string on the x0 axis. When `x0period`
  /// is round number of weeks, the `x0period0` by default would be on a Sunday
  /// i.e. 2000-01-02, otherwise it would be at 2000-01-01.
  Object? xPeriod0;

  /// Type: number or categorical coordinate string
  /// Only relevant when the axis `type` is "date". Sets the period positioning
  /// in milliseconds or "M<n>" on the y axis. Special values in the form of
  /// "M<n>" could be used to declare the number of months. In this case `n`
  /// must be a positive integer.
  Object? yPeriod;

  /// Only relevant when the axis `type` is "date". Sets the alignment of data
  /// points on the x axis.
  PlotlyAlignment? yPeriodAlignment;

  /// Type: number or categorical coordinate string
  /// Only relevant when the axis `type` is "date". Sets the base for period
  /// positioning in milliseconds or date string on the y0 axis. When `y0period`
  /// is round number of weeks, the `y0period0` by default would be on a Sunday
  /// i.e. 2000-01-02, otherwise it would be at 2000-01-01.
  Object? yPeriod0;

  static ScatterTrace fromJson(Map<String, dynamic> x) {
    late ScatterTrace trace;
    if (x
        case {
          'x': List _x,
          'y': List<num> _y,
          'type': 'scatter',
        }) {
      trace = ScatterTrace(x: _x, y: _y);
      if (x.containsKey('name')) trace.name = x['name'];
      if (x.containsKey('visible')) trace.visible = x['visible'];
      if (x.containsKey('showlegend')) trace.showLegend = x['showlegend'];
      if (x.containsKey('legend')) trace.legend = x['showlegend'];
      if (x.containsKey('legendgrouptitle')) {
        trace.legendGroupTitle =
            PlotlyLegendGroupTitle.fromJson(x['legendgrouptitle']);
      }
      if (x.containsKey('legendwidth')) {
        trace.legendWidth = x['legendwidth'];
        assert(trace.legendWidth! > 0);
      }
      if (x.containsKey('opacity')) trace.opacity = x['opacity'];
      if (x.containsKey('mode')) {
        if (!isValidMode(x['mode'])) {
          throw ArgumentError('Invalid scatter trace mode ${x['mode']}');
        }
        trace.mode = x['mode'];
      }
      if (x.containsKey('ids')) trace.ids = x['ids'];
      if (x.containsKey('x0')) trace.x0 = x['x0'];
      if (x.containsKey('dx')) trace.dx = x['dx'];
      if (x.containsKey('y0')) trace.x0 = x['y0'];
      if (x.containsKey('dy')) trace.dx = x['dy'];
      if (x.containsKey('text')) {
        if (x['text'] is String) {
          trace.text = [x['text']];
        } else if (x['text'] is List) {
          trace.text = x['text'];
          assert(trace.x.length == trace.text!.length);
        } else {
          throw ArgumentError(
              'The input for the field "text" can only be a String or a List<String>.');
        }
      }
      if (x.containsKey('textposition')) {
        if (x['textposition'] is String) {
          trace.textPosition = [PlotlyTextPosition.parse(x['text'])];
        } else if (x['textposition'] is List) {
          trace.textPosition = (x['textposition'] as List)
              .map((e) => PlotlyTextPosition.parse(e))
              .toList();
          assert(trace.x.length == trace.textPosition!.length);
        } else {
          throw ArgumentError(
              'The input for the field "textposition" can only be a String or a List<String>.');
        }
      }
      if (x.containsKey('texttemplate')) {
        if (x['texttemplate'] is String) {
          trace.textTemplate = [x['texttemplate']];
        } else if (x['texttemplate'] is List) {
          trace.textTemplate = x['texttemplate'];
          assert(trace.x.length == trace.textTemplate!.length);
        } else {
          throw ArgumentError(
              'The input for the field "texttemplate" can only be a String or a List<String>.');
        }
      }
      if (x.containsKey('hovertext')) {
        if (x['hovertext'] is String) {
          trace.hoverText = [x['hovertext']];
        } else if (x['hovertext'] is List) {
          trace.hoverText = x['hovertext'];
          assert(trace.x.length == trace.hoverText!.length);
        } else {
          throw ArgumentError(
              'The input for the field "hovertext" can only be a String or a List<String>.');
        }
      }
      if (x.containsKey('hoverinfo')) {
        if (!isValidHoverInfo(x['hoverinfo'])) {
          throw ArgumentError('Invalid hoverinfo ${x['mode']}');
        }
        trace.hoverInfo = x['hoverinfo'];
      }
      if (x.containsKey('hovertemplate')) {
        if (x['hovertemplate'] is String) {
          trace.hoverTemplate = [x['hovertemplate']];
        } else if (x['hovertemplate'] is List) {
          trace.hoverTemplate = x['hovertemplate'];
          assert(trace.x.length == trace.hoverTemplate!.length);
        } else {
          throw ArgumentError(
              'The input for the field "hovertemplate" can only be a String or a List<String>.');
        }
      }
      if (x.containsKey('xhoverformat')) trace.xHoverFormat = x['xhoverformat'];
      if (x.containsKey('yhoverformat')) trace.yHoverFormat = x['yhoverformat'];
      if (x.containsKey('meta')) trace.meta = x['meta'];
      if (x.containsKey('customdata')) {
        trace.customData = x['customdata'];
        assert(trace.x.length == trace.customData!.length);
      }
      if (x.containsKey('xaxis')) trace.xAxis = x['xaxis'];
      if (x.containsKey('yaxis')) trace.yAxis = x['yaxis'];
      if (x.containsKey('orientation')) {
        trace.orientation = PlotlyOrientation.parse(x['orientation']);
      }
      if (x.containsKey('groupnorm')) {
        trace.groupNorm = PlotlyGroupNorm.parse(x['groupnorm']);
      }
      if (x.containsKey('alignmentgroup')) {
        trace.alignmentGroup = x['alignmentgroup'];
      }
      if (x.containsKey('offsetgroup')) trace.offsetGroup = x['offsetgroup'];
      if (x.containsKey('stackgroup')) trace.stackGroup = x['stackgroup'];
      if (x.containsKey('xperiod')) trace.xPeriod = x['xperiod'];
      if (x.containsKey('xperiod0')) trace.xPeriod0 = x['xperiod0'];
      if (x.containsKey('xperiodalignment')) {
        trace.xPeriodAlignment = x['xperiodalignment'];
      }
      if (x.containsKey('yperiod')) trace.yPeriod = x['yperiod'];
      if (x.containsKey('yperiod0')) trace.yPeriod0 = x['yperiod0'];
      if (x.containsKey('yperiodalignment')) {
        trace.yPeriodAlignment = x['yperiodalignment'];
      }
    } else {
      throw ArgumentError(
          'Input $x is not a correctly formatted Polygraph project');
    }

    return trace;
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'x': x,
      'y': y,
      'type': 'scatter',
      if (name != null) 'name': name,
      if (visible != TraceVisibility.on) 'visibility': visible.toString(),
      if (!showLegend) 'showlegend': showLegend,
      if (legend != 'legend') 'legend': legend,
      if (legendRank != 1000) 'legendrank': legendRank,
      if (legendGroup != '') 'legendgroup': legendGroup,
      if (opacity != 1) 'opacity': opacity,
      if (mode != null) 'mode': mode,
      if (ids != null) 'ids': ids,
      if (x0 != 0) 'x0': x0,
      if (dx != 1) 'dx': dx,
      if (y0 != 0) 'y0': y0,
      if (dy != 1) 'dy': dy,
      if (text != null) 'text': text!.length == 1 ? text!.first : text,
      if (textPosition != null)
        'textposition':
            textPosition!.length == 1 ? textPosition!.first : textPosition,
      if (textTemplate != null)
        'texttemplate':
            textTemplate!.length == 1 ? textTemplate!.first : textTemplate,
      if (hoverText != null)
        'hovertext': hoverText!.length == 1 ? hoverText!.first : hoverText,
      if (hoverInfo != 'all') 'hoverinfo': hoverInfo,
      if (hoverTemplate != null)
        'hovertemplate':
            hoverTemplate!.length == 1 ? hoverTemplate!.first : hoverTemplate,
      if (xHoverFormat != null) 'xhoverformat': xHoverFormat,
      if (xHoverFormat != null) 'yhoverformat': xHoverFormat,
      if (meta != null) 'meta': meta,
      if (groupNorm != null) 'groupnorm': groupNorm.toString(),
      if (alignmentGroup != null) 'alignmentgroup': alignmentGroup,
      if (offsetGroup != null) 'offsetgroup': offsetGroup,
      if (stackGroup != null) 'stackgroup': stackGroup,
      if (xPeriod != null) 'xperiod': xPeriod.toString(),
      if (xPeriodAlignment != null)
        'xperiodalignment': xPeriodAlignment.toString(),
      if (xPeriod0 != null) 'xperiod0': xPeriod0.toString(),
      if (yPeriod != null) 'yperiod': yPeriod.toString(),
      if (yPeriodAlignment != null)
        'yperiodalignment': yPeriodAlignment.toString(),
      if (yPeriod0 != null) 'yperiod0': yPeriod0.toString(),



    };
  }

  static bool isValidMode(String mode) {
    const basic = {
      'lines',
      'markers',
      'text',
      'lines+markers',
      'lines+text',
      'markers+text',
      'lines+markers+text',
      'none',
    };
    if (basic.contains(mode)) {
      return true;
    } else {
      return false;
    }
  }

  static bool isValidHoverInfo(String value) {
    const basicPlus = {
      'x',
      'y',
      'z',
      'text',
      'name',
    };
    const other = {
      'all',
      'none',
      'skip',
    };
    if (value.contains('+')) {
      var parts = value.split('+');
      if (parts.length == parts.toSet().length &&
          basicPlus.containsAll(parts)) {
        return true;
      } else {
        return false;
      }
    } else {
      if (other.contains(value)) {
        return true;
      } else {
        return false;
      }
    }
  }
}

enum TraceVisibility {
  on('true'),
  off('false'),
  legendOnly('legendonly');

  const TraceVisibility(this._value);
  final String _value;

  static TraceVisibility parse(String value) {
    return switch (value) {
      'true' => on,
      'false' => off,
      'legendonly' => legendOnly,
      _ => throw ArgumentError('Can\'t parse $value as a TraceVisibility')
    };
  }

  @override
  String toString() => _value;
}
