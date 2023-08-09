library models.polygraph.variables.variable;

import 'package:date/date.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_variable.dart';
import 'package:flutter_quiver/models/polygraph/transforms/transform.dart';
import 'package:flutter_quiver/models/polygraph/display/variable_display_config.dart';
import 'package:flutter_quiver/models/polygraph/variables/transformed_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_lmp.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_marks_asofdate.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable_marks_historical_view.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeseries/timeseries.dart';
import 'package:flutter/material.dart' hide Transform;

final providerOfPolygraphVariable = Provider((ref) => PolygraphVariable());

class PolygraphVariable {
  /// What gets displayed on the screen and used in the cache
  late String label;

  /// What to show on the screen regarding this variable.  A value of '' means
  /// there is no error
  String error = '';

  /// What gets applied to this variable
  final transforms = <Transform>[];

  ///
  bool isMouseOver = false;

  /// Should the variable be displayed on the plot?
  bool isHidden = false;

  /// Gets a color at creation
  Color? color;

  // /// For the yAxis only.  If you want it displayed on the right,
  // /// set [axisPosition] to 'right'.
  // String? axisPosition;
  
  /// Customize the display on the screen
  VariableDisplayConfig? displayConfig;

  /// How to get the data in the Tab cache
  Future<TimeSeries<num>> get(DataService service, Term term) {
    throw 'Needs to be implemented by each subclasses';
  }

  /// How it's going to be persisted to the database
  Map<String,dynamic> toJson() => <String,dynamic>{};

  /// Not the cleanest implementation.  Good for now.
  static PolygraphVariable fromJson(Map<String,dynamic> x) {
    return switch (x['type']) {
      'TimeVariable' => TimeVariable.fromJson(x),
      'TransformedVariable' => TransformedVariable.fromJson(x),
      'VariableLmp' => VariableLmp.fromJson(x),
      'VariableMarksAsOfDate' => VariableMarksAsOfDate.fromJson(x),
      'VariableMarksHistoricalView' => VariableMarksHistoricalView.fromJson(x),
      _ => throw ArgumentError('Don\'t know how to parse ${x['type']}'),
    };
  }
}


class EmptyVariable extends PolygraphVariable {

  static PolygraphVariable fromMap(Map<String, dynamic> x) {
    // TODO: implement fromMongo
    throw UnimplementedError();
  }

  @override
  Future<TimeSeries<num>> get(DataService service, Term term) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toMap
    throw UnimplementedError();
  }

}


