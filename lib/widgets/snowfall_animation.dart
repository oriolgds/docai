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
    );
    if (widget.isEnabled) {
      _controller.repeat();
    }
    _initializeSnowflakes();
  }

  @override
  void didUpdateWidget(SnowfallAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isEnabled != oldWidget.isEnabled) {
      if (widget.isEnabled) {
        _controller.repeat();
      } else {
        // Delay stopping to allow fade-out animation in parent to complete
        Future.delayed(const Duration(milliseconds: 600), () {
          if (mounted && !widget.isEnabled) {
            _controller.stop();
          }
        });
      }
    }
  }

  void _initializeSnowflakes() {
    _snowflakes = List.generate(
      widget.numberOfSnowflakes,
      (index) => _generateSnowflake(true),
    );
  }

  Snowflake _generateSnowflake(bool randomY) {
    final snowflake = Snowflake(
      x: 0,
      y: 0,
      size: 0,
      speed: 0,
      opacity: 0,
    );
    _resetSnowflake(snowflake, randomY);
    return snowflake;
  }

  void _resetSnowflake(Snowflake snowflake, bool randomY) {
    snowflake.x = _random.nextDouble();
    snowflake.y = randomY ? _random.nextDouble() : -0.1;
    snowflake.size = _random.nextDouble() * 3 + 2;
    snowflake.speed = _random.nextDouble() * 0.005 + 0.002;
    snowflake.opacity = _random.nextDouble() * 0.5 + 0.3;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Optimization: Controller state is managed in didUpdateWidget/initState
    // We don't return early here to allow parent to handle fade-out transitions

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
        // Optimization: Recycle object instead of creating new one to reduce GC
        _resetSnowflake(_snowflakes[i], false);
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
