import 'package:yourappname/pages/commonpage.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webpages/webbecomeauthor.dart';
import 'package:yourappname/webpages/webcontectus.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class FooterWeb extends StatefulWidget {
  const FooterWeb({super.key});

  @override
  State<FooterWeb> createState() => _FooterWebState();
}

class _FooterWebState extends State<FooterWeb> {
  late ProfileProvider profileProvider;

  @override
  void initState() {
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileProvider.getPages();
      profileProvider.getsociallinkdata();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 1024;
    const double maxW = 1400;

    return Container(
      width: double.infinity,
      color: const Color(0xFF0F172A),
      child: Center(
        child: Container(
          width: screenWidth > maxW ? maxW : screenWidth,
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 48 : 24,
            vertical: 48,
          ),
          child: Column(
            children: [
              // ── Main Footer Content ──
              if (isDesktop)
                _buildDesktopLayout()
              else
                _buildMobileLayout(),

              const SizedBox(height: 48),

              // ── Divider ──
              Container(height: 1, color: Colors.white.withOpacity(0.08)),

              const SizedBox(height: 24),

              // ── Copyright ──
              Text(
                "©${Constant.appyear ?? "2026"} ${Constant.appName}. All rights reserved.",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Brand column
        Expanded(
          flex: 3,
          child: _buildBrandColumn(),
        ),
        const SizedBox(width: 60),

        // Pages column
        Expanded(
          flex: 2,
          child: _buildColumn(Locales.string(context, "useful_links"), _buildPagesList()),
        ),

        // Contact column
        Expanded(
          flex: 3,
          child: _buildColumn(Locales.string(context, "get_in_touch"), _buildContactList()),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBrandColumn(),
        const SizedBox(height: 36),
        _buildColumn(Locales.string(context, "useful_links"), _buildPagesList()),
        const SizedBox(height: 36),
        _buildColumn(Locales.string(context, "get_in_touch"), _buildContactList()),
      ],
    );
  }

  Widget _buildBrandColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyImage(
          width: 80,
          height: 60,
          imagePath: "logo.png",
          fit: BoxFit.contain,
        ),
        const SizedBox(height: 16),
        Text(
          Constant.appDescription ?? "",
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
            height: 1.6,
          ),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 24),
        Text(
          Locales.string(context, "follow_us"),
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        _buildSocialLinks(),
      ],
    );
  }

  Widget _buildColumn(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 32,
          height: 3,
          decoration: BoxDecoration(
            color: colorAccent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 20),
        content,
      ],
    );
  }

  Widget _buildPagesList() {
    return Consumer<ProfileProvider>(
      builder: (context, pp, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            pp.pagesModel.result?.length ?? 0,
            (i) {
              final page = pp.pagesModel.result?[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (_, __, ___) => CommonPage(
                        appBarTitle: page?.title ?? "",
                        loadURL: page?.url ?? "",
                      ),
                      transitionDuration: const Duration(milliseconds: 200),
                      transitionsBuilder: (_, a, __, c) =>
                          FadeTransition(opacity: a, child: c),
                    ));
                  },
                  child: Text(
                    page?.title ?? "",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildContactList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (Constant.userID != null &&
            Constant.userID.toString().isNotEmpty &&
            Constant.userID.toString() != "0")
          _linkItem(Locales.string(context, "become_author"), true, () {
            Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (_, __, ___) => const WebBecomeAuthor(),
              transitionDuration: const Duration(milliseconds: 200),
              transitionsBuilder: (_, a, __, c) =>
                  FadeTransition(opacity: a, child: c),
            ));
          }),
        _linkItem(Locales.string(context, "contact_us"), true, () {
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (_, __, ___) => const WebContectUS(),
            transitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder: (_, a, __, c) =>
                FadeTransition(opacity: a, child: c),
          ));
        }),

        const SizedBox(height: 24),

        // App store icons
        Text(
          Locales.string(context, "avalableon"),
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _storeIcon(FontAwesomeIcons.googlePlay, () {
              Utils.launchURL(Constant.androidAppUrl);
            }),
            const SizedBox(width: 12),
            _storeIcon(FontAwesomeIcons.appStoreIos, () {
              Utils.launchURL(Constant.iosAppUrl);
            }),
          ],
        ),
      ],
    );
  }

  Widget _linkItem(String label, bool multilang, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _storeIcon(dynamic icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.7), size: 22),
      ),
    );
  }

  Widget _buildSocialLinks() {
    return Consumer<ProfileProvider>(
      builder: (context, pp, _) {
        final links = pp.getsociallinkmodel.result;
        if (links == null || links.isEmpty) return const SizedBox.shrink();
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(links.length, (i) {
            return InkWell(
              onTap: () => Utils.launchURL(links[i].url ?? ""),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: MyNetworkImage(
                    imagePath: links[i].image ?? "",
                    fit: BoxFit.contain,
                    width: 20,
                    height: 20,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
