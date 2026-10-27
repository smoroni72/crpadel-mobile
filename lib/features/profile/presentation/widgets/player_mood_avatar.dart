import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/profile_models.dart';

class PlayerMoodAvatar extends StatelessWidget {
  const PlayerMoodAvatar({
    super.key,
    required this.stats,
    this.size = 64,
    this.showLabel = false,
  });

  final ProfileStats stats;
  final double size;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final mood = _Mood.from(stats);
    final face = Semantics(
      label: 'Forma recente: ${mood.label}',
      image: true,
      child: CustomPaint(size: Size.square(size), painter: _MoodPainter(mood)),
    );
    if (!showLabel) return face;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        face,
        const SizedBox(height: 4),
        Text(
          mood.label,
          style: TextStyle(
            color: mood.color,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _Mood {
  const _Mood({
    required this.label,
    required this.color,
    required this.fill,
    required this.mouthCurve,
    this.sleepy = false,
    this.sparkle = false,
    this.sweat = false,
  });

  final String label;
  final Color color;
  final Color fill;
  final double mouthCurve;
  final bool sleepy;
  final bool sparkle;
  final bool sweat;

  factory _Mood.from(ProfileStats stats) {
    if (stats.recentMatches == 0) {
      return const _Mood(
        label: 'In attesa',
        color: Color(0xFF64748B),
        fill: Color(0xFFE2E8F0),
        mouthCurve: 0,
        sleepy: true,
      );
    }
    if (stats.recentFormRate >= 70) {
      return const _Mood(
        label: 'Ottima',
        color: Color(0xFF16A34A),
        fill: Color(0xFFDCFCE7),
        mouthCurve: 0.38,
        sparkle: true,
      );
    }
    if (stats.recentFormRate >= 55) {
      return const _Mood(
        label: 'Buona',
        color: Color(0xFF65A30D),
        fill: Color(0xFFECFCCB),
        mouthCurve: 0.25,
      );
    }
    if (stats.recentFormRate >= 40) {
      return const _Mood(
        label: 'Alterna',
        color: Color(0xFFD97706),
        fill: Color(0xFFFEF3C7),
        mouthCurve: 0.08,
      );
    }
    return const _Mood(
      label: 'Da recuperare',
      color: Color(0xFFDC2626),
      fill: Color(0xFFFEE2E2),
      mouthCurve: -0.28,
      sweat: true,
    );
  }
}

class _MoodPainter extends CustomPainter {
  const _MoodPainter(this.mood);
  final _Mood mood;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 64;
    canvas.scale(scale, scale);
    final outline = Paint()
      ..color = mood.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(const Offset(32, 32), 29, Paint()..color = mood.fill);
    canvas.drawCircle(const Offset(32, 32), 29, outline);
    final hair = Path()
      ..moveTo(11, 28)
      ..cubicTo(17, 13, 47, 13, 53, 28);
    canvas.drawPath(hair, outline..color = mood.color.withValues(alpha: 0.55));
    final feature = Paint()
      ..color = const Color(0xFF1F2937)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    if (mood.sleepy) {
      for (final x in [18.0, 36.0]) {
        final eye = Path()
          ..moveTo(x, 30)
          ..quadraticBezierTo(x + 5, 34, x + 10, 30);
        canvas.drawPath(eye, feature);
      }
    } else {
      canvas.drawCircle(
        const Offset(23, 31),
        3,
        Paint()..color = feature.color,
      );
      canvas.drawCircle(
        const Offset(41, 31),
        3,
        Paint()..color = feature.color,
      );
    }
    final mouth = Path()
      ..moveTo(20, 39)
      ..quadraticBezierTo(32, 39 + 22 * mood.mouthCurve, 44, 39);
    canvas.drawPath(mouth, feature);
    if (mood.mouthCurve > 0.15) {
      final blush = Paint()..color = const Color(0x73FB7185);
      canvas.drawCircle(const Offset(16, 38), 3, blush);
      canvas.drawCircle(const Offset(48, 38), 3, blush);
    }
    if (mood.sparkle) {
      final sparkle = Path();
      for (var i = 0; i < 8; i++) {
        final angle = -math.pi / 2 + i * math.pi / 4;
        final radius = i.isEven ? 7.0 : 3.0;
        final point = Offset(
          52 + math.cos(angle) * radius,
          12 + math.sin(angle) * radius,
        );
        i == 0
            ? sparkle.moveTo(point.dx, point.dy)
            : sparkle.lineTo(point.dx, point.dy);
      }
      sparkle.close();
      canvas.drawPath(sparkle, Paint()..color = const Color(0xFFFACC15));
    }
    if (mood.sweat) {
      final sweat = Path()
        ..moveTo(51, 18)
        ..cubicTo(57, 25, 56, 30, 52, 30)
        ..cubicTo(47, 30, 47, 25, 51, 18)
        ..close();
      canvas.drawPath(sweat, Paint()..color = const Color(0xFF60A5FA));
    }
  }

  @override
  bool shouldRepaint(covariant _MoodPainter oldDelegate) =>
      oldDelegate.mood != mood;
}
