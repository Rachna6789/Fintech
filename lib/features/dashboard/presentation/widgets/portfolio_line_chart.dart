import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/chart_point.dart';

class PortfolioLineChart extends StatelessWidget {
  const PortfolioLineChart({
    super.key,
    required this.points,
  });

  final List<ChartPoint> points;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: CustomPaint(
        painter: _PortfolioLineChartPainter(
          points: points,
          color: Theme.of(context).colorScheme.primary,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _PortfolioLineChartPainter extends CustomPainter {
  const _PortfolioLineChartPainter({
    required this.points,
    required this.color,
  });

  final List<ChartPoint> points;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final values = points.map((point) => point.value).toList();
    if (values.length < 2) return;

    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range = (maxValue - minValue).abs() < 0.01 ? 1 : maxValue - minValue;
    final stepX = size.width / (values.length - 1);
    final path = Path();

    for (var index = 0; index < values.length; index++) {
      final x = stepX * index;
      final normalized = (values[index] - minValue) / range;
      final y = size.height - (normalized * size.height);
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final gridPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (var i = 1; i < 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _PortfolioLineChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}
