import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class InteractiveContainer extends StatefulWidget {
  final Widget Function(bool isHovered) child;

  const InteractiveContainer({
    super.key,
    required this.child,
  });

  @override
  InteractiveContainerState createState() => InteractiveContainerState();
}

class InteractiveContainerState extends State<InteractiveContainer> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final content = AnimatedContainer(
      curve: Curves.easeInOut,
      duration: const Duration(milliseconds: 800),
      child: widget.child(_hovering),
    );

    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      // Hover for web and desktop
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        onHover: (_) => _hovered(true),
        onExit: (_) => _hovered(false),
        child: content,
      );
    } else {
      // Simulate hover on mobile with a tap
      return GestureDetector(
        onTapDown: (_) => _hovered(true),
        onTapUp: (_) => _hovered(false),
        onTapCancel: () => _hovered(false),
        child: content,
      );
    }
  }

  _hovered(bool hovered) {
    setState(() {
      _hovering = hovered;
    });
  }
}
