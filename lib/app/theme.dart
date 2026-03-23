import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const sand = Color(0xFFF6F0E6);
  const ink = Color(0xFF17302E);
  const teal = Color(0xFF3A6E69);
  const mint = Color(0xFFE4F0EA);
  const gold = Color(0xFFD8A64F);
  const coral = Color(0xFFE7C4AF);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: teal,
    brightness: Brightness.light,
    surface: sand,
  ).copyWith(
    primary: teal,
    secondary: gold,
    tertiary: coral,
    surface: sand,
    onSurface: ink,
  );

  final baseTextTheme = const TextTheme(
    displayLarge: TextStyle(
      fontSize: 34,
      fontWeight: FontWeight.w800,
      color: ink,
      fontFamily: 'Manrope',
    ),
    displayMedium: TextStyle(
      fontSize: 28,
      fontWeight: FontWeight.w800,
      color: ink,
      fontFamily: 'Manrope',
    ),
    headlineMedium: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: ink,
      fontFamily: 'Manrope',
    ),
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w700,
      color: ink,
      fontFamily: 'Manrope',
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Color(0xE017302E),
      fontFamily: 'Manrope',
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xBD17302E),
      fontFamily: 'Manrope',
    ),
    labelLarge: TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      fontFamily: 'Manrope',
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: 'Manrope',
    textTheme: baseTextTheme,
    scaffoldBackgroundColor: sand,
    cupertinoOverrideTheme: const CupertinoThemeData(
      primaryColor: teal,
      scaffoldBackgroundColor: sand,
      textTheme: CupertinoTextThemeData(
        navTitleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: ink,
          fontFamily: 'Manrope',
        ),
        navLargeTitleTextStyle: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: ink,
          fontFamily: 'Manrope',
        ),
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: ink,
          fontFamily: 'Manrope',
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white.withValues(alpha: 0.92),
      indicatorColor: mint,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? teal : ink.withValues(alpha: 0.54),
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          color: selected ? teal : ink.withValues(alpha: 0.6),
          fontFamily: 'Manrope',
        );
      }),
    ),
    cardTheme: CardThemeData(
      color: Colors.white.withValues(alpha: 0.88),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: sand,
      foregroundColor: ink,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: ink,
        fontFamily: 'Manrope',
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: teal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          fontFamily: 'Manrope',
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: ink,
        side: BorderSide(color: ink.withValues(alpha: 0.14)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: teal,
      thumbColor: gold,
      inactiveTrackColor: mint,
      overlayColor: gold.withValues(alpha: 0.16),
    ),
  );
}
