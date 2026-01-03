import 'package:flutter/material.dart';
import 'package:docai/models/wellness/cycle_data.dart';
import 'package:docai/services/wellness_service.dart';
import 'package:intl/intl.dart';

class CycleHistoryChart extends StatelessWidget {
  final WellnessData data;

  const CycleHistoryChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // If fewer than 2 periods, we can't really show a history of cycle lengths
    if (data.periods.length < 2) {
      return Container(
        height: 150,
        alignment: Alignment.center,
        child: Text(
          'Not enough data for history',
          style: TextStyle(color: Colors.grey[500]),
        ),
      );
    }

    final cycleLengths = _calculateCycleLengths(data.periods);
    if (cycleLengths.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Cycle Length History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: CustomPaint(
            painter: _BarChartPainter(
              data: cycleLengths,
              color: Theme.of(context).primaryColor,
              textColor: Theme.of(context).textTheme.bodySmall?.color ?? Colors.grey,
            ),
            size: Size.infinite,
          ),
        ),
      ],
    );
  }

  List<MapEntry<String, int>> _calculateCycleLengths(List<CyclePeriod> periods) {
    // Sort periods
    final sortedPeriods = List<CyclePeriod>.from(periods)
      ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final List<MapEntry<String, int>> result = [];

    for (int i = 0; i < sortedPeriods.length - 1; i++) {
      final current = sortedPeriods[i];
      final next = sortedPeriods[i + 1];
      final length = next.startDate.difference(current.startDate).inDays;
      final label = DateFormat.MMM().format(current.startDate);

      result.add(MapEntry(label, length));
    }

    // Take last 6 cycles
    if (result.length > 6) {
      return result.sublist(result.length - 6);
    }
    return result;
  }
}

class _BarChartPainter extends CustomPainter {
  final List<MapEntry<String, int>> data;
  final Color color;
  final Color textColor;

  _BarChartPainter({
    required this.data,
    required this.color,
    required this.textColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final textStyle = TextStyle(
      color: textColor,
      fontSize: 10,
    );

    const double barWidthRatio = 0.6;
    final double sectionWidth = size.width / data.length;
    final double barWidth = sectionWidth * barWidthRatio;

    // Determine max value for scaling (min 35 for visual consistency)
    final int maxVal = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final double maxY = (maxVal < 35 ? 35 : maxVal).toDouble();

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final double barHeight = (item.value / maxY) * (size.height - 20); // Leave room for text

      final double x = (i * sectionWidth) + (sectionWidth - barWidth) / 2;
      final double y = size.height - 20 - barHeight;

      // Draw bar
      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(rrect, paint);

      // Draw value on top
      final textSpan = TextSpan(
        text: '${item.value}',
        style: textStyle.copyWith(fontWeight: FontWeight.bold),
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x + (barWidth - textPainter.width) / 2, y - 12),
      );

      // Draw Label at bottom
      final labelSpan = TextSpan(
        text: item.key,
        style: textStyle,
      );
      final labelPainter = TextPainter(
        text: labelSpan,
        textDirection: TextDirection.ltr,
      );
      labelPainter.layout();
      labelPainter.paint(
        canvas,
        Offset(x + (barWidth - labelPainter.width) / 2, size.height - 12),
      );
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter oldDelegate) {
    return oldDelegate.data != data || oldDelegate.color != color;
  }
}
