import 'parser.dart';
import 'long_division.dart';

class SolutionStep {
  final int index;
  final String description;
  final double result;
  final LongDivisionResult? longDivision;

  const SolutionStep(this.index, this.description, this.result,
      {this.longDivision});
}

class Solution {
  final String expression;
  final List<SolutionStep> steps;
  final double result;

  const Solution(this.expression, this.steps, this.result);
}

class ExpressionSolver {
  static Solution solve(
      String input, String Function(double) format, bool enableLongDivision) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      throw const FormatException('Пустое выражение');
    }
    final tokens = Lexer(trimmed).tokenize();
    final ast = Parser(tokens).parse();
    final rawSteps = <SolutionStep>[];
    final result =
        _evaluate(ast, rawSteps, format, enableLongDivision);
    final steps = <SolutionStep>[
      for (int i = 0; i < rawSteps.length; i++)
        SolutionStep(i + 1, rawSteps[i].description, rawSteps[i].result,
            longDivision: rawSteps[i].longDivision),
    ];
    return Solution(trimmed, steps, result);
  }

  static double _evaluate(Expr expr, List<SolutionStep> steps,
      String Function(double) format, bool enableLongDivision) {
    if (expr is NumberExpr) {
      return expr.value;
    }
    if (expr is UnaryMinusExpr) {
      return -_evaluate(expr.operand, steps, format, enableLongDivision);
    }
    if (expr is BinaryExpr) {
      final left =
          _evaluate(expr.left, steps, format, enableLongDivision);
      final right =
          _evaluate(expr.right, steps, format, enableLongDivision);
      double value;
      LongDivisionResult? longDiv;

      switch (expr.op) {
        case '+':
          value = left + right;
          break;
        case '-':
          value = left - right;
          break;
        case '*':
          value = left * right;
          break;
        case ':':
          if (right == 0) {
            throw const FormatException('Деление на ноль');
          }
          value = left / right;
          if (enableLongDivision) {
            longDiv = LongDivision.tryCompute(left, right);
          }
          break;
        default:
          throw const FormatException('Неизвестная операция');
      }

      steps.add(SolutionStep(
          0, '${format(left)} ${expr.op} ${format(right)}', value,
          longDivision: longDiv));
      return value;
    }
    throw const FormatException('Неизвестный узел выражения');
  }
}