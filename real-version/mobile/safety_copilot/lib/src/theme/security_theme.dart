import 'package:flutter/material.dart';

class SecurityTheme {
  static ThemeData dark() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
    );

    final textTheme = base.textTheme.copyWith(
      headlineMedium: const TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 30,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.0,
        color: Color(0xFFE3F7FF),
      ),
      headlineSmall: const TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: Color(0xFFE3F7FF),
      ),
      titleLarge: const TextStyle(
        fontFamily: 'Orbitron',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
        color: Color(0xFFD6F4FF),
      ),
      bodyLarge: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Color(0xFFC9DCE8),
      ),
      bodyMedium: const TextStyle(
        fontFamily: 'Manrope',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFFAEC4D3),
      ),
    );

    const primary = Color(0xFF00E6B4);
    const secondary = Color(0xFFFFB15A);
    const danger = Color(0xFFFF5F5F);
    const surface = Color(0xFF071929);
    const onSurface = Color(0xFFD9F1FF);
    const outline = Color(0xFF2A4C63);

    return base.copyWith(
      textTheme: textTheme,
      scaffoldBackgroundColor: const Color(0xFF030C16),
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        error: danger,
        surface: surface,
        onSurface: onSurface,
        outline: outline,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: const TextStyle(
          fontFamily: 'Orbitron',
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE8FAFF),
          letterSpacing: 0.8,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x2900E6B4),
        hintStyle: const TextStyle(
          fontFamily: 'Manrope',
          color: Color(0xAA9EC2D6),
          fontWeight: FontWeight.w500,
        ),
        labelStyle: const TextStyle(
          fontFamily: 'Manrope',
          color: Color(0xFFD2EEFF),
          fontWeight: FontWeight.w600,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0x803A6A82)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primary, width: 1.4),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xB8102435),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0x8036647C)),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xAA0A2740),
        side: const BorderSide(color: Color(0x7F2B5870)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        labelStyle: const TextStyle(
          fontFamily: 'Manrope',
          color: Color(0xFFCFE9F5),
          fontWeight: FontWeight.w600,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: const Color(0xFF06211B),
          textStyle: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFFE2F7FF),
          side: const BorderSide(color: Color(0xB055A2C7)),
          textStyle: const TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
