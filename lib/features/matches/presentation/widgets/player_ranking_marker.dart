import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/colors.dart';

/// Colore della fascia ranking. In assenza di una fascia usa la stessa
/// pallina da tennis gialla mostrata dalla webapp.
class PlayerRankingMarker extends StatelessWidget {
  const PlayerRankingMarker({
    super.key,
    required this.colorHex,
    this.size = 12,
  });

  final String? colorHex;
  final double size;

  bool get hasRankingColor => parseHexColor(colorHex) != null;

  @override
  Widget build(BuildContext context) {
    final color = parseHexColor(colorHex);
    if (color != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(color: context.colors.border),
        ),
      );
    }
    return Tooltip(
      message: 'Fascia ranking non assegnata',
      child: CustomPaint(
        size: Size.square(size),
        painter: const _TennisBallPainter(),
      ),
    );
  }
}

class _TennisBallPainter extends CustomPainter {
  const _TennisBallPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFFC8E645));
    final seam = Paint()
      ..color = const Color(0xFF8AAD0F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (size.shortestSide / 11).clamp(.8, 1.5);
    final left = Path()
      ..moveTo(size.width * .2, size.height * .22)
      ..quadraticBezierTo(
        size.width * .48,
        size.height * .5,
        size.width * .2,
        size.height * .78,
      );
    final right = Path()
      ..moveTo(size.width * .8, size.height * .22)
      ..quadraticBezierTo(
        size.width * .52,
        size.height * .5,
        size.width * .8,
        size.height * .78,
      );
    canvas
      ..drawPath(left, seam)
      ..drawPath(right, seam)
      ..drawCircle(
        center,
        radius - seam.strokeWidth / 2,
        Paint()
          ..color = const Color(0xFF8AAD0F)
          ..style = PaintingStyle.stroke
          ..strokeWidth = seam.strokeWidth,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
