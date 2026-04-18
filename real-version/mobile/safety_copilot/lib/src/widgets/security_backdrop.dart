import 'dart:math';

import 'package:flutter/material.dart';

class SecurityBackdrop extends StatefulWidget {
  const SecurityBackdrop({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<SecurityBackdrop> createState() => _SecurityBackdropState();
}

class _SecurityBackdropState extends State<SecurityBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
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
      builder: (context, child) {
        final t = _controller.value;
        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF020A14),
                Color(0xFF061427),
                Color(0xFF021C20),
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: -120 + sin(t * pi * 2) * 25,
                right: -80,
                child: _GlowBlob(
                  size: 300,
                  colors: const [
                    Color(0x5519D1FF),
                    Color(0x0019D1FF),
                  ],
                ),
              ),
              Positioned(
                bottom: -140 + cos(t * pi * 2) * 28,
                left: -120,
                child: _GlowBlob(
                  size: 360,
                  colors: const [
                    Color(0x4D00E6B4),
                    Color(0x0000E6B4),
                  ],
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(
                    painter: _SecurityGridPainter(t),
                  ),
                ),
              ),
              Positioned.fill(child: child!),
            ],
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _GlowBlob extends StatelessWidget {
  const _GlowBlob({
    required this.size,
    required this.colors,
  });

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(colors: colors),
        ),
      ),
    );
  }
}

class _SecurityGridPainter extends CustomPainter {
  _SecurityGridPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0x223FA6CB)
      ..strokeWidth = 1;

    final spacing = 28.0;
    final shift = t * spacing;
    for (double x = -spacing + shift; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final scanPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: const [
          Color(0x0000E6B4),
          Color(0x5A00E6B4),
          Color(0x0000E6B4),
        ],
        stops: const [0, 0.5, 1],
      ).createShader(Rect.fromLTWH(0, 0, size.width, 84));
    final scanY = (size.height + 84) * t - 84;
    canvas.drawRect(Rect.fromLTWH(0, scanY, size.width, 84), scanPaint);

    final particlePaint = Paint()..color = const Color(0x66D6F6FF);
    final rng = Random((t * 10000).round());
    for (var i = 0; i < 32; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final r = rng.nextDouble() * 1.6 + 0.4;
      canvas.drawCircle(Offset(x, y), r, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SecurityGridPainter oldDelegate) {
    return oldDelegate.t != t;
  }
}
