import 'package:flutter/material.dart';

/// Modern color palette for VibeCheck
class AppColors {
  AppColors._();

  // Brand Colors - Modern vibrant gradients
  static const Color primaryBlue = Color(0xFF6366F1); // Indigo
  static const Color primaryPurple = Color(0xFF8B5CF6); // Purple
  static const Color accentCyan = Color(0xFF06B6D4); // Cyan
  static const Color accentTeal = Color(0xFF14B8A6); // Teal
  static const Color accentPink = Color(0xFFEC4899); // Pink

  // Background Colors - Deep modern dark
  static const Color backgroundDeep = Color(0xFF0A0A0F); // Almost black with blue tint
  static const Color backgroundPrimary = Color(0xFF0F0F1A); // Dark navy
  static const Color backgroundSecondary = Color(0xFF16161F); // Slightly lighter
  static const Color backgroundTertiary = Color(0xFF1C1C28); // Card background

  // Surface Colors - Glass morphism ready
  static const Color surfaceGlass = Color(0xFF1E1E2E); // Glass surface
  static const Color surfaceElevated = Color(0xFF252535); // Elevated surface
  static const Color surfaceHover = Color(0xFF2A2A3C); // Hover state

  // Text Colors - High contrast
  static const Color textPrimary = Color(0xFFFFFFFF); // Pure white
  static const Color textSecondary = Color(0xFFA5B4FC); // Light indigo
  static const Color textTertiary = Color(0xFF94A3B8); // Slate
  static const Color textMuted = Color(0xFF64748B); // Muted slate
  static const Color textDisabled = Color(0xFF475569); // Disabled

  // Semantic Colors
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color successLight = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444); // Red
  static const Color errorLight = Color(0xFFF87171);
  static const Color info = Color(0xFF3B82F6); // Blue
  static const Color infoLight = Color(0xFF60A5FA);

  // Severity Colors - Enhanced
  static const Color severityCritical = Color(0xFFDC2626);
  static const Color severityHigh = Color(0xFFF97316);
  static const Color severityMedium = Color(0xFFFBBF24);
  static const Color severityLow = Color(0xFF06B6D4);

  // Border & Outline
  static const Color borderSubtle = Color(0xFF1E293B); // Subtle border
  static const Color borderDefault = Color(0xFF334155); // Default border
  static const Color borderStrong = Color(0xFF475569); // Strong border
  static const Color borderGlow = Color(0xFF6366F1); // Glowing border

  // Gradients
  static const List<Color> gradientPrimary = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF8B5CF6), // Purple
  ];

  static const List<Color> gradientSecondary = [
    Color(0xFF06B6D4), // Cyan
    Color(0xFF14B8A6), // Teal
  ];

  static const List<Color> gradientAccent = [
    Color(0xFFEC4899), // Pink
    Color(0xFF8B5CF6), // Purple
  ];

  static const List<Color> gradientSuccess = [
    Color(0xFF10B981), // Emerald
    Color(0xFF14B8A6), // Teal
  ];

  static const List<Color> gradientWarning = [
    Color(0xFFF59E0B), // Amber
    Color(0xFFF97316), // Orange
  ];

  static const List<Color> gradientError = [
    Color(0xFFEF4444), // Red
    Color(0xFFF97316), // Orange
  ];

  // Analysis Type Gradients
  static const List<Color> gradientSecurity = [
    Color(0xFF6366F1), // Indigo
    Color(0xFF3B82F6), // Blue
  ];

  static const List<Color> gradientMonitoring = [
    Color(0xFF10B981), // Emerald
    Color(0xFF14B8A6), // Teal
  ];

  // Overlay Colors
  static const Color overlay = Color(0x80000000); // 50% black
  static const Color overlayLight = Color(0x40000000); // 25% black
  static const Color overlayDark = Color(0xB3000000); // 70% black

  // Shimmer/Loading Colors
  static const Color shimmerBase = Color(0xFF1C1C28);
  static const Color shimmerHighlight = Color(0xFF252535);

  // Create LinearGradient helpers
  static LinearGradient createGradient(List<Color> colors, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: colors,
      begin: begin,
      end: end,
    );
  }

  static LinearGradient get primaryGradient => createGradient(gradientPrimary);
  static LinearGradient get secondaryGradient => createGradient(gradientSecondary);
  static LinearGradient get accentGradient => createGradient(gradientAccent);
  static LinearGradient get successGradient => createGradient(gradientSuccess);
  static LinearGradient get warningGradient => createGradient(gradientWarning);
  static LinearGradient get errorGradient => createGradient(gradientError);
  static LinearGradient get securityGradient => createGradient(gradientSecurity);
  static LinearGradient get monitoringGradient => createGradient(gradientMonitoring);
}
