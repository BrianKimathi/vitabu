import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MyImage extends StatelessWidget {
  final double? height;
  final double? width;
  final String? imagePath;
  final Color? color;
  final dynamic fit;
  final double? radius;
  final bool? isAppicon;

  const MyImage(
      {super.key,
      this.width,
      this.height,
      required this.imagePath,
      this.isAppicon,
      this.color,
      this.fit,
      this.radius});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? 0),
      child: isAppicon == true
          ? Image.asset(
              "assets/appicon/$imagePath",
              height: height,
              color: color,
              width: width,
              fit: fit,
            )
          : Image.asset(
              "assets/images/$imagePath",
              height: height,
              color: color,
              width: width,
              fit: fit,
            ),
    );
  }
}
