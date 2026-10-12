import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:foggygram/core/theme/foggy_theme.dart';

/// Frosted glass custom switch toggle (48x28) with spring animation
/// and optional companion label.
class FrostToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;

  const FrostToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    const double trackWidth = 48.0;
    const double trackHeight = 28.0;
    const double thumbSize = 22.0;
    const double thumbPadding = (trackHeight - thumbSize) / 2; // 3.0
    final isInteractive = onChanged != null;

    final toggleWidget = MouseRegion(
      cursor: isInteractive ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        onTap: isInteractive ? () => onChanged!(!value) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutBack,
          width: trackWidth,
          height: trackHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(trackHeight / 2),
            color: value
                ? Colors.white.withOpacity(0.88)
                : Colors.white.withOpacity(0.08),
            border: Border.all(
              color: value
                  ? Colors.white.withOpacity(0.20)
                  : Colors.white.withOpacity(0.10),
              width: 1.0,
            ),
            boxShadow: value
                ? [
                    BoxShadow(
                      offset: const Offset(0, 4),
                      blurRadius: 14,
                      color: Colors.white.withOpacity(0.18),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutBack,
                left: value ? (trackWidth - thumbSize - thumbPadding) : thumbPadding,
                top: thumbPadding,
                child: Container(
                  width: thumbSize,
                  height: thumbSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value ? const Color(0xFF0D0D0D) : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        offset: const Offset(0, 2),
                        blurRadius: 6,
                        color: Colors.black.withOpacity(0.35),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (label != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          toggleWidget,
          const SizedBox(width: 12),
          Text(
            label!,
            style: FoggyTextStyles.body.copyWith(
              color: FoggyColors.text,
            ),
          ),
        ],
      );
    }

    return toggleWidget;
  }
}
