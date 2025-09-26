import 'package:flutter/material.dart';

class CustomLoader extends StatefulWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  final Duration duration;
  
  const CustomLoader({
    super.key,
    this.size = 40.0,
    this.color = Colors.black,
    this.strokeWidth = 3.0,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<CustomLoader> createState() => _CustomLoaderState();
}

class _CustomLoaderState extends State<CustomLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.repeat();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * 3.14159,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.size / 2),
              border: Border.all(
                color: widget.color.withOpacity(0.3),
                width: widget.strokeWidth,
              ),
            ),
            child: Container(
              margin: EdgeInsets.all(widget.strokeWidth),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular((widget.size - widget.strokeWidth * 2) / 2),
                gradient: LinearGradient(
                  colors: [widget.color, Colors.transparent],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Alternative simple circular loader
class SimpleLoader extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  
  const SimpleLoader({
    super.key,
    this.size = 24.0,
    this.color = Colors.black,
    this.strokeWidth = 2.0,
  });
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        color: color,
        strokeWidth: strokeWidth,
      ),
    );
  }
}

// Pulsing dot loader
class PulsingLoader extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;
  
  const PulsingLoader({
    super.key,
    this.size = 12.0,
    this.color = Colors.black,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<PulsingLoader> createState() => _PulsingLoaderState();
}

class _PulsingLoaderState extends State<PulsingLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    _controller.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            final delay = index * 0.2;
            final progress = (_controller.value + delay) % 1.0;
            final scale = 0.5 + 0.5 * (1.0 - (progress - 0.5).abs() * 2).clamp(0.0, 1.0);
            
            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.2),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.7 + 0.3 * scale),
                    borderRadius: BorderRadius.circular(widget.size / 2),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}