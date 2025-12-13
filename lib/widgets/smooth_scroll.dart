import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SmoothScroll extends StatefulWidget {
  final Widget child;
  final ScrollController controller;
  final int duration;
  final double speed;
  final Curve curve;

  const SmoothScroll({
    super.key,
    required this.child,
    required this.controller,
    this.duration = 400,
    this.speed = 2.0,
    this.curve = Curves.easeOutQuart,
  });

  @override
  State<SmoothScroll> createState() => _SmoothScrollState();
}

class _SmoothScrollState extends State<SmoothScroll> {
  double? _targetScroll;

  void _onPointerScroll(PointerSignalEvent event) {
    if (event is PointerScrollEvent && event.kind == PointerDeviceKind.mouse) {
      // If the scroll delta is 0, ignore
      if (event.scrollDelta.dy == 0) return;

      // Ensure controller is attached
      if (!widget.controller.hasClients) return;

      final position = widget.controller.position;
      final double minScrollExtent = position.minScrollExtent;
      final double maxScrollExtent = position.maxScrollExtent;
      final double currentPixels = position.pixels;

      // Initialize target if null or if significantly desynced (e.g. manual drag/scroll elsewhere)
      // We consider it desynced if the difference is large and we are not currently animating (heuristic)
      // A better way is to rely on ScrollNotifications to reset _targetScroll on drag.
      if (_targetScroll == null) {
        _targetScroll = currentPixels;
      }

      // If the current position is far from target (e.g. user dragged scrollbar),
      // snap target to current to avoid jumping back.
      // Threshold is arbitrary, but should be larger than a typical frame's movement.
      if ((currentPixels - _targetScroll!).abs() > 100) {
        _targetScroll = currentPixels;
      }

      double delta = event.scrollDelta.dy * widget.speed;

      // Accumulate
      _targetScroll = _targetScroll! + delta;

      // Clamp target to extents
      _targetScroll = _targetScroll!.clamp(minScrollExtent, maxScrollExtent);

      // If we are already at the edge, don't animate to avoid overscroll visual glitches if not desired,
      // but BouncingScrollPhysics handles it.

      widget.controller.animateTo(
        _targetScroll!,
        duration: Duration(milliseconds: widget.duration),
        curve: widget.curve,
      );
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification &&
        notification.dragDetails != null) {
      // User started dragging, reset target
      _targetScroll = null;
    } else if (notification is ScrollEndNotification &&
        notification.dragDetails != null) {
      // User stopped dragging
      _targetScroll = widget.controller.position.pixels;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: _onPointerScroll,
      child: NotificationListener<ScrollNotification>(
        onNotification: _onScrollNotification,
        child: widget.child,
      ),
    );
  }
}
