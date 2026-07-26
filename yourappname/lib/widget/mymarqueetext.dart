import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:marquee/marquee.dart';

class MyMarqueeText extends StatelessWidget {
  final String? text;
  final double fontsize;
  final dynamic fontstyle, fontweight, color;

  const MyMarqueeText({
    super.key,
    this.color,
    required this.text,
    required this.fontsize,
    this.fontweight,
    this.fontstyle,
  });

  @override
  Widget build(BuildContext context) {
    if (text == null || text!.trim().isEmpty) {
      return const SizedBox.shrink(); // Or a fallback widget
    }
    return Marquee(
      text: text ?? "",
      style: GoogleFonts.inter(
        fontSize: fontsize,
        fontStyle: fontstyle,
        color:  color ?? Theme.of(context).textTheme.bodyLarge!.color,
        fontWeight: fontweight,
      ),
      scrollAxis: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.center,
      blankSpace: MediaQuery.of(context).size.width * 0.5,
      velocity: 50,
      pauseAfterRound: const Duration(milliseconds: 500),
      showFadingOnlyWhenScrolling: true,
      fadingEdgeStartFraction: 0.1,
      fadingEdgeEndFraction: 0.1,
      startPadding: 10,
      accelerationDuration: const Duration(milliseconds: 500),
      accelerationCurve: Curves.linear,
      decelerationDuration: const Duration(milliseconds: 500),
      decelerationCurve: Curves.easeOut,
    );
  }
}
