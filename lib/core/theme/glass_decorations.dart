import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'foggy_theme.dart';

/// Glassmorphism decorations and widget primitives precisely matching the CSS design specification.
class GlassDecorations {
  const GlassDecorations._();

  /// Calculates a LinearGradient matching CSS angle 160deg
  static LinearGradient angleGradient160(List<Color> colors, [List<double>? stops]) {
    return LinearGradient(
      begin: const Alignment(-0.342, -0.940),
      end: const Alignment(0.342, 0.940),
      colors: colors,
      stops: stops,
    );
  }

  /// 160-degree linear gradient helper
  static LinearGradient gradient160(List<Color> colors, [List<double>? stops]) {
    return LinearGradient(
      begin: const Alignment(-0.342, -0.940),
      end: const Alignment(0.342, 0.940),
      colors: colors,
      stops: stops,
    );
  }

  // ==========================================
  // 1. SHEET GLASS
  // ==========================================
  // background: LinearGradient(160deg, [rgba(255,255,255,0.11), rgba(255,255,255,0.03)])
  // border: 1px solid rgba(255,255,255,0.16)
  // backdropFilter: blur(34px)
  // shadow: 0 40px 90px rgba(0,0,0,0.6), inset 0 1px 0 rgba(255,255,255,0.2)
  // borderRadius: 26px
  static BoxDecoration sheetDecoration({
    BorderRadiusGeometry? borderRadius,
    List<BoxShadow>? additionalShadows,
  }) {
    return BoxDecoration(
      gradient: gradient160([
        Colors.white.withOpacity(0.11),
        Colors.white.withOpacity(0.03),
      ]),
      borderRadius: borderRadius ?? BorderRadius.circular(FoggyColors.radius),
      border: Border.all(
        color: FoggyColors.stroke, // rgba(255, 255, 255, 0.16)
        width: 1.0,
      ),
      boxShadow: [
        FoggyShadows.shadow, // 0 40px 90px rgba(0, 0, 0, 0.6)
        if (additionalShadows != null) ...additionalShadows,
      ],
    );
  }

  // ==========================================
  // 2. ROW GLASS
  // ==========================================
  // background: LinearGradient(160deg, [rgba(255,255,255,0.075), rgba(255,255,255,0.02)])
  // border: 1px solid rgba(255,255,255,0.09)
  // backdropFilter: blur(20px)
  // borderRadius: 19px
  // hover: translateY(-3px), border becomes 0.16, bg becomes rgba(255,255,255,0.1), shadow: 0 18px 40px rgba(0,0,0,0.4)
  static BoxDecoration rowDecoration({
    bool isHovered = false,
    BorderRadiusGeometry? borderRadius,
  }) {
    return BoxDecoration(
      gradient: isHovered
          ? null
          : gradient160([
              Colors.white.withOpacity(0.075),
              Colors.white.withOpacity(0.02),
            ]),
      color: isHovered ? Colors.white.withOpacity(0.10) : null,
      borderRadius: borderRadius ?? BorderRadius.circular(19.0),
      border: Border.all(
        color: isHovered ? FoggyColors.stroke : FoggyColors.border,
        width: 1.0,
      ),
      boxShadow: isHovered
          ? [FoggyShadows.hoverShadow] // 0 18px 40px rgba(0,0,0,0.4)
          : null,
    );
  }

  // ==========================================
  // 3. TOPBAR GLASS
  // ==========================================
  // background: LinearGradient(160deg, [rgba(255,255,255,0.1), rgba(255,255,255,0.025)])
  // border: 1px solid rgba(255,255,255,0.16)
  // backdropFilter: blur(30px) saturate(150%)
  // borderRadius: 20px
  static BoxDecoration topbarDecoration({
    BorderRadiusGeometry? borderRadius,
  }) {
    return BoxDecoration(
      gradient: gradient160([
        Colors.white.withOpacity(0.10),
        Colors.white.withOpacity(0.025),
      ]),
      borderRadius: borderRadius ?? BorderRadius.circular(20.0),
      border: Border.all(
        color: FoggyColors.stroke, // rgba(255,255,255,0.16)
        width: 1.0,
      ),
    );
  }

  /// Topbar ImageFilter combining blur(30px) and saturate(150%)
  static ImageFilter get topbarFilter {
    const double s = 1.5;
    const double r = 0.2126;
    const double g = 0.7152;
    const double b = 0.0722;
    return ImageFilter.compose(
      outer: ImageFilter.blur(sigmaX: 30.0, sigmaY: 30.0),
      inner: ColorFilter.matrix(<double>[
        r * (1 - s) + s, g * (1 - s),     b * (1 - s),     0, 0,
        r * (1 - s),     g * (1 - s) + s, b * (1 - s),     0, 0,
        r * (1 - s),     g * (1 - s),     b * (1 - s) + s, 0, 0,
        0,               0,               0,               1, 0,
      ]),
    );
  }

  // ==========================================
  // 4. INPUT GLASS
  // ==========================================
  // background: rgba(255,255,255,0.06)
  // border: 1px solid rgba(255,255,255,0.09)
  // borderRadius: 15px
  // padding: 14px 15px
  // hover: border rgba(255,255,255,0.24), bg rgba(255,255,255,0.09)
  // focus: border rgba(255,255,255,0.5), bg rgba(255,255,255,0.1), shadow: 0 0 0 4px rgba(255,255,255,0.07)
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: 15.0, vertical: 14.0);

  static BoxDecoration inputDecoration({
    bool isHovered = false,
    bool isFocused = false,
    BorderRadiusGeometry? borderRadius,
  }) {
    final Color bgColor = isFocused
        ? Colors.white.withOpacity(0.10)
        : isHovered
            ? Colors.white.withOpacity(0.09)
            : Colors.white.withOpacity(0.06);

    final Color borderColor = isFocused
        ? Colors.white.withOpacity(0.50)
        : isHovered
            ? Colors.white.withOpacity(0.24)
            : FoggyColors.border; // rgba(255, 255, 255, 0.09)

    return BoxDecoration(
      color: bgColor,
      borderRadius: borderRadius ?? BorderRadius.circular(FoggyColors.radiusSm), // 15px
      border: Border.all(
        color: borderColor,
        width: 1.0,
      ),
      boxShadow: isFocused ? [FoggyShadows.focusRing] : null,
    );
  }

  // ==========================================
  // 5. BUTTON PRIMARY
  // ==========================================
  // background: rgba(255,255,255,0.92), color: black
  // shadow: 0 12px 34px rgba(255,255,255,0.12)
  // hover: bg #fff, translateY(-2px), shadow: 0 20px 50px rgba(255,255,255,0.22)
  // active: scale(0.97)
  // Shimmer sweep effect (linear gradient skewed overlay)
  static BoxDecoration buttonPrimaryDecoration({
    bool isHovered = false,
    bool isPressed = false,
    BorderRadiusGeometry? borderRadius,
  }) {
    final Color bgColor = isHovered
        ? Colors.white
        : Colors.white.withOpacity(0.92);

    final BoxShadow shadow = isHovered
        ? FoggyShadows.buttonHoverShadow
        : FoggyShadows.buttonShadow;

    return BoxDecoration(
      color: bgColor,
      borderRadius: borderRadius ?? BorderRadius.circular(FoggyColors.radiusSm),
      boxShadow: [shadow],
    );
  }

  // ==========================================
  // 6. BUTTON GHOST
  // ==========================================
  // background: rgba(255,255,255,0.06)
  // border: 1px solid rgba(255,255,255,0.09)
  // hover: bg rgba(255,255,255,0.13), translateY(-1px), shadow: 0 10px 26px rgba(0,0,0,0.35)
  static BoxDecoration buttonGhostDecoration({
    bool isHovered = false,
    bool isPressed = false,
    BorderRadiusGeometry? borderRadius,
  }) {
    final Color bgColor = isHovered
        ? Colors.white.withOpacity(0.13)
        : Colors.white.withOpacity(0.06);

    return BoxDecoration(
      color: bgColor,
      borderRadius: borderRadius ?? BorderRadius.circular(FoggyColors.radiusSm),
      border: Border.all(
        color: FoggyColors.border, // 0.09
        width: 1.0,
      ),
      boxShadow: isHovered ? [FoggyShadows.ghostHoverShadow] : null,
    );
  }

  // ==========================================
  // BACKWARDS COMPATIBILITY HELPERS
  // ==========================================
  static BoxDecoration glassPanel({
    double opacity = 0.06,
    double borderOpacity = 0.12,
    double radius = 16.0,
    Color fillColor = Colors.white,
    Color borderColor = Colors.white,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: fillColor.withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: borderColor.withOpacity(borderOpacity),
        width: 1.0,
      ),
      boxShadow: shadows ?? [FoggyShadows.shadow],
    );
  }

  static BoxDecoration glassCard({
    double opacity = 0.08,
    double borderOpacity = 0.14,
    double radius = 16.0,
  }) {
    return BoxDecoration(
      color: Colors.white.withOpacity(opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: Colors.white.withOpacity(borderOpacity),
        width: 1.0,
      ),
      boxShadow: [FoggyShadows.hoverShadow],
    );
  }

  static BoxDecoration glassInput({
    double opacity = 0.05,
    double borderOpacity = 0.16,
    double radius = 12.0,
    bool isFocused = false,
  }) {
    return inputDecoration(
      isFocused: isFocused,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  static BoxDecoration glassButton({
    double opacity = 0.10,
    double borderOpacity = 0.20,
    double radius = 12.0,
    bool isHovered = false,
    bool isPressed = false,
  }) {
    return buttonGhostDecoration(
      isHovered: isHovered,
      isPressed: isPressed,
      borderRadius: BorderRadius.circular(radius),
    );
  }
}

/// Custom painter for sheet inner top highlight:
/// inset 0 1px 0 rgba(255, 255, 255, 0.2)
class _InsetHighlightPainter extends CustomPainter {
  final double radius;
  final Color highlightColor;

  const _InsetHighlightPainter({
    required this.radius,
    required this.highlightColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = highlightColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.5, 0.5, size.width - 1.0, size.height - 1.0),
      Radius.circular(radius),
    );

    // Clip to upper portion for 1px top highlight
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, math.min(size.height, 4.0)));
    canvas.drawRRect(rect, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _InsetHighlightPainter oldDelegate) {
    return oldDelegate.radius != radius || oldDelegate.highlightColor != highlightColor;
  }
}

/// Sheet glass widget:
/// - background: LinearGradient(begin top-left 160deg angle, colors: [rgba(255,255,255,0.11), rgba(255,255,255,0.03)])
/// - border: 1px solid rgba(255,255,255,0.16)
/// - backdropFilter: blur(34px)
/// - shadow: 0 40px 90px rgba(0,0,0,0.6), inset 0 1px 0 rgba(255,255,255,0.2)
/// - borderRadius: 26px
class SheetGlass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double radius;

  const SheetGlass({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.radius = FoggyColors.radius, // 26px
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: GlassDecorations.sheetDecoration(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );

    Widget result = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 34.0, sigmaY: 34.0),
            child: content,
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _InsetHighlightPainter(
                  radius: radius,
                  highlightColor: Colors.white.withOpacity(0.20), // inset 0 1px 0 rgba(255,255,255,0.2)
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (margin != null) {
      result = Padding(padding: margin!, child: result);
    }
    return result;
  }
}

/// Row glass widget:
/// - background: LinearGradient(160deg, [rgba(255,255,255,0.075), rgba(255,255,255,0.02)])
/// - border: 1px solid rgba(255,255,255,0.09)
/// - backdropFilter: blur(20px)
/// - borderRadius: 19px
/// - hover: translateY(-3px), border becomes 0.16, bg becomes rgba(255,255,255,0.1), shadow: 0 18px 40px rgba(0,0,0,0.4)
class RowGlass extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;

  const RowGlass({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.radius = 19.0,
  });

  @override
  State<RowGlass> createState() => _RowGlassState();
}

class _RowGlassState extends State<RowGlass> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Widget content = AnimatedContainer(
      duration: FoggyEasing.durationFast,
      curve: FoggyEasing.ease,
      transform: Matrix4.translationValues(0.0, _isHovered ? -3.0 : 0.0, 0.0),
      padding: widget.padding,
      decoration: GlassDecorations.rowDecoration(
        isHovered: _isHovered,
        borderRadius: BorderRadius.circular(widget.radius),
      ),
      child: widget.child,
    );

    Widget result = MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
            child: content,
          ),
        ),
      ),
    );

    if (widget.margin != null) {
      result = Padding(padding: widget.margin!, child: result);
    }
    return result;
  }
}

/// Topbar glass widget:
/// - background: LinearGradient(160deg, [rgba(255,255,255,0.1), rgba(255,255,255,0.025)])
/// - border: 1px solid rgba(255,255,255,0.16)
/// - backdropFilter: blur(30px) saturate(150%)
/// - borderRadius: 20px
class TopbarGlass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;

  const TopbarGlass({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.radius = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      padding: padding,
      decoration: GlassDecorations.topbarDecoration(
        borderRadius: BorderRadius.circular(radius),
      ),
      child: child,
    );

    Widget result = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: GlassDecorations.topbarFilter,
        child: content,
      ),
    );

    if (margin != null) {
      result = Padding(padding: margin!, child: result);
    }
    return result;
  }
}

/// Primary button with hover translation (-2px), shadow transition,
/// press scale (0.97), and Shimmer sweep effect (linear gradient skewed overlay).
class PrimaryGlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double radius;

  const PrimaryGlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 22.0, vertical: 14.0),
    this.radius = FoggyColors.radiusSm,
  });

  @override
  State<PrimaryGlassButton> createState() => _PrimaryGlassButtonState();
}

class _PrimaryGlassButtonState extends State<PrimaryGlassButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shimmerController;
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double translateY = _isHovered && !_isPressed ? -2.0 : 0.0;
    final double scale = _isPressed ? 0.97 : 1.0;

    return MouseRegion(
      cursor: widget.onPressed != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: scale,
          duration: FoggyEasing.durationFast,
          curve: FoggyEasing.ease,
          child: AnimatedContainer(
            duration: FoggyEasing.durationFast,
            curve: FoggyEasing.ease,
            transform: Matrix4.translationValues(0.0, translateY, 0.0),
            decoration: GlassDecorations.buttonPrimaryDecoration(
              isHovered: _isHovered,
              isPressed: _isPressed,
              borderRadius: BorderRadius.circular(widget.radius),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.radius),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Content with black text by default
                  Padding(
                    padding: widget.padding,
                    child: DefaultTextStyle.merge(
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      child: IconTheme(
                        data: const IconThemeData(color: Colors.black),
                        child: widget.child,
                      ),
                    ),
                  ),
                  // Shimmer sweep effect (linear gradient skewed overlay)
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _shimmerController,
                      builder: (context, _) {
                        final double progress = _shimmerController.value;
                        final double left = (progress * 3.0) - 1.5;
                        return IgnorePointer(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment(left - 0.5, -1.0),
                                end: Alignment(left + 0.5, 1.0),
                                colors: [
                                  Colors.white.withOpacity(0.0),
                                  Colors.white.withOpacity(0.35),
                                  Colors.white.withOpacity(0.0),
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ghost glass button:
/// - background: rgba(255,255,255,0.06)
/// - border: 1px solid rgba(255,255,255,0.09)
/// - hover: bg rgba(255,255,255,0.13), translateY(-1px), shadow: 0 10px 26px rgba(0,0,0,0.35)
class GhostGlassButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;
  final double radius;

  const GhostGlassButton({
    super.key,
    required this.child,
    this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
    this.radius = FoggyColors.radiusSm,
  });

  @override
  State<GhostGlassButton> createState() => _GhostGlassButtonState();
}

class _GhostGlassButtonState extends State<GhostGlassButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final double translateY = _isHovered && !_isPressed ? -1.0 : 0.0;
    final double scale = _isPressed ? 0.97 : 1.0;

    return MouseRegion(
      cursor: widget.onPressed != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() {
        _isHovered = false;
        _isPressed = false;
      }),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: scale,
          duration: FoggyEasing.durationFast,
          curve: FoggyEasing.ease,
          child: AnimatedContainer(
            duration: FoggyEasing.durationFast,
            curve: FoggyEasing.ease,
            transform: Matrix4.translationValues(0.0, translateY, 0.0),
            padding: widget.padding,
            decoration: GlassDecorations.buttonGhostDecoration(
              isHovered: _isHovered,
              isPressed: _isPressed,
              borderRadius: BorderRadius.circular(widget.radius),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Extension on [Widget] to apply frosted glass effects.
extension GlassWidgetExtension on Widget {
  Widget withGlass({
    double blurX = 20.0,
    double blurY = 20.0,
    double radius = 16.0,
    BoxDecoration? decoration,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    final effectiveDecoration =
        decoration ?? GlassDecorations.sheetDecoration(borderRadius: BorderRadius.circular(radius));

    Widget content = this;
    if (padding != null) {
      content = Padding(padding: padding, child: content);
    }

    Widget glassContainer = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurX, sigmaY: blurY),
        child: Container(
          decoration: effectiveDecoration,
          child: content,
        ),
      ),
    );

    if (margin != null) {
      glassContainer = Padding(padding: margin, child: glassContainer);
    }

    return glassContainer;
  }

  Widget withSheetGlass({
    double radius = FoggyColors.radius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return SheetGlass(
      radius: radius,
      padding: padding,
      margin: margin,
      child: this,
    );
  }

  Widget withRowGlass({
    double radius = 19.0,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    VoidCallback? onTap,
  }) {
    return RowGlass(
      radius: radius,
      padding: padding,
      margin: margin,
      onTap: onTap,
      child: this,
    );
  }

  Widget withTopbarGlass({
    double radius = 20.0,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
  }) {
    return TopbarGlass(
      radius: radius,
      padding: padding,
      margin: margin,
      child: this,
    );
  }
}
