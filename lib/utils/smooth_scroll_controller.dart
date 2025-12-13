import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class SmoothScrollController extends ScrollController {
  final int duration;
  final double speed;
  final Curve curve;

  SmoothScrollController({
    super.initialScrollOffset,
    super.keepScrollOffset,
    super.debugLabel,
    this.duration = 400,
    this.speed = 2.0,
    this.curve = Curves.easeOutQuart,
  });

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) {
    return _SmoothScrollPosition(
      physics: physics,
      context: context,
      initialPixels: initialScrollOffset,
      keepScrollOffset: keepScrollOffset,
      oldPosition: oldPosition,
      debugLabel: debugLabel,
      duration: duration,
      speed: speed,
      curve: curve,
    );
  }
}

class _SmoothScrollPosition extends ScrollPositionWithSingleContext {
  final int duration;
  final double speed;
  final Curve curve;
  double? _targetPixels;

  _SmoothScrollPosition({
    required super.physics,
    required super.context,
    super.initialPixels,
    super.keepScrollOffset,
    super.oldPosition,
    super.debugLabel,
    required this.duration,
    required this.speed,
    required this.curve,
  });

  @override
  void pointerScroll(double delta) {
    if (delta == 0.0) return;

    // If physics explicitly rejects user offset (e.g. locked), respect that.
    // However, usually pointerScroll is only called if we should scroll.
    // standard implementation checks `physics.shouldAcceptUserOffset(this)` but
    // usually that's for drag. We'll skip strict check to ensure wheel always works
    // if the scroll view is generally scrollable, but checking physics is safer.
    if (!physics.shouldAcceptUserOffset(this)) {
      return;
    }

    // Current target calculation logic
    final double currentPixels = pixels;

    // Initialize target if null
    if (_targetPixels == null) {
      _targetPixels = currentPixels;
    }

    // If the actual position has drifted far from target (e.g. user dragged scrollbar
    // or touch-dragged), reset target to current to avoid jumping back.
    if ((currentPixels - _targetPixels!).abs() > 100) {
      _targetPixels = currentPixels;
    }

    // Apply speed multiplier
    final double scrollDelta = delta * speed;

    // Update target
    _targetPixels = _targetPixels! + scrollDelta;

    // Clamp to extents
    _targetPixels = _targetPixels!.clamp(minScrollExtent, maxScrollExtent);

    // Animate to target
    animateTo(
      _targetPixels!,
      duration: Duration(milliseconds: duration),
      curve: curve,
    );
  }

  @override
  void goBallistic(double velocity) {
    // When a ballistic simulation starts (e.g. end of drag), we should clear our target
    // so future wheel events start from the settled position.
    _targetPixels = null;
    super.goBallistic(velocity);
  }
}
