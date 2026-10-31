import 'package:flutter/material.dart';
import '../services/settings_service.dart';

enum ButtonShape { circular, rounded }

class AppSettings extends ChangeNotifier {
  static final AppSettings instance = AppSettings._internal();
  factory AppSettings() => instance;
  AppSettings._internal();

  bool _showExpression = true;
  bool _showLongDivision = true;
  bool _alignRight = true;
  bool _flatBackground = false;
  ThemeMode _themeMode = ThemeMode.dark;
  int _decimalPlaces = 6;
  Color _accentColor = const Color(0xFFFF9500);
  double _buttonSizeScale = 1.0;
  ButtonShape _buttonShape = ButtonShape.circular;

  bool get showExpression => _showExpression;
  bool get showLongDivision => _showLongDivision;
  bool get alignRight => _alignRight;
  bool get flatBackground => _flatBackground;
  ThemeMode get themeMode => _themeMode;
  int get decimalPlaces => _decimalPlaces;
  Color get accentColor => _accentColor;
  double get buttonSizeScale => _buttonSizeScale;
  ButtonShape get buttonShape => _buttonShape;

  Future<void> loadSettings() async {
    final service = SettingsService.instance;
    _showExpression = await service.getShowExpression();
    _showLongDivision = await service.getShowLongDivision();
    _alignRight = await service.getAlignRight();
    _flatBackground = await service.getFlatBackground();
    _themeMode = await service.getThemeMode();
    _decimalPlaces = await service.getDecimalPlaces();
    _accentColor = await service.getAccentColor();
    _buttonSizeScale = await service.getButtonSizeScale();
    _buttonShape = await service.getButtonShape();
    notifyListeners();
  }

  Future<void> setShowExpression(bool value) async {
    _showExpression = value;
    await SettingsService.instance.setShowExpression(value);
    notifyListeners();
  }

  Future<void> setShowLongDivision(bool value) async {
    _showLongDivision = value;
    await SettingsService.instance.setShowLongDivision(value);
    notifyListeners();
  }

  Future<void> setAlignRight(bool value) async {
    _alignRight = value;
    await SettingsService.instance.setAlignRight(value);
    notifyListeners();
  }

  Future<void> setFlatBackground(bool value) async {
    _flatBackground = value;
    await SettingsService.instance.setFlatBackground(value);
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