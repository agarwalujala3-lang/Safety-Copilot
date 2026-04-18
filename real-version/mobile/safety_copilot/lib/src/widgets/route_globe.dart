import 'dart:math';

import 'package:flutter/material.dart';

class RouteGlobe extends StatefulWidget {
  const RouteGlobe({
    required this.destinationName,
    required this.destinationLat,
    required this.destinationLng,
    required this.active,
    super.key,
  });

  final String destinationName;
  final double destinationLat;
  final double destinationLng;
  final bool active;

  @override
  State<RouteGlobe> createState() => _RouteGlobeState();
}

class _RouteGlobeState extends State<RouteGlobe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destinationLabel = widget.destinationName.isEmpty
        ? 'Awaiting Destination'
        : widget.destinationName;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _RouteGlobePainter(
                  t: _controller.value,
                  active: widget.active,
                  destinationLat: widget.destinationLat,
                  destinationLng: widget.destinationLng,
                ),
                child: const SizedBox.expand(),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.active
              ? 'Route Locked: $destinationLabel'
              : 'Route Globe Idle',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFC6E8F8),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _RouteGlobePainter extends CustomPainter {
  _RouteGlobePainter({
    required this.t,
    required this.active,
    required this.destinationLat,
    required this.destinationLng,
  });

  final double t;
  final bool active;
  final double destinationLat;
  final double destinationLng;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 2);
    final radius = min(size.width, size.height) * 0.40;

    final glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24)
      ..color = const Color(0x5500E6B4);
    canvas.drawCircle(center, radius * 1.08, glowPaint);

    final spherePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFF8CF7FF),
          const Color(0xFF1AA7C3),
          const Color(0xFF0B3A57),
          const Color(0xFF06182A),
        ],
        stops: const [0, 0.26, 0.7, 1],
        center: Alignment(-0.25 + sin(t * pi * 2) * 0.12, -0.2),
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, spherePaint);

    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );

    final meridianPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;
    final rotation = t * pi * 2;
    for (var i = 0; i < 12; i++) {
      final angle = rotation + (i * pi / 6);
      final scale = cos(angle).abs().clamp(0.08, 1.0);
      meridianPaint.color =
          Color.lerp(const Color(0x112ED8FF), const Color(0xAA9DF3FF), scale) ??
          const Color(0xFF9DF3FF);
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: radius * 2 * scale,
          height: radius * 2,
        ),
        meridianPaint,
      );
    }

    final latitudePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x552CD4FF);
    for (var j = -3; j <= 3; j++) {
      final factor = j / 4.2;
      final latRadius = radius * cos(factor * pi / 2).abs();
      final y = center.dy + radius * factor;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, y),
          width: latRadius * 2,
          height: latRadius * 0.45,
        ),
        latitudePaint,
      );
    }

    if (active) {
      final start = Offset(
        center.dx - radius * 0.62,
        center.dy + radius * 0.30,
      );
      final destX =
          center.dx + radius * 0.68 * (destinationLng / 180).clamp(-1.0, 1.0);
      final destY =
          center.dy - radius * 0.62 * (destinationLat / 90).clamp(-1.0, 1.0);
      final end = Offset(destX, destY);
      final control = Offset(
        (start.dx + end.dx) / 2,
        min(start.dy, end.dy) - radius * 0.45,
      );
      final routePath = Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

      final routePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..shader = const LinearGradient(
          colors: [Color(0xFF00E6B4), Color(0xFF7CE4FF), Color(0xFFFFB15A)],
        ).createShader(Rect.fromPoints(start, end));
      canvas.drawPath(routePath, routePaint);

      final metrics = routePath.computeMetrics();
      if (metrics.isNotEmpty) {
        final metric = metrics.first;
        final position = metric.getTangentForOffset(
          metric.length * (0.1 + t * 0.8),
        );
        if (position != null) {
          final blipCenter = position.position;
          canvas.drawCircle(
            blipCenter,
            4.6,
            Paint()..color = const Color(0xFFFFE7B5),
          );
          canvas.drawCircle(
            blipCenter,
            11,
            Paint()..color = const Color(0x55FFE4A3),
          );
        }
      }
    }

    canvas.restore();

    final rimPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0xAA7BE2FF);
    canvas.drawCircle(center, radius, rimPaint);
  }

  @override
  bool shouldRepaint(covariant _RouteGlobePainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.active != active ||
        oldDelegate.destinationLat != destinationLat ||
        oldDelegate.destinationLng != destinationLng;
  }
}
