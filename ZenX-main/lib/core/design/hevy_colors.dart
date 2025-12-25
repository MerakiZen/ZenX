import 'package:flutter/material.dart';

/// Hevy-inspired color palette
/// Dark, modern, fitness-focused design
class HevyColors {
  HevyColors._();

  // Primary Brand Colors (Blue accents - only for buttons/icons)
  static const Color primary = Color(0xFF3B82F6); // Bright blue
  static const Color primaryDark = Color(0xFF2563EB);
  static const Color primaryLight = Color(0xFF60A5FA);
  
  // Background Colors (Jet Black - iOS 26 glassy matte)
  static const Color background = Color(0xFF000000); // Pure jet black
  static const Color surface = Color(0xFF000000); // Jet black
  static const Color surfaceElevated = Color(0xFF000000); // Jet black
  static const Color cardBackground = Color(0xFF000000); // Jet black
  
  // Glassmorphism Colors (iOS 26 premium glass style)
  static Color get glassSurface => Colors.black.withValues(alpha: 0.75); // Premium matte black glass
  static Color get glassCard => Colors.black.withValues(alpha: 0.65); // Premium transparent glass
  static Color get glassOverlay => Colors.black.withValues(alpha: 0.7); // Premium dark overlay
  static Color get glassBorder => Colors.white.withValues(alpha: 0.12); // Premium subtle white border
  static Color get glassBorderSubtle => Colors.white.withValues(alpha: 0.06); // Ultra subtle border
  static Color get glassHighlight => Colors.white.withValues(alpha: 0.04); // Premium highlight
  
  // Text Colors (White)
  static const Color textPrimary = Color(0xFFFFFFFF); // Pure white
  static const Color textSecondary = Color(0xFF9CA3AF); // Light grey
  static const Color textTertiary = Color(0xFF6B7280); // Medium grey
  
  // Accent Colors
  static const Color accent = Color(0xFF10B981); // Green for success
  static const Color accentOrange = Color(0xFFF59E0B); // Orange
  static const Color accentRed = Color(0xFFEF4444); // Red for errors
  
  // Status Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Border/Divider (iOS 26 premium glass style - jet black)
  static const Color border = Color(0x1FFFFFFF); // Premium glass border (12% white)
  static const Color divider = Color(0x0FFFFFFF); // Premium glass divider (6% white)
  static Color get borderGlass => Colors.white.withValues(alpha: 0.12); // Premium glass border
  static Color get dividerGlass => Colors.white.withValues(alpha: 0.08); // Premium glass divider
  
  // Input Colors (Jet black premium)
  static const Color inputBackground = Color(0xFF000000); // Jet black
  static const Color inputBorder = Color(0x1FFFFFFF); // Premium glass border (12% white)
  static const Color inputFocused = primary;
  
  // Button Colors
  static const Color buttonPrimary = primary; // Blue
  static const Color buttonSecondary = Color(0xFF000000); // Jet black
  static const Color buttonText = textPrimary; // White
  
  // Premium Gradients
  static LinearGradient get primaryGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, primary, primaryDark],
  );
  
  static LinearGradient get successGradient => const LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF34D399), accent],
  );
  
  // Premium Shadows (iOS 26 premium glass style)
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.85),
      blurRadius: 40,
      offset: const Offset(0, 12),
      spreadRadius: -10,
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.05),
      blurRadius: 2,
      offset: const Offset(0, 1),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.02),
      blurRadius: 1,
      offset: const Offset(0, -1),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get cardShadowElevated => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.95),
      blurRadius: 50,
      offset: const Offset(0, 18),
      spreadRadius: -12,
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.06),
      blurRadius: 3,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.03),
      blurRadius: 1,
      offset: const Offset(0, -1),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: primary.withValues(alpha: 0.6),
      blurRadius: 24,
      offset: const Offset(0, 10),
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.1),
      blurRadius: 1,
      offset: const Offset(0, 1),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> get glassShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.8),
      blurRadius: 45,
      offset: const Offset(0, 12),
      spreadRadius: -15,
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.05),
      blurRadius: 2,
      offset: const Offset(0, 1),
      spreadRadius: 0,
    ),
    BoxShadow(
      color: Colors.white.withValues(alpha: 0.02),
      blurRadius: 1,
      offset: const Offset(0, -1),
      spreadRadius: 0,
    ),
  ];
  
  // Workout Status Colors
  static const Color workoutActive = Color(0xFF10B981);
  static const Color workoutCompleted = Color(0xFF6366F1);
  static const Color workoutPlanned = Color(0xFF64748B);
  
  // Exercise Category Colors
  static const Color categoryChest = Color(0xFFEF4444);
  static const Color categoryBack = Color(0xFF3B82F6);
  static const Color categoryLegs = Color(0xFF10B981);
  static const Color categoryShoulders = Color(0xFFF59E0B);
  static const Color categoryArms = Color(0xFF8B5CF6);
  static const Color categoryCore = Color(0xFFEC4899);
}

