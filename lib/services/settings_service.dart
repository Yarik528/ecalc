import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings.dart';

class SettingsService {
  static final SettingsService instance = SettingsService._internal();
  factory SettingsService() => instance;
  SettingsService._internal();

  static const String _expressionKey = 'show_expression';
  static const String _longDivisionKey = 'show_long_division';
  static const String _alignRightKey = 'align_right';
  static const String _flatBgKey = 'flat_background';
  static const String _themeKey = 'theme_mode';
  static const String _decimalKey = 'decimal_places';
  static const String _accentColorKey = 'accent_color';
  static const String _buttonSizeKey = 'button_size_scale';
  static const String _buttonShapeKey = 'button_shape';

  Future<bool> getShowExpression() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_expressionKey) ?? true;
  }

  Future<void> setShowExpression(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_expressionKey, value);
  }

  Future<bool> getShowLongDivision() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_longDivisionKey) ?? true;
  }

  Future<void> setShowLongDivision(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_longDivisionKey, value);
  }

  Future<bool> getAlignRight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_alignRightKey) ?? true;
  }

  Future<void> setAlignRight(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_alignRightKey, value);
  }

  Future<bool> getFlatBackground() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_flatBgKey) ?? false;
  }

  Future<void> setFlatBackground(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_flatBgKey, value);
  }

  Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_themeKey) ?? ThemeMode.dark.index;
    return ThemeMode.values[index];
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, mode.index);
  }

  Future<int> getDecimalPlaces() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_decimalKey) ?? 6;
  }

  Future<void> setDecimalPlaces(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_decimalKey, value);
  }

  Future<Color> getAccentColor() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_accentColorKey) ?? 0xFFFF9500;
    return Color(value);
  }

  Future<void> setAccentColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentColorKey, color.value);
  }

  Future<double> getButtonSizeScale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_buttonSizeKey) ?? 1.0;
  }

  Future<void> setButtonSizeScale(double scale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_buttonSizeKey, scale);
  }

  Future<ButtonShape> getButtonShape() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_buttonShapeKey) ?? ButtonShape.circular.index;
    return ButtonShape.values[index];
  }

  Future<void> setButtonShape(ButtonShape shape) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_buttonShapeKey, shape.index);
  }
}