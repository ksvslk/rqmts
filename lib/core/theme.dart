import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Light Theme Colors ---
const _lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF677DB7), // Sophisticated Slate Blue
  onPrimary: Colors.white,
  secondary: Color(0xFFFFA726), // Warm Amber/Gold Accent
  onSecondary: Colors.black,
  error: Color(0xFFB00020),
  onError: Colors.white,
  background: Color(0xFFF9FAFC), // Clean, cool off-white
  onBackground: Color(0xFF1C1F26), // Very dark, near-black for text
  surface: Colors.white,
  onSurface: Color(0xFF1C1F26),
);

// --- Dark Theme Colors ---
const _darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF8B9DD4), // Lighter Slate Blue for contrast
  onPrimary: Colors.black,
  secondary: Color(0xFFFFB74D), // A slightly lighter Amber for dark BG
  onSecondary: Colors.black,
  error: Color(0xFFCF6679),
  onError: Colors.black,
  background: Color(0xFF1C1F26), // Rich, blue-tinted charcoal
  onBackground: Color(0xFFF0F2F5), // Soft off-white text
  surface: Color(0xFF252932), // Lighter charcoal for cards
  onSurface: Color(0xFFF0F2F5),
);

// --- Common Theme Components ---
TextTheme _textTheme(ColorScheme colorScheme) {
  return GoogleFonts.poppinsTextTheme(
    ThemeData(brightness: colorScheme.brightness).textTheme.copyWith(
          headlineSmall: TextStyle(
            color: colorScheme.onBackground,
            fontWeight: FontWeight.w600,
            fontSize: 24,
          ),
          bodyLarge: TextStyle(
            color: colorScheme.onSurface,
            fontSize: 16.0,
            height: 1.5,
          ),
          labelLarge: const TextStyle(fontWeight: FontWeight.w600),
        ),
  );
}

ElevatedButtonThemeData _elevatedButtonTheme(ColorScheme colorScheme) {
  return ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      textStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

// --- Exportable Themes ---
final ThemeData lightTheme = ThemeData.from(
  colorScheme: _lightColorScheme,
  textTheme: _textTheme(_lightColorScheme),
).copyWith(
  elevatedButtonTheme: _elevatedButtonTheme(_lightColorScheme),
  scaffoldBackgroundColor: _lightColorScheme.background,
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: _lightColorScheme.primary),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: _lightColorScheme.onBackground,
    contentTextStyle:
        GoogleFonts.poppins(color: _lightColorScheme.background),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
);

final ThemeData darkTheme = ThemeData.from(
  colorScheme: _darkColorScheme,
  textTheme: _textTheme(_darkColorScheme),
).copyWith(
  elevatedButtonTheme: _elevatedButtonTheme(_darkColorScheme),
  scaffoldBackgroundColor: _darkColorScheme.background,
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(foregroundColor: _darkColorScheme.primary),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: _darkColorScheme.onBackground,
    contentTextStyle: GoogleFonts.poppins(color: _darkColorScheme.background),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
);