import 'dart:ui';
import 'package:flutter/material.dart';

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    // BouncingScrollPhysics provides a smoother feel than the default ClampingScrollPhysics
    // on desktop, similar to mobile or modern web experiences.
    return const BouncingScrollPhysics();
  }
}
