// ignore_for_file: avoid_public_notifier_properties
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:forui/forui.dart';
import 'package:vsync/core/theme/app_theme.dart';

part 'theme_provider.g.dart';

enum AppThemeMode { navy, campus, mono }

bool isDarkAppTheme(AppThemeMode mode) {
  switch (mode) {
    case AppThemeMode.navy:
    case AppThemeMode.mono:
      return true;
    case AppThemeMode.campus:
      return false;
  }
}

@Riverpod(keepAlive: true)
class ThemeController extends _$ThemeController {
  static const String _themeKey = 'app_theme_mode';

  @override
  AppThemeMode build() {
    _loadThemeMode();
    return AppThemeMode.navy;
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeKey) ?? 'navy';
    state = AppThemeMode.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => AppThemeMode.navy,
    );
  }

  Future<void> setThemeMode(AppThemeMode themeMode) async {
    state = themeMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeMode.name);
  }
}

@Riverpod(keepAlive: true)
ThemeData materialTheme(Ref ref) {
  final mode = ref.watch(themeControllerProvider);
  switch (mode) {
    case AppThemeMode.navy:
      return navyTheme;
    case AppThemeMode.campus:
      return campusTheme;
    case AppThemeMode.mono:
      return monoTheme;
  }
}

@Riverpod(keepAlive: true)
FThemeData fTheme(Ref ref) {
  final themeMode = ref.watch(themeControllerProvider);

  return isDarkAppTheme(themeMode)
      ? FThemes.zinc.dark.touch
      : FThemes.zinc.light.touch;
}
