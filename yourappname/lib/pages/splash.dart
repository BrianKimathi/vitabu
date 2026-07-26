import 'dart:math' as math;
import 'package:yourappname/pages/bottombar.dart';
import 'package:yourappname/pages/genresprefrences.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yourappname/pages/intro.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with TickerProviderStateMixin {
  SharedPref sharedPre = SharedPref();
  late GeneralProvider generalProvider;

  late AnimationController _logoController;
  late AnimationController _particleController;
  late AnimationController _taglineController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _taglineFade;
  late Animation<Offset> _taglineSlide;

  @override
  void initState() {
    super.initState();
    // Enable full screen (hide status bar & navigation bar)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Logo pop-in animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.elasticOut,
    );
    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0, 0.45, curve: Curves.easeIn),
      ),
    );

    // Floating subtle background shapes
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Tagline slide-up & fade-in
    _taglineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOut),
    );
    _taglineSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _taglineController, curve: Curves.easeOutCubic),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _logoController.forward().then((_) {
          if (mounted) _taglineController.forward();
        });
      }
    });

    ischeckFirstTime();
  }

  @override
  void dispose() {
    // Restore system UI overlay
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    _logoController.dispose();
    _particleController.dispose();
    _taglineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark || Constant.isDarkMode;
    final size = MediaQuery.sizeOf(context);

    final cardBg = Colors.white;
    final titleColor = const Color(0xFF1F2937);
    final subtitleColor = const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Main Center Content
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Clean Logo presentation on pure white
                ScaleTransition(
                  scale: _logoScale,
                  child: FadeTransition(
                    opacity: _logoFade,
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: const MyImage(
                        imagePath: "logo.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 36),

                // App Tagline
                SlideTransition(
                  position: _taglineSlide,
                  child: FadeTransition(
                    opacity: _taglineFade,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: colorPrimary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: colorPrimary.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: colorPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Your World of Books",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorPrimary,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 64),

                // Loading Indicator
                FadeTransition(
                  opacity: _taglineFade,
                  child: SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        colorPrimary,
                      ),
                      backgroundColor: colorPrimary.withValues(alpha: 0.15),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Caption
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _taglineFade,
              child: Text(
                "Books  ·  Magazines  ·  Audiobooks",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: subtitleColor,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future ischeckFirstTime() async {
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);

    await generalProvider.getGeneralsetting(context);
    String? seen = await sharedPre.read("seen") ?? "";
    String? edit = await sharedPre.read("isEdit") ?? "";

    await getUserData();
    if (!mounted) return;

    if (!generalProvider.loading) {
      if (seen == "1") {
        if (Constant.userID != null && Constant.userID != "") {
          if (edit == "0") {
            Navigator.of(context).pushReplacement(PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return GenresPrefrences(
                  isCategoryType: true,
                  isEditType: "2",
                );
              },
              transitionDuration: const Duration(milliseconds: 150),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return ClipPath(
                      clipper: CircularRevealClipper(progress: animation.value),
                      child: child,
                    );
                  },
                  child: child,
                );
              },
            ));
          } else {
            Navigator.of(context).pushReplacement(PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return Bottombar();
              },
              transitionDuration: const Duration(milliseconds: 150),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return ClipPath(
                      clipper: CircularRevealClipper(progress: animation.value),
                      child: child,
                    );
                  },
                  child: child,
                );
              },
            ));
          }
        } else {
          Navigator.of(context).pushReplacement(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return Bottombar();
            },
            transitionDuration: const Duration(milliseconds: 150),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return ClipPath(
                    clipper: CircularRevealClipper(progress: animation.value),
                    child: child,
                  );
                },
                child: child,
              );
            },
          ));
        }
      } else {
        if (generalProvider.onBoardingModel.status == 400 &&
            (generalProvider.onBoardingModel.result?.length ?? 0) <= 0) {
          Navigator.of(context).pushReplacement(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return Bottombar();
            },
            transitionDuration: const Duration(milliseconds: 150),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return ClipPath(
                    clipper: CircularRevealClipper(progress: animation.value),
                    child: child,
                  );
                },
                child: child,
              );
            },
          ));
        } else {
          Navigator.of(context).pushReplacement(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              return Intro(
                introList: generalProvider.onBoardingModel.result ?? [],
              );
            },
            transitionDuration: const Duration(milliseconds: 150),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return ClipPath(
                    clipper: CircularRevealClipper(progress: animation.value),
                    child: child,
                  );
                },
                child: child,
              );
            },
          ));
        }
      }
    }
  }

  Future<void> getUserData() async {
    final String? onesignalID = await sharedPre.read('onesignal_apid');
    if (!kIsWeb) {
      if (onesignalID == null || onesignalID.isEmpty) {
        printLog("OneSignal ID is missing; skipping OneSignal init");
        return;
      }

      printLog("Has onesignalID ==> $onesignalID");
      OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
      OneSignal.initialize(onesignalID);
      OneSignal.Notifications.requestPermission(true);
      OneSignal.Notifications.addPermissionObserver((state) {
        printLog("Has permission ==> $state");
      });
      OneSignal.User.pushSubscription.addObserver((state) {
        printLog(
            "pushSubscription state ==> ${state.current.jsonRepresentation()}");
      });
      OneSignal.Notifications.addForegroundWillDisplayListener((event) {
        event.preventDefault();
        event.notification.display();
      });
    }
  }
}
