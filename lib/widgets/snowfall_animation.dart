import 'dart:math';
import 'package:flutter/material.dart';

class SnowfallAnimation extends StatefulWidget {
  final int numberOfSnowflakes;
  final bool isEnabled;

  const SnowfallAnimation({
    super.key,
    this.numberOfSnowflakes = 50,
    this.isEnabled = true,
  });

  @override
  State<SnowfallAnimation> createState() => _SnowfallAnimationState();
}

class _SnowfallAnimationState extends State<SnowfallAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Snowflake> _snowflakes = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _initializeSnowflakes();
  }

  void _initializeSnowflakes() {
    _snowflakes = List.generate(
      widget.numberOfSnowflakes,
      (index) => _generateSnowflake(true),
    );
  }

  Snowflake _generateSnowflake(bool randomY) {
    return Snowflake(
      x: _random.nextDouble(),
      y: randomY ? _random.nextDouble() : -0.1,
      size: _random.nextDouble() * 3 + 2,
      speed: _random.nextDouble() * 0.005 + 0.002,
      opacity: _random.nextDouble() * 0.5 + 0.3,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEnabled) return const SizedBox.shrink();

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          _updateSnowflakes();
          return CustomPaint(
            painter: SnowPainter(_snowflakes),
            size: Size.infinite,
          );
        },
      ),
    );
  }

  void _updateSnowflakes() {
    for (int i = 0; i < _snowflakes.length; i++) {
      _snowflakes[i].y += _snowflakes[i].speed;
      if (_snowflakes[i].y > 1.1) {
        _snowflakes[i] = _generateSnowflake(false);
      }
    }
  }
}

class Snowflake {
  double x;
  double y;
  double size;
  double speed;
  double opacity;

  Snowflake({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
  });
}

class SnowPainter extends CustomPainter {
  final List<Snowflake> snowflakes;

  SnowPainter(this.snowflakes);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (var snowflake in snowflakes) {
      paint.color = Colors.white.withOpacity(snowflake.opacity);
      canvas.drawCircle(
        Offset(snowflake.x * size.width, snowflake.y * size.height),
        snowflake.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
