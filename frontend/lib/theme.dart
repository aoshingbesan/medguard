import 'package:flutter/material.dart';

/// ==== Brand tokens (from your Figma) ====
const kBrandPrimary = Color(0xFF176F5B);
const kBrandPrimaryDark = Color(0xFF0F4D40);
const kAppBg = Color(0xFFFFFFFF);

const kTextPrimary = Color(0xFF111827);
const kTextSecondary = Color(0xFF6B7280);

const kSuccess = Color(0xFF22C55E);
const kWarning = Color(0xFFD48806);

const kCardBorder = Color(0xFFE5E7EB);
const kRadius = 16.0;

/// Build the app theme (Material 3)
ThemeData buildAppTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: kBrandPrimary,
    primary: kBrandPrimary,
    surface: kAppBg,
    background: kAppBg,
    onSurface: kTextPrimary,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: kAppBg,

    // NOTE: using system fonts for now (no fontFamily set)
    textTheme: const TextTheme(
      displaySmall: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: kTextPrimary),
      titleLarge:  TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: kTextPrimary),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: kTextPrimary),
      bodyLarge:   TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: kTextPrimary),
      bodyMedium:  TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: kTextSecondary),
      labelLarge:  TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: kAppBg,
      elevation: 0,
      centerTitle: true,
      foregroundColor: kTextPrimary,
      titleTextStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: kTextPrimary),
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: kBrandPrimary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: kBrandPrimary, width: 1.4),
        foregroundColor: kTextPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(kRadius)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(kRadius)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(kRadius),
        borderSide: const BorderSide(color: kBrandPrimary, width: 1.6),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      hintStyle: const TextStyle(color: kTextSecondary),
      labelStyle: const TextStyle(color: kTextSecondary),
    ),

    // Flutter 3.24+ expects CardThemeData here
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: kCardBorder),
        borderRadius: BorderRadius.circular(kRadius),
      ),
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: kAppBg,
      selectedItemColor: kBrandPrimary,
      unselectedItemColor: Color(0xFFD1D5DB),
      showUnselectedLabels: true,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
    ),
  );
}
