library petitparser.parser;

import 'dart:math' as math;
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

final variable = (letter() & word().star())
    .flatten('variable name expected')
    .trim()
    .map(_createVariable);

final expression = () {
  final builder = ExpressionBuilder<Expression>();
  builder.group()
    ..primitive(number)
    ..primitive(variable)

    /// functions of arity 1
    ..wrapper(
        seq2(
          word().plus().flatten('function expected').trim(),
          char('(').trim(),
        ),
        char(')').trim(),
        (left, value, right) => _createFunction1(left.first, value))

    /// parentheses just return the value
    ..wrapper(
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

final parser = () {
  final builder = ExpressionBuilder<Expression>();
  builder.group()
    ..primitive(number)
    ..primitive(variable)
    /// parentheses just return the value
    ..wrapper(
        char('(').trim(), char(')').trim(), (left, value, right) => value);

  /// Function of general arity
  builder.group().primitive(callable);

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
    return Unary(name, args.first, functions1[name]!);
  } else if (args.length == 2) {
    return Binary(name, args[0], args[1], functions2[name]!);
  } else {
    throw StateError('Arity ${args.length} not yet supported!');
  }
}
