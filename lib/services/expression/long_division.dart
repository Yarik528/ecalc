class DivisionStep {
  final String currentDividend;
  final int quotientDigit;
  final int product;
  final int remainder;
  final String? broughtDown;

  const DivisionStep({
    required this.currentDividend,
    required this.quotientDigit,
    required this.product,
    required this.remainder,
    this.broughtDown,
  });
}

class LongDivisionResult {
  final int dividend;
  final int divisor;
  final int quotient;
  final int remainder;
  final List<DivisionStep> steps;

  const LongDivisionResult({
    required this.dividend,
    required this.divisor,
    required this.quotient,
    required this.remainder,
    required this.steps,
  });
}

class LongDivision {
  static LongDivisionResult? tryCompute(double a, double b) {
    if (b == 0) return null;
    if (a % 1 != 0 || b % 1 != 0) return null;
    if (a < 0 || b < 0) return null;
    if (a > 999999999 || b > 999999999) return null;

    final dividend = a.toInt();
    final divisor = b.toInt();
    final dividendStr = dividend.toString();
    final steps = <DivisionStep>[];

    int current = 0;
    int quotient = 0;

    for (int i = 0; i < dividendStr.length; i++) {
      final digit = int.parse(dividendStr[i]);
      current = current * 10 + digit;

      final q = current ~/ divisor;
      final product = q * divisor;
      final remainder = current - product;

      quotient = quotient * 10 + q;

      steps.add(DivisionStep(
        currentDividend: current.toString(),
        quotientDigit: q,
        product: product,
        remainder: remainder,
        broughtDown: i < dividendStr.length - 1 ? dividendStr[i + 1] : null,
      ));

      current = remainder;
    }

    return LongDivisionResult(
      dividend: dividend,
      divisor: divisor,
      quotient: quotient,
      remainder: current,
      steps: steps,
    );
  }
}