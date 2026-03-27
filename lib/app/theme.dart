import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

@immutable
class PocketShiftColors extends ThemeExtension<PocketShiftColors> {
  const PocketShiftColors({
    required this.softGradientColors,
    required this.cardSurface,
    required this.cardBorder,
    required this.cardShadow,
    required this.navBarSurface,
    required this.navBarInactive,
    required this.subtleSurface,
    required this.subtleBorder,
    required this.chipSurface,
    required this.accentSurface,
    required this.badgeCurrent,
    required this.badgeClosed,
  });

  final List<Color> softGradientColors;
  final Color cardSurface;
  final Color cardBorder;
  final Color cardShadow;
  final Color navBarSurface;
  final Color navBarInactive;
  final Color subtleSurface;
  final Color subtleBorder;
  final Color chipSurface;
  final Color accentSurface;
  final Color badgeCurrent;
  final Color badgeClosed;

  static const light = PocketShiftColors(
    softGradientColors: [Color(0xFFF9F3E7), Color(0xFFE9F0E8), Color(0xFFF5EDE4)],
    cardSurface: Color(0xDBFFFFFF),
    cardBorder: Color(0xB3FFFFFF),
    cardShadow: Color(0x0F16302E),
    navBarSurface: Color(0xF0FFFFFF),
    navBarInactive: Color(0xFF667784),
    subtleSurface: Color(0xFFF4EBDD),
    subtleBorder: Color(0xFFE8DAC8),
    chipSurface: Color(0xBFFFFFFF),
    accentSurface: Color(0xFFE3EEE8),
    badgeCurrent: Color(0xFFE2F0E7),
    badgeClosed: Color(0xFFF4E9DE),
  );

  static const dark = PocketShiftColors(
    softGradientColors: [Color(0xFF161B21), Color(0xFF171D20), Color(0xFF181B21)],
    cardSurface: Color(0xEB1F252D),
    cardBorder: Color(0x18FFFFFF),
    cardShadow: Color(0x2E000000),
    navBarSurface: Color(0xF51A2028),
    navBarInactive: Color(0xFF7E8A96),
    subtleSurface: Color(0xFF272D35),
    subtleBorder: Color(0xFF3A424C),
    chipSurface: Color(0xBF272D35),
    accentSurface: Color(0xFF1E3028),
    badgeCurrent: Color(0xFF1E3028),
    badgeClosed: Color(0xFF332A22),
  );

  @override
  PocketShiftColors copyWith({
    List<Color>? softGradientColors,
    Color? cardSurface,
    Color? cardBorder,
    Color? cardShadow,
    Color? navBarSurface,
    Color? navBarInactive,
    Color? subtleSurface,
    Color? subtleBorder,
    Color? chipSurface,
    Color? accentSurface,
    Color? badgeCurrent,
    Color? badgeClosed,
  }) {
    return PocketShiftColors(
      softGradientColors: softGradientColors ?? this.softGradientColors,
      cardSurface: cardSurface ?? this.cardSurface,
      cardBorder: cardBorder ?? this.cardBorder,
      cardShadow: cardShadow ?? this.cardShadow,
      navBarSurface: navBarSurface ?? this.navBarSurface,
      navBarInactive: navBarInactive ?? this.navBarInactive,
      subtleSurface: subtleSurface ?? this.subtleSurface,
      subtleBorder: subtleBorder ?? this.subtleBorder,
      chipSurface: chipSurface ?? this.chipSurface,
      accentSurface: accentSurface ?? this.accentSurface,
      badgeCurrent: badgeCurrent ?? this.badgeCurrent,
      badgeClosed: badgeClosed ?? this.badgeClosed,
    );
  }

  @override
  PocketShiftColors lerp(PocketShiftColors? other, double t) {
    if (other is! PocketShiftColors) return this;
    return PocketShiftColors(
      softGradientColors: [
        for (var i = 0; i < softGradientColors.length; i++)
          Color.lerp(softGradientColors[i], other.softGradientColors[i], t)!,
      ],
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      cardShadow: Color.lerp(cardShadow, other.cardShadow, t)!,
      navBarSurface: Color.lerp(navBarSurface, other.navBarSurface, t)!,
      navBarInactive: Color.lerp(navBarInactive, other.navBarInactive, t)!,
      subtleSurface: Color.lerp(subtleSurface, other.subtleSurface, t)!,
      subtleBorder: Color.lerp(subtleBorder, other.subtleBorder, t)!,
      chipSurface: Color.lerp(chipSurface, other.chipSurface, t)!,
      accentSurface: Color.lerp(accentSurface, other.accentSurface, t)!,
      badgeCurrent: Color.lerp(badgeCurrent, other.badgeCurrent, t)!,
      badgeClosed: Color.lerp(badgeClosed, other.badgeClosed, t)!,
    );
  }
}

extension PocketShiftColorsX on BuildContext {
  PocketShiftColors get ps => Theme.of(this).extension<PocketShiftColors>()!;
}

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
  ).copyWith(primary: teal, secondary: gold, tertiary: coral, surface: sand, onSurface: ink);

  final baseTextTheme = const TextTheme(
    displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: ink, fontFamily: 'Manrope'),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: ink, fontFamily: 'Manrope'),
    headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: ink, fontFamily: 'Manrope'),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ink, fontFamily: 'Manrope'),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xE017302E), fontFamily: 'Manrope'),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xBD17302E), fontFamily: 'Manrope'),
    labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Manrope'),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: 'Manrope',
    textTheme: baseTextTheme,
    scaffoldBackgroundColor: sand,
    extensions: const [PocketShiftColors.light],
    cupertinoOverrideTheme: const CupertinoThemeData(
      primaryColor: teal,
      scaffoldBackgroundColor: sand,
      textTheme: CupertinoTextThemeData(
        navTitleTextStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: ink, fontFamily: 'Manrope'),
        navLargeTitleTextStyle: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: ink, fontFamily: 'Manrope'),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: ink, fontFamily: 'Manrope'),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Colors.white.withValues(alpha: 0.92),
      indicatorColor: mint,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? teal : ink.withValues(alpha: 0.54));
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
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: ink, fontFamily: 'Manrope'),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: teal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'Manrope'),
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

ThemeData buildDarkAppTheme() {
  const surface = Color(0xFF14181E);
  const onSurface = Color(0xFFE5E1DC);
  const teal = Color(0xFF5A9A94);
  const mint = Color(0xFF243832);
  const gold = Color(0xFFDFB25A);
  const coral = Color(0xFFA37E6A);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: teal,
    brightness: Brightness.dark,
    surface: surface,
  ).copyWith(primary: teal, secondary: gold, tertiary: coral, surface: surface, onSurface: onSurface);

  const baseTextTheme = TextTheme(
    displayLarge: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: onSurface, fontFamily: 'Manrope'),
    displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: onSurface, fontFamily: 'Manrope'),
    headlineMedium: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: onSurface, fontFamily: 'Manrope'),
    titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: onSurface, fontFamily: 'Manrope'),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xE0E5E1DC), fontFamily: 'Manrope'),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xBDE5E1DC), fontFamily: 'Manrope'),
    labelLarge: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Manrope'),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    fontFamily: 'Manrope',
    textTheme: baseTextTheme,
    scaffoldBackgroundColor: surface,
    extensions: const [PocketShiftColors.dark],
    cupertinoOverrideTheme: CupertinoThemeData(
      primaryColor: teal,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: surface,
      textTheme: const CupertinoTextThemeData(
        navTitleTextStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: onSurface,
          fontFamily: 'Manrope',
        ),
        navLargeTitleTextStyle: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: onSurface,
          fontFamily: 'Manrope',
        ),
        textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: onSurface, fontFamily: 'Manrope'),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF1A2028).withValues(alpha: 0.96),
      indicatorColor: mint,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? teal : onSurface.withValues(alpha: 0.54));
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          color: selected ? teal : onSurface.withValues(alpha: 0.6),
          fontFamily: 'Manrope',
        );
      }),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF1F252D).withValues(alpha: 0.92),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: onSurface,
      elevation: 0,
      titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: onSurface, fontFamily: 'Manrope'),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: teal,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, fontFamily: 'Manrope'),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: onSurface,
        side: BorderSide(color: onSurface.withValues(alpha: 0.14)),
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
