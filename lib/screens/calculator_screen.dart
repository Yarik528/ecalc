import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/settings.dart';
import '../widgets/calc_button.dart';
import '../widgets/gradient_background.dart';
import '../widgets/noise_painter.dart';
import 'settings_screen.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _display = '0';
  String _expression = '';
  double? _firstOperand;
  String? _operator;
  bool _isTypingNumber = false;

  @override
  void initState() {
    super.initState();
    NoisePainter.precache();
    AppSettings.instance.loadSettings();
  }

  double? _calculate(double a, double b, String op) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case 'x':
        return a * b;
      case '/':
        return b == 0 ? null : a / b;
    }
    return null;
  }

  String _format(double v) {
    final settings = AppSettings.instance;
    String s = v % 1 == 0 ? v.toInt().toString() : v.toString();
    if (s.length > settings.decimalPlaces + 2) {
      s = v
          .toStringAsFixed(settings.decimalPlaces)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }

  void _showError() {
    setState(() {
      _display = 'Ошибка';
      _expression = '';
      _firstOperand = null;
      _operator = null;
      _isTypingNumber = false;
    });
  }

  void _onButtonPressed(String value) {
    final settings = AppSettings.instance;
    if (settings.hapticFeedback) {
      HapticFeedback.lightImpact();
    }

    setState(() {
      if (value == 'C') {
        _display = '0';
        _expression = '';
        _firstOperand = null;
        _operator = null;
        _isTypingNumber = false;
      } else if (value == 'back') {
        if (_isTypingNumber) {
          _display = _display.length > 1
              ? _display.substring(0, _display.length - 1)
              : '0';
          if (_display == '0' || _display == '-') _isTypingNumber = false;
        }
      } else if (['+', '-', 'x', '/'].contains(value)) {
        if (_firstOperand != null && _operator != null && _isTypingNumber) {
          final result = _calculate(
              _firstOperand!, double.tryParse(_display) ?? 0, _operator!);
          if (result == null) {
            _showError();
            return;
          }
          _firstOperand = result;
          _display = _format(result);
        } else {
          _firstOperand = double.tryParse(_display) ?? 0;
        }
        _operator = value;
        _expression = '${_format(_firstOperand!)} $value';
        _isTypingNumber = false;
      } else if (value == '=') {
        if (_firstOperand != null && _operator != null) {
          final second = double.tryParse(_display) ?? 0;
          final result = _calculate(_firstOperand!, second, _operator!);
          _expression =
              '${_format(_firstOperand!)} $_operator ${_format(second)} =';
          if (result == null) {
            _showError();
            return;
          }
          _display = _format(result);
          _firstOperand = null;
          _operator = null;
          _isTypingNumber = false;
        }
      } else if (value == '.') {
        if (!_isTypingNumber) {
          _display = '0.';
          _isTypingNumber = true;
        } else if (!_display.contains('.')) {
          _display += '.';
        }
      } else if (value == 'negate') {
        if (_display != '0') {
          _display = _display.startsWith('-')
              ? _display.substring(1)
              : '-$_display';
        }
      } else {
        if (!_isTypingNumber) {
          _display = value;
          _isTypingNumber = true;
        } else if (_display.length < 12) {
          _display = _display == '0' ? value : _display + value;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;
    final isDark = settings.themeMode == ThemeMode.dark ||
        (settings.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    const double gap = 12;
    const double sidePadding = 22;
    final double baseButtonSize =
        (MediaQuery.of(context).size.width - sidePadding * 2 - gap * 3) / 4;
    final double buttonSize = baseButtonSize * settings.buttonSizeScale;

    return Scaffold(
      body: GradientBackground(
        isDark: isDark,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 12, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.settings_outlined,
                        color: isDark ? Colors.white70 : Colors.black54,
                        size: 26,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (settings.showExpression)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            _expression.isEmpty ? '\u00A0' : _expression,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                              color: isDark
                                  ? Colors.white.withOpacity(0.35)
                                  : Colors.black.withOpacity(0.35),
                            ),
                          ),
                        ),
                      if (settings.showExpression)
                        const SizedBox(height: 4),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            _display,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 84,
                              fontWeight: FontWeight.w200,
                              color: isDark ? Colors.white : Colors.black,
                              height: 1.05,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(sidePadding, 4, sidePadding, 18),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildRow(['C', 'negate', 'back', '/'], buttonSize, gap, isDark, settings),
                    SizedBox(height: gap),
                    _buildRow(['7', '8', '9', 'x'], buttonSize, gap, isDark, settings),
                    SizedBox(height: gap),
                    _buildRow(['4', '5', '6', '-'], buttonSize, gap, isDark, settings),
                    SizedBox(height: gap),
                    _buildRow(['1', '2', '3', '+'], buttonSize, gap, isDark, settings),
                    SizedBox(height: gap),
                    Row(
                      children: [
                        _buttonFor('0', buttonSize, gap,
                            width: buttonSize * 2 + gap, isDark: isDark, settings: settings),
                        SizedBox(width: gap),
                        _buttonFor('.', buttonSize, gap, isDark: isDark, settings: settings),
                        SizedBox(width: gap),
                        _buttonFor('=', buttonSize, gap, isDark: isDark, settings: settings),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(List<String> labels, double size, double gap, bool isDark, AppSettings settings) {
    return Row(
      children: [
        for (int i = 0; i < labels.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          _buttonFor(labels[i], size, gap, isDark: isDark, settings: settings),
        ],
      ],
    );
  }

  Widget _buttonFor(String label, double size, double gap,
      {double? width, required bool isDark, required AppSettings settings}) {
    final bool isFunc = (label == 'C' || label == 'negate' || label == 'back');
    final bool isOp = ['/', 'x', '-', '+', '='].contains(label);
    final bool isActive =
        (label == _operator && _operator != null && !_isTypingNumber);

    Gradient gradient;
    Color textColor;
    List<BoxShadow> shadows;
    Widget child;
    final Color accent = settings.accentColor;

    if (isFunc) {
      if (isDark) {
        gradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF43434D), Color(0xFF33333C)],
        );
        textColor = const Color(0xFFEDEDF2);
      } else {
        gradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD1D1D6), Color(0xFFAEAEB2)],
        );
        textColor = const Color(0xFF1C1C1E);
      }
      shadows = [
        BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
            blurRadius: 10,
            offset: const Offset(0, 5))
      ];
    } else if (isOp) {
      if (isActive) {
        gradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFE6E6EA)],
        );
        textColor = accent;
        shadows = [
          BoxShadow(
              color: Colors.white.withOpacity(0.25),
              blurRadius: 14,
              offset: const Offset(0, 5))
        ];
      } else {
        gradient = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(accent, Colors.white, 0.15)!,
            accent,
          ],
        );
        textColor = Colors.white;
        shadows = [
          BoxShadow(
              color: accent.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ];
      }
    } else {
      if (isDark) {
        gradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B2B33), Color(0xFF1F1F26)],
        );
        textColor = Colors.white;
      } else {
        gradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFFFFF), Color(0xFFF2F2F7)],
        );
        textColor = const Color(0xFF1C1C1E);
      }
      shadows = [
        BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5))
      ];
    }

    if (label == 'back') {
      child = Icon(Icons.backspace_outlined,
          size: size * 0.34, color: textColor);
    } else if (label == 'negate') {
      child = Text('+/-',
          style: TextStyle(
              fontSize: size * 0.30,
              fontWeight: FontWeight.w500,
              color: textColor));
    } else {
      child = Text(label,
          style: TextStyle(
              fontSize: size * 0.36,
              fontWeight: FontWeight.w500,
              color: textColor));
    }

    final double borderRadius = settings.buttonShape == ButtonShape.circular
        ? size / 2
        : size * 0.25;

    return CalcButton(
      width: width ?? size,
      height: size,
      gradient: gradient,
      shadows: shadows,
      borderRadius: borderRadius,
      onTap: () => _onButtonPressed(label),
      child: child,
    );
  }
}