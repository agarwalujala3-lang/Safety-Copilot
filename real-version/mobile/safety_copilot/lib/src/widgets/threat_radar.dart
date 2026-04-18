import 'dart:math';

import 'package:flutter/material.dart';

class ThreatRadar extends StatefulWidget {
  const ThreatRadar({
    required this.active,
    required this.lowCount,
    required this.mediumCount,
    required this.highCount,
    required this.criticalCount,
    super.key,
  });

  final bool active;
  final int lowCount;
  final int mediumCount;
  final int highCount;
  final int criticalCount;

  @override
  State<ThreatRadar> createState() => _ThreatRadarState();
}

class _ThreatRadarState extends State<ThreatRadar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total =
        widget.lowCount +
        widget.mediumCount +
        widget.highCount +
        widget.criticalCount;
    final stance = widget.criticalCount > 0
        ? 'Critical'
        : widget.highCount > 0
        ? 'High'
        : widget.mediumCount > 0
        ? 'Guarded'
        : 'Stable';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _ThreatRadarPainter(
                  t: _controller.value,
                  active: widget.active,
                  lowCount: widget.lowCount,
                  mediumCount: widget.mediumCount,
                  highCount: widget.highCount,
                  criticalCount: widget.criticalCount,
                ),
                child: const SizedBox.expand(),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Threat Stance: $stance  |  Active Alerts: $total',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFFCEEFFF),
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ThreatRadarPainter extends CustomPainter {
  _ThreatRadarPainter({
    required this.t,
    required this.active,
    required this.lowCount,
    required this.mediumCount,
    required this.highCount,
    required this.criticalCount,
  });

  final double t;
  final bool active;
  final int lowCount;
  final int mediumCount;
  final int highCount;
  final int criticalCount;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2 - 2);
    final radius = min(size.width, size.height) * 0.40;

    final glowColor = criticalCount > 0
        ? const Color(0x55FF5F6B)
        : highCount > 0
        ? const Color(0x55FFB15A)
        : const Color(0x5500E6B4);
    canvas.drawCircle(
      center,
      radius * 1.08,
      Paint()
        ..color = glowColor
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22),
    );

    final basePaint = Paint()
      ..shader = const RadialGradient(
        colors: [Color(0xFF0D2A37), Color(0xFF0A202D), Color(0xFF07131E)],
        stops: [0, 0.68, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, basePaint);

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x663EA2C8);

    for (var i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * (i / 4), gridPaint);
    }
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      gridPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      gridPaint,
    );

    final sweep = t * pi * 2;
    final sweepPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = SweepGradient(
        startAngle: -0.1,
        endAngle: 0.55,
        colors: const [
          Color(0x0000E6B4),
          Color(0x6600E6B4),
          Color(0x1A7CF2FF),
          Color(0x0000E6B4),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(sweep);
    final sector = Path()
      ..moveTo(0, 0)
      ..arcTo(
        Rect.fromCircle(center: Offset.zero, radius: radius),
        -0.24,
        0.48,
        false,
      )
      ..close();
    canvas.drawPath(sector, sweepPaint);
    canvas.restore();

    final edgePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..color = const Color(0xAA78E2FF);
    canvas.drawCircle(center, radius, edgePaint);

    if (!active) {
      return;
    }

    final blips = _blips();
    for (final blip in blips) {
      final angle = blip.angle + sin(t * pi * 2) * 0.04;
      final position =
          center +
          Offset(cos(angle), sin(angle)) *
              (radius * blip.distance.clamp(0.1, 1.0));

      final sweepDelta = _wrappedDelta(sweep, angle).abs();
      final boost = (1 - (sweepDelta / 0.55)).clamp(0.0, 1.0);
      final alpha = (0.4 + boost * 0.6).clamp(0.0, 1.0);

      final core = Paint()..color = blip.color.withValues(alpha: alpha);
      final halo = Paint()
        ..color = blip.color.withValues(alpha: alpha * 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

      canvas.drawCircle(position, blip.size * 2.1, halo);
      canvas.drawCircle(position, blip.size, core);
    }
  }

  List<_RadarBlip> _blips() {
    final result = <_RadarBlip>[];
    _appendBlips(
      target: result,
      count: lowCount,
      startAngle: 0.3,
      spread: 1.7,
      distance: 0.42,
      color: const Color(0xFF5DE5B2),
      size: 2.4,
    );
    _appendBlips(
      target: result,
      count: mediumCount,
      startAngle: 1.7,
      spread: 1.5,
      distance: 0.58,
      color: const Color(0xFF8ED8FF),
      size: 2.8,
    );
    _appendBlips(
      target: result,
      count: highCount,
      startAngle: 3.6,
      spread: 1.4,
      distance: 0.74,
      color: const Color(0xFFFFBE69),
      size: 3.3,
    );
    _appendBlips(
      target: result,
      count: criticalCount,
      startAngle: 5.1,
      spread: 1.2,
      distance: 0.88,
      color: const Color(0xFFFF6363),
      size: 3.8,
    );
    return result;
  }

  void _appendBlips({
    required List<_RadarBlip> target,
    required int count,
    required double startAngle,
    required double spread,
    required double distance,
    required Color color,
    required double size,
  }) {
    if (count <= 0) {
      return;
    }
    final visibleCount = min(count, 8);
    for (var i = 0; i < visibleCount; i++) {
      final segment = visibleCount == 1 ? 0.5 : i / (visibleCount - 1);
      target.add(
        _RadarBlip(
          angle: startAngle + spread * segment,
          distance: distance + (i % 2 == 0 ? -0.04 : 0.04),
          color: color,
          size: size,
        ),
      );
    }
  }

  double _wrappedDelta(double a, double b) {
    var diff = (a - b) % (pi * 2);
    if (diff > pi) {
      diff -= pi * 2;
    }
    if (diff < -pi) {
      diff += pi * 2;
    }
    return diff;
  }

  @override
  bool shouldRepaint(covariant _ThreatRadarPainter oldDelegate) {
    return oldDelegate.t != t ||
        oldDelegate.active != active ||
        oldDelegate.lowCount != lowCount ||
        oldDelegate.mediumCount != mediumCount ||
        oldDelegate.highCount != highCount ||
        oldDelegate.criticalCount != criticalCount;
  }
}

class _RadarBlip {
  _RadarBlip({
    required this.angle,
    required this.distance,
    required this.color,
    required this.size,
  });

  final double angle;
  final double distance;
  final Color color;
  final double size;
}
