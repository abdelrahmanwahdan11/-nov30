import 'dart:math' as math;

import 'package:flutter/material.dart';

class PodGauge extends StatelessWidget {
  const PodGauge({super.key, required this.value, this.size = 200});

  final double value;
  final double size;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return SizedBox(
          height: size,
          width: size,
          child: CustomPaint(
            painter: _GaugePainter(value),
            child: Center(
              child: Text(
                '${(value * 100).toStringAsFixed(0)}%',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  const _GaugePainter(this.value);

  final double value;

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 16.0;
    final startAngle = -math.pi * 3 / 4;
    final sweepAngle = math.pi * 3 / 2 * value;
    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeCap = StrokeCap.round;
    final foregroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = const LinearGradient(
        colors: [Color(0xFF909D92), Color(0xFFDDE3D6)],
      ).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );
    canvas.drawArc(
      Rect.fromLTWH(strokeWidth, strokeWidth, size.width - strokeWidth * 2, size.height - strokeWidth * 2),
      startAngle,
      math.pi * 3 / 2,
      false,
      backgroundPaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(strokeWidth, strokeWidth, size.width - strokeWidth * 2, size.height - strokeWidth * 2),
      startAngle,
      sweepAngle,
      false,
      foregroundPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) => oldDelegate.value != value;
}
