import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:foggygram/core/theme/foggy_theme.dart';
import 'package:foggygram/shared/widgets/widgets.dart';

/// Vault unlock screen protecting local encrypted session keys with a 6-digit PIN.
/// Features a reactive cloud mascot peeker that covers its eyes during PIN entry.
class VaultUnlockScreen extends StatefulWidget {
  const VaultUnlockScreen({super.key});

  @override
  State<VaultUnlockScreen> createState() => _VaultUnlockScreenState();
}

class _VaultUnlockScreenState extends State<VaultUnlockScreen>
    with TickerProviderStateMixin {
  final FocusNode _keyboardFocusNode = FocusNode();
  String _pin = '';
  bool _isShaking = false;
  late final AnimationController _shakeController;
  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _bgController.dispose();
    _shakeController.dispose();
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  void _handleKey(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;

    final keyLabel = event.logicalKey.keyLabel;
    if (event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_pin.isNotEmpty) {
        setState(() {
          _pin = _pin.substring(0, _pin.length - 1);
        });
      }
      return;
    }

    // Check if numeric digit 0-9
    if (RegExp(r'^[0-9]$').hasMatch(keyLabel) && _pin.length < 6) {
      setState(() {
        _pin += keyLabel;
      });

      if (_pin.length == 6) {
        _verifyPin();
      }
    }
  }

  void _verifyPin() {
    // Correct default pin: '000000'
    if (_pin == '000000') {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) context.go('/home');
      });
    } else {
      // Shake animation and reset
      setState(() => _isShaking = true);
      _shakeController.forward(from: 0).then((_) {
        if (mounted) {
          setState(() {
            _pin = '';
            _isShaking = false;
          });
        }
      });
    }
  }

  String? _getSpeechBubble() {
    if (_pin.isEmpty) return 'Enter your PIN 🔐';
    if (_pin.length >= 4 && _pin.length < 6) return 'Almost there...';
    if (_pin.length == 6) return null;
    return 'Shh... no peeking!';
  }

  @override
  Widget build(BuildContext context) {
    final speechBubble = _getSpeechBubble();

    return Scaffold(
      backgroundColor: FoggyColors.base,
      body: RawKeyboardListener(
        focusNode: _keyboardFocusNode,
        autofocus: true,
        onKey: _handleKey,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Dark gradient background mesh
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _bgController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _UnlockMeshPainter(progress: _bgController.value),
                  );
                },
              ),
            ),

            // Card with peeker cloud
            Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.topCenter,
                    children: [
                      // Centered FrostPanel card
                      FrostPanel(
                        width: 400,
                        padding: const EdgeInsets.fromLTRB(28, 90, 28, 28),
                        borderRadius: BorderRadius.circular(26),
                        backgroundColor: Colors.white.withOpacity(0.06),
                        borderColor: Colors.white.withOpacity(0.12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Welcome back',
                              style: FoggyTextStyles.sheetTitle,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Unlock your vault to access your accounts',
                              style: FoggyTextStyles.bodySmall.copyWith(
                                color: FoggyColors.muted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),

                            // PIN boxes with shake animation
                            AnimatedBuilder(
                              animation: _shakeController,
                              builder: (context, child) {
                                double offset = 0;
                                if (_isShaking) {
                                  offset = math.sin(_shakeController.value * math.pi * 6) * 12;
                                }
                                return Transform.translate(
                                  offset: Offset(offset, 0),
                                  child: child,
                                );
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: List.generate(6, (index) {
                                  final isFilled = index < _pin.length;
                                  final isActive = index == _pin.length;

                                  return FrostPanel(
                                    width: 48,
                                    height: 56,
                                    borderRadius: BorderRadius.circular(15),
                                    backgroundColor: isFilled
                                        ? Colors.white.withOpacity(0.12)
                                        : Colors.white.withOpacity(0.04),
                                    borderColor: isActive
                                        ? Colors.white.withOpacity(0.35)
                                        : isFilled
                                            ? Colors.white.withOpacity(0.25)
                                            : Colors.white.withOpacity(0.10),
                                    borderWidth: isActive ? 1.5 : 1.0,
                                    child: Center(
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 150),
                                        child: isFilled
                                            ? Container(
                                                key: const ValueKey('filled'),
                                                width: 10,
                                                height: 10,
                                                decoration: const BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                ),
                                              )
                                            : Container(
                                                key: const ValueKey('empty'),
                                                width: 6,
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 28),

                            // Number pad for quick click / touch support
                            _buildKeypad(),
                            const SizedBox(height: 20),

                            // Biometrics button
                            FrostButton.ghost(
                              label: '🔒 Use biometrics',
                              width: double.infinity,
                              onPressed: () {
                                // Simulate instant biometric unlock
                                context.go('/home');
                              },
                            ),
                            const SizedBox(height: 16),

                            // New vault / login switch
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                TextButton(
                                  onPressed: () => context.go('/login'),
                                  child: Text(
                                    'Create New Vault or Sign In',
                                    style: FoggyTextStyles.caption.copyWith(
                                      color: FoggyColors.muted,
                                      decoration: TextDecoration.underline,
                                      decorationColor: FoggyColors.muted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Mascot Peeker on top of the card
                      Positioned(
                        top: -70,
                        child: IgnorePointer(
                          child: FoggyCloudMascot(
                            scale: 0.7,
                            isCoveringEyes: _pin.isNotEmpty,
                            enableBobbing: true,
                            enableMouseTracking: true,
                            speechBubble: speechBubble,
                          ),
                        ),
                      ),
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

  Widget _buildKeypad() {
    return Column(
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['', '0', '⌫'],
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: row.map((key) {
                if (key.isEmpty) {
                  return const SizedBox(width: 64, height: 44);
                }
                return SizedBox(
                  width: 64,
                  height: 44,
                  child: FrostButton.ghost(
                    padding: EdgeInsets.zero,
                    borderRadius: 12,
                    onPressed: () {
                      if (key == '⌫') {
                        if (_pin.isNotEmpty) {
                          setState(() {
                            _pin = _pin.substring(0, _pin.length - 1);
                          });
                        }
                      } else if (_pin.length < 6) {
                        setState(() {
                          _pin += key;
                        });
                        if (_pin.length == 6) {
                          _verifyPin();
                        }
                      }
                    },
                    child: Text(
                      key,
                      style: FoggyTextStyles.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: FoggyColors.text,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

class _UnlockMeshPainter extends CustomPainter {
  final double progress;

  const _UnlockMeshPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double t = progress * 2 * math.pi;

    final p1 = Offset(w * 0.5 + math.sin(t) * 40, h * 0.4 + math.cos(t) * 30);
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF191919).withOpacity(0.40),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: p1, radius: 360));

    final p2 = Offset(w * 0.2, h * 0.8);
    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF141416).withOpacity(0.35),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: p2, radius: 280));

    canvas.drawCircle(p1, 360, paint1);
    canvas.drawCircle(p2, 280, paint2);
  }

  @override
  bool shouldRepaint(covariant _UnlockMeshPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
