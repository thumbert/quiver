library models.polygraph.variables.variable;

import 'package:date/date.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service.dart';
import 'package:flutter_quiver/models/polygraph/transforms/transform.dart';
import 'package:flutter_quiver/models/polygraph/display/variable_display_config.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeseries/timeseries.dart';
import 'package:flutter/material.dart' hide Transform;

final providerOfPolygraphVariable = Provider((ref) => PolygraphVariable());

class PolygraphVariable {
  /// Internal representation used for the cache key
  late final String id;

  /// What gets displayed on the screen
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

  // /// How it's going to be persisted to the database
  // Map<String,dynamic> toMap();
  //
  // PolygraphVariable fromMongo(Map<String,dynamic> x);
}


class EmptyVariable extends PolygraphVariable {
  @override
  PolygraphVariable fromMongo(Map<String, dynamic> x) {
    // TODO: implement fromMongo
    throw UnimplementedError();
  }

  @override
  Future<TimeSeries<num>> get(DataService service, Term term) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toMap() {
    // TODO: implement toMap
    throw UnimplementedError();
  }

}


