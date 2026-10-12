import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:foggygram/core/theme/foggy_theme.dart';

/// Glassmorphic container panel with backdrop blur and subtle border.
class FrostPanel extends StatelessWidget {
  final Widget? child;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double blur;
  final List<BoxShadow>? boxShadow;
  final VoidCallback? onTap;

  const FrostPanel({
    super.key,
    this.child,
    this.width,
    this.height,
    this.padding,
    this.margin,
    this.borderRadius,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.blur = 24.0,
    this.boxShadow,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? BorderRadius.circular(16.0);
    final effectiveBg = backgroundColor ?? Colors.white.withOpacity(0.06);
    final effectiveBorder = borderColor ?? Colors.white.withOpacity(0.12);

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveBg,
        borderRadius: effectiveRadius,
        border: Border.all(color: effectiveBorder, width: borderWidth),
        boxShadow: boxShadow,
      ),
      child: child,
    );

    Widget frosted = ClipRRect(
      borderRadius: effectiveRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: content,
      ),
    );

    if (onTap != null) {
      frosted = InkWell(
        onTap: onTap,
        borderRadius: effectiveRadius is BorderRadius ? effectiveRadius : BorderRadius.circular(16),
        child: frosted,
      );
    }

    if (margin != null) {
      frosted = Padding(padding: margin!, child: frosted);
    }

    return frosted;
  }
}

/// Glassmorphism button supporting primary (white filled) and ghost (glass translucent) variants.
class FrostButton extends StatefulWidget {
  final Widget? child;
  final String? label;
  final Widget? icon;
  final VoidCallback? onPressed;
  final bool isGhost;
  final bool isPrimary;
  final EdgeInsetsGeometry? padding;
  final double borderRadius;
  final double? width;
  final double? height;

  const FrostButton({
    super.key,
    this.child,
    this.label,
    this.icon,
    this.onPressed,
    this.isGhost = false,
    this.isPrimary = true,
    this.padding,
    this.borderRadius = 12.0,
    this.width,
    this.height,
  });

  const FrostButton.primary({
    super.key,
    this.child,
    this.label,
    this.icon,
    this.onPressed,
    this.padding,
    this.borderRadius = 12.0,
    this.width,
    this.height,
  })  : isGhost = false,
        isPrimary = true;

  const FrostButton.ghost({
    super.key,
    this.child,
    this.label,
    this.icon,
    this.onPressed,
    this.padding,
    this.borderRadius = 12.0,
    this.width,
    this.height,
  })  : isGhost = true,
        isPrimary = false;

  @override
  State<FrostButton> createState() => _FrostButtonState();
}

class _FrostButtonState extends State<FrostButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.isPrimary && !widget.isGhost;

    Color bg;
    Color textColor;
    Border? border;
    List<BoxShadow>? shadows;

    if (isPrimary) {
      bg = _isHovered ? Colors.white : Colors.white.withOpacity(0.92);
      textColor = Colors.black;
      border = null;
      shadows = [
        _isHovered ? FoggyShadows.buttonHoverShadow : FoggyShadows.buttonShadow,
      ];
    } else {
      bg = _isHovered ? Colors.white.withOpacity(0.12) : Colors.white.withOpacity(0.06);
      textColor = FoggyColors.text;
      border = Border.all(
        color: _isHovered ? Colors.white.withOpacity(0.24) : Colors.white.withOpacity(0.10),
        width: 1.0,
      );
      shadows = _isHovered ? [FoggyShadows.ghostHoverShadow] : null;
    }

    Widget content;
    if (widget.child != null) {
      content = widget.child!;
    } else {
      content = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (widget.icon != null) ...[
            widget.icon!,
            const SizedBox(width: 8),
          ],
          if (widget.label != null)
            Text(
              widget.label!,
              style: FoggyTextStyles.bodySmall.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      );
    }

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
            width: widget.width,
            height: widget.height,
            padding: widget.padding ??
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: border,
              boxShadow: shadows,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Center(
                child: DefaultTextStyle.merge(
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                  child: IconTheme(
                    data: IconThemeData(color: textColor, size: 18),
                    child: content,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Frosted input field with subtle glass style and focus glow.
class FrostInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int maxLines;
  final int? minLines;
  final double borderRadius;
  final bool showBorder;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextStyle? style;
  final EdgeInsetsGeometry? contentPadding;
  final FocusNode? focusNode;

  const FrostInput({
    super.key,
    this.controller,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.maxLines = 1,
    this.minLines,
    this.borderRadius = 15.0,
    this.showBorder = true,
    this.autofocus = false,
    this.keyboardType,
    this.style,
    this.contentPadding,
    this.focusNode,
  });

  @override
  State<FrostInput> createState() => _FrostInputState();
}

class _FrostInputState extends State<FrostInput> {
  late FocusNode _focusNode;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    } else {
      _focusNode.removeListener(_handleFocusChange);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = _focusNode.hasFocus;

    Color bg = isFocused
        ? Colors.white.withOpacity(0.10)
        : _isHovered
            ? Colors.white.withOpacity(0.08)
            : Colors.white.withOpacity(0.05);

    Color borderColor = !widget.showBorder
        ? Colors.transparent
        : isFocused
            ? Colors.white.withOpacity(0.45)
            : _isHovered
                ? Colors.white.withOpacity(0.22)
                : Colors.white.withOpacity(0.10);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: borderColor, width: widget.showBorder ? 1.0 : 0.0),
          boxShadow: isFocused && widget.showBorder ? [FoggyShadows.focusRing] : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
            child: TextField(
              controller: widget.controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              obscureText: widget.obscureText,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              maxLines: widget.maxLines,
              minLines: widget.minLines,
              keyboardType: widget.keyboardType,
              style: widget.style ?? FoggyTextStyles.body.copyWith(color: FoggyColors.text),
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: FoggyTextStyles.bodySmall.copyWith(color: FoggyColors.muted),
                prefixIcon: widget.prefixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: widget.prefixIcon,
                      )
                    : null,
                prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                suffixIcon: widget.suffixIcon != null
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: widget.suffixIcon,
                      )
                    : null,
                suffixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: widget.contentPadding ??
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Frosted search bar with search icon and clear button.
class FrostSearch extends StatelessWidget {
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const FrostSearch({
    super.key,
    this.controller,
    this.hintText = 'Search chats, contacts, messages...',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return FrostInput(
      controller: controller,
      hintText: hintText,
      prefixIcon: Icon(Icons.search_rounded, size: 18, color: FoggyColors.muted),
      suffixIcon: controller != null && controller!.text.isNotEmpty
          ? IconButton(
              icon: Icon(Icons.close_rounded, size: 16, color: FoggyColors.muted),
              onPressed: () {
                controller?.clear();
                onClear?.call();
                onChanged?.call('');
              },
            )
          : null,
      borderRadius: 14.0,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      onChanged: onChanged,
    );
  }
}

/// Frosted circular avatar supporting initials and image fallback.
class FrostAvatar extends StatelessWidget {
  final double size;
  final String? imageUrl;
  final String? name;
  final bool isOnline;
  final Border? border;
  final Color? backgroundColor;

  const FrostAvatar({
    super.key,
    this.size = 40.0,
    this.imageUrl,
    this.name,
    this.isOnline = false,
    this.border,
    this.backgroundColor,
  });

  String _getInitials() {
    if (name == null || name!.trim().isEmpty) return '?';
    final parts = name!.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? Colors.white.withOpacity(0.08);

    Widget avatarChild;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      avatarChild = Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackInitials(),
      );
    } else {
      avatarChild = _buildFallbackInitials();
    }

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: effectiveBg,
            border: border ??
                Border.all(
                  color: Colors.white.withOpacity(0.12),
                  width: 1.0,
                ),
          ),
          child: ClipOval(
            child: avatarChild,
          ),
        ),
        if (isOnline)
          Positioned(
            right: 1,
            bottom: 1,
            child: Container(
              width: size * 0.26,
              height: size * 0.26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: FoggyColors.base,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFallbackInitials() {
    return Center(
      child: Text(
        _getInitials(),
        style: TextStyle(
          fontSize: size * 0.38,
          fontWeight: FontWeight.w600,
          color: FoggyColors.text,
        ),
      ),
    );
  }
}

/// Frosted segmented tab selector.
class FrostSegmented extends StatelessWidget {
  final List<String> segments;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const FrostSegmented({
    super.key,
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: List.generate(segments.length, (index) {
          final isSelected = selectedIndex == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withOpacity(0.14) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10.0),
                  border: isSelected
                      ? Border.all(color: Colors.white.withOpacity(0.24), width: 1.0)
                      : null,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    segments[index],
                    style: FoggyTextStyles.caption.copyWith(
                      color: isSelected ? FoggyColors.text : FoggyColors.muted,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// Frosted interactive chip.
class FrostChip extends StatelessWidget {
  final String label;
  final Widget? icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const FrostChip({
    super.key,
    required this.label,
    this.icon,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withOpacity(0.18)
              : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.35)
                : Colors.white.withOpacity(0.10),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: FoggyTextStyles.caption.copyWith(
                color: isSelected ? FoggyColors.text : FoggyColors.muted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Frosted toggle switch.
class FrostToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  final String? label;

  const FrostToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final toggle = GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 48,
        height: 28,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: value ? Colors.white.withOpacity(0.3) : Colors.white.withOpacity(0.07),
          border: Border.all(
            color: value ? Colors.white.withOpacity(0.5) : Colors.white.withOpacity(0.12),
          ),
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: value ? Colors.white : Colors.white.withOpacity(0.6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (label == null) return toggle;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label!,
          style: FoggyTextStyles.bodySmall.copyWith(color: FoggyColors.text),
        ),
        toggle,
      ],
    );
  }
}

/// Frosted circular loading spinner.
class FrostLoading extends StatelessWidget {
  final double size;
  final Color? color;

  const FrostLoading({
    super.key,
    this.size = 28.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: 2.2,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }
}
