import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  static final ThemeController _instance = ThemeController._internal();
  factory ThemeController() => _instance;
  ThemeController._internal();

  static const _key = 'theme_mode';
  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _mode = ThemeMode.values[prefs.getInt(_key) ?? 0];
  }

  Future<void> toggle() async {
    _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, _mode.index);
    notifyListeners();
  }
}

const _seed = Colors.deepPurple;

/// pixel-style text theme for extra retro flavour (optional)
TextTheme _pixelTextTheme(TextTheme base) => base.copyWith(
      displayLarge: base.displayLarge?.copyWith(letterSpacing: 0),
      displayMedium: base.displayMedium?.copyWith(letterSpacing: 0),
      displaySmall: base.displaySmall?.copyWith(letterSpacing: 0),
      headlineLarge: base.headlineLarge?.copyWith(letterSpacing: 0),
      headlineMedium: base.headlineMedium?.copyWith(letterSpacing: 0),
      headlineSmall: base.headlineSmall?.copyWith(letterSpacing: 0),
      titleLarge: base.titleLarge?.copyWith(letterSpacing: 0),
      titleMedium: base.titleMedium?.copyWith(letterSpacing: 0),
      titleSmall: base.titleSmall?.copyWith(letterSpacing: 0),
      bodyLarge: base.bodyLarge?.copyWith(letterSpacing: 0),
      bodyMedium: base.bodyMedium?.copyWith(letterSpacing: 0),
      bodySmall: base.bodySmall?.copyWith(letterSpacing: 0),
      labelLarge: base.labelLarge?.copyWith(letterSpacing: 0),
      labelMedium: base.labelMedium?.copyWith(letterSpacing: 0),
      labelSmall: base.labelSmall?.copyWith(letterSpacing: 0),
    );

final ThemeData _lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'PixelGame', // <-- custom pixel font
  textTheme: _pixelTextTheme(Typography.material2021().black),
  colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.light),
  appBarTheme: const AppBarTheme(centerTitle: true),
);

final ThemeData _darkTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'PixelGame', // <-- custom pixel font
  textTheme: _pixelTextTheme(Typography.material2021().white),
  colorScheme: ColorScheme.fromSeed(seedColor: _seed, brightness: Brightness.dark),
  appBarTheme: const AppBarTheme(centerTitle: true),
);

ThemeData get appLightTheme => _lightTheme;
ThemeData get appDarkTheme  => _darkTheme;
