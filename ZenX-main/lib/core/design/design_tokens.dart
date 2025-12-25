/// Design tokens for the ZenX design system
class DesignTokens {
  DesignTokens._();

  // Spacing System (Base Unit: 4dp)
  static const double spacingXXS = 4.0;
  static const double spacingXS = 8.0;
  static const double spacingS = 12.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  static const double spacingXXXL = 64.0;

  // Padding (iOS 26 premium style - generous spacing)
  static const double paddingScreen = 20.0; // Premium balanced
  static const double paddingCard = 20.0; // Premium balanced
  static const double paddingM = 20.0; // Premium balanced
  static const double paddingListItemVertical = 16.0; // Premium balanced
  static const double paddingListItemHorizontal = 20.0; // Premium balanced
  static const double paddingButtonVertical = 14.0; // Premium balanced
  static const double paddingButtonHorizontal = 28.0; // Premium balanced

  // Corner Radius (iOS 26 premium style - more rounded)
  static const double radiusNone = 0.0;
  static const double radiusXS = 10.0; // Premium rounded
  static const double radiusS = 14.0; // Premium rounded
  static const double radiusM = 20.0; // Premium rounded
  static const double radiusL = 28.0; // Premium rounded
  static const double radiusXL = 36.0; // Premium rounded
  static const double radiusFull = 999.0;

  // Elevation Levels (Premium shadows)
  static const double elevation0 = 0.0;
  static const double elevation1 = 2.0; // Increased from 1
  static const double elevation2 = 4.0; // Increased from 3
  static const double elevation3 = 8.0; // Increased from 6
  static const double elevation4 = 12.0; // Increased from 8
  static const double elevation5 = 16.0; // Increased from 12
  
  // Animation Durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationStandard = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 400);
  static const Duration animationVerySlow = Duration(milliseconds: 600);
  
  // Letter Spacing (Minimal Premium - refined)
  static const double letterSpacingTight = -0.2;
  static const double letterSpacingNormal = 0.0;
  static const double letterSpacingWide = 0.2;
  static const double letterSpacingWider = 0.4;
  
  // Line Heights (Minimal Premium - tighter for smaller fonts)
  static const double lineHeightTight = 1.15;
  static const double lineHeightNormal = 1.3;
  static const double lineHeightRelaxed = 1.45;
  static const double lineHeightLoose = 1.6;

  // Icon Sizes
  static const double iconSmall = 16.0;
  static const double iconMedium = 24.0;
  static const double iconLarge = 32.0;
  static const double iconXLarge = 48.0;

  // Typography Sizes (Minimal Premium iOS 26 style)
  static const double displayLarge = 40.0;
  static const double displayMedium = 32.0;
  static const double displaySmall = 26.0;
  static const double headlineLarge = 22.0;
  static const double headlineMedium = 18.0;
  static const double headlineSmall = 16.0;
  static const double titleLarge = 14.0;
  static const double titleMedium = 12.0;
  static const double titleSmall = 11.0;
  static const double bodyLarge = 12.0;
  static const double bodyMedium = 11.0;
  static const double bodySmall = 9.5;
  static const double labelLarge = 11.0;
  static const double labelMedium = 9.0;
  static const double labelSmall = 8.0;

  // Font Weights (Minimalistic - cleaner, lighter)
  static const int fontWeightUltraLight = 100;
  static const int fontWeightThin = 200;
  static const int fontWeightLight = 300;
  static const int fontWeightRegular = 400;
  static const int fontWeightMedium = 500;
  static const int fontWeightSemiBold = 600;
  static const int fontWeightBold = 700;

  // Breakpoints
  static const double breakpointMobile = 600.0;
  static const double breakpointTablet = 1024.0;
}

