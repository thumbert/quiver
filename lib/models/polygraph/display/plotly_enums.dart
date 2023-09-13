library models.polygraph.display.plotly_enums;


enum PlotlyAlignment {
  start('start'),
  middle('middle'),
  end('end');

  const PlotlyAlignment(this._value);
  final String _value;

  static PlotlyAlignment parse(String value) {
    return switch (value) {
      'start' => PlotlyAlignment.start,
      'middle' => PlotlyAlignment.middle,
      'end' => PlotlyAlignment.end,
      _ => throw ArgumentError('Invalid value $value for PlotlyAlignment'),
    };
  }

  @override
  String toString() => _value;
}

enum PlotlyAngleRef {
  previous,
  up;

  static PlotlyAngleRef parse(String value) {
    return switch (value) {
      'previous' => PlotlyAngleRef.previous,
      'up' => PlotlyAngleRef.up,
      _ => throw ArgumentError('Invalid value $value for PlotlyAngleRef'),
    };
  }
}

/// Determines a formatting rule for the tick exponents. For example, consider
/// the number 1,000,000,000. If "none", it appears as 1,000,000,000. If "e",
/// 1e+9. If "E", 1E+9. If "power", 1x10^9 (with 9 in a super script).
/// If "SI", 1G. If "B", 1B.
enum PlotlyExponentFormat {
  none('none'),
  e('e'),
  E('E'),
  power('power'),
  internationalSystemOfUnits('SI'),
  B('B');

  const PlotlyExponentFormat(this._value);
  final String _value;

  static PlotlyExponentFormat parse(String value) {
    return switch (value) {
      'none' => PlotlyExponentFormat.none,
      'e' => PlotlyExponentFormat.e,
      'E' => PlotlyExponentFormat.E,
      'power' => PlotlyExponentFormat.power,
      'SI' => PlotlyExponentFormat.internationalSystemOfUnits,
      'B' => PlotlyExponentFormat.B,
      _ => throw ArgumentError('Invalid value $value for PlotlyExponentFormat'),
    };
  }

  @override
  String toString() => _value;
}



enum PlotlyGroupNorm {
  none(''),
  fraction('fraction'),
  percent('percent');

  const PlotlyGroupNorm(this._value);
  final String _value;

  static PlotlyGroupNorm parse(String value) {
    return switch (value) {
      '' => PlotlyGroupNorm.none,
      'fraction' => PlotlyGroupNorm.fraction,
      'percent' => PlotlyGroupNorm.percent,
      _ => throw ArgumentError('Invalid value $value for PlotlyGroupNorm'),
    };
  }

  @override
  String toString() => _value;
}


enum PlotlyLenMode {
  fraction,
  pixels;

  static PlotlyLenMode parse(String value) {
    return switch (value) {
      'fraction' => PlotlyLenMode.fraction,
      'pixels' => PlotlyLenMode.pixels,
      _ => throw ArgumentError('Invalid value $value for PlotlyLenMode'),
    };
  }
}


enum PlotlyShowExponent {
  all,
  first,
  last,
  none;

  static PlotlyShowExponent parse(String value) {
    return switch (value) {
      'all' => PlotlyShowExponent.all,
      'first' => PlotlyShowExponent.first,
      'last' => PlotlyShowExponent.last,
      'none' => PlotlyShowExponent.none,
      _ => throw ArgumentError('Invalid value $value for PlotlyShowExponent'),
    };
  }
}

