import 'package:yourappname/pages/audiobookplaying.dart';
import 'package:yourappname/provider/audiodetailsprovider.dart';
import 'package:yourappname/provider/audioplayprovider.dart';
import 'package:yourappname/provider/bookprovider.dart';
import 'package:yourappname/provider/categorywisedataprovider.dart';
import 'package:yourappname/provider/languagewisedataprovider.dart';
import 'package:yourappname/utils/appthem.dart';
import 'package:yourappname/provider/allcommnetprovider.dart';
import 'package:yourappname/provider/allviewprovider.dart';
import 'package:yourappname/provider/audiobookprovider.dart';
import 'package:yourappname/provider/autherprovider.dart';
import 'package:yourappname/provider/bookdetailsprovider.dart';
import 'package:yourappname/provider/categoryprovider.dart';
import 'package:yourappname/provider/magazinedetailsprovider.dart';
import 'package:yourappname/provider/magazineprovider.dart';
import 'package:yourappname/provider/mylibraryprovider.dart';
import 'package:yourappname/provider/mypurchasedprovider.dart';
import 'package:yourappname/provider/releteditemprovider.dart';
import 'package:yourappname/provider/reviewviewprovider.dart';
import 'package:yourappname/provider/themeprovider.dart';
import 'package:yourappname/provider/viewallprovider.dart';
import 'package:yourappname/provider/walletprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webpages/webhome.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' show PlatformDispatcher;

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:yourappname/firebase_options.dart';
import 'package:yourappname/pages/splash.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/provider/homeprovider.dart';
import 'package:yourappname/provider/notificationprovider.dart';
import 'package:yourappname/provider/packageprovider.dart';
import 'package:yourappname/provider/paymentoptionprovider.dart';
import 'package:yourappname/provider/searchprovider.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/provider/updateprofileprovider.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/webpages/webaudiobookdetails.dart';
import 'package:yourappname/webpages/webdetails.dart';
import 'package:yourappname/webpages/webmagazinedetails.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Readable stack traces in browser console (release web is minified as main.dart.js).
  if (kIsWeb) {
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      print('[WEB_FLUTTER_ERROR] ${details.exceptionAsString()}');
      print(details.stack);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      print('[WEB_UNCAUGHT] $error');
      print(stack);
      return true;
    };
  }

  // Guard against duplicate default app initialization on some devices/engines.
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      printLog('Firebase already initialized, reusing existing [DEFAULT] app.');
    }
  } on FirebaseException catch (e) {
    if (e.code == 'duplicate-app') {
      // Some Android launches auto-init [DEFAULT] natively before Dart syncs apps list.
      printLog('Firebase duplicate-app detected; continuing with existing app.');
    } else {
      rethrow;
    }
  }
  await Locales.init(['en', 'ar', 'hi']);
  
  // Load user credentials immediately to prevent web authentication flicker on refresh
  try {
    final prefs = await SharedPreferences.getInstance();
    Constant.userID = prefs.getString("userid");
    Constant.userCategoryId = prefs.getString("categoryId");
    Constant.isAuthor = prefs.getString("isAuthor");
    Constant.userimage = prefs.getString("userimage");
    Constant.isSubscription = int.tryParse(prefs.getString("is_subscription") ?? "0") ?? 0;
  } catch(e) {
      printLog("Failed to load generic prefs: $e");
  }

  if (!kIsWeb) {
    await JustAudioBackground.init(
        androidNotificationChannelId: Constant.appPackageName,
        androidNotificationChannelName: Constant.appName,
        androidNotificationOngoing: false,
        androidStopForegroundOnPause: true,
        notificationColor: colorPrimary.withOpacity( 0.5));

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => GeneralProvider()),
      ChangeNotifierProvider(create: (_) => HomeProvider()), // home provider
      ChangeNotifierProvider(create: (_) => MagazineProvider()),
      ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ChangeNotifierProvider(create: (_) => UpdateprofileProvider()),
      ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ChangeNotifierProvider(create: (_) => PackageProvider()),
      ChangeNotifierProvider(create: (_) => SearchProvider()),
      ChangeNotifierProvider(create: (_) => PaymentOptionProvider()),
      ChangeNotifierProvider(create: (_) => WalletProvider()),
      ChangeNotifierProvider(create: (_) => AutherProvider()),
      ChangeNotifierProvider(create: (_) => MylibraryProvider()),
      ChangeNotifierProvider(create: (_) => MyPurchasedProvider()),
      ChangeNotifierProvider(create: (_) => AllViewProvider()),
      ChangeNotifierProvider(create: (_) => BookDetailsProvider()),
      ChangeNotifierProvider(create: (_) => MagazineDetailsProvider()),
      ChangeNotifierProvider(create: (_) => AllCommentProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(create: (_) => CategoryProvider()),
      ChangeNotifierProvider(create: (_) => ReletedItemProvider()),
      ChangeNotifierProvider(create: (_) => AudioBookProvider()),
      ChangeNotifierProvider(create: (_) => ReviewViewProvider()),
      ChangeNotifierProvider(create: (_) => AudioDetailsProvider()),
      ChangeNotifierProvider(create: (_) => CategoryWiseDataProvider()),
      ChangeNotifierProvider(create: (_) => LanguageWiseDataProvider()),
      ChangeNotifierProvider(create: (_) => AudioPlayProvider()),
      ChangeNotifierProvider(create: (_) => BookProvider()),

      ChangeNotifierProvider(
        create: (context) => ViewAllProvider(),
      )
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late ThemeProvider themeProvider;
  GeneralProvider generalProvider = GeneralProvider();
  late HomeProvider homeProvider;
  int currentIndex = 0;

  @override
  void initState() {
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    super.initState();
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    WidgetsBinding.instance.addObserver(this);
    if (kIsWeb) {
      getApi(0);
    }
  }

  Future<void> getApi(pageno) async {
    await generalProvider.getGeneralsetting(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!kIsWeb) {
      switch (state) {
        case AppLifecycleState.detached:
          printLog("App detached");
          audioPlayer.stop();
          audioPlayer.dispose();
          break;
        case AppLifecycleState.inactive:
          printLog("App inactive");

          break;
        case AppLifecycleState.paused:
          printLog("App paused");

          break;
        case AppLifecycleState.resumed:
          printLog("App resumed");
          break;
        default:
          break;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    _setSystemUIOverlayStyle();
  }

  Brightness get platformBrightness => MediaQueryData.fromView(
          WidgetsBinding.instance.platformDispatcher.views.single)
      .platformBrightness;

  void _setSystemUIOverlayStyle() {
    if (platformBrightness == Brightness.light) {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.grey[50],
        systemNavigationBarIconBrightness: Brightness.dark,
      ));
    } else {
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.grey[850],
        systemNavigationBarIconBrightness: Brightness.light,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return LocaleBuilder(
          builder: (locale) {
            return MaterialApp(
              navigatorKey: navigatorKey,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme, // Light Theme
              darkTheme: AppTheme.darkTheme, // Dark Theme
              themeMode: Constant.isDarkMode ? ThemeMode.dark : ThemeMode.light,
              title: Constant.appName,
              localizationsDelegates: Locales.delegates,
              supportedLocales: Locales.supportedLocales,
              locale: locale,
              localeResolutionCallback:
                  (Locale? locale, Iterable<Locale> supportedLocales) {
                return locale;
              },
              builder: (context, child) => ResponsiveBreakpoints.builder(
                child: child!,
                breakpoints: [
                  const Breakpoint(start: 0, end: 450, name: MOBILE),
                  const Breakpoint(start: 451, end: 800, name: TABLET),
                  const Breakpoint(start: 801, end: 1920, name: DESKTOP),
                  const Breakpoint(
                      start: 1921, end: double.infinity, name: '4K'),
                ],
              ),
              home: kIsWeb ? _buildInitialWebPage() : Splash(),
              scrollBehavior: const MaterialScrollBehavior().copyWith(
                dragDevices: {
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.touch,
                  PointerDeviceKind.stylus,
                  PointerDeviceKind.unknown,
                  PointerDeviceKind.trackpad
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInitialWebPage() {
    final params = Uri.base.queryParameters;
    final contentType = params['content_type'] ?? '';
    final contentId = params['content_id'] ?? '';
    final categoryId = params['category_id'] ?? '';
    final authorId = params['author_id'] ?? '';
    final name = params['name'] ?? '';

    if (contentId.isEmpty || contentType.isEmpty) return WebHome();

    if (contentType == "1") {
      return WebAudioBookDetails(
        contentId: contentId,
        categoryId: categoryId,
        authorId: authorId,
        name: name,
      );
    }
    if (contentType == "3") {
      return WebMagazineDetails(
        contentId: contentId,
        categoryId: categoryId,
        type: contentType,
        name: name,
      );
    }
    return WebDetails(
      contentId: contentId,
      categoryId: categoryId,
      authorId: authorId,
      name: name,
      type: contentType,
    );
  }
}
