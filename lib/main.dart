import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

const String appVersion = '1.0.0';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'eCalc',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF101014),
      ),
      home: const CalculatorScreen(),
    );
  }
}

class AppSettings extends ChangeNotifier {
  bool _hapticFeedback = true;
  bool _showExpression = true;
  bool _keepScreenOn = false;
  ThemeMode _themeMode = ThemeMode.dark;
  int _decimalPlaces = 6;

  bool get hapticFeedback => _hapticFeedback;
  bool get showExpression => _showExpression;
  bool get keepScreenOn => _keepScreenOn;
  ThemeMode get themeMode => _themeMode;
  int get decimalPlaces => _decimalPlaces;

  void setHapticFeedback(bool value) {
    _hapticFeedback = value;
    notifyListeners();
  }

  void setShowExpression(bool value) {
    _showExpression = value;
    notifyListeners();
  }

  void setKeepScreenOn(bool value) {
    _keepScreenOn = value;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setDecimalPlaces(int value) {
    _decimalPlaces = value;
    notifyListeners();
  }
}

class _NoisePainter extends CustomPainter {
  static ui.Image? _cached;

  static Future<void> precache() async {
    if (_cached != null) return;
    const size = 128;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final random = Random(42);
    final paint = Paint();
    for (int y = 0; y < size; y++) {
      for (int x = 0; x < size; x++) {
        final v = random.nextInt(255);
        paint.color = Color.fromARGB(5, v, v, v);
        canvas.drawRect(Rect.fromLTWH(x.toDouble(), y.toDouble(), 1, 1), paint);
      }
    }
    final picture = recorder.endRecording();
    _cached = await picture.toImage(size, size);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final image = _cached;
    if (image == null) return;
    final matrix = Float64List.fromList([
      1, 0, 0, 0,
      0, 1, 0, 0,
      0, 0, 1, 0,
      0, 0, 0, 1,
    ]);
    final shader = ImageShader(image, TileMode.repeated, TileMode.repeated, matrix);
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = shader,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GradientBackground extends StatelessWidget {
  final Widget child;
  const _GradientBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF1C1C24), Color(0xFF0E0E12)],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: _NoisePainter())),
        ),
        Positioned.fill(child: child),
      ],
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final AppSettings _settings = AppSettings();

  String _display = '0';
  String _expression = '';
  double? _firstOperand;
  String? _operator;
  bool _isTypingNumber = false;

  @override
  void initState() {
    super.initState();
    _NoisePainter.precache();
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
    String s = v % 1 == 0 ? v.toInt().toString() : v.toString();
    if (s.length > _settings.decimalPlaces + 2) {
      s = v
          .toStringAsFixed(_settings.decimalPlaces)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
    return s;
  }

  void _showError() {
    _display = 'Ошибка';
    _expression = '';
    _firstOperand = null;
    _operator = null;
    _isTypingNumber = false;
  }

  void _onButtonPressed(String value) {
    if (_settings.hapticFeedback) {
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
    const double gap = 12;
    const double sidePadding = 22;
    final double buttonSize =
        (MediaQuery.of(context).size.width - sidePadding * 2 - gap * 3) / 4;

    return Scaffold(
      body: _GradientBackground(
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
                            builder: (_) => SettingsScreen(settings: _settings),
                          ),
                        );
                      },
                      icon: const Icon(Icons.settings_outlined,
                          color: Colors.white70, size: 26),
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
                      if (_settings.showExpression)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            _expression.isEmpty ? '\u00A0' : _expression,
                            maxLines: 1,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                              color: Colors.white.withOpacity(0.35),
                            ),
                          ),
                        ),
                      if (_settings.showExpression)
                        const SizedBox(height: 4),
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerRight,
                          child: Text(
                            _display,
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 84,
                              fontWeight: FontWeight.w200,
                              color: Colors.white,
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
                    _buildRow(['C', 'negate', 'back', '/'], buttonSize, gap),
                    SizedBox(height: gap),
                    _buildRow(['7', '8', '9', 'x'], buttonSize, gap),
                    SizedBox(height: gap),
                    _buildRow(['4', '5', '6', '-'], buttonSize, gap),
                    SizedBox(height: gap),
                    _buildRow(['1', '2', '3', '+'], buttonSize, gap),
                    SizedBox(height: gap),
                    Row(
                      children: [
                        _buttonFor('0', buttonSize, gap,
                            width: buttonSize * 2 + gap),
                        SizedBox(width: gap),
                        _buttonFor('.', buttonSize, gap),
                        SizedBox(width: gap),
                        _buttonFor('=', buttonSize, gap),
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

  Widget _buildRow(List<String> labels, double size, double gap) {
    return Row(
      children: [
        for (int i = 0; i < labels.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          _buttonFor(labels[i], size, gap),
        ],
      ],
    );
  }

  Widget _buttonFor(String label, double size, double gap, {double? width}) {
    final bool isFunc = (label == 'C' || label == 'negate' || label == 'back');
    final bool isOp = ['/', 'x', '-', '+', '='].contains(label);
    final bool isActive =
        (label == _operator && _operator != null && !_isTypingNumber);

    Gradient gradient;
    Color textColor;
    List<BoxShadow> shadows;
    Widget child;

    if (isFunc) {
      gradient = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF43434D), Color(0xFF33333C)],
      );
      textColor = const Color(0xFFEDEDF2);
      shadows = [
        BoxShadow(
            color: Colors.black.withOpacity(0.4),
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
        textColor = const Color(0xFFFF9500);
        shadows = [
          BoxShadow(
              color: Colors.white.withOpacity(0.25),
              blurRadius: 14,
              offset: const Offset(0, 5))
        ];
      } else {
        gradient = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFB43A), Color(0xFFFF8A00)],
        );
        textColor = Colors.white;
        shadows = [
          BoxShadow(
              color: const Color(0xFFFF9500).withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ];
      }
    } else {
      gradient = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF2B2B33), Color(0xFF1F1F26)],
      );
      textColor = Colors.white;
      shadows = [
        BoxShadow(
            color: Colors.black.withOpacity(0.4),
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

    return _CalcButton(
      width: width ?? size,
      height: size,
      gradient: gradient,
      shadows: shadows,
      onTap: () => _onButtonPressed(label),
      child: child,
    );
  }
}

class _CalcButton extends StatefulWidget {
  final double width;
  final double height;
  final Gradient gradient;
  final List<BoxShadow> shadows;
  final VoidCallback onTap;
  final Widget child;

  const _CalcButton({
    required this.width,
    required this.height,
    required this.gradient,
    required this.shadows,
    required this.onTap,
    required this.child,
  });

  @override
  State<_CalcButton> createState() => _CalcButtonState();
}

class _CalcButtonState extends State<_CalcButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(widget.height / 2),
            boxShadow: widget.shadows,
          ),
          child: Center(child: widget.child),
        ),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  final AppSettings settings;

  const SettingsScreen({super.key, required this.settings});

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 22),
                    ),
                    const Text(
                      'Настройки',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: settings,
                  builder: (context, _) {
                    return ListView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      children: [
                        _sectionTitle('Общее'),
                        _card(
                          child: _switchTile(
                            title: 'Виброотклик',
                            subtitle: 'Вибрация при нажатии кнопок',
                            value: settings.hapticFeedback,
                            onChanged: settings.setHapticFeedback,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _card(
                          child: _switchTile(
                            title: 'Показывать выражение',
                            subtitle: 'Отображать текущую операцию над результатом',
                            value: settings.showExpression,
                            onChanged: settings.setShowExpression,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _card(
                          child: _switchTile(
                            title: 'Не выключать экран',
                            subtitle: 'Держать экран включённым во время работы',
                            value: settings.keepScreenOn,
                            onChanged: settings.setKeepScreenOn,
                          ),
                        ),
                        const SizedBox(height: 22),
                        _sectionTitle('Внешний вид'),
                        _card(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 10, bottom: 4),
                                  child: Text('Тема',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500)),
                                ),
                                SegmentedButton<ThemeMode>(
                                  segments: const [
                                    ButtonSegment(
                                        value: ThemeMode.light,
                                        label: Text('Светлая')),
                                    ButtonSegment(
                                        value: ThemeMode.dark,
                                        label: Text('Тёмная')),
                                    ButtonSegment(
                                        value: ThemeMode.system,
                                        label: Text('Система')),
                                  ],
                                  selected: {settings.themeMode},
                                  onSelectionChanged: (v) =>
                                      settings.setThemeMode(v.first),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith(
                                            (states) => states.contains(
                                                    MaterialState.selected)
                                                ? const Color(0xFFFF9500)
                                                : const Color(0xFF2B2B33)),
                                    foregroundColor:
                                        const MaterialStatePropertyAll(
                                            Colors.white),
                                    side: const MaterialStatePropertyAll(
                                        BorderSide(color: Colors.transparent)),
                                  ),
                                ),
                                const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        _sectionTitle('Точность'),
                        _card(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text('Знаков после запятой',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500)),
                                    Text('${settings.decimalPlaces}',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: Color(0xFFFF9500),
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                Slider(
                                  value: settings.decimalPlaces.toDouble(),
                                  min: 0,
                                  max: 10,
                                  divisions: 10,
                                  activeColor: const Color(0xFFFF9500),
                                  inactiveColor:
                                      Colors.white.withOpacity(0.15),
                                  onChanged: (v) =>
                                      settings.setDecimalPlaces(v.round()),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        _sectionTitle('О приложении'),
                        _card(
                          child: ListTile(
                            leading: const Icon(Icons.info_outline,
                                color: Colors.white70),
                            title: const Text('Версия'),
                            subtitle: Text(appVersion),
                            textColor: Colors.white,
                            subtitleTextStyle:
                                TextStyle(color: Colors.white.withOpacity(0.55)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _card(
                          child: ListTile(
                            leading: const Icon(Icons.code_outlined,
                                color: Colors.white70),
                            title: const Text('Исходный код'),
                            subtitle: const Text('github.com/Yarik528/ecalc'),
                            textColor: Colors.white,
                            subtitleTextStyle:
                                TextStyle(color: Colors.white.withOpacity(0.55)),
                            onTap: () => _openLink('https://github.com/Yarik528/ecalc'),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 0, 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: Colors.white.withOpacity(0.45)),
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF26262E), Color(0xFF1C1C22)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 10,
              offset: const Offset(0, 4)),
        ],
      ),
      child: child,
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title,
          style:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle,
          style: TextStyle(
              fontSize: 13, color: Colors.white.withOpacity(0.55))),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFFFF9500),
      activeTrackColor: const Color(0xFFFF9500).withOpacity(0.35),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}