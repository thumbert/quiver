library models.polygraph.display.plotly_layout;

import 'plotly_title.dart';

class PlotlyLayout {
  PlotlyLayout({
    required this.width,
    required this.height,
    this.legend,
    this.title,
    this.xAxis,
    this.yAxis,
    this.hoverMode,
  });

  final num width;
  final num height;

  bool displayLogo = false;
  HoverMode? hoverMode;
  bool showLegend = true;

  PlotlyLegend? legend;
  PlotlyTitle? title;
  PlotlyXAxis? xAxis;
  PlotlyYAxis? yAxis;

  static PlotlyLayout getDefault({required num width, required num height}) =>
      PlotlyLayout(width: width, height: height);

  /// Construct a layout object from storage
  static PlotlyLayout fromMap(Map<String, dynamic> x) {
    var layout = PlotlyLayout(width: x['width'], height: x['height']);
    if (x.containsKey('hovermode')) {
      layout.hoverMode = HoverMode.parse(x['hovermode']);
    }
    if (x.containsKey('showlegend')) layout.showLegend = x['showlegend'];
    if (x.containsKey('title')) layout.title = PlotlyTitle.fromMap(x['title']);
    if (x.containsKey('xaxis')) layout.xAxis = PlotlyXAxis.fromMap(x['xaxis']);
    if (x.containsKey('yaxis')) layout.yAxis = PlotlyYAxis.fromMap(x['yaxis']);
    if (x.containsKey('displaylogo')) layout.displayLogo = x['displaylogo'];
    return layout;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'width': width,
      'height': height,
      if (hoverMode != null) 'hovermode': hoverMode.toString(),
      if (!showLegend) 'showlegend': showLegend,
      if (legend != null) 'legend': legend!.toMap(),
      if (title != null) 'title': title!.toMap(),
      if (xAxis != null) 'xaxis': xAxis!.toMap(),
      if (yAxis != null) 'yaxis': yAxis!.toMap(),
      'displaylogo': displayLogo,
    };
  }

  PlotlyLayout copyWith(
      {num? width,
        num? height,
        PlotlyTitle? title,
        PlotlyXAxis? xAxis,
        PlotlyYAxis? yAxis,
        PlotlyLegend? legend,
        bool? showLegend,
        HoverMode? hoverMode}) {
    return PlotlyLayout(
        width: width ?? this.width, height: height ?? this.height)
      ..title = title ?? this.title
      ..xAxis = xAxis ?? this.xAxis
      ..yAxis = yAxis ?? this.yAxis
      ..legend = legend ?? this.legend
      ..showLegend = showLegend ?? this.showLegend
      ..hoverMode = hoverMode ?? this.hoverMode;
  }
}


class AnchorXAxis {
  const AnchorXAxis._internal(this._value);
  final String _value;

  static const free = AnchorXAxis._internal('free');
  static const x = AnchorXAxis._internal('x');
  static const x2 = AnchorXAxis._internal('x2');
  static const x3 = AnchorXAxis._internal('x3');
  static const x4 = AnchorXAxis._internal('x4');

  factory AnchorXAxis.parse(String value) {
    var mode = _map[value];
    if (mode == null) {
      throw StateError('Don\'t know how to parse $value as axis x anchor.');
    }
    return mode;
  }

  static const _map = {
    'free': AnchorXAxis.free,
    'x': AnchorXAxis.x,
    'x2': AnchorXAxis.x2,
    'x3': AnchorXAxis.x3,
    'x4': AnchorXAxis.x4,
  };

  static final values = <String>[
    'free',
    'x',
    'x2',
    'x3',
    'x4',
  ];

  @override
  String toString() => _value;
}

class AnchorYAxis {
  const AnchorYAxis._internal(this._value);
  final String _value;

  static const free = AnchorYAxis._internal('free');
  static const y = AnchorYAxis._internal('y');
  static const y2 = AnchorYAxis._internal('y2');
  static const y3 = AnchorYAxis._internal('y3');
  static const y4 = AnchorYAxis._internal('y4');

  factory AnchorYAxis.parse(String value) {
    var mode = _map[value];
    if (mode == null) {
      throw StateError('Don\'t know how to parse $value as axis y anchor.');
    }
    return mode;
  }

  static const _map = {
    'free': AnchorYAxis.free,
    'y': AnchorYAxis.y,
    'y2': AnchorYAxis.y2,
    'y3': AnchorYAxis.y3,
    'y4': AnchorYAxis.y4,
  };

  static final values = <String>[
    'free',
    'y',
    'y2',
    'y3',
    'y4',
  ];

  @override
  String toString() => _value;
}

class AnchorXTitle {
  const AnchorXTitle._internal(this._value);
  final String _value;

  static const auto = AnchorXTitle._internal('auto');
  static const left = AnchorXTitle._internal('left');
  static const center = AnchorXTitle._internal('center');
  static const right = AnchorXTitle._internal('right');

  factory AnchorXTitle.parse(String value) {
    var mode = _map[value];
    if (mode == null) {
      throw StateError('Don\'t know how to parse $value as a title x anchor.');
    }
    return mode;
  }

  @override
  String toString() => _value;

  static const _map = {
    'auto': AnchorXTitle.auto,
    'center': AnchorXTitle.center,
    'right': AnchorXTitle.right,
    'left': AnchorXTitle.left,
  };

  static final values = <String>['auto', 'center', 'right', 'left'];
}

class AnchorYTitle {
  const AnchorYTitle._internal(this._value);
  final String _value;

  static const auto = AnchorYTitle._internal('auto');
  static const top = AnchorYTitle._internal('top');
  static const middle = AnchorYTitle._internal('middle');
  static const bottom = AnchorYTitle._internal('bottom');

  factory AnchorYTitle.parse(String value) {
    var mode = _values[value];
    if (mode == null) {
      throw StateError('Don\'t know how to parse $value as a title y anchor.');
    }
    return mode;
  }

  @override
  String toString() => _value;

  static final _values = {
    'auto': AnchorYTitle.auto,
    'middle': AnchorYTitle.middle,
    'bottom': AnchorYTitle.bottom,
    'top': AnchorYTitle.top,
  };
}

enum AutoTypeNumbers {
  convertTypes('convert types'),
  strict('strict');

  const AutoTypeNumbers(this._value);

  final String _value;

  @override
  String toString() => _value;
}

class AxisLayer {
  const AxisLayer._internal(this._value);
  final String _value;

  static const aboveTraces = AxisLayer._internal('above traces');
  static const belowTraces = AxisLayer._internal('below traces');

  factory AxisLayer.parse(String value) {
    var layer = _map[value];
    if (layer == null) {
      throw StateError('Don\'t know how to parse $value as an axis layer');
    }
    return layer;
  }

  static final _map = {
    'above traces': AxisLayer.aboveTraces,
    'below traces': AxisLayer.belowTraces,
  };

  static const values = <String>['above traces', 'below traces'];

  @override
  String toString() => _value;
}

class AxisType {
  const AxisType._internal(this._value);
  final String _value;

  static const theDefault = AxisType._internal('-');
  static const linear = AxisType._internal('linear');
  static const log = AxisType._internal('log');
  static const date = AxisType._internal('date');
  static const category = AxisType._internal('category');
  static const multiCategory = AxisType._internal('multicategory');

  static AxisType parse(String value) {
    var type = _map[value];
    if (type == null) {
      throw StateError('Don\'t know how to parse $value as an axis type');
    }
    return type;
  }

  static const _map = {
    '-': AxisType.theDefault,
    'linear': AxisType.linear,
    'log': AxisType.log,
    'date': AxisType.date,
    'category': AxisType.category,
    'multicategory': AxisType.multiCategory,
  };

  static const values = <String>[
    '-',
    'linear',
    'log',
    'date',
    'category',
    'multicategory'
  ];

  @override
  String toString() => _value;
}

class DashStyle {
  const DashStyle._internal(this._value);
  final String _value;

  static const solid = DashStyle._internal('solid');
  static const dash = DashStyle._internal('dash');
  static const dashDot = DashStyle._internal('dashdot');
  static const longDash = DashStyle._internal('longdash');
  static const longDashDot = DashStyle._internal('longdashdot');

  factory DashStyle.parse(String value) {
    var mode = _map[value];
    if (mode == null) {
      throw StateError('Don\'t know how to parse $value as a hovermode');
    }
    return mode;
  }

  static final _map = {
    'solid': DashStyle.solid,
    'dash': DashStyle.dash,
    'dashdot': DashStyle.dashDot,
    'longdash': DashStyle.longDash,
    'longdashdot': DashStyle.longDashDot,
  };

  static const List<String> values = [
    'solid',
    'dash',
    'dashdot',
    'longdash',
    'longdashdot'
  ];

  @override
  String toString() => _value;
}

class HoverMode {
  const HoverMode._internal(this._mode);
  final String _mode;

  static const x = HoverMode._internal('x');
  static const y = HoverMode._internal('y');
  static const closest = HoverMode._internal('closest');
  static const xUnified = HoverMode._internal('x unified');
  static const yUnified = HoverMode._internal('y unified');

  factory HoverMode.parse(String value) {
    var mode = _hoverModes[value];
    if (mode == null) {
      throw StateError('Don\'t know how to parse $value as a hovermode');
    }
    return mode;
  }

  @override
  String toString() => _mode;

  static const values = <String>['closest', 'x', 'x unified', 'y', 'y unified'];

  static final _hoverModes = {
    'closest': HoverMode.closest,
    'x': HoverMode.x,
    'x unified': HoverMode.xUnified,
    'y': HoverMode.y,
    'y unified': HoverMode.yUnified,
  };
}

enum LegendToggleOption {
  toggle,
  toggleOthers,
  none,
}

enum LegendOrientation {
  vertical('v'),
  horizontal('h');

  const LegendOrientation(this._orientation);

  final String _orientation;

  @override
  String toString() => _orientation;
}

class RefPosition {
  final String _value;
  const RefPosition._internal(this._value);

  factory RefPosition.parse(String x) {
    if (x != 'container' && x != 'paper') {
      throw ArgumentError('Can\'t parse $x for reference position.');
    }
    return x == 'container' ? container : paper;
  }

  static const container = RefPosition._internal('container');
  static const paper = RefPosition._internal('paper');

  static const List<String> values = ['container', 'paper'];

  @override
  String toString() => _value;
}

class SideX {
  const SideX._internal(this._value);
  final String _value;

  static const top = SideX._internal('top');
  static const bottom = SideX._internal('bottom');

  factory SideX.parse(String x) {
    if (x != 'top' && x != 'bottom') {
      throw ArgumentError('Can\'t parse $x for side x axis position.');
    }
    return x == 'top' ? top : bottom;
  }

  static const List<String> values = ['top', 'bottom'];

  @override
  String toString() => _value;
}

enum SideY {
  left('left'),
  right('right');

  const SideY(this._value);

  final String _value;

  @override
  String toString() => _value;
}

enum TicksPosition {
  inside('inside'),
  outside('outside'),
  none('');

  const TicksPosition(this._value);

  final String _value;

  @override
  String toString() => _value;
}

enum TickMode {
  auto('auto'),
  linear('linear'),
  array('array'),
  sync('sync');

  const TickMode(this._value);

  final String _value;

  @override
  String toString() => _value;
}

class PlotlyLegend {
  PlotlyLegend();

  LegendOrientation orientation = LegendOrientation.horizontal;
  LegendToggleOption itemClick = LegendToggleOption.toggle;
  LegendToggleOption itemDoubleClick = LegendToggleOption.toggleOthers;

  static PlotlyLegend getDefault() {
    return PlotlyLegend();
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (orientation != LegendOrientation.vertical)
        'orientation': orientation.toString(),
    };
  }
}

class PlotlyFont {
  String? color;
  String? family;
  int? size;

  static PlotlyFont fromMap(Map<String, dynamic> x) {
    var font = PlotlyFont();
    if (x.containsKey('color')) font.color = x['color'];
    if (x.containsKey('family')) font.family = x['family'];
    if (x.containsKey('size')) font.size = x['size'];
    return font;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (color != null) 'color': color,
      if (family != null) 'family': family,
      if (size != null) 'size': size,
    };
  }
}

class PlotlyAxisTitle {
  String? text;
  num? standoff;
  PlotlyFont? font;

  static PlotlyAxisTitle fromMap(Map<String, dynamic> x) {
    var title = PlotlyAxisTitle();
    if (x.containsKey('text')) title.text = x['text'];
    if (x.containsKey('standoff')) title.standoff = x['standoff'];
    if (x.containsKey('font')) title.font = PlotlyFont.fromMap(x['font']);
    return title;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (text != '') 'text': text,
      if (standoff != null) 'standoff': standoff,
      if (font != null) 'font': font!.toMap(),
    };
  }
}

class PlotlyXAxis {
  PlotlyXAxis();

  AnchorXAxis? anchor;
  String? color;
  String gridColor = '#eee';
  DashStyle? gridDash;
  int gridWidth = 1;
  bool isVisible = true;
  AxisLayer layer = AxisLayer.aboveTraces;
  String lineColor = '#444';
  SideX? side;
  bool showGrid = true;
  bool showZeroLine = false;
  TicksPosition? ticksPosition;
  TickMode? tickMode;
  PlotlyAxisTitle? title;
  AxisType? type;
  String zeroLineColor = '#444';
  int zeroLineWidth = 1;

  static PlotlyXAxis fromMap(Map<String, dynamic> x) {
    var axis = PlotlyXAxis();
    if (x.containsKey('anchor')) axis.anchor = AnchorXAxis.parse(x['anchor']);
    if (x.containsKey('color')) axis.color = x['color'];
    if (x.containsKey('showgrid')) axis.showGrid = x['showgrid'];
    if (x.containsKey('gridcolor')) axis.gridColor = x['gridcolor'];
    if (x.containsKey('griddash')) {
      axis.gridDash = DashStyle.parse(x['griddash']);
    }
    if (x.containsKey('gridwidth')) axis.gridWidth = x['gridwidth'];
    if (x.containsKey('layer')) axis.layer = AxisLayer.parse(x['layer']);
    if (x.containsKey('linecolor')) axis.lineColor = x['linecolor'];
    if (x.containsKey('type')) axis.type = AxisType.parse(x['type']);
    if (x.containsKey('visible')) axis.isVisible = x['visible'];
    if (x.containsKey('zeroline')) axis.showZeroLine = x['zeroline'];

    /// TODO: continue
    if (x.containsKey('title')) {
      axis.title = PlotlyAxisTitle.fromMap(x['title']);
    }
    if (x.containsKey('side')) axis.side = SideX.parse(x['side']);

    return axis;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (anchor != null) 'anchor': anchor.toString(),
      if (color != null) 'color': color,
      if (gridColor != '#eee') 'gridcolor': gridColor,
      if (gridDash != null) 'griddash': gridDash.toString(),
      if (gridWidth != 1) 'gridwidth': gridWidth,
      if (lineColor != '#444') 'linecolor': lineColor,
      if (!isVisible) 'visible': isVisible,
      if (layer != AxisLayer.aboveTraces) 'layer': layer.toString(),
      if (showZeroLine) 'zeroline': showZeroLine,
      if (!showGrid) 'showgrid': showGrid,
      if (side != null) 'side': side.toString(),
      if (ticksPosition != null) 'ticks': ticksPosition.toString(),
      if (tickMode != null) 'tickmode': tickMode.toString(),
      if (title != null) 'title': title!.toMap(),
      if (type != null) 'type': type.toString(),
      if (zeroLineColor != '#444') 'zerolinecolor': zeroLineColor,
      if (zeroLineWidth != 1) 'zerolinewidth': zeroLineWidth,
    };
  }

  PlotlyXAxis copyWith({PlotlyAxisTitle? title}) {
    var axis = PlotlyXAxis()
      ..title = title;
    return axis;
  }


}

class PlotlyYAxis {
  PlotlyYAxis();

  AnchorYAxis? anchor;
  String? color;
  String gridColor = '#eee';
  DashStyle? gridDash;
  int gridWidth = 1;
  bool isVisible = true;
  AxisLayer layer = AxisLayer.aboveTraces;
  String lineColor = '#444';
  SideX? side;
  bool showGrid = true;
  bool showZeroLine = false;
  TicksPosition? ticksPosition;
  TickMode? tickMode;
  PlotlyAxisTitle? title;
  AxisType? type;
  String zeroLineColor = '#444';
  int zeroLineWidth = 1;

  static PlotlyYAxis fromMap(Map<String, dynamic> x) {
    var axis = PlotlyYAxis();
    if (x.containsKey('anchor')) axis.anchor = AnchorYAxis.parse(x['anchor']);
    if (x.containsKey('color')) axis.color = x['color'];
    if (x.containsKey('showgrid')) axis.showGrid = x['showgrid'];
    if (x.containsKey('gridcolor')) axis.gridColor = x['gridcolor'];
    if (x.containsKey('griddash')) {
      axis.gridDash = DashStyle.parse(x['griddash']);
    }
    if (x.containsKey('gridwidth')) axis.gridWidth = x['gridwidth'];
    if (x.containsKey('layer')) axis.layer = AxisLayer.parse(x['layer']);
    if (x.containsKey('linecolor')) axis.lineColor = x['linecolor'];
    if (x.containsKey('type')) axis.type = AxisType.parse(x['type']);
    if (x.containsKey('visible')) axis.isVisible = x['visible'];
    if (x.containsKey('zeroline')) axis.showZeroLine = x['zeroline'];

    /// TODO: continue
    if (x.containsKey('title')) {
      axis.title = PlotlyAxisTitle.fromMap(x['title']);
    }
    if (x.containsKey('side')) axis.side = SideX.parse(x['side']);

    return axis;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      if (anchor != null) 'anchor': anchor.toString(),
      if (color != null) 'color': color,
      if (gridColor != '#eee') 'gridcolor': gridColor,
      if (gridDash != null) 'griddash': gridDash.toString(),
      if (gridWidth != 1) 'gridwidth': gridWidth,
      if (lineColor != '#444') 'linecolor': lineColor,
      if (!isVisible) 'visible': isVisible,
      if (layer != AxisLayer.aboveTraces) 'layer': layer.toString(),
      if (showZeroLine) 'zeroline': showZeroLine,
      if (!showGrid) 'showgrid': showGrid,
      if (side != null) 'side': side.toString(),
      if (ticksPosition != null) 'ticks': ticksPosition.toString(),
      if (tickMode != null) 'tickmode': tickMode.toString(),
      if (title != null) 'title': title!.toMap(),
      if (type != null) 'type': type.toString(),
      if (zeroLineColor != '#444') 'zerolinecolor': zeroLineColor,
      if (zeroLineWidth != 1) 'zerolinewidth': zeroLineWidth,
    };
  }
}