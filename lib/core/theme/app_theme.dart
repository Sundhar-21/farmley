import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: DesignColors.primary,
      secondary: DesignColors.primaryLight,
      surface: DesignColors.surface,
      onPrimary: Colors.white,
      onSurface: DesignColors.textPrimary,
      error: DesignColors.error,
    ),
    scaffoldBackgroundColor: DesignColors.background,
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      bodyLarge: GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF111111),
      ),
      bodyMedium: GoogleFonts.poppins(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF111111),
      ),
      bodySmall: GoogleFonts.poppins(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF666666),
      ),
      titleLarge: GoogleFonts.poppins(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF111111),
      ),
      titleMedium: GoogleFonts.poppins(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF111111),
      ),
      titleSmall: GoogleFonts.poppins(
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF111111),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: DesignColors.background,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        color: DesignColors.textPrimary,
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: DesignColors.textPrimary),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.xxl),
        ),
        elevation: 0,
        textStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignRadius.l),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignRadius.l),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(DesignRadius.l),
        borderSide: const BorderSide(color: DesignColors.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: DesignColors.textPrimary,
      contentTextStyle: GoogleFonts.poppins(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignRadius.m),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: DesignColors.primary,
      secondary: DesignColors.secondary,
      surface: const Color(0xFF1A1A1A),
      onPrimary: Colors.black,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF111111),
    textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignColors.primary,
        foregroundColor: Colors.black,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignRadius.xxl),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
