import 'dart:math';
import 'package:flutter/material.dart';
import 'package:foggygram/core/theme/foggy_theme.dart';

/// Glassmorphism circle avatar with initials/network image, online badge,
/// and smooth hover tilt & scale animation.
class FrostAvatar extends StatefulWidget {
  final String? name;
  final String? imageUrl;
  final double size;
  final bool isOnline;
  final VoidCallback? onTap;
  final BoxBorder? border;

  const FrostAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.size = 44.0,
    this.isOnline = false,
    this.onTap,
    this.border,
  });

  @override
  State<FrostAvatar> createState() => _FrostAvatarState();
}

class _FrostAvatarState extends State<FrostAvatar> {
  bool _isHovered = false;

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      final first = parts[0].isNotEmpty ? parts[0][0] : '';
      final second = parts[1].isNotEmpty ? parts[1][0] : '';
      return '$first$second'.toUpperCase();
    }
    return (name.trim().isNotEmpty ? name.trim()[0] : '?').toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveSize = widget.size;
    final initials = _getInitials(widget.name);
    final indicatorSize = (effectiveSize * 0.24).clamp(8.0, 14.0);

    // Hover transform: scale(1.06), rotate(-2deg)
    final double targetScale = _isHovered ? 1.06 : 1.0;
    final double targetAngle = _isHovered ? (-2.0 * (pi / 180.0)) : 0.0;

    Widget avatarCore;
    if (widget.imageUrl != null && widget.imageUrl!.isNotEmpty) {
      avatarCore = ClipOval(
        child: Image.network(
          widget.imageUrl!,
          width: effectiveSize,
          height: effectiveSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitialsCore(initials),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              width: effectiveSize,
              height: effectiveSize,
              color: Colors.white.withOpacity(0.08),
              child: const Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white70),
                  ),
                ),
              ),
            );
          },
        ),
      );
    } else {
      avatarCore = _buildInitialsCore(initials);
    }

    Widget content = Stack(
      clipBehavior: Clip.none,
      children: [
        // Avatar circle with glass ring
        AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: FoggyEasing.easeIn,
          transform: Matrix4.identity()
            ..scale(targetScale)
            ..rotateZ(targetAngle),
          transformAlignment: Alignment.center,
          width: effectiveSize,
          height: effectiveSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: widget.border ??
                Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 2.0,
                ),
          ),
          child: avatarCore,
        ),

        // Online indicator (bottom-right 10px circle with shadow)
        if (widget.isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: indicatorSize,
              height: indicatorSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: const Color(0xFF0D0D0D),
                  width: 2.0,
                ),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 2),
                    blurRadius: 6,
                    color: Colors.black.withOpacity(0.50),
                  ),
                  BoxShadow(
                    offset: Offset.zero,
                    blurRadius: 4,
                    color: Colors.white.withOpacity(0.60),
                  ),
                ],
              ),
            ),
          ),
      ],
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: widget.onTap,
        child: content,
      ),
    );
  }

  Widget _buildInitialsCore(String initials) {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xD9FFFFFF), // white 0.85
            Color(0xB3FFFFFF), // white 0.70
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            fontSize: widget.size * 0.38,
            fontWeight: FontWeight.w700,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
      ),
    );
  }
}
