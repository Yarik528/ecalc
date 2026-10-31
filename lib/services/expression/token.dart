enum TokenType {
  number,
  plus,
  minus,
  multiply,
  divide,
  leftParen,
  rightParen,
  end,
}

class Token {
  final TokenType type;
  final String value;

  const Token(this.type, this.value);
}