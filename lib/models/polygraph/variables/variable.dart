library models.polygraph.variables.variable;


mixin PolygraphVariable {
  late final String name;
  String label();
  Map<String,dynamic> toJson();
}

class TimeVariable extends Object with PolygraphVariable {
  TimeVariable({this.skipWeekends = false}) {
    name = 'Time';
  }

  bool skipWeekends;

  @override
  Map<String,dynamic> toJson() => {
    'category': 'Time',
    'config': {
      'skipWeekends': skipWeekends,
    }
  };

  @override
  String label() => 'Time';
}




