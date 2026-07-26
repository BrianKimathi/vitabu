import 'package:yourappname/provider/categoryprovider.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:yourappname/provider/homeprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webpages/webaudiobook.dart';
import 'package:yourappname/webpages/webbecomeauthor.dart';
import 'package:yourappname/webpages/webbook.dart';
import 'package:yourappname/webpages/webhome.dart';
import 'package:yourappname/webpages/weblibrary.dart';
import 'package:yourappname/webpages/weblogin.dart';
import 'package:yourappname/webpages/webmagazine.dart';
import 'package:yourappname/webpages/webprofile.dart';
import 'package:yourappname/webpages/websearch.dart';
import 'package:yourappname/webwidget/interactive_icon.dart';
import 'package:yourappname/webwidget/interactivecontainer.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class WebAppBar extends StatefulWidget {
  final dynamic widget;
  final bool hideAppBar;

  const WebAppBar({super.key, required this.widget, this.hideAppBar = false});

  @override
  State<WebAppBar> createState() => _WebAppBarState();
}

class _WebAppBarState extends State<WebAppBar> {
  GeneralProvider generalProvider = GeneralProvider();
  late HomeProvider homeProvider;
  late CategoryProvider categoryProvider;

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    getApiData();
  }

  Future getApiData() async {
    await homeProvider.getProfile(Constant.userID);
  }

  // ── Navigation helper (reduces repetition) ──
  void _navigateTo(Widget page, {bool replaceAll = true}) {
    final route = PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
    if (replaceAll) {
      Navigator.of(context).pushAndRemoveUntil(route, (_) => false);
    } else {
      Navigator.of(context).push(route);
    }
    // Close mobile drawer if open
    if (generalProvider.isNotification) {
      generalProvider.getNotificationSectionShowHide(false);
    }
  }

  // ── Desktop nav items ──
  final List<_NavItem> _navItems = const [
    _NavItem(count: "1", label: "home", icon: FontAwesomeIcons.house),
    _NavItem(count: "3", label: "book", icon: FontAwesomeIcons.bookOpen),
    _NavItem(count: "4", label: "audio_book", icon: FontAwesomeIcons.headphones),
    _NavItem(count: "5", label: "magazine", icon: FontAwesomeIcons.newspaper),
    _NavItem(count: "6", label: "library", icon: FontAwesomeIcons.bookmark),
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    final isTablet = screenWidth >= 768 && screenWidth < 1024;
    final isMobile = screenWidth < 768;

    if (widget.hideAppBar) {
      return Scaffold(body: widget.widget);
    }

    return Scaffold(
      body: Stack(
        children: [
          // ── Main content ──
          Column(
            children: [
              _buildNavbar(screenWidth, isDesktop, isTablet, isMobile),
              Expanded(child: widget.widget),
            ],
          ),
          // ── Mobile drawer overlay ──
          if (isMobile && generalProvider.isNotification)
            GestureDetector(
              onTap: () => generalProvider.getNotificationSectionShowHide(false),
              child: Container(color: Colors.black.withOpacity( 0.3)),
            ),
          if (isMobile && generalProvider.isNotification)
            Align(
              alignment: Alignment.centerLeft,
              child: _buildMobileDrawer(generalProvider),
            ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  NAVBAR
  // ─────────────────────────────────────────────
  Widget _buildNavbar(double screenWidth, bool isDesktop, bool isTablet, bool isMobile) {
    return Consumer<GeneralProvider>(
      builder: (context, gp, _) {
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFE2E8F0).withValues(alpha: 0.6),
                width: 1,
              ),
            ),
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1400),
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : isTablet ? 24 : 32,
                vertical: isMobile ? 10 : 12,
              ),
              child: isMobile
                  ? _buildMobileNav(gp)
                  : _buildDesktopNav(gp, isTablet),
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  //  DESKTOP / TABLET NAV
  // ─────────────────────────────────────────────
  Widget _buildDesktopNav(GeneralProvider gp, bool isTablet) {
    return Row(
      children: [
        // ── Uncropped Logo Container ──
        _Logo(onTap: () {
          gp.setTab("1");
          _navigateTo(const WebHome());
        }),
        const SizedBox(width: 36),

        // ── Nav Tabs ──
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final item in _navItems) ...[
                _NavTab(
                  label: item.label,
                  count: item.count,
                  isActive: gp.selectTab == item.count,
                  onTap: () {
                    gp.setTab(item.count);
                    switch (item.count) {
                      case "1": _navigateTo(const WebHome());
                      case "3": _navigateTo(const WebBook());
                      case "4": _navigateTo(const WebAudioBook());
                      case "5": _navigateTo(const WebMagazine());
                      case "6": _navigateTo(const WebLibrary());
                    }
                  },
                ),
                const SizedBox(width: 6),
              ],
            ],
          ),
        ),

        // ── Actions ──
        _Actions(
          isTablet: isTablet,
          gp: gp,
          onSearch: () => _navigateTo(Websearch(showType: "all"), replaceAll: false),
          onLanguage: () => _showLanguagePicker(),
          onProfile: () => _handleProfile(gp),
          onBecomeAuthor: () => _handleBecomeAuthor(gp),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  MOBILE NAV
  // ─────────────────────────────────────────────
  Widget _buildMobileNav(GeneralProvider gp) {
    return Row(
      children: [
        // Hamburger
        GestureDetector(
          onTap: () {
            gp.getNotificationSectionShowHide(!gp.isNotification);
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFF1F4F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              gp.isNotification ? Icons.close : Icons.menu_rounded,
              color: colorAccent,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Logo
        Expanded(
          child: _Logo(onTap: () {
            gp.setTab("1");
            _navigateTo(const WebHome());
          }),
        ),

        // Search
        GestureDetector(
          onTap: () => _navigateTo(Websearch(showType: "all"), replaceAll: false),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xFFF1F4F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.search_rounded, color: colorAccent, size: 22),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  MOBILE DRAWER (slide-out)
  // ─────────────────────────────────────────────
  Widget _buildMobileDrawer(GeneralProvider gp) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      height: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
      decoration: BoxDecoration(
        color: white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity( 0.1),
            blurRadius: 40,
            offset: const Offset(-10, 0),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drawer Logo
            _Logo(onTap: () {
              gp.setTab("1");
              _navigateTo(const WebHome());
            }),
            const SizedBox(height: 32),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 16),

            // Profile section
            Consumer<HomeProvider>(builder: (context, hp, _) {
              if (hp.profileLoading) {
                return const SizedBox(
                  height: 40, width: 40,
                  child: CircularProgressIndicator(strokeWidth: 2),
                );
              }
              final isLoggedIn = hp.profileModel.status == 200 &&
                  (hp.profileModel.result?.length ?? 0) > 0;
              return isLoggedIn
                  ? _DrawerProfileTile(
                      name: "${hp.profileModel.result?[0].firstName ?? ""} ${hp.profileModel.result?[0].lastName ?? ""}",
                      email: hp.profileModel.result?[0].email ?? "",
                      image: Constant.userimage ?? "",
                      onTap: () {
                        gp.getNotificationSectionShowHide(false);
                        _navigateTo(const WebProfile(), replaceAll: false);
                      },
                    )
                  : _DrawerProfileTile(
                      name: "Sign In",
                      email: "Login to your account",
                      image: "",
                      isLogin: true,
                      onTap: () {
                        gp.getNotificationSectionShowHide(false);
                        _navigateTo(const Weblogin(), replaceAll: false);
                      },
                    );
            }),
            const SizedBox(height: 16),
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 8),

            // Nav items
            for (final item in _navItems) ...[
              _DrawerNavItem(
                icon: item.icon,
                label: item.label,
                isActive: gp.selectTab == item.count,
                onTap: () {
                  gp.setTab(item.count);
                  switch (item.count) {
                    case "1": _navigateTo(const WebHome());
                    case "3": _navigateTo(const WebBook());
                    case "4": _navigateTo(const WebAudioBook());
                    case "5": _navigateTo(const WebMagazine());
                    case "6": _navigateTo(const WebLibrary());
                  }
                },
              ),
            ],

            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            const SizedBox(height: 8),

            // Language
            _DrawerNavItem(
              icon: FontAwesomeIcons.language,
              label: "Language",
              onTap: () {
                gp.getNotificationSectionShowHide(false);
                _showLanguagePicker();
              },
            ),

            // Become Author / Dashboard
            if (Constant.userID != null &&
                Constant.userID.toString().isNotEmpty &&
                Constant.userID.toString() != "0") ...[
              _DrawerNavItem(
                icon: Constant.isAuthor == "1" ? Icons.dashboard_rounded : Icons.person_add_rounded,
                label: Constant.isAuthor == "1" ? "Dashboard" : "become_author",
                onTap: () {
                  gp.getNotificationSectionShowHide(false);
                  if (Constant.isAuthor == "1") {
                    Utils.launchURL("https://console.vitabu.online/author/login");
                    return;
                  }
                  _navigateTo(const WebBecomeAuthor(), replaceAll: false);
                },
              ),
              _DrawerNavItem(
                icon: Icons.logout_rounded,
                label: "logout",
                color: red,
                onTap: () async {
                  await Utils.removeUser();
                  Constant.userID = null;
                  Constant.userimage = null;
                  Constant.email = null;
                  if (!context.mounted) return;
                  _navigateTo(const WebHome());
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HANDLERS
  // ─────────────────────────────────────────────
  void _handleProfile(GeneralProvider gp) {
    if (Utils.checkLoginUser(context)) {
      _navigateTo(const WebProfile(), replaceAll: false);
    }
  }

  void _handleBecomeAuthor(GeneralProvider gp) {
    if (Constant.isAuthor == "1") {
      Utils.launchURL("https://console.vitabu.online/author/login");
      return;
    }
    _navigateTo(const WebBecomeAuthor(), replaceAll: false);
  }

  void _showLanguagePicker() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: ligthDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(
                    text: "Select Language",
                    fontsize: 18,
                    fontwaight: FontWeight.bold,
                    color: colorAccent,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(color: Colors.white24, height: 20),
              _langOpt(ctx, "en", "English"),
              _langOpt(ctx, "ar", "عربي"),
              _langOpt(ctx, "hi", "हिंदी"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _langOpt(BuildContext ctx, String code, String label) {
    return InkWell(
      onTap: () {
        LocaleNotifier.of(context)?.change(code);
        Navigator.pop(ctx);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: MyText(text: label, fontsize: Dimens.medium16TextSize, color: white),
      ),
    );
  }
}

// ═════════════════════════════════════════════
//  SUB-WIDGETS
// ═════════════════════════════════════════════

class _Logo extends StatelessWidget {
  final VoidCallback onTap;
  const _Logo({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InteractiveContainer(child: (hovered) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: hovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 180),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            alignment: Alignment.centerLeft,
            child: const MyImage(
              imagePath: 'logo.png',
              height: 40,
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    });
  }
}

class _NavTab extends StatelessWidget {
  final String label;
  final String count;
  final bool isActive;
  final VoidCallback onTap;
  const _NavTab({required this.label, required this.count, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InteractiveContainer(child: (hovered) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? colorAccent.withValues(alpha: 0.1)
                : hovered
                    ? const Color(0xFFF1F5F9)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isActive) ...[
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: colorAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              MyText(
                color: isActive
                    ? colorAccent
                    : hovered
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF64748B),
                multilanguage: true,
                text: label,
                fontsize: Dimens.medium14TextSize,
                fontsizeWeb: Dimens.medium14TextSize,
                fontwaight: isActive ? FontWeight.w700 : FontWeight.w500,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _Actions extends StatelessWidget {
  final bool isTablet;
  final GeneralProvider gp;
  final VoidCallback onSearch;
  final VoidCallback onLanguage;
  final VoidCallback onProfile;
  final VoidCallback onBecomeAuthor;
  const _Actions({
    required this.isTablet,
    required this.gp,
    required this.onSearch,
    required this.onLanguage,
    required this.onProfile,
    required this.onBecomeAuthor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Become Author / Dashboard CTA
        if (Constant.userID != null &&
            Constant.userID.toString().isNotEmpty &&
            Constant.userID.toString() != "0")
          _ActionBtn(
            label: Constant.isAuthor == "1" ? "Dashboard" : "Become Author",
            icon: Constant.isAuthor == "1" ? Icons.dashboard_rounded : Icons.create_rounded,
            isTablet: isTablet,
            onTap: onBecomeAuthor,
          ),

        const SizedBox(width: 10),

        // Search button
        _IconBtn(
          icon: FontAwesomeIcons.magnifyingGlass,
          tooltip: "Search",
          onTap: onSearch,
        ),

        const SizedBox(width: 6),

        // Language selector
        _IconBtn(
          icon: FontAwesomeIcons.language,
          tooltip: "Language",
          onTap: onLanguage,
        ),

        const SizedBox(width: 12),

        // Profile / Login Avatar Badge
        Consumer<HomeProvider>(builder: (context, hp, _) {
          if (hp.profileLoading) {
            return CustomWidget.circular(width: 38, height: 38);
          }
          final isLoggedIn = hp.profileModel.status == 200 &&
              (hp.profileModel.result?.length ?? 0) > 0;
          if (isLoggedIn) {
            return GestureDetector(
              onTap: onProfile,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorAccent.withValues(alpha: 0.5), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: colorAccent.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: MyNetworkImage(
                    imagePath: Constant.userimage ?? "",
                    fit: BoxFit.cover,
                    height: 36,
                    width: 36,
                  ),
                ),
              ),
            );
          }
          return _ActionBtn(
            label: "Sign In",
            icon: Icons.login_rounded,
            isTablet: isTablet,
            onTap: () {
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (_, __, ___) => const Weblogin(),
                transitionDuration: const Duration(milliseconds: 200),
                transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
              ));
            },
          );
        }),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isTablet;
  final VoidCallback onTap;
  const _ActionBtn({
    required this.label,
    this.icon,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isTablet) {
      return _IconBtn(icon: icon ?? FontAwesomeIcons.user, onTap: onTap);
    }
    return InteractiveContainer(child: (hovered) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: hovered
                ? const LinearGradient(
                    colors: [colorAccent, colorPrimaryDark],
                  )
                : null,
            color: hovered ? null : colorAccent.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorAccent.withValues(alpha: hovered ? 1.0 : 0.4),
              width: 1.2,
            ),
            boxShadow: hovered
                ? [
                    BoxShadow(
                      color: colorAccent.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: hovered ? Colors.white : colorAccent,
                ),
                const SizedBox(width: 8),
              ],
              MyText(
                color: hovered ? Colors.white : colorAccent,
                text: label,
                fontsize: 13,
                fontwaight: FontWeight.w600,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _IconBtn extends StatelessWidget {
  final dynamic icon;
  final String? tooltip;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InteractiveContainer(child: (hovered) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: hovered
                ? colorAccent.withValues(alpha: 0.1)
                : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hovered
                  ? colorAccent.withValues(alpha: 0.3)
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Icon(
            icon,
            size: 16,
            color: hovered ? colorAccent : const Color(0xFF64748B),
          ),
        ),
      );
    });
  }
}

class _DrawerNavItem extends StatelessWidget {
  final dynamic icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? color;
  const _DrawerNavItem({required this.icon, required this.label, this.isActive = false, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: isActive ? colorAccent.withOpacity( 0.08) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                Icon(icon, size: 20, color: color ?? (isActive ? colorAccent : gray)),
                const SizedBox(width: 14),
                MyText(
                  text: label,
                  multilanguage: true,
                  color: color ?? (isActive ? colorAccent : const Color(0xFF334155)),
                  fontsize: Dimens.medium15TextSize,
                  fontwaight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerProfileTile extends StatelessWidget {
  final String name, email, image;
  final bool isLogin;
  final VoidCallback onTap;
  const _DrawerProfileTile({required this.name, required this.email, required this.image, this.isLogin = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colorAccent.withOpacity( 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isLogin
                    ? Icon(Icons.person_add_rounded, color: colorAccent, size: 22)
                    : ClipOval(
                        child: MyNetworkImage(
                          imagePath: image,
                          fit: BoxFit.cover,
                          height: 44,
                          width: 44,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyText(
                      text: name,
                      fontsize: Dimens.medium14TextSize,
                      fontwaight: FontWeight.w600,
                      color: const Color(0xFF0F172A),
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    MyText(
                      text: email,
                      fontsize: 12,
                      color: const Color(0xFF64748B),
                      maxline: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final String count;
  final String label;
  final dynamic icon;
  const _NavItem({required this.count, required this.label, required this.icon});
}
