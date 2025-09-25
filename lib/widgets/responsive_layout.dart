import 'package:flutter/material.dart';

/// A responsive layout widget that adapts to different screen sizes.
/// Provides breakpoints for mobile, tablet, and desktop layouts.
class ResponsiveLayout extends StatelessWidget {
  /// Widget to show on mobile devices (width < 600)
  final Widget mobile;
  
  /// Widget to show on tablet devices (width >= 600 and < 1200)
  final Widget? tablet;
  
  /// Widget to show on desktop devices (width >= 1200)
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1200) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= 600) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }

  /// Helper method to determine if current screen is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Helper method to determine if current screen is tablet
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  /// Helper method to determine if current screen is desktop
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  /// Get the appropriate padding for the current screen size
  static EdgeInsets getScreenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 120, vertical: 40);
    } else if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 60, vertical: 24);
    } else {
      return const EdgeInsets.all(16);
    }
  }

  /// Get the appropriate max width for content on large screens
  static double getContentMaxWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 800;
    } else if (isTablet(context)) {
      return 600;
    } else {
      return double.infinity;
    }
  }
}

/// Widget that centers content with appropriate max width for large screens
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? maxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? ResponsiveLayout.getScreenPadding(context);
    final effectiveMaxWidth = maxWidth ?? ResponsiveLayout.getContentMaxWidth(context);

    return Container(
      width: double.infinity,
      padding: effectivePadding,
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: effectiveMaxWidth),
          child: child,
        ),
      ),
    );
  }
}

/// A responsive card widget that adapts its styling based on screen size
class ResponsiveCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ResponsiveCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = ResponsiveLayout.isTablet(context) || ResponsiveLayout.isDesktop(context);
    
    return Container(
      margin: margin ?? (isLargeScreen 
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
        : const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isLargeScreen ? 16 : 12),
        boxShadow: isLargeScreen ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ] : [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isLargeScreen ? Colors.grey.shade200 : Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(isLargeScreen ? 24 : 16),
        child: child,
      ),
    );
  }
}