import 'package:flutter/material.dart';

/// Consistent spacing system for VibeCheck
class AppSpacing {
  AppSpacing._();

  // Base spacing unit (4px)
  static const double base = 4.0;

  // Spacing scale
  static const double xs = base; // 4px
  static const double sm = base * 2; // 8px
  static const double md = base * 3; // 12px
  static const double lg = base * 4; // 16px
  static const double xl = base * 5; // 20px
  static const double xxl = base * 6; // 24px
  static const double xxxl = base * 8; // 32px
  static const double huge = base * 10; // 40px
  static const double massive = base * 12; // 48px
  static const double giant = base * 16; // 64px

  // Padding shortcuts
  static const EdgeInsets paddingXS = EdgeInsets.all(xs);
  static const EdgeInsets paddingSM = EdgeInsets.all(sm);
  static const EdgeInsets paddingMD = EdgeInsets.all(md);
  static const EdgeInsets paddingLG = EdgeInsets.all(lg);
  static const EdgeInsets paddingXL = EdgeInsets.all(xl);
  static const EdgeInsets paddingXXL = EdgeInsets.all(xxl);
  static const EdgeInsets paddingXXXL = EdgeInsets.all(xxxl);
  static const EdgeInsets paddingHuge = EdgeInsets.all(huge);

  // Horizontal padding
  static const EdgeInsets horizontalXS = EdgeInsets.symmetric(horizontal: xs);
  static const EdgeInsets horizontalSM = EdgeInsets.symmetric(horizontal: sm);
  static const EdgeInsets horizontalMD = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets horizontalLG = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets horizontalXL = EdgeInsets.symmetric(horizontal: xl);
  static const EdgeInsets horizontalXXL = EdgeInsets.symmetric(horizontal: xxl);
  static const EdgeInsets horizontalXXXL = EdgeInsets.symmetric(horizontal: xxxl);

  // Vertical padding
  static const EdgeInsets verticalXS = EdgeInsets.symmetric(vertical: xs);
  static const EdgeInsets verticalSM = EdgeInsets.symmetric(vertical: sm);
  static const EdgeInsets verticalMD = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets verticalLG = EdgeInsets.symmetric(vertical: lg);
  static const EdgeInsets verticalXL = EdgeInsets.symmetric(vertical: xl);
  static const EdgeInsets verticalXXL = EdgeInsets.symmetric(vertical: xxl);
  static const EdgeInsets verticalXXXL = EdgeInsets.symmetric(vertical: xxxl);

  // SizedBox shortcuts
  static const SizedBox gapXS = SizedBox(height: xs, width: xs);
  static const SizedBox gapSM = SizedBox(height: sm, width: sm);
  static const SizedBox gapMD = SizedBox(height: md, width: md);
  static const SizedBox gapLG = SizedBox(height: lg, width: lg);
  static const SizedBox gapXL = SizedBox(height: xl, width: xl);
  static const SizedBox gapXXL = SizedBox(height: xxl, width: xxl);
  static const SizedBox gapXXXL = SizedBox(height: xxxl, width: xxxl);
  static const SizedBox gapHuge = SizedBox(height: huge, width: huge);
  static const SizedBox gapMassive = SizedBox(height: massive, width: massive);
  static const SizedBox gapGiant = SizedBox(height: giant, width: giant);

  // Vertical gaps
  static const SizedBox verticalGapXS = SizedBox(height: xs);
  static const SizedBox verticalGapSM = SizedBox(height: sm);
  static const SizedBox verticalGapMD = SizedBox(height: md);
  static const SizedBox verticalGapLG = SizedBox(height: lg);
  static const SizedBox verticalGapXL = SizedBox(height: xl);
  static const SizedBox verticalGapXXL = SizedBox(height: xxl);
  static const SizedBox verticalGapXXXL = SizedBox(height: xxxl);
  static const SizedBox verticalGapHuge = SizedBox(height: huge);
  static const SizedBox verticalGapMassive = SizedBox(height: massive);
  static const SizedBox verticalGapGiant = SizedBox(height: giant);

  // Horizontal gaps
  static const SizedBox horizontalGapXS = SizedBox(width: xs);
  static const SizedBox horizontalGapSM = SizedBox(width: sm);
  static const SizedBox horizontalGapMD = SizedBox(width: md);
  static const SizedBox horizontalGapLG = SizedBox(width: lg);
  static const SizedBox horizontalGapXL = SizedBox(width: xl);
  static const SizedBox horizontalGapXXL = SizedBox(width: xxl);
  static const SizedBox horizontalGapXXXL = SizedBox(width: xxxl);
  static const SizedBox horizontalGapHuge = SizedBox(width: huge);
}

/// Border radius constants
class AppRadius {
  AppRadius._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double full = 9999.0;

  // BorderRadius shortcuts
  static const BorderRadius radiusXS = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius radiusSM = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMD = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLG = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusXL = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius radiusXXL = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius radiusXXXL = BorderRadius.all(Radius.circular(xxxl));
  static const BorderRadius radiusFull = BorderRadius.all(Radius.circular(full));

  // Top-only radius
  static const BorderRadius radiusTopXS = BorderRadius.vertical(top: Radius.circular(xs));
  static const BorderRadius radiusTopSM = BorderRadius.vertical(top: Radius.circular(sm));
  static const BorderRadius radiusTopMD = BorderRadius.vertical(top: Radius.circular(md));
  static const BorderRadius radiusTopLG = BorderRadius.vertical(top: Radius.circular(lg));
  static const BorderRadius radiusTopXL = BorderRadius.vertical(top: Radius.circular(xl));
  static const BorderRadius radiusTopXXL = BorderRadius.vertical(top: Radius.circular(xxl));

  // Bottom-only radius
  static const BorderRadius radiusBottomXS = BorderRadius.vertical(bottom: Radius.circular(xs));
  static const BorderRadius radiusBottomSM = BorderRadius.vertical(bottom: Radius.circular(sm));
  static const BorderRadius radiusBottomMD = BorderRadius.vertical(bottom: Radius.circular(md));
  static const BorderRadius radiusBottomLG = BorderRadius.vertical(bottom: Radius.circular(lg));
  static const BorderRadius radiusBottomXL = BorderRadius.vertical(bottom: Radius.circular(xl));
  static const BorderRadius radiusBottomXXL = BorderRadius.vertical(bottom: Radius.circular(xxl));
}

/// Elevation and shadow constants
class AppElevation {
  AppElevation._();

  static const double none = 0;
  static const double sm = 2;
  static const double md = 4;
  static const double lg = 8;
  static const double xl = 16;
  static const double xxl = 24;

  // Custom glow shadows for dark theme
  static List<BoxShadow> glowSM(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 8,
      spreadRadius: 0,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> glowMD(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.4),
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> glowLG(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.5),
      blurRadius: 24,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glowXL(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.6),
      blurRadius: 40,
      spreadRadius: 0,
      offset: const Offset(0, 12),
    ),
  ];

  // Subtle shadows for cards
  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> cardShadowHover = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 24,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
  ];
}
