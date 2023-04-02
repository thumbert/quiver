library models.polygraph.variables.variable;

import 'package:date/date.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service.dart';
import 'package:flutter_quiver/models/polygraph/transforms/transform.dart';
import 'package:flutter_quiver/models/polygraph/variables/slope_intercept_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_display_config.dart';
import 'package:timeseries/timeseries.dart';
import 'package:flutter/material.dart' hide Transform;


abstract class PolygraphVariable {
  /// Internal representation used for the cache key
  late final String id;

  /// If true, it needs refresh
  bool isDirty = true;

  /// What gets displayed on the screen
  late String label;

  /// What to show on the screen regarding this variable.
  String error = '';


  /// What gets applied to this variable
  final transforms = <Transform>[];


  bool isMouseOver = false;
  /// Should the variable be displayed on the plot?
  bool isHidden = false;
  Color? color;

  /// For the yAxis only.  If you want it displayed on the right,
  /// set [axisPosition] to 'right'.
  String? axisPosition;
  
  /// Customize the display on the screen
  VariableDisplayConfig? displayConfig;

  /// How to get the data in the Tab cache
  Future<TimeSeries<num>> get(DataService service, Term term);

  /// How it's going to be persisted to the database
  Map<String,dynamic> toMongo();

  PolygraphVariable fromMongo(Map<String,dynamic> x);
}






