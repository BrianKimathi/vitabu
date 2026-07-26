import 'package:flutter/material.dart';
import 'package:yourappname/utils/color.dart';
import 'package:shimmer/shimmer.dart';

class CustomWidget extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

// Rectangular
  const CustomWidget.rectangular(
      {super.key, this.width = double.infinity, required this.height})
      : shapeBorder = const RoundedRectangleBorder();

// Circle

  const CustomWidget.circular(
      {super.key,
      this.width = double.infinity,
      required this.height,
      this.shapeBorder = const CircleBorder()});

// Round corner Container

  const CustomWidget.roundcorner(
      {super.key,
      this.width = double.infinity,
      required this.height,
      this.shapeBorder = const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
        Radius.circular(8),
      ))});

// for line / text

  const CustomWidget.roundrectborder(
      {super.key,
      this.width = double.infinity,
      required this.height,
      this.shapeBorder = const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
        Radius.circular(5),
      ))});

  const CustomWidget.bottomrightcorner(
      {super.key,
      this.width = double.infinity,
      required this.height,
      this.shapeBorder = const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(20),
      ))});

  @override
  Widget build(BuildContext context) => Shimmer.fromColors(
        baseColor: gray,
        highlightColor: white,
        period: const Duration(seconds: 1),
        child: Container(
          // padding: const EdgeInsets.all(5.0),
          // margin: const EdgeInsets.all(5.0),
          width: width,
          height: height,
          decoration: ShapeDecoration(
            color: colorAccent,
            shape: shapeBorder,
          ),
        ),
      );
}
