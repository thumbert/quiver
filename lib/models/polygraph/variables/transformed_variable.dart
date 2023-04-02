library models.polygraph.variables.transformed_variable;

import 'package:date/date.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:flutter_quiver/models/polygraph/parser/parser.dart' as juice;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petitparser/petitparser.dart';
import 'package:timeseries/timeseries.dart';

class TransformedVariable extends PolygraphVariable {
  TransformedVariable({
    required this.expression,
    required String id,
  }) {
    this.id = id;
    isDirty = true;
    label = id;
  }

  /// For example, 'toMonthly(bos_temp, mean)'
  final String expression;

  static TransformedVariable getDefault() =>
      TransformedVariable(expression: '', id: '');

  TransformedVariable copyWith({
    String? expression,
    String? id,
  }) =>
      TransformedVariable(
        expression: expression ?? this.expression,
        id: id ?? this.id,
      );

  /// The [cache] should already contain all variables needed for the eval
  /// already.
  /// If the parsing fails, set the error message and don't store anything
  /// in the cache.
  void eval(Map<String, dynamic> cache) {
    var res = juice.parser.parse(expression);
    if (res.isFailure) {
      error = res.message;
    } else {
      var out = res.value.eval(cache);
      if (out is Failure) {
        error = out.message;
      } else {
        if (out is Success) {
          cache[id] = out.value;
        } else {
          cache[id] = out;
        }
        // if parsing succeeds, reset the error message
        error = '';
      }
    }
  }

  @override
  Future<TimeSeries<num>> get(DataService service, Term term) {
    throw 'A TransformedVariable doesn\'t have get, use eval!';
  }

  @override
  TransformedVariable fromMongo(Map<String, dynamic> x) {
    // TODO: implement fromMongo
    throw UnimplementedError();
  }

  @override
  Map<String, dynamic> toMongo() {
    // TODO: implement toMongo
    throw UnimplementedError();
  }
}

class TransformedVariableNotifier extends StateNotifier<TransformedVariable> {
  TransformedVariableNotifier(this.ref)
      : super(TransformedVariable.getDefault());

  final Ref ref;

  set label(String value) {
    state = state.copyWith(id: value);
  }

  set expression(String value) {
    state = state.copyWith(expression: value);
  }
}
