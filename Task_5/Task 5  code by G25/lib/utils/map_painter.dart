import 'package:flutter/material.dart';

class MapPathsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange.withOpacity(0.6)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw dotted roads/paths
    final path1 = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(
        size.width * 0.3,
        size.height * 0.2,
        size.width * 0.8,
        size.height * 0.3,
      )
      ..lineTo(size.width, size.height * 0.35);

    final path2 = Path()
      ..moveTo(size.width * 0.2, 0)
      ..quadraticBezierTo(
        size.width * 0.4,
        size.height * 0.3,
        size.width * 0.6,
        size.height * 0.8,
      )
      ..lineTo(size.width * 0.7, size.height);

    _drawDottedPath(canvas, path1, paint);
    _drawDottedPath(canvas, path2, paint);
  }

  void _drawDottedPath(Canvas canvas, Path path, Paint paint) {
    final pathMetrics = path.computeMetrics();
    for (final pathMetric in pathMetrics) {
      const dashLength = 8.0;
      const gapLength = 6.0;
      double distance = 0.0;
      while (distance < pathMetric.length) {
        final dashPath = pathMetric.extractPath(
          distance,
          distance + dashLength,
        );
        canvas.drawPath(dashPath, paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}