library models.polygraph.display.plotly_margins;

class PlotlyMargin {
  PlotlyMargin();

  /// Turns on/off margin expansion computations. Legends, colorbars,
  /// updatemenus, sliders, axis rangeselector and rangeslider are allowed to
  /// push the margins by defaults.
  bool autoexpand = true;
  num _bottom = defaultBottomPx;
  num _left = defaultLeftPx;
  num _right = defaultRightPx;
  num _top = defaultTopPx;  // it's 100 in Plotly
  num _pad = 0;

  static const num defaultBottomPx = 80;
  static const num defaultLeftPx = 80;
  static const num defaultRightPx = 80;
  static const num defaultTopPx = 80;

  static PlotlyMargin fromJson(Map<String,dynamic> x) {
    var margin = PlotlyMargin();
    if (x.containsKey('autoexpand')) {
      margin.autoexpand = x['autoexpand'];
    }
    if (x.containsKey('b')) {
      margin.bottom = x['b'] as num;
    }
    if (x.containsKey('l')) {
      margin.left = x['l'] as num;
    }
    if (x.containsKey('r')) {
      margin.right = x['r'] as num;
    }
    if (x.containsKey('t')) {
      margin.top = x['t'] as num;
    }
    if (x.containsKey('pad')) {
      margin.pad = x['pad'] as num;
    }
    return margin;
  }

  Map<String,dynamic> toJson() {
    return <String,dynamic> {
      if (!autoexpand) 'autoexpand': true,
      if (bottom != 80) 'b': bottom,
      if (left != 80) 'l': left,
      if (right != 80) 'r': right,
      if (top != 100) 't': top,
      if (pad != 0) 'pad': pad,
    };
  }

  /// Set the bottom margin (in px.)
  set bottom(num value) {
    if (value < 0) {
      throw ArgumentError('Only values >= 0 are valid.');
    }
    _bottom = value;
  }
  num get bottom => _bottom;

  /// Set the left margin (in px.)
  set left(num value) {
    if (value < 0) {
      throw ArgumentError('Only values >= 0 are valid.');
    }
    _left = value;
  }
  num get left => _left;

  /// Set the right margin (in px.)
  set right(num value) {
    if (value < 0) {
      throw ArgumentError('Only values >= 0 are valid.');
    }
    _right = value;
  }
  num get right => _right;

  /// Set the top margin (in px.)
  set top(num value) {
    if (value < 0) {
      throw ArgumentError('Only values >= 0 are valid.');
    }
    _top = value;
  }
  num get top => _top;

  /// Set the amount of padding (in px.) between the the plotting area and the
  /// axes,
  set pad(num value) {
    if (value < 0) {
      throw ArgumentError('Only values >= 0 are valid.');
    }
    _pad = value;
  }
  num get pad => _pad;
}