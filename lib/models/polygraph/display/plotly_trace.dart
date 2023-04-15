library models.polygraph.display.plotly_trace;

class ScatterTrace {
  ScatterTrace({required this.x, required this.y});

  List<dynamic> x;
  List<num> y;
  String? name;
  TraceVisibility visibility = TraceVisibility.on;
  bool showLegend = true;

  int legendRank = 1000;
  String legendGroup = '';

  Map<String,dynamic> toMap() {
    return <String,dynamic>{
      'x': x,
      'y': y,
      'type': 'scatter',
      if (name != null) 'name': name,
      if (visibility != TraceVisibility.on) 'visibility': visibility.toString(),
      if (!showLegend) 'showlegend': showLegend,
      if (legendRank != 1000) 'legendrank': legendRank,
      if (legendGroup != '') 'legendgroup': legendGroup,
    };
  }
}

enum TraceVisibility {
  on('true'),
  off('false'),
  legendOnly('legendonly');

  const TraceVisibility(this._value);
  final String _value;
  @override
  String toString() => _value;
}