library petitparser.parser;

import 'dart:math' as math;
import 'package:elec/elec.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_quiver/models/polygraph/parser/ast/custom/ma_expr.dart';
import 'package:flutter_quiver/models/polygraph/parser/ast/custom/window_expr.dart';
import 'package:flutter_quiver/models/polygraph/parser/ast/int_list_expr.dart';
import 'package:flutter_quiver/models/polygraph/parser/ast/ternary.dart';
import 'package:petitparser/petitparser.dart';
import 'package:timeseries/timeseries.dart';
import 'ast.dart';
import 'common.dart';
import 'package:elec/elec.dart';

final id = seq2(letter(), [letter(), digit()].toChoiceParser().star());

final number = (digit().plus() &
        (char('.') & digit().plus()).optional() &
        (pattern('eE') & pattern('+-').optional() & digit().plus()).optional())
    .flatten('number expected')
    .trim()
    .map(_createValue);

/// A non-empty list of positive integers, or integer ranges.
/// For example it parses the string `[3, 7, 9-11, 15, 20-24]`
/// It will parse into an ordered int list.  Overlapping values and
/// duplicates are ignored.
///
final intList = (char('[').trim() &
        ((digit().plus() & (char('-') & digit().plus()).optional()).trim() &
            (char(',').trim() & (digit().plus() & (char('-') & digit().plus()).optional()).trim()).star()) &
        char(']'))
    .trim()
    .map(_createIntList);

/// Input list [x] can be either:
/// * list of digit characters: ['2', '1']
///
/// * list of digit characters separated by dash: ['2', '1', '-', '2', '4']
Expression _createIntList(List x) {
  List<int> _processIntListElement(List xs) {
    var i = xs.indexOf('-');
    if (i == -1) {
      // an integer
      return [int.parse(xs.join())];
    } else {
      // an integer range
      var start = int.parse(xs.sublist(0, i).join());
      var end = int.parse(xs.sublist(i + 1).join());
      if (end < start) {
        throw const ParserException(Failure('', 0, 'end before start in integer range'));
      }
      return List.generate(end - start + 1, (i) => start + i);
    }
  }

  /// x[0] = '[', x[2] = ']'
  var z0 = x[1][0][0] as List;
  if (x[1][0][1] != null) {
    z0 = [...z0, x[1][0][1][0], ...x[1][0][1][1]];
  }

  var z = [
    z0,
    if ((x[1] as List).length == 2)
      ...(x[1][1] as List).map((e) {
        var x1 = e[1] as List;
        if (x1[1] == null) {
          return x1[0];
        } else {
          return [...x1[0], x1[1][0], ...x1[1][1]];
        }
      })
  ];

  var y = z.expand((e) => _processIntListElement(e)).toSet().toList();
  y.sort();

  return IntListExpr(y);
}

/// Parse a bucket argument for a function.  
/// For example, `bucket = 7x24`, or `bucket = offpeak`, etc.
final bucketArg = (string('bucket').trim() & char('=').trim() & char("'") & word().plus() & char("'")).trim().map((value) {
  return Bucket.parse((value[3] as List).join());
});

/// Parse a months argument for a function.  Allowed values are between [1, 12].
/// For example, parse `months = [1-2, 7-8]`, or `months = [3, 4-5, 12]`
final monthsArg = (string('months').trim() & char('=').trim() & intList).map((value) {
  var xs = (value[2] as IntListExpr).value;
  if (xs.any((e) => e < 1 || e > 12)) {
    throw const ParserException(Failure('', 0, 'Invalid month value.  Value must be between 1 and 12.'));
  }
  return MonthsListExpr(xs);
});

/// Parse the hours argument for a function.  Allowed values are between [0, 23].
/// For example, parse `hours = [1-2, 7-8]`, or `hours = [3, 4-5, 12]`
final hoursArg = (string('hours').trim() & char('=').trim() & intList).map((value) {
  var xs = (value[2] as IntListExpr).value;
  if (xs.any((e) => e < 0 || e > 23)) {
    throw const ParserException(Failure('', 0, 'Invalid hour value.  Value must be between 0 and 23.'));
  }
  return HoursListExpr(xs);
});

final variable = (letter() & word().star()).flatten('variable name expected').trim().map(_createVariable);

final expression = () {
  final builder = ExpressionBuilder<Expression>();
  builder
    ..primitive(number)
    ..primitive(variable);

  /// parentheses just return the value
  builder.group().wrapper(char('(').trim(), char(')').trim(), (left, value, right) => value);

  /// Simple math ops
  builder.group()
    ..prefix(char('+').trim(), (op, a) => a)
    ..prefix(char('-').trim(), (op, a) => Unary('-', a, (x) => -x));
  builder.group().right(char('^').trim(), (a, op, b) => Binary('^', a, b, (a, b) => math.pow(a, b)));
  builder.group()
    ..left(char('*').trim(), (a, op, b) => Binary('*', a, b, (x, y) => x * y))
    ..left(char('/').trim(), (a, op, b) => Binary('/', a, b, (x, y) => x / y));
  builder.group()
    ..left(char('+').trim(), (a, op, b) => Binary('+', a, b, (x, y) => x + y))
    ..left(char('-').trim(), (a, op, b) => Binary('-', a, b, (x, y) => x - y));
  return builder.build();
}();

final windowArg = (bucketArg | monthsArg | hoursArg);

final windowFun = (string('window(') & variable & seq2(char(',').trim(), windowArg).plus() & char(')'))
    .trim().map((value) {
  var x2 = value[2] as List;
  Bucket? bucket;
  var months = <int>[];
  var hours = <int>[];
  for (Sequence2 e in x2) {
    var e2 = e.second;
    switch (e2) {
      case (Bucket e2) : {
        if (bucket != null) {
          throw StateError('You can\'t have argument bucket twice!');
        }
        bucket = e2;
      }
      case (MonthsListExpr e2) : {
        if (months.isNotEmpty) {
          throw StateError('You can\'t have argument months twice!');
        }
        months = e2.value;
      }
      case (HoursListExpr e2) :
        {
          if (months.isNotEmpty) {
            throw StateError('You can\'t have argument months twice!');
          }
          hours = e2.value;
        }
      case _ : throw StateError('Unsupported window argument $e2!');
    }
  }

  return WindowExpr(x: value[1], bucket: bucket, months: months, hours: hours);
});

final maFun = (string('ma(') & expression & seq2(char(',').trim(), digit().plus()).trim() & char(')'))
    .trim().map((value) {
  var n = value[2] as List;
  return MaExpr(x: value[1], n: 3);
});

/// Comma separated list of expressions
final argList = (expression & (char(',').trim() & expression).star()).map((values) {
  return <Expression>[values[0], ...(values[1] as List).map((e) => e[1])];
});

final callable = seq4(word().plus().flatten('function expected').trim(), char('(').trim(), argList, char(')').trim())
    .map((value) => _createFunctionN(value.first, value.third));

final chain = seq2(variable, [string('=>').trim(), callable].toSequenceParser().plus()).map((value) {
  return value.second.first[1] as Expression;
});

final parser = () {
  final builder = ExpressionBuilder<Expression>();
  builder
    ..primitive(number)
    ..primitive(callable)
    ..primitive(variable);

  /// parentheses just return the value
  builder.group().wrapper(char('(').trim(), char(')').trim(), (left, value, right) => value);

  /// TODO: add chain/transform
  // builder.;

  /// Simple math ops
  builder.group()
    ..prefix(char('+').trim(), (op, a) => a)
    ..prefix(char('-').trim(), (op, a) => UnaryNegation(a));
  builder.group().right(char('^').trim(), (a, op, b) => Binary('^', a, b, (a, b) => math.pow(a, b)));
  builder.group()
    ..left(char('*').trim(), (a, op, b) => BinaryMultiply(a, b))
    ..left(char('/').trim(), (a, op, b) => BinaryDivide(a, b));
  builder.group()
    ..left(char('+').trim(), (a, op, b) => BinaryAdd(a, b))
    ..left(string('.+').trim(), (a, op, b) => BinaryDotAddition(a, b))
    ..left(char('-').trim(), (a, op, b) => BinarySubtract(a, b));
  builder.group()
    ..left(char('>').trim(), (a, op, b) => BinaryGreaterThan(a, b))
    ..left(string('>=').trim(), (a, op, b) => BinaryGreaterThanEqual(a, b))
    ..left(char('<').trim(), (a, op, b) => BinaryLessThan(a, b))
    ..left(string('<=').trim(), (a, op, b) => BinaryLessThanEqual(a, b));



  return builder.build().end();
}();

Expression _createValue(String value) => Value(num.parse(value));

Expression _createVariable(String name) => constants.containsKey(name) ? Value(constants[name]!) : Variable(name);

// Expression _createFunction1(String name, Expression expression) {
//   return Unary(name, expression, functions1[name]!);
// }

Expression _createFunctionN(String name, List<Expression> args) {
  if (args.length == 1) {
    if (!functions1.containsKey(name)) {
      throw 'Can\'t find function $name among list of functions with one argument.';
    }
    return Unary(name, args.first, functions1[name]!);

    ///
    ///
    ///
  } else if (args.length == 2) {
    return switch (name) {
      'max' => BinaryMax(args[0], args[1]),
      'min' => BinaryMin(args[0], args[1]),
      'toMonthly' => ToMonthly(args[0], args[1].toString().replaceFirst('Variable ', '')),
      _ => throw StateError('Wah-wah-wah...  Function $name is not supported.'),
    };

    ///
    ///
    ///
  } else if (args.length == 3) {
    return switch (name) {
      'toMonthly' => ToMonthly3(
          args[0], args[1].toString().replaceFirst('Variable ', ''), args[2].toString().replaceFirst('Variable ', '')),
      _ => throw StateError('Wah-wah-wah...  Function $name is not supported.'),
    };

    ///
    ///
    ///
  } else {
    throw 'Arity ${args.length} not yet supported!';
  }
}
