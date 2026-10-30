import 'package:flutter/material.dart';
import '../services/settings_service.dart';

enum ButtonShape { circular, rounded }

class AppSettings extends ChangeNotifier {
  static final AppSettings instance = AppSettings._internal();
  factory AppSettings() => instance;
  AppSettings._internal();

  bool _hapticFeedback = true;
  bool _showExpression = true;
  bool _keepScreenOn = false;
  ThemeMode _themeMode = ThemeMode.dark;
  int _decimalPlaces = 6;
  Color _accentColor = const Color(0xFFFF9500);
  double _buttonSizeScale = 1.0;
  ButtonShape _buttonShape = ButtonShape.circular;

  bool get hapticFeedback => _hapticFeedback;
  bool get showExpression => _showExpression;
  bool get keepScreenOn => _keepScreenOn;
  ThemeMode get themeMode => _themeMode;
  int get decimalPlaces => _decimalPlaces;
  Color get accentColor => _accentColor;
  double get buttonSizeScale => _buttonSizeScale;
  ButtonShape get buttonShape => _buttonShape;

  Future<void> loadSettings() async {
    final service = SettingsService.instance;
    _hapticFeedback = await service.getHapticFeedback();
    _showExpression = await service.getShowExpression();
    _keepScreenOn = await service.getKeepScreenOn();
    _themeMode = await service.getThemeMode();
    _decimalPlaces = await service.getDecimalPlaces();
    _accentColor = await service.getAccentColor();
    _buttonSizeScale = await service.getButtonSizeScale();
    _buttonShape = await service.getButtonShape();
    notifyListeners();
  }

  Future<void> setHapticFeedback(bool value) async {
    _hapticFeedback = value;
    await SettingsService.instance.setHapticFeedback(value);
    notifyListeners();
  }

  Future<void> setShowExpression(bool value) async {
    _showExpression = value;
    await SettingsService.instance.setShowExpression(value);
    notifyListeners();
  }

  Future<void> setKeepScreenOn(bool value) async {
    _keepScreenOn = value;
    await SettingsService.instance.setKeepScreenOn(value);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await SettingsService.instance.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> setDecimalPlaces(int value) async {
    _decimalPlaces = value;
    await SettingsService.instance.setDecimalPlaces(value);
    notifyListeners();
  }

  Future<void> setAccentColor(Color color) async {
    _accentColor = color;
    await SettingsService.instance.setAccentColor(color);
    notifyListeners();
  }

  Future<void> setButtonSizeScale(double scale) async {
    _buttonSizeScale = scale;
    await SettingsService.instance.setButtonSizeScale(scale);
    notifyListeners();
  }

  Future<void> setButtonShape(ButtonShape shape) async {
    _buttonShape = shape;
    await SettingsService.instance.setButtonShape(shape);
    notifyListeners();
  }
}