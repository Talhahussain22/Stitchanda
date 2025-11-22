import 'package:flutter/material.dart';

const Color primaryColorLight = Color(0xFFDEA666);
const Color primaryDarkColor = Color(0xFF8E7051);
const Color primaryLightColor = Color(0xFFE6BA88);

const Color secondaryColorLight = Color(0xFF5B4632);
const Color successColorLight = Color(0xFF3FA34D);
const Color warningColorLight = Color(0xFFF59E0B);
const Color errorColorLight = Color(0xFFDC2626);
const Color infoColorLight = Color(0xFF4F46E5);

const Color backgroundLight = Color(0xFFFFFDF9);
const Color surfaceLight = Color(0xFFFFFFFF);
const Color outlineLight = Color(0xFFE5E1DA);

ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  fontFamily: 'Roboto',
  primaryColor: primaryColorLight,
  scaffoldBackgroundColor: backgroundLight,
  cardColor: surfaceLight,
  disabledColor: const Color(0xFFA0A4A8),
  hintColor: const Color(0xFF9CA3AF),

  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: primaryColorLight,
    onPrimary: Colors.white,
    secondary: secondaryColorLight,
    onSecondary: Colors.white,
    error: errorColorLight,
    onError: Colors.white,
    surface: surfaceLight,
    onSurface: Color(0xFF27251F),
    surfaceContainerHighest: Color(0xFFF5EFE6),
    outline: outlineLight,
    tertiary: infoColorLight,
    onTertiary: Colors.white,
  ),

  textTheme: const TextTheme(
    displayLarge: TextStyle(fontSize: 48, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: Color(0xFF27251F)),
    displayMedium: TextStyle(fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -0.25, color: Color(0xFF27251F)),
    headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Color(0xFF27251F)),
    headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, color: Color(0xFF27251F)),
    titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF27251F)),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF3F3A34)),
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Color(0xFF3F3A34)),
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF5C5852)),
    labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white),
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: surfaceLight,
    foregroundColor: primaryDarkColor,
    elevation: 0,
    centerTitle: true,
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.black12,
    titleTextStyle: TextStyle(
      color: primaryDarkColor,
      fontWeight: FontWeight.w700,
      fontSize: 20,
      letterSpacing: 0.2,
    ),
  ),

  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColorLight,
      foregroundColor: Colors.white,
      elevation: 2,
      shadowColor: primaryDarkColor.withValues(alpha: 0.25),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3),
    ),
  ),

  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: primaryDarkColor,
      foregroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    ),
  ),

  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primaryDarkColor,
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
    ),
  ),

  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: primaryDarkColor,
      side: const BorderSide(color: primaryLightColor, width: 1.2),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    ),
  ),

  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF8F6F2),
    hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: outlineLight),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: outlineLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: primaryColorLight, width: 1.6),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: errorColorLight),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: errorColorLight, width: 1.4),
    ),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: primaryDarkColor,
    foregroundColor: Colors.white,
    elevation: 3,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
  ),

  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Color(0xFF2E2A24),
    behavior: SnackBarBehavior.floating,
    contentTextStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
  ),

  cardTheme: CardTheme(
    color: surfaceLight,
    elevation: 1.5,
    shadowColor: Colors.black.withValues(alpha: 0.06),
    margin: const EdgeInsets.all(12),
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),

  dividerTheme: const DividerThemeData(
    color: outlineLight,
    thickness: 1,
    space: 1,
  ),

  listTileTheme: const ListTileThemeData(
    iconColor: primaryDarkColor,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
  ),

  iconTheme: const IconThemeData(color: primaryDarkColor),

  tabBarTheme: const TabBarTheme(
    labelColor: primaryDarkColor,
    unselectedLabelColor: Color(0xFF8C847B),
    indicatorSize: TabBarIndicatorSize.label,
  ),

  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: surfaceLight,
    selectedItemColor: primaryDarkColor,
    unselectedItemColor: Color(0xFF8C847B),
    type: BottomNavigationBarType.fixed,
    elevation: 8,
  ),

  chipTheme: ChipThemeData(
    backgroundColor: const Color(0xFFF1EBE2),
    selectedColor: primaryLightColor,
    disabledColor: const Color(0xFFE7E1D8),
    labelStyle: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF3F3A34)),
    secondaryLabelStyle: const TextStyle(fontWeight: FontWeight.w700, color: Colors.white),
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    side: const BorderSide(color: outlineLight),
  ),

  tooltipTheme: TooltipThemeData(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    margin: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: const Color(0xFF2E2A24),
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 6)),
      ],
    ),
    textStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
  ),

  dialogTheme: const DialogTheme(
    backgroundColor: surfaceLight,
    surfaceTintColor: Colors.transparent,
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
  ),

  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: surfaceLight,
    surfaceTintColor: Colors.transparent,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    elevation: 8,
    clipBehavior: Clip.antiAlias,
  ),

  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: primaryDarkColor,
    linearTrackColor: outlineLight,
    circularTrackColor: outlineLight,
  ),

  // Subtle page transitions for polish
  pageTransitionsTheme: const PageTransitionsTheme(
    builders: {
      TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
    },
  ),
);
