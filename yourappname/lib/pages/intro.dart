import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:yourappname/model/onboardingmodel.dart';
import 'package:yourappname/pages/bottombar.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/nodata.dart';

class Intro extends StatefulWidget {
  final List<Result>? introList;
  const Intro({super.key, required this.introList});

  @override
  State<Intro> createState() => _IntroState();
}

class _IntroState extends State<Intro> {
  final SharedPref sharedPre = SharedPref();
  late PageController pageController;
  late GeneralProvider generalProvider;

  @override
  void initState() {
    super.initState();
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    pageController = PageController(initialPage: generalProvider.pageIdex ?? 0);
  }

  @override
  void dispose() {
    pageController.dispose();
    generalProvider.clearProvider();
    super.dispose();
  }

  Future<void> _finishOnboarding() async {
    await sharedPre.save("seen", "1");
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) {
          return const Bottombar();
        },
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return ClipPath(
            clipper: CircularRevealClipper(progress: animation.value),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final list = widget.introList;

    if (list == null || list.isEmpty) {
      return const Scaffold(body: NoData());
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF12121A) : const Color(0xFFF8F9FD),
      body: Consumer<GeneralProvider>(
        builder: (context, generalProvider, child) {
          final currentIndex = generalProvider.pageIdex ?? 0;
          final isLastPage = currentIndex == list.length - 1;

          return SafeArea(
            child: Column(
              children: [
                // Top Header Bar: Skip Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Brand accent dot
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorPrimary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          "${currentIndex + 1} / ${list.length}",
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: colorPrimary,
                          ),
                        ),
                      ),
                      // Skip Action
                      if (!isLastPage)
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: _finishOnboarding,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Text(
                              "Skip",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Main PageView Content
                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    itemCount: list.length,
                    physics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      generalProvider.setIntroIndexChange(index);
                    },
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Hero Image Card
                            Container(
                              height: MediaQuery.sizeOf(context).height * 0.38,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black.withValues(alpha: 0.4)
                                        : colorPrimary.withValues(alpha: 0.08),
                                    blurRadius: 24,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: MyNetworkImage(
                                  imagePath: item.image ?? "",
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                            const SizedBox(height: 36),

                            // Title
                            Text(
                              item.title ?? "",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : const Color(0xFF1F2937),
                                letterSpacing: -0.5,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Description
                            Text(
                              item.description ?? "",
                              textAlign: TextAlign.center,
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Navigation Bar Area
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                  child: Column(
                    children: [
                      // Animated Indicator Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          list.length,
                          (dotIndex) {
                            final isSelected = currentIndex == dotIndex;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(right: 6),
                              height: 8,
                              width: isSelected ? 28 : 8,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? colorPrimary
                                    : isDark
                                        ? Colors.grey[800]
                                        : const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Primary Action CTA Button
                      InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          if (isLastPage) {
                            _finishOnboarding();
                          } else {
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [colorPrimary, colorPrimaryDark],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: colorPrimary.withValues(alpha: 0.3),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                isLastPage ? "Get Started" : "Continue",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                isLastPage
                                    ? FontAwesomeIcons.rocket
                                    : Icons.arrow_forward_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
