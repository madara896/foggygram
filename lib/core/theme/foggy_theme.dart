import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'glass_decorations.dart';

/// Design system color palette for Foggygram precisely matching the CSS design specification:
/// ```css
/// :root {
///   --radius: 26px;
///   --radius-sm: 15px;
///   --stroke: rgba(255, 255, 255, 0.16);
///   --stroke-soft: rgba(255, 255, 255, 0.09);
///   --text: #f5f5f7;
///   --muted: rgba(245, 245, 247, 0.55);
///   --shadow: 0 40px 90px rgba(0, 0, 0, 0.6);
///   --ease: cubic-bezier(0.22, 0.61, 0.36, 1);
///   --ease-in: cubic-bezier(0.42, 0, 1, 1);
///   --base: #000;
///   --border: rgba(255, 255, 255, 0.09);
/// }
/// ```
class FoggyColors {
  const FoggyColors._();

  // Core CSS variables
  static const Color base = Color(0xFF000000); // pure black background
  static const Color text = Color(0xFFF5F5F7); // primary text
  static final Color muted = const Color(0xFFF5F5F7).withOpacity(0.55); // secondary text
  static final Color stroke = Colors.white.withOpacity(0.16); // borders
  static final Color strokeSoft = Colors.white.withOpacity(0.09); // subtle borders
  static final Color border = Colors.white.withOpacity(0.09); // border alias

  static const double radius = 26.0;
  static const double radiusSm = 15.0;

  // Compatibility aliases for existing Foggygram codebase
  static const Color foggyBlack = base;
  static const Color foggyDark = Color(0xFF101012);
  static final Color foggyMid = strokeSoft;
  static const Color foggyGrey = Color(0xFF757577);
  static final Color foggyLight = muted;
  static const Color foggyMist = Color(0xFFB0B0B5);
  static const Color foggyCloud = text;
  static const Color foggyWhite = text;

  // Glass overlay colors
  static final Color glassSurface = Colors.white.withOpacity(0.06);
  static final Color glassBorder = stroke;
  static final Color glassHighlight = Colors.white.withOpacity(0.20);
}

/// Easing curves and transition durations matching CSS specification:
/// --ease: cubic-bezier(0.22, 0.61, 0.36, 1)
/// --ease-in: cubic-bezier(0.42, 0, 1, 1)
class FoggyEasing {
  const FoggyEasing._();

  static const Cubic ease = Cubic(0.22, 0.61, 0.36, 1.0);
  static const Cubic easeIn = Cubic(0.42, 0.0, 1.0, 1.0);

  static const Duration duration = Duration(milliseconds: 600); // CSS 0.6s
  static const Duration durationFast = Duration(milliseconds: 400); // CSS 0.4s
  static const Duration durationSlow = Duration(milliseconds: 900); // CSS 0.9s
}

/// Typography tokens based on Google Fonts Inter with precise letterSpacing and line weights.
class FoggyTextStyles {
  const FoggyTextStyles._();

  static const String _defaultFontFamily = 'Inter';

  // Base font style generator with fallback letterSpacing: -0.011 * fontSize
  static TextStyle _font({
    required double fontSize,
    FontWeight fontWeight = FontWeight.w400,
    double? letterSpacing,
    Color? color,
    double? height,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing ?? (-0.011 * fontSize),
      color: color ?? FoggyColors.text,
      height: height,
      decoration: decoration,
    );
  }

  // Specified CSS text styles
  // heading: 22px, weight 700, letterSpacing: -0.02em
  static TextStyle get heading => _font(
        fontSize: 22.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 22.0,
        color: FoggyColors.text,
      );

  // sheetTitle: 19px, weight 700, letterSpacing: -0.02em
  static TextStyle get sheetTitle => _font(
        fontSize: 19.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 19.0,
        color: FoggyColors.text,
      );

  // appTitle: 17px, weight 700, letterSpacing: -0.02em
  static TextStyle get appTitle => _font(
        fontSize: 17.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 17.0,
        color: FoggyColors.text,
      );

  // body: 15px, weight 400
  static TextStyle get body => _font(
        fontSize: 15.0,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.011 * 15.0,
        color: FoggyColors.text,
        height: 1.45,
      );

  // bodySmall: 14px
  static TextStyle get bodySmall => _font(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.011 * 14.0,
        color: FoggyColors.text,
        height: 1.4,
      );

  // caption: 13px, color muted
  static TextStyle get caption => _font(
        fontSize: 13.0,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.011 * 13.0,
        color: FoggyColors.muted,
      );

  // label: 12.5px, weight 500, color muted, letterSpacing: 0.01em
  static TextStyle get label => _font(
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.01 * 12.5,
        color: FoggyColors.muted,
      );

  // chip: 10.5px, uppercase, letterSpacing: 0.06em
  static TextStyle get chip => _font(
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.06 * 10.5,
        color: FoggyColors.text,
      );

  // Additional backwards-compatible styles for Foggygram views
  static TextStyle get titleLarge => _font(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 28.0,
        color: FoggyColors.text,
      );

  static TextStyle get subheading => _font(
        fontSize: 16.0,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.015 * 16.0,
        color: FoggyColors.muted,
      );

  static TextStyle get bodyMedium => _font(
        fontSize: 13.0,
        fontWeight: FontWeight.w400,
        letterSpacing: -0.011 * 13.0,
        color: FoggyColors.text,
        height: 1.35,
      );

  static TextStyle get code => GoogleFonts.jetBrainsMono(
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        color: FoggyColors.text,
      );
}

/// Box shadow tokens matching CSS specifications:
/// --shadow: 0 40px 90px rgba(0, 0, 0, 0.6)
class FoggyShadows {
  const FoggyShadows._();

  // Primary sheet shadow: 0 40px 90px rgba(0, 0, 0, 0.6)
  static final BoxShadow shadow = BoxShadow(
    offset: const Offset(0, 40),
    blurRadius: 90,
    spreadRadius: 0,
    color: Colors.black.withOpacity(0.6),
  );

  // Row hover shadow: 0 18px 40px rgba(0, 0, 0, 0.4)
  static final BoxShadow hoverShadow = BoxShadow(
    offset: const Offset(0, 18),
    blurRadius: 40,
    spreadRadius: 0,
    color: Colors.black.withOpacity(0.4),
  );

  // Button primary shadow: 0 12px 34px rgba(255, 255, 255, 0.12)
  static final BoxShadow buttonShadow = BoxShadow(
    offset: const Offset(0, 12),
    blurRadius: 34,
    spreadRadius: 0,
    color: Colors.white.withOpacity(0.12),
  );

  // Button hover shadow: 0 20px 50px rgba(255, 255, 255, 0.22)
  static final BoxShadow buttonHoverShadow = BoxShadow(
    offset: const Offset(0, 20),
    blurRadius: 50,
    spreadRadius: 0,
    color: Colors.white.withOpacity(0.22),
  );

  // Button ghost hover shadow: 0 10px 26px rgba(0, 0, 0, 0.35)
  static final BoxShadow ghostHoverShadow = BoxShadow(
    offset: const Offset(0, 10),
    blurRadius: 26,
    spreadRadius: 0,
    color: Colors.black.withOpacity(0.35),
  );

  // Focus ring glow: 0 0 0 4px rgba(255, 255, 255, 0.07)
  static final BoxShadow focusRing = BoxShadow(
    offset: Offset.zero,
    blurRadius: 0,
    spreadRadius: 4,
    color: Colors.white.withOpacity(0.07),
  );
}

/// Convenience decoration tokens for Foggygram UI.
class FoggyDecorations {
  const FoggyDecorations._();

  static BoxDecoration get glassDecoration => GlassDecorations.sheetDecoration();

  static BoxDecoration get cardDecoration => BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(FoggyColors.radiusSm),
        border: Border.all(color: FoggyColors.strokeSoft, width: 1.0),
      );

  static InputDecoration inputDecoration({
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool isFocused = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: FoggyTextStyles.bodySmall.copyWith(color: FoggyColors.muted),
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isFocused
          ? Colors.white.withOpacity(0.10)
          : Colors.white.withOpacity(0.06),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FoggyColors.radiusSm),
        borderSide: BorderSide(color: FoggyColors.strokeSoft, width: 1.0),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FoggyColors.radiusSm),
        borderSide: BorderSide(color: FoggyColors.strokeSoft, width: 1.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(FoggyColors.radiusSm),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.50), width: 1.0),
      ),
    );
  }
}

/// Complete application theme configured for pure black aesthetic with glass tokens.
class FoggyTheme {
  const FoggyTheme._();

  static ThemeData get darkTheme {
    final baseTextTheme = Typography.material2021().white;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: FoggyColors.base,
      canvasColor: FoggyColors.base,
      cardColor: Colors.white.withOpacity(0.04),
      dividerColor: FoggyColors.border,
      fontFamily: GoogleFonts.inter().fontFamily,
      colorScheme: ColorScheme.dark(
        surface: FoggyColors.base,
        onSurface: FoggyColors.text,
        primary: FoggyColors.text,
        onPrimary: FoggyColors.base,
        secondary: FoggyColors.muted,
        onSecondary: FoggyColors.base,
        error: const Color(0xFFFF453A),
        onError: FoggyColors.base,
        outline: FoggyColors.strokeSoft,
        outlineVariant: FoggyColors.stroke,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: FoggyTextStyles.titleLarge,
        headlineMedium: FoggyTextStyles.heading,
        titleLarge: FoggyTextStyles.sheetTitle,
        titleMedium: FoggyTextStyles.appTitle,
        titleSmall: FoggyTextStyles.subheading,
        bodyLarge: FoggyTextStyles.body,
        bodyMedium: FoggyTextStyles.bodySmall,
        bodySmall: FoggyTextStyles.caption,
        labelLarge: FoggyTextStyles.label,
        labelMedium: FoggyTextStyles.label,
        labelSmall: FoggyTextStyles.chip,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: FoggyTextStyles.appTitle,
        iconTheme: const IconThemeData(color: FoggyColors.text),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      dividerTheme: DividerThemeData(
        color: FoggyColors.border,
        thickness: 1,
        space: 1,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.dragged)) {
            return Colors.white.withOpacity(0.35);
          }
          return Colors.white.withOpacity(0.15);
        }),
        radius: const Radius.circular(8),
        thickness: WidgetStateProperty.all(5),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: FoggyColors.strokeSoft),
          boxShadow: [
            BoxShadow(
              offset: const Offset(0, 8),
              blurRadius: 20,
              color: Colors.black.withOpacity(0.4),
            ),
          ],
        ),
        textStyle: FoggyTextStyles.caption.copyWith(color: FoggyColors.text),
      ),
    );
  }
}
