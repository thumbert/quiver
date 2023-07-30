library models.polygraph.variables.transformed_variable;

import 'package:date/date.dart';
import 'package:flutter_quiver/models/polygraph/data_service/data_service.dart';
import 'package:flutter_quiver/models/polygraph/display/variable_display_config.dart';
import 'package:flutter_quiver/models/polygraph/parser/ast.dart';
import 'package:flutter_quiver/models/polygraph/polygraph_variable.dart';
import 'package:flutter_quiver/models/polygraph/variables/variable.dart';
import 'package:flutter_quiver/models/polygraph/parser/parser.dart' as juice;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petitparser/petitparser.dart';
import 'package:timeseries/timeseries.dart';

class TransformedVariable extends PolygraphVariable {
  TransformedVariable({
    required this.expression,
    required String label,
  }) {
    this.label = label;
  }

  /// For example, 'toMonthly(bos_temp, mean)'
  final String expression;
  String errorLabel = '';
  String errorExpression = '';

  /// The concept of [isDirty] only applies to a [TransformedVariable].
  /// It is used to force the [updateCache] method in polygraph_window to
  /// evaluate the variable.
  ///
  /// How does a variable become dirty?  In two ways:
  /// 1) A variable becomes [isDirty] at creation, or
  /// 2) When the expression changes
  bool isDirty = true;

  static TransformedVariable getDefault() =>
      TransformedVariable(expression: '', label: '');

  TransformedVariable copyWith({
    String? expression,
    String? label,
    String? error,
  }) =>
      TransformedVariable(
        expression: expression ?? this.expression,
        label: label ?? this.label,
      )..error = error ?? this.error;

  /// The [cache] should already contain all variables needed for the eval
  /// already.
  /// If the parsing fails, set the error message and don't store anything
  /// in the cache.
  void eval(Map<String, dynamic> cache) {
    Result<Expression> res;
    try {
      res = juice.parser.parse(expression);
    } catch (e) {
      res = Failure('', 0, e.toString());
    }
    if (res.isFailure) {
      error = 'Parsing error: ${res.message}';
    } else {
      try {
        var out = res.value.eval(cache);
        if (out is Failure) {
          error = out.message;
        } else {
          if (out is Success) {
            cache[label] = out.value;
          } else {
            cache[label] = out;
          }
          // if parsing succeeds, reset the error message
          error = '';
        }
      } catch (e) {
        error = 'Evaluation error: ${e.toString()}';
      }
    }
  }

  List<String> getErrors() {
    return <String>[
      if (hasInvalidLabel()) 'Label can\'t be empty',
      if (hasInvalidExpression()) 'Expression can\'t be empty',
      if (hasParsingError()) error,
    ];
  }

  bool hasInvalidLabel() => label == '';

  bool hasInvalidExpression() => expression == '';

  bool hasParsingError() => error != '';

  @override
  Future<TimeSeries<num>> get(DataService service, Term term) {
    throw 'A TransformedVariable doesn\'t have get, use eval!';
  }

  static TransformedVariable fromMongo(Map<String, dynamic> x) {
    if (x['type'] != 'TransformedVariable') {
      throw ArgumentError('Input doesn\'t have type TransformedVariable');
    }
    if (x
        case {
          'expression': String expression,
          'label': String label,
          'displayConfig': Map<String, dynamic> displayConfig,
        }) {
      var config = VariableDisplayConfig.fromMongo(displayConfig);
      return TransformedVariable(expression: expression, label: label)
        ..displayConfig = config;
    } else {
      throw ArgumentError(
          'Input in not a correctly formatted TransformedVariable');
    }
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'type': 'TransformedVariable',
      'label': label,
      'expression': expression,
      'displayConfig': displayConfig == null ? <String,dynamic>{} : displayConfig!.toJson(),
    };
  }
}

class TransformedVariableNotifier extends StateNotifier<TransformedVariable> {
  TransformedVariableNotifier(this.ref)
      : super(TransformedVariable.getDefault());

  final Ref ref;

  set label(String value) {
    state = state.copyWith(label: value);
  }

  set expression(String value) {
    state = state.copyWith(expression: value);
  }

  set error(String value) {
    state = state.copyWith(error: value);
  }

  void fromMongo(Map<String,dynamic> x) {
    state = TransformedVariable.fromMongo(x);
  }

  void reset() {
    state = TransformedVariable.getDefault();
  }
}
