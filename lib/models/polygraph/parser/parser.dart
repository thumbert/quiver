library petitparser.parser;

import 'dart:math' as math;
import 'package:flutter_quiver/models/polygraph/parser/ast/ternary.dart';
import 'package:petitparser/petitparser.dart';
import 'package:timeseries/timeseries.dart';
import 'ast.dart';
import 'common.dart';

final id = seq2(letter(), [letter(), digit()].toChoiceParser().star());

final number = (digit().plus() &
        (char('.') & digit().plus()).optional() &
        (pattern('eE') & pattern('+-').optional() & digit().plus()).optional())
    .flatten('number expected')
    .trim()
    .map(_createValue);

final variable = (letter() & word().star())
    .flatten('variable name expected')
    .trim()
    .map(_createVariable);

final expression = () {
  final builder = ExpressionBuilder<Expression>();
  builder
    ..primitive(number)
    ..primitive(variable);

  // /// functions of arity 1
  // builder.group()
  //   ..wrapper(
  //       seq2(
  //         word().plus().flatten('function expected').trim(),
  //         char('(').trim(),
  //       ),
  //       char(')').trim(),
  //       (left, value, right) => _createFunction1(left.first, value))

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

/// Comma separated list of expressions
final argList =
    (expression & (char(',').trim() & expression).star()).map((values) {
  return <Expression>[values[0], ...(values[1] as List).map((e) => e[1])];
});

final callable = seq4(word().plus().flatten('function expected').trim(),
        char('(').trim(), argList, char(')').trim())
    .map((value) => _createFunctionN(value.first, value.third));

final chain = seq2(variable, [string('=>').trim(), callable].toSequenceParser().plus());

final parser = () {
  final builder = ExpressionBuilder<Expression>();
  builder
    ..primitive(number)
    ..primitive(callable)
    ..primitive(variable);

  /// parentheses just return the value
  builder.group().wrapper(
      char('(').trim(), char(')').trim(), (left, value, right) => value);

  /// chain/transform
  // builder.;

  /// Simple math ops
  builder.group()
    ..prefix(char('+').trim(), (op, a) => a)
    ..prefix(char('-').trim(), (op, a) => Unary('-', a, (x) => -x));
  builder.group().right(char('^').trim(),
      (a, op, b) => Binary('^', a, b, (a, b) => math.pow(a, b)));
  builder.group()
    ..left(char('*').trim(), (a, op, b) => BinaryMultiply(a, b))
    ..left(char('/').trim(), (a, op, b) => BinaryDivide(a, b));
  builder.group()
    ..left(char('+').trim(), (a, op, b) => BinaryAdd(a, b))
    ..left(char('-').trim(), (a, op, b) => BinarySubtract(a, b));

  return builder.build().end();
}();

Expression _createValue(String value) => Value(num.parse(value));

Expression _createVariable(String name) =>
    constants.containsKey(name) ? Value(constants[name]!) : Variable(name);

Expression _createFunction1(String name, Expression expression) {
  return Unary(name, expression, functions1[name]!);
}

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
