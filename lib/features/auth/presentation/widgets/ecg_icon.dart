import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class EcgIcon extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;

  const EcgIcon({
    super.key,
    required this.size,
    this.color,
    this.strokeWidth = 3,
  });

  @override
  Widget build(BuildContext context) =>
      CustomPaint(
        size: Size(size, size),
        painter: _EcgPainter(
          color: color ?? AppColors.white,
          strokeWidth: strokeWidth,
        ),
      );
}

class _EcgPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _EcgPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas c, Size s) {
    final p = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    final mid = s.height * 0.5;
    final path = Path()
      ..moveTo(0, mid)
      ..lineTo(s.width * 0.2, mid)
      ..lineTo(s.width * 0.3, mid * 0.25)
      ..lineTo(s.width * 0.4, mid * 1.8)
      ..lineTo(s.width * 0.5, mid * 0.05)
      ..lineTo(s.width * 0.6, mid)
      ..lineTo(s.width, mid);
    c.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_) => false;
}
