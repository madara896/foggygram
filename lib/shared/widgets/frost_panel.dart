import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:foggygram/core/theme/foggy_theme.dart';

/// Core frosted glass card container for Foggygram.
///
/// Features 28px blur backdrop, 160-degree subtle white gradient,
/// inner top highlight rim, deep ambient shadow, and a smooth hover border glow.
class FrostPanel extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final dynamic borderRadius; // accepts double or BorderRadiusGeometry
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final List<BoxShadow>? boxShadow;
  final AlignmentGeometry? alignment;
  final Clip clipBehavior;

  const FrostPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
    this.borderRadius = 26.0,
    this.width,
    this.height,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.boxShadow,
    this.alignment,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  State<FrostPanel> createState() => _FrostPanelState();
}

class _FrostPanelState extends State<FrostPanel> {
  bool _isHovered = false;

  BorderRadius _resolveRadius() {
    if (widget.borderRadius is BorderRadius) {
      return widget.borderRadius as BorderRadius;
    } else if (widget.borderRadius is double) {
      return BorderRadius.circular(widget.borderRadius as double);
    } else if (widget.borderRadius is int) {
      return BorderRadius.circular((widget.borderRadius as int).toDouble());
    }
    return BorderRadius.circular(26.0);
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = _resolveRadius();

    final defaultBorderColor = Colors.white.withValues(alpha: _isHovered ? 0.20 : 0.12);
    final effectiveBorderColor = widget.borderColor ?? defaultBorderColor;
    final effectiveBorderWidth = widget.borderWidth ?? 1.0;

    final defaultBackground = LinearGradient(
      begin: const Alignment(-0.7, -0.8),
      end: const Alignment(0.7, 0.8),
      colors: [
        Colors.white.withValues(alpha: 0.08),
        Colors.white.withValues(alpha: 0.02),
      ],
    );

    Widget content = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: FoggyEasing.easeIn,
          width: widget.width,
          height: widget.height,
          margin: widget.margin,
          alignment: widget.alignment,
          decoration: BoxDecoration(
            borderRadius: effectiveRadius,
            boxShadow: widget.boxShadow ?? [
              BoxShadow(
                offset: const Offset(0, 32),
                blurRadius: 70,
                color: Colors.black.withValues(alpha: 0.50),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: effectiveRadius,
            clipBehavior: widget.clipBehavior,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: FoggyEasing.easeIn,
                padding: widget.padding,
                decoration: BoxDecoration(
                  borderRadius: effectiveRadius,
                  color: widget.backgroundColor,
                  gradient: widget.backgroundColor == null ? defaultBackground : null,
                  border: Border.all(
                    color: effectiveBorderColor,
                    width: effectiveBorderWidth,
                  ),
                ),
                child: Stack(
                  children: [
                    // Inner top specular rim
                    Positioned(
                      top: 0,
                      left: 12,
                      right: 12,
                      child: Container(
                        height: 1,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              Colors.white.withValues(alpha: 0.22),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    widget.child,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return content;
  }
}
