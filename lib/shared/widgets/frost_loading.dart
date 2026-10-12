import 'package:flutter/material.dart';
import 'package:foggygram/core/theme/foggy_theme.dart';
import 'foggy_cloud_mascot.dart';

/// Loading indicator widget with the 3D FoggyCloudMascot and a subtle pulsing opacity animation.
class FrostLoading extends StatefulWidget {
  final String? message;
  final double scale;

  const FrostLoading({
    super.key,
    this.message = 'Loading...',
    this.scale = 0.6,
  });

  @override
  State<FrostLoading> createState() => _FrostLoadingState();
}

class _FrostLoadingState extends State<FrostLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.65, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _pulseAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FoggyCloudMascot(
            scale: widget.scale,
            enableBobbing: true,
            enableMouseTracking: false,
          ),
          if (widget.message != null && widget.message!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              widget.message!,
              textAlign: TextAlign.center,
              style: FoggyTextStyles.caption.copyWith(
                color: FoggyColors.muted,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
