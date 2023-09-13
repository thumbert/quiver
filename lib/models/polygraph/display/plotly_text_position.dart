library models.polygraph.display.plotly_text_position;

enum PlotlyTextPosition {
  bottomCenter('bottom center'),
  bottomLeft('bottom left'),
  bottomRight('bottom right'),

  middleCenter('middle center'),
  middleLeft('middle left'),
  middleRight('middle right'),

  topCenter('top center'),
  topLeft('top left'),
  topRight('top right');

  const PlotlyTextPosition(this._value);
  final String _value;

  static PlotlyTextPosition parse(String value) {
    return switch (value) {
      'bottom center' => bottomCenter,
      'bottom left' => bottomLeft,
      'bottom right' => bottomRight,
      'middle center' => middleCenter,
      'middle left' => middleLeft,
      'middle right' => middleRight,
      'top center' => topCenter,
      'top left' => topLeft,
      'top right' => topRight,
      _ => throw ArgumentError('Can\'t parse $value as a PlotlyTextPosition')
    };
  }

  @override
  String toString() => _value;
}
