import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/colors.dart';

class PerformanceChart extends StatefulWidget {
  final Map<String, int> scores; // e.g. {"Gaming": 92, "Coding": 98, ...}
  final double size;

  const PerformanceChart({
    super.key,
    required this.scores,
    this.size = 200.0,
  });

  @override
  State<PerformanceChart> createState() => _PerformanceChartState();
}

class _PerformanceChartState extends State<PerformanceChart> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(PerformanceChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.reset();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: RadarChartPainter(
            scores: widget.scores,
            animationValue: _animation.value,
          ),
        );
      },
    );
  }
}

class RadarChartPainter extends CustomPainter {
  final Map<String, int> scores;
  final double animationValue;

  RadarChartPainter({required this.scores, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 * 0.75;
    final keys = scores.keys.toList();
    final values = scores.values.toList();
    final count = keys.length;

    if (count < 3) return;

    final paintGrid = Paint()
      ..color = PremiumTheme.darkBorder.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final paintWeb = Paint()
      ..color = PremiumTheme.darkBorder.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // 1. Draw background concentric grid polygons (e.g. 4 levels: 25%, 50%, 75%, 100%)
    for (int step = 1; step <= 4; step++) {
      final currentRadius = radius * (step / 4.0);
      final path = Path();
      for (int i = 0; i < count; i++) {
        final angle = (i * 2 * pi / count) - pi / 2;
        final point = Offset(
          center.dx + currentRadius * cos(angle),
          center.dy + currentRadius * sin(angle),
        );
        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();
      canvas.drawPath(path, paintGrid);
    }

    // 2. Draw spoke lines from center to outer vertices
    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * pi / count) - pi / 2;
      final point = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      canvas.drawLine(center, point, paintWeb);
    }

    // 3. Draw the dynamic value polygon
    final paintValue = Paint()
      ..shader = PremiumTheme.primaryGradient.createShader(
        Rect.fromCircle(center: center, radius: radius),
      )
      ..style = PaintingStyle.fill;

    final paintStroke = Paint()
      ..color = PremiumTheme.primaryNeon
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final valuePath = Path();
    final valuePoints = <Offset>[];

    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * pi / count) - pi / 2;
      final valPercent = (values[i] / 100.0) * animationValue;
      final point = Offset(
        center.dx + radius * valPercent * cos(angle),
        center.dy + radius * valPercent * sin(angle),
      );
      valuePoints.add(point);
      if (i == 0) {
        valuePath.moveTo(point.dx, point.dy);
      } else {
        valuePath.lineTo(point.dx, point.dy);
      }
    }
    valuePath.close();

    // Draw solid gradient shape with transparency
    canvas.save();
    canvas.drawPath(valuePath, paintValue..color = PremiumTheme.primaryNeon.withValues(alpha: 0.18));
    canvas.restore();

    // Draw neon border stroke
    canvas.drawPath(valuePath, paintStroke);

    // Draw dots at value points
    final dotPaint = Paint()
      ..color = PremiumTheme.secondaryNeon
      ..style = PaintingStyle.fill;
    final dotStrokePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var point in valuePoints) {
      canvas.drawCircle(point, 4, dotPaint);
      canvas.drawCircle(point, 4, dotStrokePaint);
    }

    // 4. Draw labels text
    const textStyle = TextStyle(
      color: PremiumTheme.textSecondary,
      fontSize: 10,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
    );

    for (int i = 0; i < count; i++) {
      final angle = (i * 2 * pi / count) - pi / 2;
      final textRadius = radius + 15;
      final point = Offset(
        center.dx + textRadius * cos(angle),
        center.dy + textRadius * sin(angle),
      );

      final span = TextSpan(
        style: textStyle,
        children: [
          TextSpan(text: '${keys[i]}\n'),
          TextSpan(
            text: '${(values[i] * animationValue).toInt()}%',
            style: const TextStyle(
              color: PremiumTheme.primaryNeon,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      );
      final tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      tp.layout();
      
      // Calculate alignment offsets based on vertex direction
      double xOffset = 0.0;
      double yOffset = 0.0;

      if (cos(angle).abs() < 0.1) {
        xOffset = -tp.width / 2;
        yOffset = sin(angle) < 0 ? -tp.height : 0;
      } else if (cos(angle) > 0) {
        xOffset = 2.0;
        yOffset = -tp.height / 2;
      } else {
        xOffset = -tp.width - 2;
        yOffset = -tp.height / 2;
      }

      tp.paint(canvas, point + Offset(xOffset, yOffset));
    }
  }

  @override
  bool shouldRepaint(covariant RadarChartPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue || oldDelegate.scores != scores;
  }
}
