import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:foggygram/core/theme/foggy_theme.dart';
import 'package:foggygram/shared/widgets/widgets.dart';

/// Splash screen featuring the Foggygram cloud mascot drifting over a subtle
/// dark ambient mesh, before seamlessly transitioning to vault unlock.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _meshController;
  Timer? _navTimer;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _meshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _navTimer = Timer(const Duration(milliseconds: 2800), () {
      if (mounted) {
        setState(() => _isExiting = true);
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            context.go('/vault-unlock');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    _meshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FoggyColors.base,
      body: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        opacity: _isExiting ? 0.0 : 1.0,
        child: Stack(
          children: [
            // Ambient drifting dark mesh painter
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _meshController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _DarkGradientMeshPainter(progress: _meshController.value),
                  );
                },
              ),
            ),

            // Center branding column
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const FoggyCloudMascot(
                    scale: 1.3,
                    enableBobbing: true,
                    enableMouseTracking: true,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Foggygram',
                    style: FoggyTextStyles.heading.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.6,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                      .slideY(begin: 0.25, end: 0, duration: 600.ms, curve: Curves.easeOut),
                  const SizedBox(height: 8),
                  Text(
                    'Messaging in the mist',
                    style: FoggyTextStyles.caption.copyWith(
                      color: FoggyColors.muted,
                      letterSpacing: 0.2,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 400.ms, duration: 600.ms, curve: Curves.easeOut)
                      .slideY(begin: 0.15, end: 0, delay: 400.ms, duration: 600.ms, curve: Curves.easeOut),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter generating 3-4 subtle drifting radial gradients in dark grey tones.
class _DarkGradientMeshPainter extends CustomPainter {
  final double progress;

  const _DarkGradientMeshPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double t = progress * 2 * math.pi;

    // Center 1
    final p1 = Offset(
      w * 0.3 + math.sin(t) * (w * 0.08),
      h * 0.35 + math.cos(t) * (h * 0.08),
    );
    final paint1 = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.8,
        colors: [
          const Color(0xFF161616).withOpacity(0.45),
          const Color(0xFF101012).withOpacity(0.15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: p1, radius: w * 0.55));

    // Center 2
    final p2 = Offset(
      w * 0.7 - math.cos(t) * (w * 0.08),
      h * 0.65 - math.sin(t) * (h * 0.08),
    );
    final paint2 = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.7,
        colors: [
          const Color(0xFF131315).withOpacity(0.50),
          const Color(0xFF0D0D0D).withOpacity(0.20),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromCircle(center: p2, radius: w * 0.50));

    // Center 3
    final p3 = Offset(
      w * 0.5 + math.sin(t * 1.5) * (w * 0.05),
      h * 0.2 + math.cos(t * 1.5) * (h * 0.05),
    );
    final paint3 = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.6,
        colors: [
          const Color(0xFF1C1C1F).withOpacity(0.35),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: p3, radius: w * 0.40));

    canvas.drawCircle(p1, w * 0.55, paint1);
    canvas.drawCircle(p2, w * 0.50, paint2);
    canvas.drawCircle(p3, w * 0.40, paint3);
  }

  @override
  bool shouldRepaint(covariant _DarkGradientMeshPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
