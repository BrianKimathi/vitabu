import 'package:flutter/material.dart';

class CircularRevealClipper extends CustomClipper<Path> {
  final double progress;

  CircularRevealClipper({required this.progress});

  @override
  Path getClip(Size size) {
    final radius = size.longestSide * progress;
    final center = Offset(size.width / 2, size.height / 2);
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(covariant CircularRevealClipper oldClipper) {
    return progress != oldClipper.progress;
  }
}
