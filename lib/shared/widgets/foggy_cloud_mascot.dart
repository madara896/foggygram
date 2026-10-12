import 'dart:math';
import 'package:flutter/material.dart';
import 'package:foggygram/core/theme/foggy_theme.dart';

/// 3D CSS-style cloud mascot widget for Foggygram.
///
/// Translated directly from CSS specifications:
/// - Overlapping volumetric puffs with radial gradient and layered lighting
/// - Expressive eyes with blinking animation and mouse-following glint reflections
/// - Cute curved smile
/// - Animated hands that slide up and scale to cover eyes when typing passwords
/// - Smooth bobbing floating animation
/// - 3D parallax tilt response to cursor position
/// - Optional glass speech bubble with triangular pointer
class FoggyCloudMascot extends StatefulWidget {
  /// Overall scale multiplier for the mascot canvas (default 1.0).
  final double scale;

  /// When true, hands animate to cover the cloud's eyes (e.g. for password entry).
  final bool isCoveringEyes;

  /// Whether the gentle floating bob animation is enabled.
  final bool enableBobbing;

  /// Whether the 3D tilt and eye/glint tracking follow the mouse cursor.
  final bool enableMouseTracking;

  /// Optional text displayed in a glass speech bubble above the cloud.
  final String? speechBubble;

  const FoggyCloudMascot({
    super.key,
    this.scale = 1.0,
    this.isCoveringEyes = false,
    this.enableBobbing = true,
    this.enableMouseTracking = true,
    this.speechBubble,
  });

  @override
  State<FoggyCloudMascot> createState() => _FoggyCloudMascotState();
}

class _FoggyCloudMascotState extends State<FoggyCloudMascot>
    with TickerProviderStateMixin {
  late final AnimationController _blinkController;
  late final AnimationController _bobController;

  final GlobalKey _cloudKey = GlobalKey();
  Offset _targetMouse = Offset.zero;

  @override
  void initState() {
    super.initState();

    // Blink cycle: 5.5 seconds infinite
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5500),
    )..repeat();

    // Bobbing animation: 6.5s full cycle (0 -> -16px -> 0)
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6500),
    );

    if (widget.enableBobbing) {
      _bobController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant FoggyCloudMascot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enableBobbing != oldWidget.enableBobbing) {
      if (widget.enableBobbing) {
        _bobController.repeat();
      } else {
        _bobController.stop();
        _bobController.reset();
      }
    }
    if (!widget.enableMouseTracking && oldWidget.enableMouseTracking) {
      setState(() {
        _targetMouse = Offset.zero;
      });
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    _bobController.dispose();
    super.dispose();
  }

  void _onHover(PointerEvent event) {
    if (!widget.enableMouseTracking) return;
    final RenderBox? box =
        _cloudKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) {
      final local = box.globalToLocal(event.position);
      final halfW = box.size.width / 2;
      final halfH = box.size.height / 2;
      if (halfW > 0 && halfH > 0) {
        final nx = ((local.dx - halfW) / halfW).clamp(-1.0, 1.0);
        final ny = ((local.dy - halfH) / halfH).clamp(-1.0, 1.0);
        if ((nx - _targetMouse.dx).abs() > 0.01 ||
            (ny - _targetMouse.dy).abs() > 0.01) {
          setState(() {
            _targetMouse = Offset(nx, ny);
          });
        }
      }
    }
  }

  void _onExit(PointerEvent event) {
    if (!widget.enableMouseTracking) return;
    setState(() {
      _targetMouse = Offset.zero;
    });
  }

  /// Calculates eye scaleY based on CSS keyframes:
  /// 0% - 92%: 1.0
  /// 92% - 95%: squash to 0.12
  /// 95% - 98%: open back to 1.0
  /// 98% - 100%: 1.0
  double _calculateBlinkScale(double t) {
    if (t < 0.92) {
      return 1.0;
    } else if (t < 0.95) {
      final p = (t - 0.92) / 0.03;
      return 1.0 - p * (1.0 - 0.12);
    } else if (t < 0.98) {
      final p = (t - 0.95) / 0.03;
      return 0.12 + p * (1.0 - 0.12);
    } else {
      return 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: _onHover,
      onExit: _onExit,
      child: Transform.scale(
        scale: widget.scale,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Optional glass speech bubble
            if (widget.speechBubble != null &&
                widget.speechBubble!.trim().isNotEmpty) ...[
              FoggySpeechBubble(text: widget.speechBubble!.trim()),
              const SizedBox(height: 10),
            ],

            // Bobbing translateY animation wrapper
            AnimatedBuilder(
              animation: _bobController,
              builder: (context, child) {
                // Smooth sinusoidal bobbing: 0 -> -16px -> 0
                final bobY = widget.enableBobbing
                    ? -16.0 * (0.5 - 0.5 * cos(_bobController.value * 2 * pi))
                    : 0.0;
                return Transform.translate(
                  offset: Offset(0, bobY),
                  child: child,
                );
              },
              child: _buildCloudCanvas(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the 180px x 130px 3D interactive cloud canvas.
  Widget _buildCloudCanvas() {
    return TweenAnimationBuilder<Offset>(
      key: _cloudKey,
      tween: Tween<Offset>(
        begin: Offset.zero,
        end: widget.enableMouseTracking ? _targetMouse : Offset.zero,
      ),
      duration: const Duration(milliseconds: 900),
      curve: const Cubic(0.42, 0, 1, 1),
      builder: (context, mouse, child) {
        final mx = mouse.dx;
        final my = mouse.dy;

        // 3D rotation: rotateY(mx * 16deg) rotateX(my * -13deg)
        final matrix = Matrix4.identity()
          ..setEntry(3, 2, 0.001) // 3D perspective
          ..rotateY(mx * 16.0 * (pi / 180.0))
          ..rotateX(my * -13.0 * (pi / 180.0));

        final faceOffset = Offset(mx * 7.0, my * 5.0);
        final glintOffset = Offset(mx * 4.0, my * 4.0);

        return Transform(
          alignment: Alignment.center,
          transform: matrix,
          child: SizedBox(
            width: 180,
            height: 130,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Puffs stack translated from CSS .p1 to .p5
                // p1: width 92, height 92, left 0, bottom 0
                const Positioned(
                  left: 0,
                  bottom: 0,
                  child: _CloudPuff(width: 92, height: 92),
                ),
                // p2: width 116, height 116, left 38, bottom 8
                const Positioned(
                  left: 38,
                  bottom: 8,
                  child: _CloudPuff(width: 116, height: 116),
                ),
                // p3: width 80, height 80, left 100, bottom 2
                const Positioned(
                  left: 100,
                  bottom: 2,
                  child: _CloudPuff(width: 80, height: 80),
                ),
                // p4: width 72, height 72, left 18, bottom 34
                const Positioned(
                  left: 18,
                  bottom: 34,
                  child: _CloudPuff(width: 72, height: 72),
                ),
                // p5: width 66, height 66, left 66, bottom 44
                const Positioned(
                  left: 66,
                  bottom: 44,
                  child: _CloudPuff(width: 66, height: 66),
                ),

                // Face: left: 50%, top: 47% + translate(-50% + mx * 7, -50% + my * 5)
                Positioned(
                  left: 90 - 32 + faceOffset.dx, // 50% (90px) - half face width (32px)
                  top: 61 - 20 + faceOffset.dy,  // 47% (61.1px) - half face height (20px)
                  child: _buildFace(glintOffset),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds the face containing animated blinking eyes, glints, smile, and covering hands.
  Widget _buildFace(Offset glintOffset) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Eyes row + hands covering layer
        SizedBox(
          width: 64,
          height: 24,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Pair of blinking eyes
              AnimatedBuilder(
                animation: _blinkController,
                builder: (context, child) {
                  final blinkScale = _calculateBlinkScale(_blinkController.value);
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildEye(blinkScale, glintOffset),
                      const SizedBox(width: 24),
                      _buildEye(blinkScale, glintOffset),
                    ],
                  );
                },
              ),

              // Left Hand: left: -10px, top: -5px
              Positioned(
                left: -10,
                top: -5,
                child: _buildHand(),
              ),

              // Right Hand: right: -10px, top: -5px
              Positioned(
                right: -10,
                top: -5,
                child: _buildHand(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 5),

        // Mouth: width 22, height 11, border-bottom 3px #0a0a0a, bottom-radius 50%
        Container(
          width: 22,
          height: 11,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Color(0xFF0A0A0A),
                width: 3,
              ),
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(11),
              bottomRight: Radius.circular(11),
            ),
          ),
        ),
      ],
    );
  }

  /// Single eye with squashing blink transform and moving glint reflection.
  Widget _buildEye(double blinkScale, Offset glintOffset) {
    return Transform.scale(
      scaleY: blinkScale,
      alignment: Alignment.center,
      child: Container(
        width: 20,
        height: 24,
        decoration: const BoxDecoration(
          color: Color(0xFF0A0A0A),
          borderRadius: BorderRadius.all(Radius.elliptical(10, 12)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              left: 6,
              top: 6,
              child: Transform.translate(
                offset: glintOffset,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Single puffy hand that transitions from translateY(20) scale(0.6) opacity(0)
  /// to translateY(0) scale(1.0) opacity(1.0) when [widget.isCoveringEyes] is true.
  Widget _buildHand() {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: widget.isCoveringEyes ? 1.0 : 0.0,
        end: widget.isCoveringEyes ? 1.0 : 0.0,
      ),
      duration: const Duration(milliseconds: 550),
      curve: const Cubic(0.42, 0, 1, 1),
      builder: (context, value, child) {
        if (value <= 0.001) {
          return const SizedBox.shrink();
        }
        final translateY = (1.0 - value) * 20.0;
        final scale = 0.6 + 0.4 * value;
        return Opacity(
          opacity: value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, translateY),
            child: Transform.scale(
              scale: scale,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          gradient: const RadialGradient(
            center: Alignment(-0.30, -0.40), // 35% 30%
            radius: 0.75,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFD8D8D8),
            ],
            stops: [0.0, 0.75],
          ),
        ),
      ),
    );
  }
}

/// Volumetric cloud puff circle widget matching the CSS radial gradient and shadows.
class _CloudPuff extends StatelessWidget {
  final double width;
  final double height;

  const _CloudPuff({
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // box-shadow: 0 22px 44px rgba(0, 0, 0, 0.5)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 44,
            offset: const Offset(0, 22),
          ),
        ],
        // radial-gradient(circle at 34% 28%, #ffffff 0%, #e8e8e8 55%, #bdbdbd 100%)
        gradient: const RadialGradient(
          center: Alignment(-0.32, -0.44), // 34% 28%
          radius: 0.72,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFE8E8E8),
            Color(0xFFBDBDBD),
          ],
          stops: [0.0, 0.55, 1.0],
        ),
      ),
      child: ClipOval(
        child: Stack(
          children: [
            // Inset top highlight: inset 0 10px 18px rgba(255, 255, 255, 0.95)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: height * 0.45,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.95),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),

            // Inset bottom shadow: inset 0 -8px 16px rgba(0, 0, 0, 0.14)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: height * 0.4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.14),
                      Colors.black.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Glass speech bubble with a downward triangle pointer.
class FoggySpeechBubble extends StatelessWidget {
  final String text;

  const FoggySpeechBubble({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.09),
              width: 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: FoggyColors.foggyMist,
              fontWeight: FontWeight.w400,
              letterSpacing: -0.1,
            ),
          ),
        ),
        const _BubblePointer(),
      ],
    );
  }
}

/// Small triangular pointer for the bottom of the glass speech bubble.
class _BubblePointer extends StatelessWidget {
  const _BubblePointer();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(12, 6),
      painter: _BubblePointerPainter(),
    );
  }
}

class _BubblePointerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0);

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
