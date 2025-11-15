import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// Modern theme configuration for VibeCheck
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    // Color Scheme
    colorScheme: ColorScheme.dark(
      primary: AppColors.primaryBlue,
      secondary: AppColors.accentCyan,
      tertiary: AppColors.primaryPurple,
      surface: AppColors.backgroundTertiary,
      surfaceContainerHighest: AppColors.surfaceElevated,
      error: AppColors.error,
      onPrimary: AppColors.textPrimary,
      onSecondary: AppColors.textPrimary,
      onSurface: AppColors.textPrimary,
      onError: AppColors.textPrimary,
      outline: AppColors.borderDefault,
      outlineVariant: AppColors.borderSubtle,
      shadow: Colors.black,
      scrim: AppColors.overlay,
    ),

    // Scaffold
    scaffoldBackgroundColor: AppColors.backgroundPrimary,

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.backgroundPrimary,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      centerTitle: true,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: AppTypography.titleLarge,
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),
    ),

    // Card Theme
    cardTheme: CardThemeData(
      color: AppColors.backgroundTertiary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusXL,
        side: const BorderSide(
          color: AppColors.borderSubtle,
          width: 1,
        ),
      ),
      margin: AppSpacing.paddingLG,
    ),

    // Elevated Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.lg,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLG,
        ),
        textStyle: AppTypography.buttonMedium,
      ),
    ),

    // Outlined Button Theme
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: AppSpacing.lg,
        ),
        side: const BorderSide(
          color: AppColors.borderDefault,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusLG,
        ),
        textStyle: AppTypography.buttonMedium,
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primaryBlue,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMD,
        ),
        textStyle: AppTypography.buttonMedium,
      ),
    ),

    // Icon Button Theme
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColors.textSecondary,
        highlightColor: AppColors.surfaceHover,
        padding: AppSpacing.paddingMD,
        iconSize: 24,
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceGlass,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.lg,
      ),
      border: OutlineInputBorder(
        borderRadius: AppRadius.radiusLG,
        borderSide: const BorderSide(
          color: AppColors.borderDefault,
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusLG,
        borderSide: const BorderSide(
          color: AppColors.borderDefault,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusLG,
        borderSide: const BorderSide(
          color: AppColors.primaryBlue,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusLG,
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: AppRadius.radiusLG,
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 2,
        ),
      ),
      labelStyle: AppTypography.bodyMedium,
      hintStyle: AppTypography.bodyMedium.copyWith(
        color: AppColors.textMuted,
      ),
      errorStyle: AppTypography.bodySmall.copyWith(
        color: AppColors.error,
      ),
      prefixIconColor: AppColors.textTertiary,
      suffixIconColor: AppColors.textTertiary,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceGlass,
      deleteIconColor: AppColors.textTertiary,
      disabledColor: AppColors.surfaceGlass.withValues(alpha: 0.5),
      selectedColor: AppColors.primaryBlue.withValues(alpha: 0.2),
      secondarySelectedColor: AppColors.accentCyan.withValues(alpha: 0.2),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      labelPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusMD,
        side: const BorderSide(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      labelStyle: AppTypography.labelMedium,
      secondaryLabelStyle: AppTypography.labelMedium,
      brightness: Brightness.dark,
      elevation: 0,
      pressElevation: 0,
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.backgroundTertiary,
      elevation: AppElevation.xl,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusXXL,
        side: const BorderSide(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      titleTextStyle: AppTypography.headlineSmall,
      contentTextStyle: AppTypography.bodyMedium,
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: AppColors.backgroundTertiary,
      modalBackgroundColor: AppColors.backgroundTertiary,
      elevation: AppElevation.xl,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xxl),
        ),
        side: BorderSide(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      modalElevation: AppElevation.xxl,
    ),

    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceElevated,
      contentTextStyle: AppTypography.bodyMedium,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLG,
        side: const BorderSide(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      behavior: SnackBarBehavior.floating,
      elevation: AppElevation.md,
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.borderSubtle,
      thickness: 1,
      space: AppSpacing.xl,
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primaryBlue,
      linearTrackColor: AppColors.surfaceGlass,
      circularTrackColor: AppColors.surfaceGlass,
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.textPrimary;
        }
        return AppColors.textTertiary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryBlue;
        }
        return AppColors.surfaceGlass;
      }),
      trackOutlineColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.transparent;
        }
        return AppColors.borderDefault;
      }),
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryBlue;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(AppColors.textPrimary),
      side: const BorderSide(
        color: AppColors.borderDefault,
        width: 2,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusXS,
      ),
    ),

    // Radio Theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.primaryBlue;
        }
        return AppColors.borderDefault;
      }),
    ),

    // Slider Theme
    sliderTheme: SliderThemeData(
      activeTrackColor: AppColors.primaryBlue,
      inactiveTrackColor: AppColors.surfaceGlass,
      thumbColor: AppColors.textPrimary,
      overlayColor: AppColors.primaryBlue.withValues(alpha: 0.2),
      valueIndicatorColor: AppColors.surfaceElevated,
      valueIndicatorTextStyle: AppTypography.labelSmall,
    ),

    // Tooltip Theme
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.radiusMD,
        border: Border.all(
          color: AppColors.borderDefault,
          width: 1,
        ),
      ),
      textStyle: AppTypography.bodySmall,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
    ),

    // Badge Theme
    badgeTheme: const BadgeThemeData(
      backgroundColor: AppColors.error,
      textColor: AppColors.textPrimary,
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
    ),

    // Navigation Bar Theme
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.backgroundTertiary,
      indicatorColor: AppColors.primaryBlue.withValues(alpha: 0.2),
      labelTextStyle: WidgetStateProperty.all(AppTypography.labelSmall),
      iconTheme: WidgetStateProperty.all(
        const IconThemeData(
          color: AppColors.textTertiary,
          size: 24,
        ),
      ),
      height: 80,
      elevation: 0,
    ),

    // List Tile Theme
    listTileTheme: ListTileThemeData(
      tileColor: AppColors.backgroundTertiary,
      selectedTileColor: AppColors.surfaceHover,
      iconColor: AppColors.textTertiary,
      textColor: AppColors.textPrimary,
      titleTextStyle: AppTypography.bodyLarge,
      subtitleTextStyle: AppTypography.bodySmall,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusLG,
      ),
    ),

    // Text Selection Theme
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: AppColors.primaryBlue,
      selectionColor: AppColors.primaryBlue.withValues(alpha: 0.3),
      selectionHandleColor: AppColors.primaryBlue,
    ),

    // Extensions
    extensions: const <ThemeExtension<dynamic>>[],
  );
}
