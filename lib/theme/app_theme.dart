import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData buildLightTheme(Color primary) {
  final base = ThemeData.light();
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
      primary: primary,
      background: const Color(0xFFE5E5E5),
    ),
    scaffoldBackgroundColor: const Color(0xFFE5E5E5),
    textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).apply(
      bodyColor: const Color(0xFF222527),
      displayColor: const Color(0xFF222527),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: Color(0xFF222527),
    ),
    cardColor: Colors.white,
  );
}

ThemeData buildDarkTheme(Color primary) {
  final base = ThemeData.dark();
  return base.copyWith(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
      primary: primary,
      background: const Color(0xFF222527),
    ),
    scaffoldBackgroundColor: const Color(0xFF222527),
    textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    cardColor: const Color(0xFF2F3336),
  );
}
