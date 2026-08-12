import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Material 3 Design System for فواتيري app
/// Colors + Typography combined
class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════
  // COLORS
  // ═══════════════════════════════════════════════════

  // ── Primary ──
  static const Color primary = Color(0xFF8BD6B6);
  static const Color onPrimary = Color(0xFF003828);
  static const Color primaryContainer = Color(0xFF065F46);
  static const Color onPrimaryContainer = Color(0xFF8BD6B7);
  static const Color primaryFixed = Color(0xFFA6F2D1);
  static const Color primaryFixedDim = Color(0xFF8BD6B6);
  static const Color onPrimaryFixed = Color(0xFF002116);
  static const Color onPrimaryFixedVariant = Color(0xFF00513B);
  static const Color inversePrimary = Color(0xFF1B6B51);

  // ── Secondary ──
  static const Color secondary = Color(0xFFFFB77D);
  static const Color onSecondary = Color(0xFF4D2600);
  static const Color secondaryContainer = Color(0xFFD97707);
  static const Color onSecondaryContainer = Color(0xFF432100);
  static const Color secondaryFixed = Color(0xFFFFDCC3);
  static const Color secondaryFixedDim = Color(0xFFFFB77D);
  static const Color onSecondaryFixed = Color(0xFF2F1500);
  static const Color onSecondaryFixedVariant = Color(0xFF6E3900);

  // ── Tertiary ──
  static const Color tertiary = Color(0xFFFFB4AB);
  static const Color onTertiary = Color(0xFF690005);
  static const Color tertiaryContainer = Color(0xFFAB000F);
  static const Color onTertiaryContainer = Color(0xFFFFB5AD);
  static const Color tertiaryFixed = Color(0xFFFFDAD6);
  static const Color tertiaryFixedDim = Color(0xFFFFB4AB);
  static const Color onTertiaryFixed = Color(0xFF410002);
  static const Color onTertiaryFixedVariant = Color(0xFF93000B);

  // ── Error ──
  static const Color error = Color(0xFFFFB4AB);
  static const Color onError = Color(0xFF690005);
  static const Color errorContainer = Color(0xFF93000A);
  static const Color onErrorContainer = Color(0xFFFFDAD6);

  // ── Surface ──
  static const Color background = Color(0xFF131313);
  static const Color onBackground = Color(0xFFE5E2E1);
  static const Color surface = Color(0xFF131313);
  static const Color onSurface = Color(0xFFE5E2E1);
  static const Color surfaceVariant = Color(0xFF353534);
  static const Color onSurfaceVariant = Color(0xFFBEC9C2);
  static const Color surfaceDim = Color(0xFF131313);
  static const Color surfaceBright = Color(0xFF393939);
  static const Color surfaceContainerLowest = Color(0xFF0E0E0E);
  static const Color surfaceContainerLow = Color(0xFF1C1B1B);
  static const Color surfaceContainer = Color(0xFF201F1F);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighest = Color(0xFF353534);
  static const Color inverseSurface = Color(0xFFE5E2E1);
  static const Color inverseOnSurface = Color(0xFF313030);

  // ── Outline ──
  static const Color outline = Color(0xFF89938D);
  static const Color outlineVariant = Color(0xFF3F4944);

  // ── Surface Tint ──
  static const Color surfaceTint = Color(0xFF8BD6B6);


  // ── Status Colors ──
static const Color statusApproved = Color(0xFF34D399);
static const Color statusSent     = Color(0xFFFBBF24);

  // ═══════════════════════════════════════════════════
  // TYPOGRAPHY
  // ═══════════════════════════════════════════════════

  static TextStyle _font({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    double? height,
    Color? color,
  }) {
    return GoogleFonts.ibmPlexSansArabic(
      fontSize: fontSize,
      fontWeight: fontWeight,
      height: height,
      color: color,
    );
  }

  // ── Display ──
  static TextStyle displayLarge({Color color = primary}) => _font(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        height: 44 / 36,
        color: color,
      );

  // ── Headline ──
  static TextStyle headlineMedium({Color color = onSurface}) => _font(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        height: 32 / 24,
        color: color,
      );

  static TextStyle headlineSmall({Color color = onSurface}) => _font(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 28 / 20,
        color: color,
      );

  // ── Body ──
  static TextStyle bodyLarge({Color color = onSurface}) => _font(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 28 / 18,
        color: color,
      );

  static TextStyle bodyMedium({Color color = onSurface}) => _font(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 24 / 16,
        color: color,
      );

  // ── Label ──
  static TextStyle labelMedium({Color color = onSurface}) => _font(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 20 / 14,
        color: color,
      );

  static TextStyle labelSmall({Color color = onSurface}) => _font(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 16 / 12,
        color: color,
      );
}