import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:foggygram/core/theme/foggy_theme.dart';
import 'package:foggygram/shared/widgets/widgets.dart';

enum LoginStep { phone, otp, password }

/// Foggygram login screen supporting both Telegram phone login flow (with OTP and 2FA)
/// and Telegram QR code quick-pairing login.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0; // 0: Phone, 1: QR Code
  LoginStep _step = LoginStep.phone;

  final TextEditingController _phoneController =
      TextEditingController(text: '+1 ');
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();
  String _otpCode = '';
  bool _isLoading = false;

  late final AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  String _getSpeech() {
    if (_tabIndex == 1) return 'Scan with your camera 📸';
    switch (_step) {
      case LoginStep.phone:
        return 'Let\'s get you in!';
      case LoginStep.otp:
        return 'Check your Telegram app 📱';
      case LoginStep.password:
        return 'One more step!';
    }
  }

  void _onSendCode() {
    if (_phoneController.text.trim().length > 4) {
      setState(() {
        _isLoading = true;
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _step = LoginStep.otp;
          });
        }
      });
    }
  }

  void _onVerifyOtp() {
    if (_otpCode.length == 5) {
      setState(() {
        _isLoading = true;
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          setState(() {
            _isLoading = false;
            _step = LoginStep.password;
          });
        }
      });
    }
  }

  void _onVerifyPassword() {
    setState(() {
      _isLoading = true;
    });
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        context.go('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FoggyColors.base,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Background ambient mesh
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgController,
              builder: (context, _) {
                return CustomPaint(
                  painter: _LoginMeshPainter(progress: _bgController.value),
                );
              },
            ),
          ),

          // Central login card with peeker
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: SizedBox(
                width: 420,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.topCenter,
                  children: [
                    FrostPanel(
                      width: 420,
                      padding: const EdgeInsets.fromLTRB(28, 74, 28, 28),
                      borderRadius: BorderRadius.circular(26),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Sign in to Telegram', style: FoggyTextStyles.sheetTitle),
                          const SizedBox(height: 6),
                          Text(
                            'Connect an account to your encrypted vault',
                            style: FoggyTextStyles.bodySmall.copyWith(
                              color: FoggyColors.muted,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Tab selector
                          FrostSegmented(
                            segments: const ['Phone', 'QR Code'],
                            selectedIndex: _tabIndex,
                            onChanged: (index) {
                              setState(() {
                                _tabIndex = index;
                              });
                            },
                          ),
                          const SizedBox(height: 24),

                          // Body based on active tab
                          if (_tabIndex == 0) _buildPhoneFlow() else _buildQrFlow(),

                          const SizedBox(height: 20),
                          TextButton(
                            onPressed: () => context.go('/vault-unlock'),
                            child: Text(
                              '← Back to Vault Unlock',
                              style: FoggyTextStyles.caption.copyWith(
                                color: FoggyColors.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Mascot peeker above card
                    Positioned(
                      top: -65,
                      child: IgnorePointer(
                        child: FoggyCloudMascot(
                          scale: 0.65,
                          isCoveringEyes: _step == LoginStep.password && _tabIndex == 0,
                          enableBobbing: true,
                          enableMouseTracking: true,
                          speechBubble: _getSpeech(),
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
    );
  }

  Widget _buildPhoneFlow() {
    switch (_step) {
      case LoginStep.phone:
        return Column(
          children: [
            FrostInput(
              controller: _phoneController,
              hintText: '+1 234 567 8900',
              prefixIcon: Icon(Icons.phone_outlined, size: 18, color: FoggyColors.muted),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            FrostButton.primary(
              label: _isLoading ? 'Sending...' : 'Send Code',
              width: double.infinity,
              onPressed: _isLoading ? null : _onSendCode,
            ),
          ],
        );

      case LoginStep.otp:
        return RawKeyboardListener(
          focusNode: _otpFocusNode,
          autofocus: true,
          onKey: (event) {
            if (event is! RawKeyDownEvent) return;
            final label = event.logicalKey.keyLabel;
            if (event.logicalKey == LogicalKeyboardKey.backspace) {
              if (_otpCode.isNotEmpty) {
                setState(() => _otpCode = _otpCode.substring(0, _otpCode.length - 1));
              }
            } else if (RegExp(r'^[0-9]$').hasMatch(label) && _otpCode.length < 5) {
              setState(() => _otpCode += label);
              if (_otpCode.length == 5) {
                _onVerifyOtp();
              }
            }
          },
          child: Column(
            children: [
              Text(
                'Enter the 5-digit code sent to your Telegram app',
                style: FoggyTextStyles.caption.copyWith(color: FoggyColors.muted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  final hasDigit = index < _otpCode.length;
                  final digit = hasDigit ? _otpCode[index] : '';
                  final isCurrent = index == _otpCode.length;

                  return FrostPanel(
                    width: 50,
                    height: 58,
                    borderRadius: BorderRadius.circular(15),
                    backgroundColor: hasDigit
                        ? Colors.white.withOpacity(0.12)
                        : Colors.white.withOpacity(0.04),
                    borderColor: isCurrent
                        ? Colors.white.withOpacity(0.40)
                        : Colors.white.withOpacity(0.10),
                    child: Center(
                      child: Text(
                        digit,
                        style: FoggyTextStyles.heading.copyWith(fontSize: 22),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _step = LoginStep.phone;
                        _otpCode = '';
                      });
                    },
                    child: Text('Wrong number?', style: FoggyTextStyles.caption),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('Resend code', style: FoggyTextStyles.caption),
                  ),
                ],
              ),
            ],
          ),
        );

      case LoginStep.password:
        return Column(
          children: [
            Text(
              'Your Telegram account has Two-Step Verification enabled.',
              style: FoggyTextStyles.caption.copyWith(color: FoggyColors.muted),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FrostInput(
              controller: _passwordController,
              hintText: '2FA Cloud Password',
              prefixIcon: Icon(Icons.lock_outline, size: 18, color: FoggyColors.muted),
              obscureText: true,
              onSubmitted: (_) => _onVerifyPassword(),
            ),
            const SizedBox(height: 20),
            FrostButton.primary(
              label: _isLoading ? 'Verifying...' : 'Verify & Continue',
              width: double.infinity,
              onPressed: _isLoading ? null : _onVerifyPassword,
            ),
          ],
        );
    }
  }

  Widget _buildQrFlow() {
    return Column(
      children: [
        FrostPanel(
          width: 220,
          height: 220,
          borderRadius: BorderRadius.circular(20),
          backgroundColor: Colors.white.withOpacity(0.04),
          borderColor: Colors.white.withOpacity(0.12),
          padding: const EdgeInsets.all(12),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(8),
                child: QrImageView(
                  data: 'tg://login?token=foggygram_mock_qr_token_session_secure_xyz9812',
                  version: QrVersions.auto,
                  size: 180,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Open Telegram on your phone → Settings → Devices → Scan QR Code',
          style: FoggyTextStyles.caption.copyWith(color: FoggyColors.muted),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 14),
        FrostButton.ghost(
          label: 'Simulate Quick QR Scan',
          onPressed: () {
            context.go('/home');
          },
        ),
      ],
    );
  }
}

class _LoginMeshPainter extends CustomPainter {
  final double progress;

  const _LoginMeshPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;
    final double t = progress * 2 * math.pi;

    final p1 = Offset(w * 0.4 + math.cos(t) * 35, h * 0.5 + math.sin(t) * 35);
    final paint1 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF161616).withOpacity(0.40),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: p1, radius: 340));

    final p2 = Offset(w * 0.8, h * 0.2);
    final paint2 = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF121214).withOpacity(0.30),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: p2, radius: 260));

    canvas.drawCircle(p1, 340, paint1);
    canvas.drawCircle(p2, 260, paint2);
  }

  @override
  bool shouldRepaint(covariant _LoginMeshPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
