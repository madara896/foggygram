import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:foggygram/core/theme/foggy_theme.dart';

/// Glassmorphism styled text input field with animated focus state,
/// outer glow ring, custom cursor, and frosted background.
class FrostInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? maxLines;
  final int? minLines;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final bool showBorder;
  final dynamic borderRadius;
  final EdgeInsetsGeometry? contentPadding;

  const FrostInput({
    super.key,
    this.controller,
    this.hintText,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.autofocus = false,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.showBorder = true,
    this.borderRadius = 15.0,
    this.contentPadding,
  });

  @override
  State<FrostInput> createState() => _FrostInputState();
}

class _FrostInputState extends State<FrostInput> {
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _internalFocusNode = false;

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
  void initState() {
    super.initState();
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _internalFocusNode = true;
    }
    _isFocused = _focusNode.hasFocus;
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(covariant FrostInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      if (_internalFocusNode) {
        _focusNode.removeListener(_handleFocusChange);
        _focusNode.dispose();
        _internalFocusNode = false;
      }
      if (widget.focusNode != null) {
        _focusNode = widget.focusNode!;
      } else {
        _focusNode = FocusNode();
        _internalFocusNode = true;
      }
      _isFocused = _focusNode.hasFocus;
      _focusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    if (_internalFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = _resolveRadius();

    // Outer glow ring: white 0.06 spread 4px when focused
    final boxShadow = _isFocused && widget.showBorder
        ? [
            BoxShadow(
              offset: Offset.zero,
              blurRadius: 0,
              spreadRadius: 4,
              color: Colors.white.withValues(alpha: 0.06),
            ),
          ]
        : <BoxShadow>[];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: FoggyEasing.easeIn,
      decoration: BoxDecoration(
        borderRadius: effectiveRadius,
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: effectiveRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: FoggyEasing.easeIn,
            padding: widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: effectiveRadius,
              color: _isFocused
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.white.withValues(alpha: 0.05),
              border: widget.showBorder
                  ? Border.all(
                      color: _isFocused
                          ? Colors.white.withValues(alpha: 0.40)
                          : Colors.white.withValues(alpha: 0.08),
                      width: 1.0,
                    )
                  : Border.all(color: Colors.transparent),
            ),
            child: Row(
              children: [
                if (widget.prefixIcon != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: widget.prefixIcon,
                  ),
                ],
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focusNode,
                    obscureText: widget.obscureText,
                    autofocus: widget.autofocus,
                    enabled: widget.enabled,
                    maxLines: widget.obscureText ? 1 : widget.maxLines,
                    minLines: widget.minLines,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    cursorColor: Colors.white.withValues(alpha: 0.85),
                    cursorWidth: 1.5,
                    style: const TextStyle(
                      color: Color(0xFFF5F5F7),
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      letterSpacing: -0.011 * 15,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: widget.hintText,
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.35),
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: -0.011 * 15,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (widget.suffixIcon != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: widget.suffixIcon,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
