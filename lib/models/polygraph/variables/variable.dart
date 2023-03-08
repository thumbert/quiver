library models.polygraph.variables.variable;

import 'package:date/date.dart';
import 'package:flutter_quiver/models/polygraph/transforms/transform.dart';
import 'package:flutter_quiver/models/polygraph/variables/slope_intercept_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_display_config.dart';
import 'package:timeseries/timeseries.dart';
import 'package:flutter/material.dart' hide Transform;

mixin PolygraphVariable {
  ///
  late final String name;

  /// Internal representation used for the cache key
  // String id();

  /// What gets applied to this variable
  final transforms = <Transform>[];

  /// Data that gets displayed on the screen after all the transforms are
  /// applied.  This method will access the cache except for trivial variables
  /// like [SlopeInterceptVariable].
  TimeSeries<num> timeSeries(Term term);

  /// What gets displayed on the screen
  String label();
  bool isMouseOver = false;
  /// Should the variable be displayed on the plot?
  bool isHidden = false;
  Color? color;

  /// For the yAxis only.  If you want it displayed on the right,
  /// set [axisPosition] to 'right'.
  String? axisPosition;



  /// Customize the display on the screen
  VariableDisplayConfig? displayConfig;

  /// How it's going to be persisted to the database
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

  @override
  TimeSeries<num> timeSeries(Term term) {
    // TODO: implement timeSeries
    throw UnimplementedError();
  }
}




