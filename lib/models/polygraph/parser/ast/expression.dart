library ast.expression;

/// An abstract expression that can be evaluated.
abstract class Expression {
  /// Evaluates the expression with the provided [variables].
  dynamic eval(Map<String, dynamic> variables);
}

class CommentExpression extends Expression {
  @override
  eval(Map<String, dynamic> variables) {
    return 0;
  }

  @override
  String toString() => 'Comment';
}

