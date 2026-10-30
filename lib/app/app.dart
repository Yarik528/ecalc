import 'package:flutter/material.dart';
import '../models/settings.dart';
import '../screens/calculator_screen.dart';
import 'theme.dart';

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettings.instance,
      builder: (context, _) {
        final settings = AppSettings.instance;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'eCalc',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: settings.themeMode,
          home: const CalculatorScreen(),
        );
      },
    );
  }
}