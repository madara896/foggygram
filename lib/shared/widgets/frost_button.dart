import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:foggygram/core/theme/foggy_theme.dart';

enum FrostButtonVariant {
  primary,
  ghost,
}

enum FrostButtonSize {
  regular,
  small,
}

/// Frosted glass button with primary and ghost variants, animated hover lift,
/// active press scale, and shimmering hover sweeps.
class FrostButton extends StatefulWidget {
  final String? label;
  final Widget? child;
  final VoidCallback? onPressed;
  final FrostButtonVariant variant;
  final FrostButtonSize size;
  final IconData? icon;
  final bool isLoading;
  final bool isExpanded;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final dynamic borderRadius;

  const FrostButton({
    super.key,
    this.label,
    this.child,
    this.onPressed,
    this.variant = FrostButtonVariant.primary,
    this.size = FrostButtonSize.regular,
    this.icon,
    this.isLoading = false,
    this.isExpanded = false,
    this.width,
    this.height,
    this.padding,
    this.borderRadius,
  });

  factory FrostButton.primary({
    Key? key,
    String? label,
    Widget? child,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isExpanded = false,
    FrostButtonSize size = FrostButtonSize.regular,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    dynamic borderRadius,
  }) =>
      FrostButton(
        key: key,
        label: label,
        child: child,
        onPressed: onPressed,
        variant: FrostButtonVariant.primary,
        size: size,
        icon: icon,
        isLoading: isLoading,
        isExpanded: isExpanded,
        width: width,
        height: height,
        padding: padding,
        borderRadius: borderRadius,
      );

  factory FrostButton.ghost({
    Key? key,
    String? label,
    Widget? child,
    required VoidCallback? onPressed,
    IconData? icon,
    bool isLoading = false,
    bool isExpanded = false,
    FrostButtonSize size = FrostButtonSize.regular,
    double? width,
    double? height,
    EdgeInsetsGeometry? padding,
    dynamic borderRadius,
  }) =>
      FrostButton(
        key: key,
        label: label,
        child: child,
        onPressed: onPressed,
        variant: FrostButtonVariant.ghost,
        size: size,
        icon: icon,
        isLoading: isLoading,
        isExpanded: isExpanded,
        width: width,
        height: height,
        padding: padding,
        borderRadius: borderRadius,
      );

  @override
  State<FrostButton> createState() => _FrostButtonState();
}

class _FrostButtonState extends State<FrostButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  bool _isPressed = false;
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _onHoverChanged(bool hovered) {
    setState(() => _isHovered = hovered);
    if (hovered && widget.variant == FrostButtonVariant.primary) {
      _shimmerController.forward(from: 0.0);
    } else {
      _shimmerController.stop();
      _shimmerController.value = 0.0;
    }
  }

  BorderRadius _resolveRadius() {
    if (widget.borderRadius is BorderRadius) {
      return widget.borderRadius as BorderRadius;
    } else if (widget.borderRadius is double) {
      return BorderRadius.circular(widget.borderRadius as double);
    } else if (widget.borderRadius is int) {
      return BorderRadius.circular((widget.borderRadius as int).toDouble());
    }
    return const BorderRadius.all(Radius.circular(15.0));
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null && !widget.isLoading;
    final isPrimary = widget.variant == FrostButtonVariant.primary;
    final isSmall = widget.size == FrostButtonSize.small;

    final defaultPadding = isSmall
        ? const EdgeInsets.symmetric(horizontal: 16.0, vertical: 9.0)
        : const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0);
    final effectivePadding = widget.padding ?? defaultPadding;
    final fontSize = isSmall ? 13.0 : 15.0;
    final effectiveRadius = _resolveRadius();

    // Dynamic translateY
    double translateY = 0.0;
    if (_isHovered && isEnabled && !_isPressed) {
      translateY = isPrimary ? -2.0 : -1.0;
    }

    // Dynamic scale for active/pressed
    final scale = _isPressed && isEnabled ? 0.97 : 1.0;

    // Background color
    Color backgroundColor;
    if (isPrimary) {
      backgroundColor = _isHovered
          ? Colors.white
          : Colors.white.withValues(alpha: 0.90);
    } else {
      backgroundColor = _isHovered
          ? Colors.white.withValues(alpha: 0.10)
          : Colors.white.withValues(alpha: 0.05);
    }

    // Foreground / text color
    final textColor = isPrimary ? const Color(0xFF000000) : FoggyColors.text;

    // Box shadow
    List<BoxShadow> shadows = [];
    if (isPrimary) {
      if (_isHovered) {
        shadows = [FoggyShadows.buttonHoverShadow];
      } else {
        shadows = [FoggyShadows.buttonShadow];
      }
    } else if (_isHovered) {
      shadows = [FoggyShadows.ghostHoverShadow];
    }

    Widget content;
    if (widget.child != null) {
      content = widget.child!;
    } else {
      content = Row(
        mainAxisSize: widget.isExpanded ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.isLoading) ...[
            SizedBox(
              width: isSmall ? 14 : 16,
              height: isSmall ? 14 : 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            ),
            SizedBox(width: isSmall ? 8 : 10),
          ] else if (widget.icon != null) ...[
            Icon(
              widget.icon,
              size: isSmall ? 15 : 18,
              color: textColor,
            ),
            SizedBox(width: isSmall ? 8 : 10),
          ],
          if (widget.label != null)
            Text(
              widget.label!,
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.011 * fontSize,
              ),
            ),
        ],
      );
    }

    Widget button = MouseRegion(
      onEnter: (_) => _onHoverChanged(true),
      onExit: (_) => _onHoverChanged(false),
      cursor: isEnabled ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTapDown: isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: isEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: isEnabled ? () => setState(() => _isPressed = false) : null,
        onTap: isEnabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: FoggyEasing.easeIn,
          width: widget.width,
          height: widget.height,
          transform: Matrix4.identity()
            ..translate(0.0, translateY)
            ..scale(scale),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: effectiveRadius,
            boxShadow: shadows,
          ),
          child: ClipRRect(
            borderRadius: effectiveRadius,
            child: Stack(
              children: [
                // Backdrop blur for ghost variant
                if (!isPrimary)
                  BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      color: Colors.transparent,
                    ),
                  ),

                // Button body
                AnimatedContainer(
                  duration: const Duration(milliseconds: 600),
                  curve: FoggyEasing.easeIn,
                  padding: effectivePadding,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: effectiveRadius,
                    border: isPrimary
                        ? null
                        : Border.all(
                            color: Colors.white.withValues(alpha: 0.09),
                            width: 1.0,
                          ),
                  ),
                  child: Center(
                    widthFactor: widget.width == null ? 1.0 : null,
                    heightFactor: widget.height == null ? 1.0 : null,
                    child: content,
                  ),
                ),

                // Shimmer sweep effect for primary on hover
                if (isPrimary)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: AnimatedBuilder(
                        animation: _shimmerController,
                        builder: (context, _) {
                          if (_shimmerController.value == 0.0) {
                            return const SizedBox.shrink();
                          }
                          final progress = _shimmerController.value;
                          return FractionallySizedBox(
                            alignment: Alignment(
                              -1.4 + (progress * 2.8),
                              0.0,
                            ),
                            widthFactor: 0.55,
                            child: Transform(
                              transform: Matrix4.skewX(-0.314),
                              alignment: Alignment.center,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: const Alignment(-1.0, 0.0),
                                    end: const Alignment(1.0, 0.0),
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.10),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.isExpanded) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }
}
