import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MyNetworkImage extends StatelessWidget {
  final String? imagePath;
  final double? height, width, radius;
  final dynamic fit;

  const MyNetworkImage({
    super.key,
    required this.imagePath,
    this.height,
    this.width,
    this.fit,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseCol = isDark ? const Color(0xFF262636) : const Color(0xFFE5E7EB);
    final highlightCol = isDark ? const Color(0xFF3F3F56) : const Color(0xFFF3F4F6);

    // Fallback widget when image is missing or failed to load - pulse animation with brand symbol instead of broken icon
    Widget buildFallback() {
      return Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: baseCol,
          borderRadius: BorderRadius.circular(radius ?? 0),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Shimmer.fromColors(
              baseColor: baseCol,
              highlightColor: highlightCol,
              period: const Duration(milliseconds: 1500),
              child: Container(
                height: height,
                width: width,
                decoration: BoxDecoration(
                  color: baseCol,
                  borderRadius: BorderRadius.circular(radius ?? 0),
                ),
              ),
            ),
            Icon(
              Icons.menu_book_rounded,
              size: (height != null && height! < 50) ? 16 : 28,
              color: isDark ? const Color(0xFF3B3B52) : const Color(0xFFD1D5DB),
            ),
          ],
        ),
      );
    }

    // Safeguard against empty or null URLs to prevent image painting assertion failures
    if (imagePath == null || imagePath!.trim().isEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(radius ?? 0),
        child: buildFallback(),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? 0),
      child: CachedNetworkImage(
        imageUrl: imagePath!,
        fit: fit ?? BoxFit.cover,
        height: height,
        width: width,
        placeholder: (context, url) {
          return Shimmer.fromColors(
            baseColor: baseCol,
            highlightColor: highlightCol,
            period: const Duration(milliseconds: 1200),
            child: Container(
              height: height,
              width: width,
              decoration: BoxDecoration(
                color: baseCol,
                borderRadius: BorderRadius.circular(radius ?? 0),
              ),
            ),
          );
        },
        errorWidget: (context, url, error) => buildFallback(),
      ),
    );
  }
}
