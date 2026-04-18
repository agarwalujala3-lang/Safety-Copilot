import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AnimatedSafetyHero extends StatefulWidget {
  const AnimatedSafetyHero({super.key});

  @override
  State<AnimatedSafetyHero> createState() => _AnimatedSafetyHeroState();
}

class _AnimatedSafetyHeroState extends State<AnimatedSafetyHero>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final wobble = sin(t * pi * 2) * 0.12;
        return SizedBox(
          height: 240,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _LightningRingPainter(t)),
                ),
              ),
              Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0018)
                  ..rotateX(-0.24 + wobble * 0.4)
                  ..rotateY(0.55 + wobble)
                  ..scaleByDouble(
                    1.02 + sin(t * pi * 2) * 0.03,
                    1.02 + sin(t * pi * 2) * 0.03,
                    1.02 + sin(t * pi * 2) * 0.03,
                    1,
                  ),
                alignment: Alignment.center,
                child: Container(
                  width: 172,
                  height: 172,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFF99F5FF),
                        Color(0xFF2BE5C2),
                        Color(0xFF0C3E53),
                        Color(0x000C3E53),
                      ],
                      stops: [0, 0.34, 0.8, 1],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0x8800E6B4),
                        blurRadius: 48,
                        spreadRadius: 10,
                      ),
                      BoxShadow(
                        color: const Color(0x5525B9FF),
                        blurRadius: 58,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.verified_user_rounded,
                      color: const Color(0xFFF0FDFF).withValues(alpha: 0.92),
                      size: 62,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 20,
                child: Container(
                  width: 220,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0x0000E6B4),
                        Color(0x6600E6B4),
                        Color(0x0000E6B4),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 700.ms).scaleXY(begin: 0.92, end: 1),
        );
      },
    );
  }
}

class _LightningRingPainter extends CustomPainter {
  _LightningRingPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 10);
    final radius = min(size.width, size.height) * 0.34;

    final outerRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..shader = SweepGradient(
        colors: const [
          Color(0x00FFFFFF),
          Color(0xFF28C9FF),
          Color(0xFF00E6B4),
          Color(0x00FFFFFF),
        ],
        transform: GradientRotation(t * pi * 2),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, outerRing);

    final innerRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0x9976E3FF);
    canvas.drawCircle(center, radius * 0.78 + sin(t * pi * 2) * 3, innerRing);

    final rng = Random((t * 9000).round());
    final lightningPaint = Paint()
      ..color = const Color(0xA8B8F2FF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < 5; i++) {
      final angle = rng.nextDouble() * pi * 2;
      final start = center + Offset(cos(angle), sin(angle)) * (radius * 0.56);
      final mid =
          center + Offset(cos(angle + 0.2), sin(angle + 0.2)) * (radius * 0.92);
      final end =
          center + Offset(cos(angle + 0.05), sin(angle + 0.05)) * (radius + 18);
      final path = Path()
        ..moveTo(start.dx, start.dy)
        ..lineTo(mid.dx, mid.dy)
        ..lineTo(end.dx, end.dy);
      canvas.drawPath(path, lightningPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LightningRingPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
