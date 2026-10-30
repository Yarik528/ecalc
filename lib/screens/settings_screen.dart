import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/settings.dart';
import '../widgets/gradient_background.dart';

const String appVersion = '1.3.0';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettings.instance;
    final isDark = settings.themeMode == ThemeMode.dark ||
        (settings.themeMode == ThemeMode.system &&
            MediaQuery.of(context).platformBrightness == Brightness.dark);

    return Scaffold(
      body: GradientBackground(
        isDark: isDark,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: Icon(
                        Icons.arrow_back_ios_new,
                        color: isDark ? Colors.white : Colors.black,
                        size: 22,
                      ),
                    ),
                    Text(
                      'Настройки',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.white : Colors.black,
                      ),
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
                        _sectionTitle('Общее', isDark),
                        _card(
                          isDark: isDark,
                          child: _switchTile(
                            title: 'Виброотклик',
                            subtitle: 'Вибрация при нажатии кнопок',
                            value: settings.hapticFeedback,
                            onChanged: settings.setHapticFeedback,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _card(
                          isDark: isDark,
                          child: _switchTile(
                            title: 'Показывать выражение',
                            subtitle: 'Отображать текущую операцию над результатом',
                            value: settings.showExpression,
                            onChanged: settings.setShowExpression,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _card(
                          isDark: isDark,
                          child: _switchTile(
                            title: 'Не выключать экран',
                            subtitle: 'Держать экран включённым во время работы',
                            value: settings.keepScreenOn,
                            onChanged: settings.setKeepScreenOn,
                            isDark: isDark,
                          ),
                        ),
                        const SizedBox(height: 22),
                        _sectionTitle('Внешний вид', isDark),
                        _card(
                          isDark: isDark,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, bottom: 4),
                                  child: Text('Тема',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? Colors.white : Colors.black)),
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
                                                ? settings.accentColor
                                                : isDark
                                                    ? const Color(0xFF2B2B33)
                                                    : const Color(0xFFE5E5EA)),
                                    foregroundColor:
                                        MaterialStateProperty.resolveWith(
                                            (states) => states.contains(
                                                    MaterialState.selected)
                                                ? Colors.white
                                                : isDark
                                                    ? Colors.white
                                                    : Colors.black),
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
                        _sectionTitle('Кастомизация', isDark),
                        _card(
                          isDark: isDark,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Цвет акцента',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: isDark ? Colors.white : Colors.black)),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 12,
                                  runSpacing: 12,
                                  children: [
                                    _colorOption(const Color(0xFFFF9500), settings, isDark),
                                    _colorOption(const Color(0xFF34C759), settings, isDark),
                                    _colorOption(const Color(0xFF007AFF), settings, isDark),
                                    _colorOption(const Color(0xFFAF52DE), settings, isDark),
                                    _colorOption(const Color(0xFFFF2D55), settings, isDark),
                                    _colorOption(const Color(0xFFFFCC00), settings, isDark),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _card(
                          isDark: isDark,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Размер кнопок',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: isDark ? Colors.white : Colors.black)),
                                    Text('${(settings.buttonSizeScale * 100).round()}%',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: settings.accentColor,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                Slider(
                                  value: settings.buttonSizeScale,
                                  min: 0.7,
                                  max: 1.3,
                                  divisions: 6,
                                  activeColor: settings.accentColor,
                                  inactiveColor:
                                      (isDark ? Colors.white : Colors.black).withOpacity(0.15),
                                  onChanged: settings.setButtonSizeScale,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _card(
                          isDark: isDark,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 6),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(top: 10, bottom: 4),
                                  child: Text('Форма кнопок',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: isDark ? Colors.white : Colors.black)),
                                ),
                                SegmentedButton<ButtonShape>(
                                  segments: const [
                                    ButtonSegment(
                                        value: ButtonShape.circular,
                                        label: Text('Круглые')),
                                    ButtonSegment(
                                        value: ButtonShape.rounded,
                                        label: Text('Скруглённые')),
                                  ],
                                  selected: {settings.buttonShape},
                                  onSelectionChanged: (v) =>
                                      settings.setButtonShape(v.first),
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.resolveWith(
                                            (states) => states.contains(
                                                    MaterialState.selected)
                                                ? settings.accentColor
                                                : isDark
                                                    ? const Color(0xFF2B2B33)
                                                    : const Color(0xFFE5E5EA)),
                                    foregroundColor:
                                        MaterialStateProperty.resolveWith(
                                            (states) => states.contains(
                                                    MaterialState.selected)
                                                ? Colors.white
                                                : isDark
                                                    ? Colors.white
                                                    : Colors.black),
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
                        _sectionTitle('Точность', isDark),
                        _card(
                          isDark: isDark,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Знаков после запятой',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: isDark ? Colors.white : Colors.black)),
                                    Text('${settings.decimalPlaces}',
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: settings.accentColor,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                                Slider(
                                  value: settings.decimalPlaces.toDouble(),
                                  min: 0,
                                  max: 10,
                                  divisions: 10,
                                  activeColor: settings.accentColor,
                                  inactiveColor:
                                      (isDark ? Colors.white : Colors.black).withOpacity(0.15),
                                  onChanged: (v) =>
                                      settings.setDecimalPlaces(v.round()),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        _sectionTitle('О приложении', isDark),
                        _card(
                          isDark: isDark,
                          child: ListTile(
                            leading: Icon(Icons.info_outline,
                                color: isDark ? Colors.white70 : Colors.black54),
                            title: Text('Версия',
                                style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black)),
                            subtitle: Text(appVersion,
                                style: TextStyle(
                                    color: (isDark ? Colors.white : Colors.black)
                                        .withOpacity(0.55))),
                          ),
                        ),
                        const SizedBox(height: 10),
                        _card(
                          isDark: isDark,
                          child: ListTile(
                            leading: Icon(Icons.code_outlined,
                                color: isDark ? Colors.white70 : Colors.black54),
                            title: Text('Исходный код',
                                style: TextStyle(
                                    color: isDark ? Colors.white : Colors.black)),
                            subtitle: Text('github.com/Yarik528/ecalc',
                                style: TextStyle(
                                    color: (isDark ? Colors.white : Colors.black)
                                        .withOpacity(0.55))),
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

  Widget _colorOption(Color color, AppSettings settings, bool isDark) {
    final bool isSelected = settings.accentColor == color;
    return GestureDetector(
      onTap: () => settings.setAccentColor(color),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(
                  color: isDark ? Colors.white : Colors.black,
                  width: 3,
                )
              : null,
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 20)
            : null,
      ),
    );
  }

  Widget _sectionTitle(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 0, 0, 10),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.45)),
      ),
    );
  }

  Widget _card({required Widget child, required bool isDark}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF26262E), const Color(0xFF1C1C22)]
              : [const Color(0xFFFFFFFF), const Color(0xFFF2F2F7)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.35 : 0.08),
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
    required bool isDark,
  }) {
    return SwitchListTile(
      title: Text(title,
          style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black)),
      subtitle: Text(subtitle,
          style: TextStyle(
              fontSize: 13,
              color: (isDark ? Colors.white : Colors.black).withOpacity(0.55))),
      value: value,
      onChanged: onChanged,
      activeColor: AppSettings.instance.accentColor,
      activeTrackColor: AppSettings.instance.accentColor.withOpacity(0.35),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}