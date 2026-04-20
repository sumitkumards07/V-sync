import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ── Functional colors (binary: good / bad) ──────────────────────────────
const Color kSafe = Color(0xFF34D399); // Pastel Mint  >= 75%
const Color kDanger = Color(0xFFFB7185); // Soft Rose    < 75%
const Color kGlassBlue = Color(0xFF0A84FF);
const Color kGlassBlueDeep = Color(0xFF0B3F8A);
const Color kGlassCyan = Color(0xFF64D2FF);
const Color kGlassPurple = Color(0xFF7D7AFF);
const Color kUniversityBlue = kGlassBlue;

// ── Semantic Colors (Timetable) ─────────────────────────────────────
const Color kLec = Color(0xFF60A5FA); // Muted Pastel Blue
const Color kLab = Color(0xFF34D399); // Muted Pastel Mint
const Color kBrk = Color(0xFFFB923C); // Soft Coral/Orange

// ── Midnight Navy (dark) ────────────────────────────────────────────
const ColorScheme navyScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: kGlassBlue,
  onPrimary: Color(0xFF04111F),
  secondary: kGlassCyan,
  onSecondary: Color(0xFF04111F),
  surface: Color(0x1AFFFFFF),
  onSurface: Color(0xFFF4F8FF),
  surfaceContainerHighest: Color(0xFF06111F),
  outline: Color(0x40FFFFFF),
  outlineVariant: Color(0x1FECF6FF),
  error: kDanger,
  onError: Color(0xFFFFFFFF),
);

// ── Clean Campus (light) ────────────────────────────────────────────
const ColorScheme campusScheme = ColorScheme(
  brightness: Brightness.light,
  primary: kGlassBlue,
  onPrimary: Color(0xFFFFFFFF),
  secondary: kGlassCyan,
  onSecondary: Color(0xFFFFFFFF),
  surface: Color(0x8FFFFFFF),
  onSurface: Color(0xFF10243A),
  surfaceContainerHighest: Color(0xFFF4F8FC),
  outline: Color(0x80FFFFFF),
  outlineVariant: Color(0x99E8F0FF),
  error: kDanger,
  onError: Color(0xFFFFFFFF),
);

// ── Monochrome Focus (dark grey) ────────────────────────────────────
const ColorScheme monoScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFFA8A29E),
  onPrimary: Color(0xFF121212),
  secondary: Color(0xFFD6D3D1),
  onSecondary: Color(0xFF121212),
  surface: Color(0xFF1C1917),
  onSurface: Color(0xFFF5F5F4),
  surfaceContainerHighest: Color(0xFF0C0A09),
  outline: Color(0xFF292524),
  outlineVariant: Color(0xFF1C1917),
  error: kDanger,
  onError: Color(0xFFFFFFFF),
);

// ── ThemeData builder ───────────────────────────────────────────────
ThemeData buildTheme(ColorScheme scheme) {
  final isDark = scheme.brightness == Brightness.dark;
  final borderRadius = BorderRadius.circular(24);
  final glassFill = isDark
      ? Colors.white.withOpacity(0.10)
      : Colors.white.withOpacity(0.58);

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: Colors.transparent,
    canvasColor: Colors.transparent,
    dialogBackgroundColor: glassFill,
    fontFamily: 'Inter',

    textTheme: TextTheme(
      headlineLarge: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: scheme.onSurface,
        letterSpacing: -0.8,
      ),
      headlineMedium: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
        letterSpacing: -0.5,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
        letterSpacing: -0.3,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: scheme.onSurface,
      ),
      bodySmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: scheme.onSurface.withOpacity(0.5),
      ),
      labelLarge: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
        letterSpacing: 0.4,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: scheme.onSurface.withOpacity(0.4),
      ),
    ),

    cardTheme: CardThemeData(
      color: glassFill,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(isDark ? 0.18 : 0.08),
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark
          ? Colors.white.withOpacity(0.08)
          : Colors.white.withOpacity(0.46),
      hintStyle: TextStyle(color: scheme.onSurface.withOpacity(0.45)),
      labelStyle: TextStyle(color: scheme.onSurface.withOpacity(0.75)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: Colors.white.withOpacity(isDark ? 0.16 : 0.55),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(
          color: Colors.white.withOpacity(isDark ? 0.14 : 0.48),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadius,
        borderSide: BorderSide(color: scheme.primary, width: 1.4),
      ),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: glassFill,
      modalBackgroundColor: glassFill,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: borderRadius),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      centerTitle: false,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: scheme.onSurface,
        letterSpacing: -0.4,
        fontFamily: 'Inter',
      ),
    ),
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      tileColor: Colors.transparent,
    ),
    dividerColor: scheme.outline.withOpacity(0.18),
    dividerTheme: DividerThemeData(
      color: Colors.white.withOpacity(isDark ? 0.08 : 0.32),
      thickness: 1,
      space: 1,
    ),
  );
}

// Public theme objects
final ThemeData navyTheme = buildTheme(navyScheme);
final ThemeData campusTheme = buildTheme(campusScheme);
final ThemeData monoTheme = buildTheme(monoScheme);
