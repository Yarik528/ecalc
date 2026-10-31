import 'token.dart';

class Lexer {
  final String input;
  int _pos = 0;

  Lexer(this.input);

  List<Token> tokenize() {
    final tokens = <Token>[];
    while (_pos < input.length) {
      final c = input[_pos];
      if (c == ' ' || c == '\t') {
        _pos++;
      } else if (_isDigit(c) || c == '.' || c == ',') {
        tokens.add(_readNumber());
      } else if (c == '+') {
        tokens.add(const Token(TokenType.plus, '+'));
        _pos++;
      } else if (c == '-') {
        tokens.add(const Token(TokenType.minus, '-'));
        _pos++;
      } else if (c == '*' || c == '×') {
        tokens.add(const Token(TokenType.multiply, '*'));
        _pos++;
      } else if (c == '/' || c == ':') {
        tokens.add(const Token(TokenType.divide, ':'));
        _pos++;
      } else if (c == '(') {
        tokens.add(const Token(TokenType.leftParen, '('));
        _pos++;
      } else if (c == ')') {
        tokens.add(const Token(TokenType.rightParen, ')'));
        _pos++;
      } else {
        throw FormatException('Недопустимый символ: $c');
      }
    }
    tokens.add(const Token(TokenType.end, ''));
    return tokens;
  }

  bool _isDigit(String c) {
    final code = c.codeUnitAt(0);
    return code >= 48 && code <= 57;
  }

  Token _readNumber() {
    final start = _pos;
    bool dotSeen = false;
    while (_pos < input.length) {
      final c = input[_pos];
      if (_isDigit(c)) {
        _pos++;
      } else if ((c == '.' || c == ',') && !dotSeen) {
        dotSeen = true;
        _pos++;
      } else {
        break;
      }
    }
    final raw = input.substring(start, _pos);
    return Token(TokenType.number, raw.replaceAll(',', '.'));
  }
}

abstract class Expr {
  const Expr();
}

class NumberExpr extends Expr {
  final double value;
  const NumberExpr(this.value);
}

class UnaryMinusExpr extends Expr {
  final Expr operand;
  const UnaryMinusExpr(this.operand);
}

class BinaryExpr extends Expr {
  final Expr left;
  final String op;
  final Expr right;
  const BinaryExpr(this.left, this.op, this.right);
}

class Parser {
  final List<Token> _tokens;
  int _pos = 0;

  Parser(this._tokens);

  Token get _current => _tokens[_pos];

  Token _advance() {
    final t = _tokens[_pos];
    _pos++;
    return t;
  }

  Expr parse() {
    final expr = _parseExpression();
    if (_current.type != TokenType.end) {
      throw FormatException('Неожиданный символ: ${_current.value}');
    }
    return expr;
  }

  Expr _parseExpression() {
    var left = _parseTerm();
    while (_current.type == TokenType.plus ||
        _current.type == TokenType.minus) {
      final op = _advance().type == TokenType.plus ? '+' : '-';
      final right = _parseTerm();
      left = BinaryExpr(left, op, right);
    }
    return left;
  }

  Expr _parseTerm() {
    var left = _parseFactor();
    while (_current.type == TokenType.multiply ||
        _current.type == TokenType.divide) {
      final op = _advance().type == TokenType.multiply ? '*' : ':';
      final right = _parseFactor();
      left = BinaryExpr(left, op, right);
    }
    return left;
  }

  Expr _parseFactor() {
    if (_current.type == TokenType.minus) {
      _advance();
      return UnaryMinusExpr(_parseFactor());
    }
    return _parsePrimary();
  }

  Expr _parsePrimary() {
    if (_current.type == TokenType.number) {
      final t = _advance();
      final v = double.tryParse(t.value);
      if (v == null) {
        throw FormatException('Некорректное число: ${t.value}');
      }
      return NumberExpr(v);
    }
    if (_current.type == TokenType.leftParen) {
      _advance();
      final expr = _parseExpression();
      if (_current.type != TokenType.rightParen) {
        throw FormatException('Ожидалась закрывающая скобка');
      }
      _advance();
      return expr;
    }
    throw FormatException(
        'Неожиданный символ: ${_current.value.isEmpty ? 'конец ввода' : _current.value}');
  }
}