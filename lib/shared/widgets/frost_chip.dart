import 'package:flutter/material.dart';
import 'package:foggygram/core/theme/foggy_theme.dart';

/// Small frosted pill chip with active state and uppercase styling.
class FrostChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const FrostChip({
    super.key,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const borderRadius = BorderRadius.all(Radius.circular(20.0));

    return MouseRegion(
      cursor: onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: FoggyEasing.easeIn,
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 3.0),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: isActive
                ? Colors.white.withOpacity(0.88)
                : Colors.white.withOpacity(0.07),
            border: Border.all(
              color: isActive
                  ? Colors.white.withOpacity(0.20)
                  : Colors.white.withOpacity(0.08),
              width: 1.0,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      offset: const Offset(0, 2),
                      blurRadius: 8,
                      color: Colors.white.withOpacity(0.15),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.05 * 11.0,
              color: isActive ? const Color(0xFF0D0D0D) : FoggyColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}
