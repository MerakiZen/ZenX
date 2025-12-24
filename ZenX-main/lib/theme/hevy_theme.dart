import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/design/hevy_colors.dart';
import '../core/design/design_tokens.dart';

/// Hevy-inspired dark theme
class HevyTheme {
  HevyTheme._();

  // Get Inter text style with specified parameters
  static TextStyle _interTextStyle({
    required double fontSize,
    required FontWeight fontWeight,
    required Color color,
    double? height,
    double? letterSpacing,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        
        // Color Scheme
        colorScheme: const ColorScheme.dark(
          primary: HevyColors.primary,
          onPrimary: HevyColors.textPrimary,
          secondary: HevyColors.accent,
          onSecondary: HevyColors.textPrimary,
          error: HevyColors.error,
          onError: HevyColors.textPrimary,
          surface: HevyColors.surface,
          onSurface: HevyColors.textPrimary,
          surfaceContainerHighest: HevyColors.surfaceElevated,
          outline: HevyColors.border,
        ),
        
        // Scaffold
        scaffoldBackgroundColor: HevyColors.background,
        
        // App Bar
        appBarTheme: AppBarTheme(
          backgroundColor: HevyColors.background, // Pure black
          elevation: DesignTokens.elevation0, // 0dp - Flat
          centerTitle: false,
          titleTextStyle: _interTextStyle(
            fontSize: DesignTokens.titleLarge,
            fontWeight: FontWeight.w500,
            color: HevyColors.textPrimary,
            height: 1.25,
            letterSpacing: -0.1,
          ),
          iconTheme: const IconThemeData(
            color: HevyColors.textPrimary,
            size: DesignTokens.iconMedium, // 24dp
          ),
        ),
        
        // Card
        cardTheme: CardThemeData(
          color: HevyColors.cardBackground,
          elevation: DesignTokens.elevation1, // 1dp - Cards at rest
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusM), // 12dp
            side: const BorderSide(color: HevyColors.border, width: 1),
          ),
          margin: EdgeInsets.zero,
        ),
        
        // Input Decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: HevyColors.inputBackground,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
            borderSide: const BorderSide(color: HevyColors.inputBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
            borderSide: const BorderSide(color: HevyColors.inputBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
            borderSide: const BorderSide(color: HevyColors.inputFocused, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(DesignTokens.radiusM),
            borderSide: const BorderSide(color: HevyColors.error),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.paddingM,
            vertical: DesignTokens.paddingM,
          ),
          labelStyle: _interTextStyle(
            color: HevyColors.textSecondary,
            fontSize: DesignTokens.labelMedium,
            fontWeight: FontWeight.w400,
          ),
          hintStyle: _interTextStyle(
            color: HevyColors.textTertiary,
            fontSize: DesignTokens.bodyMedium,
            fontWeight: FontWeight.w300,
          ),
        ),
        
        // Elevated Button
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: HevyColors.buttonPrimary,
            foregroundColor: HevyColors.buttonText,
            elevation: 0,
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.paddingButtonHorizontal,
              vertical: DesignTokens.paddingButtonVertical,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusM), // 12dp
            ),
            textStyle: _interTextStyle(
              fontSize: DesignTokens.labelLarge,
              fontWeight: FontWeight.w500,
              color: HevyColors.buttonText,
            ),
          ),
        ),
        
        // Text Button
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: HevyColors.primary,
            textStyle: _interTextStyle(
              fontSize: DesignTokens.labelLarge,
              fontWeight: FontWeight.w500,
              color: HevyColors.buttonText,
            ),
          ),
        ),
        
        // Outlined Button
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: HevyColors.textPrimary,
            side: const BorderSide(color: HevyColors.border),
            padding: const EdgeInsets.symmetric(
              horizontal: DesignTokens.paddingButtonHorizontal,
              vertical: DesignTokens.paddingButtonVertical,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(DesignTokens.radiusM),
            ),
          ),
        ),
        
        // Bottom Navigation Bar
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: HevyColors.background, // Pure black
          selectedItemColor: HevyColors.primary, // Blue
          unselectedItemColor: HevyColors.textTertiary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        
        // Divider
        dividerTheme: const DividerThemeData(
          color: HevyColors.divider,
          thickness: 1,
          space: 1,
        ),
        
        // Text Theme - Inter font with exact specifications
        textTheme: TextTheme(
          // Display styles - Hero headings
          displayLarge: _interTextStyle(
            fontSize: DesignTokens.displayLarge,
            fontWeight: FontWeight.w200,
            color: HevyColors.textPrimary,
            height: 1.12,
            letterSpacing: -0.2,
          ),
          displayMedium: _interTextStyle(
            fontSize: DesignTokens.displayMedium,
            fontWeight: FontWeight.w200,
            color: HevyColors.textPrimary,
            height: 1.14,
            letterSpacing: -0.1,
          ),
          displaySmall: _interTextStyle(
            fontSize: DesignTokens.displaySmall,
            fontWeight: FontWeight.w200,
            color: HevyColors.textPrimary,
            height: 1.2,
            letterSpacing: -0.1,
          ),
          // Headline styles
          headlineLarge: _interTextStyle(
            fontSize: DesignTokens.headlineLarge,
            fontWeight: FontWeight.w200,
            color: HevyColors.textPrimary,
            height: 1.24,
            letterSpacing: -0.1,
          ),
          headlineMedium: _interTextStyle(
            fontSize: DesignTokens.headlineMedium,
            fontWeight: FontWeight.w200,
            color: HevyColors.textPrimary,
            height: 1.28,
            letterSpacing: -0.05,
          ),
          headlineSmall: _interTextStyle(
            fontSize: DesignTokens.headlineSmall,
            fontWeight: FontWeight.w200,
            color: HevyColors.textPrimary,
            height: 1.3,
            letterSpacing: 0,
          ),
          // Title styles
          titleLarge: _interTextStyle(
            fontSize: DesignTokens.titleLarge,
            fontWeight: FontWeight.w300,
            color: HevyColors.textPrimary,
            height: 1.25,
            letterSpacing: -0.05,
          ),
          titleMedium: _interTextStyle(
            fontSize: DesignTokens.titleMedium,
            fontWeight: FontWeight.w300,
            color: HevyColors.textPrimary,
            height: 1.45,
            letterSpacing: 0.05,
          ),
          titleSmall: _interTextStyle(
            fontSize: DesignTokens.titleSmall,
            fontWeight: FontWeight.w300,
            color: HevyColors.textPrimary,
            height: 1.4,
            letterSpacing: 0.05,
          ),
          // Body styles
          bodyLarge: _interTextStyle(
            fontSize: DesignTokens.bodyLarge,
            fontWeight: FontWeight.w300,
            color: HevyColors.textPrimary,
            height: 1.45,
            letterSpacing: 0.3,
          ),
          bodyMedium: _interTextStyle(
            fontSize: DesignTokens.bodyMedium,
            fontWeight: FontWeight.w300,
            color: HevyColors.textPrimary,
            height: 1.4,
            letterSpacing: 0.2,
          ),
          bodySmall: _interTextStyle(
            fontSize: DesignTokens.bodySmall,
            fontWeight: FontWeight.w300,
            color: HevyColors.textSecondary,
            height: 1.28,
            letterSpacing: 0.3,
          ),
          // Label styles
          labelLarge: _interTextStyle(
            fontSize: DesignTokens.labelLarge,
            fontWeight: FontWeight.w300,
            color: HevyColors.textPrimary,
            height: 1.35,
            letterSpacing: 0.05,
          ),
          labelMedium: _interTextStyle(
            fontSize: DesignTokens.labelMedium,
            fontWeight: FontWeight.w300,
            color: HevyColors.textSecondary,
            height: 1.3,
            letterSpacing: 0.4,
          ),
          labelSmall: _interTextStyle(
            fontSize: DesignTokens.labelSmall,
            fontWeight: FontWeight.w300,
            color: HevyColors.textTertiary,
            height: 1.4,
            letterSpacing: 0.4,
          ),
        ),
      );
}

