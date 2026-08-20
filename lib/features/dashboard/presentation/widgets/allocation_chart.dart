import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/allocation_slice.dart';

class AllocationChart extends StatelessWidget {
  const AllocationChart({
    super.key,
    required this.allocation,
    required this.formatCurrency,
  });

  final List<AllocationSlice> allocation;
  final String Function(double value) formatCurrency;

  @override
  Widget build(BuildContext context) {
    if (allocation.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: Text('No allocation data yet.')),
      );
    }

    return Row(
      children: [
        SizedBox(
          width: 132,
          height: 132,
          child: CustomPaint(
            painter: _AllocationPainter(
              allocation: allocation,
              colors: _colors(context),
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              for (var index = 0; index < allocation.length; index++)
                _AllocationLegendItem(
                  color: _colors(context)[index % _colors(context).length],
                  slice: allocation[index],
                  formatCurrency: formatCurrency,
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<Color> _colors(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return [
      scheme.primary,
      scheme.tertiary,
      Colors.green.shade600,
      Colors.amber.shade700,
      scheme.secondary,
    ];
  }
}

class _AllocationLegendItem extends StatelessWidget {
  const _AllocationLegendItem({
    required this.color,
    required this.slice,
    required this.formatCurrency,
  });

  final Color color;
  final AllocationSlice slice;
  final String Function(double value) formatCurrency;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(width: 10, height: 10, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(slice.label)),
          Text('${slice.percent.toStringAsFixed(1)}%'),
        ],
      ),
    );
  }
}

class _AllocationPainter extends CustomPainter {
  const _AllocationPainter({
    required this.allocation,
    required this.colors,
  });

  final List<AllocationSlice> allocation;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final total = allocation.fold<double>(0, (sum, item) => sum + item.value);
    if (total <= 0) return;

    final rect = Offset.zero & size;
    var start = -math.pi / 2;
    final paint = Paint()..style = PaintingStyle.stroke;
    paint.strokeWidth = size.width * 0.18;
    paint.strokeCap = StrokeCap.round;

    for (var index = 0; index < allocation.length; index++) {
      final sweep = (allocation[index].value / total) * math.pi * 2;
      paint.color = colors[index % colors.length];
      canvas.drawArc(
          rect.deflate(paint.strokeWidth / 2), start, sweep, false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _AllocationPainter oldDelegate) {
    return oldDelegate.allocation != allocation || oldDelegate.colors != colors;
  }
}
