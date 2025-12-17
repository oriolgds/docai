import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class CachedMarkdownBody extends StatefulWidget {
  final String data;
  final bool isDark;

  const CachedMarkdownBody({
    super.key,
    required this.data,
    required this.isDark,
  });

  @override
  State<CachedMarkdownBody> createState() => _CachedMarkdownBodyState();
}

class _CachedMarkdownBodyState extends State<CachedMarkdownBody> {
  // Cache the widget to prevent re-parsing when parent rebuilds
  Widget? _cachedWidget;
  String? _cachedData;
  bool? _cachedIsDark;

  @override
  Widget build(BuildContext context) {
    // Check if we can reuse the cached widget
    if (_cachedWidget != null &&
        _cachedData == widget.data &&
        _cachedIsDark == widget.isDark) {
      return _cachedWidget!;
    }

    // Update cache keys
    _cachedData = widget.data;
    _cachedIsDark = widget.isDark;

    final codeBackgroundColor = widget.isDark ? Colors.black26 : Colors.grey[100];

    // Create and cache the widget
    _cachedWidget = MarkdownBody(
      data: widget.data,
      styleSheet: MarkdownStyleSheet(
        p: TextStyle(
          color: widget.isDark ? Colors.grey[200] : Colors.black87,
          fontSize: 15,
          height: 1.4,
        ),
        code: TextStyle(
          backgroundColor: codeBackgroundColor,
          color: widget.isDark ? Colors.green[300] : Colors.green[700],
          fontFamily: 'monospace',
        ),
        codeblockDecoration: BoxDecoration(
          color: codeBackgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );

    return _cachedWidget!;
  }
}
