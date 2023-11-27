library petitparser.parser;

import 'dart:math' as math;
import 'package:elec/elec.dart';
import 'package:flutter_quiver/models/polygraph/parser/ast/custom/hourly_schedule_expr.dart';
import 'package:flutter_quiver/models/polygraph/parser/ast/custom/ma_expr.dart';
import 'package:flutter_quiver/models/polygraph/parser/ast/custom/window_expr.dart';
import 'package:flutter_quiver/models/polygraph/parser/ast/int_list_expr.dart';
import 'package:flutter_quiver/models/polygraph/parser/ast/ternary.dart';
import 'package:petitparser/petitparser.dart';
import 'ast.dart';
import 'common.dart';

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
            (char(',').trim() &
                    (digit().plus() & (char('-') & digit().plus()).optional())
                        .trim())
                .star()) &
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
        throw const ParserException(
            Failure('', 0, 'end before start in integer range'));
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
final bucketArg = (string('bucket').trim() &
        char('=').trim() &
        char("'") &
        word().plus() &
        char("'"))
    .trim()
    .map((value) {
  return Bucket.parse((value[3] as List).join());
});

/// Parse a months argument for a function.  Allowed values are between [1, 12].
/// For example, parse `months = [1-2, 7-8]`, or `months = [3, 4-5, 12]`
final monthsArg =
    (string('months').trim() & char('=').trim() & intList).map((value) {
  var xs = (value[2] as IntListExpr).value;
  if (xs.any((e) => e < 1 || e > 12)) {
    throw const ParserException(Failure(
        '', 0, 'Invalid month value.  Value must be between 1 and 12.'));
  }
  return MonthsListExpr(xs);
});

/// Parse the hours argument for a function.  Allowed values are between [0, 23].
/// For example, parse `hours = [1-2, 7-8]`, or `hours = [3, 4-5, 12]`
final hoursArg =
    (string('hours').trim() & char('=').trim() & intList).map((value) {
  var xs = (value[2] as IntListExpr).value;
  if (xs.any((e) => e < 0 || e > 23)) {
    throw const ParserException(
        Failure('', 0, 'Invalid hour value.  Value must be between 0 and 23.'));
  }
  return HoursListExpr(xs);
});

final variable = (letter() & word().star())
    .flatten('variable name expected')
    .trim()
    .map(_createVariable);

final expression = () {
  final builder = ExpressionBuilder<Expression>();
  builder
    ..primitive(number)
    ..primitive(variable);

  /// parentheses just return the value
  builder.group().wrapper(
      char('(').trim(), char(')').trim(), (left, value, right) => value);

  /// Simple math ops
  builder.group()
    ..prefix(char('+').trim(), (op, a) => a)
    ..prefix(char('-').trim(), (op, a) => Unary('-', a, (x) => -x));
  builder.group().right(char('^').trim(),
      (a, op, b) => Binary('^', a, b, (a, b) => math.pow(a, b)));
  builder.group()
    ..left(char('*').trim(), (a, op, b) => Binary('*', a, b, (x, y) => x * y))
    ..left(char('/').trim(), (a, op, b) => Binary('/', a, b, (x, y) => x / y));
  builder.group()
    ..left(char('+').trim(), (a, op, b) => Binary('+', a, b, (x, y) => x + y))
    ..left(char('-').trim(), (a, op, b) => Binary('-', a, b, (x, y) => x - y));
  return builder.build();
}();

final windowArg = seq3(
    seq2(char(',').trim(), bucketArg).optional(),
    seq2(char(',').trim(), monthsArg).optional(),
    seq2(char(',').trim(), hoursArg).optional());
final windowFun = (string('window(') &
        variable &
        windowArg.times(1) &
        char(')'))
    .trim()
    .map((value) {
  Bucket? bucket;
  var months = <int>[];
  var hours = <int>[];

  /// TODO: FIXME!
  // var v2 = (value[2] as List).first as Sequence2;
  // if (v2.first != null) {
  //   bucket = (v2.first as Sequence2).second;
  // }
  // if (v2.second != null) {
  //   months = ((v2.second as Sequence2).second as MonthsListExpr).value;
  // }
  // if (v2.third != null) {
  //   hours = ((v2.third as Sequence2).second as HoursListExpr).value;
  // }

  return WindowExpr(x: value[1], bucket: bucket, months: months, hours: hours);
});

final hourlyScheduleArg = seq2(seq2(char(',').trim(), bucketArg).optional(),
    seq2(char(',').trim(), monthsArg).optional());
final hourlyScheduleFun = (string('hourly_schedule(') &
        number &
        hourlyScheduleArg.times(1) &
        char(')'))
    .trim()
    .map((value) {
  var x = (value[1] as Value).value;

  Bucket? bucket;
  var months = <int>[];
  // var v2 = (value[2] as List).first as Sequence2;
  // if (v2.first != null) {
  //   bucket = (v2.first as Sequence2).second;
  // }
  // if (v2.second != null) {
  //   months = ((v2.second as Sequence2).second as MonthsListExpr).value;
  // }
  return HourlyScheduleExpr(x, bucket: bucket, months: months);
});

final maFun = (string('ma(') &
        expression &
        seq2(char(',').trim(), digit().plus()).trim() &
        char(')'))
    .trim()
    .map((value) {
  // var n = int.parse(((value[2] as Sequence2).second as List).join());
  /// FIXME!
  var n = 10;
  return MaExpr(x: value[1], n: n);
});

/// Comma separated list of expressions
final argList =
    (expression & (char(',').trim() & expression).star()).map((values) {
  return <Expression>[values[0], ...(values[1] as List).map((e) => e[1])];
});

final callable = seq4(word().plus().flatten('function expected').trim(),
        char('(').trim(), argList, char(')').trim())
    .map((value) => _createFunctionN(value.$1, value.$3));

final chain =
    seq2(variable, [string('=>').trim(), callable].toSequenceParser().plus())
        .map((value) {
  return value.$2.first[1] as Expression;
});

Parser<List> hiddenWhitespace() => ref0(hiddenStuffWhitespace).plus();

Parser hiddenStuffWhitespace() => ref0(whitespace) | ref0(singleLineComment);

Parser<List> singleLineComment() =>
    string('//').trim() & ref0(any).star() & ref0(newline).optional();

final comment1 = (string('//').trim() & any().star() & newline().optional())
    .map((value) => CommentExpression());

final parser = () {
  final builder = ExpressionBuilder<Expression>();
  builder
    ..primitive(comment1)
    ..primitive(number)
    ..primitive(hourlyScheduleFun)
    ..primitive(maFun)
    ..primitive(callable)
    ..primitive(variable);

  /// parentheses just return the value
  builder.group().wrapper(
      char('(').trim(), char(')').trim(), (left, value, right) => value);

  /// Simple math ops
  builder.group()
    ..prefix(char('+').trim(), (op, a) => a)
    ..prefix(char('-').trim(), (op, a) => UnaryNegation(a));
  builder.group().right(char('^').trim(),
      (a, op, b) => Binary('^', a, b, (a, b) => math.pow(a, b)));
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

Expression _createVariable(String name) =>
    constants.containsKey(name) ? Value(constants[name]!) : Variable(name);

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
      'toMonthly' =>
        ToMonthly(args[0], args[1].toString().replaceFirst('Variable ', '')),
      _ => throw StateError('Wah-wah-wah...  Function $name is not supported.'),
    };

    ///
    ///
    ///
  } else if (args.length == 3) {
    return switch (name) {
      'toMonthly' => ToMonthly3(
          args[0],
          args[1].toString().replaceFirst('Variable ', ''),
          args[2].toString().replaceFirst('Variable ', '')),
      _ => throw StateError('Wah-wah-wah...  Function $name is not supported.'),
    };

    ///
    ///
    ///
  } else {
    throw 'Arity ${args.length} not yet supported!';
  }
}
