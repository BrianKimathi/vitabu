import 'package:yourappname/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/widget/mynetworkimg.dart';

class InteractiveNetworkIcon extends StatefulWidget {
  final String imagePath;
  final BoxFit? iconFit;
  final Color? bgColor;
  final Color? bgHoverColor;
  final BorderRadius? bgRadius; // ✅ now supports BorderRadius
  final double? height;
  final double? width;
  final bool withBG;

  const InteractiveNetworkIcon({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.iconFit,
    this.bgColor,
    this.bgHoverColor,
    this.bgRadius,
    this.withBG = true,
  });

  @override
  State<InteractiveNetworkIcon> createState() => _InteractiveNetworkIconState();
}

class _InteractiveNetworkIconState extends State<InteractiveNetworkIcon> {
  bool _hovering = false;

  void _setHover(bool hovering) {
    setState(() {
      _hovering = hovering;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = _hovering
        ? widget.bgHoverColor ?? transparent
        : widget.bgColor ?? transparent;
    final scale = _hovering ? 1.05 : 1.0;

    return MouseRegion(
      onEnter: (_) => _setHover(true),
      onExit: (_) => _setHover(false),
      child: widget.withBG
          ? AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              transform: Matrix4.identity()..scale(scale),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: widget.bgRadius ?? BorderRadius.zero,
                boxShadow: _hovering
                    ? [
                        BoxShadow(
                          color: transparent.withOpacity( 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : [],
              ),
              padding: const EdgeInsets.all(6),
              child: ClipRRect(
                borderRadius: widget.bgRadius ?? BorderRadius.zero,
                child: MyNetworkImage(
                  imagePath: widget.imagePath,
                  width: widget.width,
                  height: widget.height,
                  fit: widget.iconFit,
                ),
              ),
            )
          : ClipRRect(
              borderRadius: widget.bgRadius ?? BorderRadius.zero,
              child: MyNetworkImage(
                imagePath: widget.imagePath,
                width: widget.width,
                height: widget.height,
                fit: widget.iconFit,
              ),
            ),
    );
  }
}
