import 'dart:math';

import 'package:flutter/material.dart';

class SosImpactOverlay extends StatefulWidget {
  const SosImpactOverlay({
    required this.visible,
    required this.critical,
    super.key,
  });

  final bool visible;
  final bool critical;

  @override
  State<SosImpactOverlay> createState() => _SosImpactOverlayState();
}

class _SosImpactOverlayState extends State<SosImpactOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        opacity: widget.visible ? 1 : 0,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return CustomPaint(
              painter: _SosImpactPainter(
                t: _controller.value,
                critical: widget.critical,
              ),
              child: const SizedBox.expand(),
            );
          },
        ),
      ),
    );
  }
}

class _SosImpactPainter extends CustomPainter {
  _SosImpactPainter({required this.t, required this.critical});

  final double t;
  final bool critical;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.34);
    final base = critical ? const Color(0xFFFF5563) : const Color(0xFFFFA84C);

    final pulse = 0.78 + sin(t * pi * 2) * 0.22;
    final radius = min(size.width, size.height) * (0.24 + pulse * 0.12);

    final veilPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.25),
        radius: 1.1,
        colors: [
          base.withValues(alpha: critical ? 0.22 : 0.16),
          base.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Offset.zero & size, veilPaint);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    for (var i = 0; i < 3; i++) {
      final spread = (t + i * 0.22) % 1;
      final r = radius + spread * min(size.width, size.height) * 0.35;
      final alpha = (1 - spread).clamp(0.0, 1.0) * (critical ? 0.5 : 0.38);
      ringPaint.color = base.withValues(alpha: alpha);
      canvas.drawCircle(center, r, ringPaint);
    }

    final corePaint = Paint()
      ..color = base.withValues(alpha: critical ? 0.36 : 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);
    canvas.drawCircle(center, radius * 0.74, corePaint);

    final arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = const Color(0xAAFFE8C3);
    final ringRect = Rect.fromCircle(center: center, radius: radius * 0.92);
    final start = -pi / 2 + t * pi * 2;
    canvas.drawArc(ringRect, start, 0.95, false, arcPaint);
    canvas.drawArc(ringRect, start + pi, 0.65, false, arcPaint);

    final lightning = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = base.withValues(alpha: critical ? 0.78 : 0.58);
    final random = Random((t * 10000).round());
    for (var i = 0; i < (critical ? 5 : 3); i++) {
      final x = size.width * (0.15 + random.nextDouble() * 0.7);
      final yTop = size.height * (0.02 + random.nextDouble() * 0.18);
      final yMid = yTop + size.height * (0.04 + random.nextDouble() * 0.08);
      final yBottom = yMid + size.height * (0.03 + random.nextDouble() * 0.07);
      final path = Path()
        ..moveTo(x, yTop)
        ..lineTo(x - 8 + random.nextDouble() * 16, yMid)
        ..lineTo(x - 12 + random.nextDouble() * 24, yBottom);
      canvas.drawPath(path, lightning);
    }

    final barHeight = 44.0;
    final barPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          base.withValues(alpha: critical ? 0.32 : 0.22),
          base.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, barHeight));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, barHeight), barPaint);
  }

  @override
  bool shouldRepaint(covariant _SosImpactPainter oldDelegate) {
    return oldDelegate.t != t || oldDelegate.critical != critical;
  }
}
