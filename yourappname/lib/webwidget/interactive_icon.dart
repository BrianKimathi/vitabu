import 'package:yourappname/utils/color.dart';
import 'package:flutter/material.dart';

class InteractiveIcon extends StatefulWidget {
  final IconData iconData;
  final double? size;
  final Color? color, secondColor;
  final dynamic onTap;
  const InteractiveIcon(
      {super.key,
      required this.iconData,
      this.color,
      this.secondColor,
      this.size,
      required this.onTap});

  @override
  InteractiveIconState createState() => InteractiveIconState();
}

class InteractiveIconState extends State<InteractiveIcon> {
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _hovering = false;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
        onHover: (_) => _hovered(true),
        onExit: (_) => _hovered(false),
        child: InkWell(
          splashColor: transparent,
          focusColor: transparent,
          hoverColor: transparent,
          highlightColor: transparent,
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _hovering ? 1.2 : 0.7,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            child: Icon(
              widget.iconData,
              size: widget.size ?? 20,
              color: _hovering ? widget.color : widget.secondColor ?? black,
            ),
          ),
        ));
  }

  _hovered(bool hovered) {
    setState(() {
      _hovering = hovered;
    });
  }
}
