import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:yourappname/provider/homeprovider.dart';
import 'package:yourappname/provider/themeprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webpages/webaudiobookdetails.dart' hide SizedBox, Container, Row;
import 'package:yourappname/webpages/webauthor.dart' hide SizedBox, Container, Row;
import 'package:yourappname/webpages/webcategorywisedata.dart' hide SizedBox, Container, Row;
import 'package:yourappname/webpages/webdetails.dart' hide SizedBox, Container, Row;
import 'package:yourappname/webpages/weblanguagewisedata.dart' hide SizedBox, Container, Row;
import 'package:yourappname/webpages/webmagazinedetails.dart' hide SizedBox, Container, Row;
import 'package:yourappname/webpages/webviewall.dart' hide SizedBox, Container, Row;
import 'package:yourappname/webwidget/footerweb.dart' hide SizedBox, Container, Row;
import 'package:yourappname/webwidget/interactive_networkicon.dart' hide SizedBox, Container, Row;
import 'package:yourappname/webwidget/interactivecontainer.dart' hide SizedBox, Container, Row;
import 'package:yourappname/webwidget/webappbar.dart' hide SizedBox, Container, Row;
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/widget/musicmaneger.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:yourappname/model/sectionmodel.dart' as list;
import 'package:yourappname/model/sectionmodel.dart';

class WebHome extends StatefulWidget {
  const WebHome({super.key});

  @override
  State<WebHome> createState() => _WebHomeState();
}

class _WebHomeState extends State<WebHome> {
  HomeProvider homeProvider = HomeProvider();
  final searchController = TextEditingController();
  late ScrollController scrollController;
  final MusicManager musicManager = MusicManager();
  late ThemeProvider themeProvider;
  final ScrollController _headLine = ScrollController();
  final ScrollController _scrollController = ScrollController();

  final double _scrollAmount = 200;
  // int _currentPage = 0;
  double scrollPosition = 0.0;

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    scrollController = ScrollController();
    scrollController.addListener(_scrollListener);
    getApiData(0);
  }

  _scrollListener() {
    if (!scrollController.hasClients) return;
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange &&
        (homeProvider.currentPage ?? 0) < (homeProvider.totalPage ?? 0)) {
      printLog("-----?? api call page 2 ");
      homeProvider.setLoadMore(true);
      getApiData(homeProvider.currentPage ?? 0);
    }
  }

  Future getApiData(pageno) async {
    // await homeProvider.getProfile(Constant.userID);
    await homeProvider.getSectionList(
        "0", Constant.userCategoryId, (pageno ?? 0) + 1);
  }

  addView(contentType, contentId, subContentId) async {
    if (Constant.userID != null) {
      await homeProvider.setView(contentType, contentId, subContentId);
    }
  }

  @override
  void dispose() {
    _headLine.dispose();
    scrollController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebAppBar(
      widget: Consumer<HomeProvider>(builder: (context, homeProvider, child) {
        return SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.vertical,
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            spacing: 30,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionData(),
              if (homeProvider.loadMore)
                Utils.pageLoader(context)
              else
                const SizedBox.shrink(),
              FooterWeb()
            ],
          ),
        );
      }),
    );
  }

  /* Section Shimmer */
  Widget sectionShimmer() {
    return ListView.builder(
      itemCount: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: (index == 1)
                ? buildbannershimmer(context)
                : (index == 2)
                    ? categoryshimmer(context)
                    : (index == 3)
                        ? _buildPortraitshimmer()
                        : (index == 4)
                            ? categoryshimmer(context)
                            : (index == 5)
                                ? _buildPortraitshimmer()
                                : (index == 6)
                                    ? _buildHorizontalshimmer()
                                    : (index == 7)
                                        ? _buildHorizontalshimmer()
                                        : const SizedBox.shrink());
      },
    );
  }

/* ── Section Title ── */
  Widget _buildTitle({title, shortTitle, onTap}) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    const double maxContentWidth = 1400;
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Container(
        width: isDesktop
            ? (screenWidth > maxContentWidth ? maxContentWidth : screenWidth - 40)
            : screenWidth,
        padding: EdgeInsets.fromLTRB(
          isDesktop ? 0 : 20, 16, isDesktop ? 0 : 20, 4,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: title + decorative bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 4,
                      height: 24,
                      decoration: BoxDecoration(
                        color: colorPrimary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      title ?? "",
                      style: TextStyle(
                        fontSize: isDesktop ? 24 : 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
                if (shortTitle != null && shortTitle.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 16, top: 4),
                    child: Text(
                      shortTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
              ],
            ),

            // Right: View All pill button
            if (onTap != null)
              _buildViewAllButton(onTap: onTap),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAllButton({VoidCallback? onTap}) {
    return StatefulBuilder(
      builder: (context, setLocalState) {
        bool hovered = false;
        return MouseRegion(
          onEnter: (_) => setLocalState(() => hovered = true),
          onExit: (_) => setLocalState(() => hovered = false),
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: hovered ? colorPrimary : const Color(0xFFF1F4F9),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "more",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: hovered ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 16,
                    color: hovered ? Colors.white : const Color(0xFF475569),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /* Section APi Calling Logic */
  Widget _buildSectionData() {
    if (homeProvider.loading && !homeProvider.loadMore) {
      return sectionShimmer();
    } else {
      if (homeProvider.sectionListModel.status == 200 &&
          homeProvider.sectionListData != null &&
          (homeProvider.sectionListData?.length ?? 0) > 0) {
        return setSectionByType(homeProvider.sectionListData);
      } else {
        return NoData();
      }
    }
  }

  Widget setSectionByType(List<list.Result>? sectionList) {
    return ListView.builder(
      itemCount: sectionList?.length ?? 0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        if (sectionList?[index].data != null &&
            (sectionList?[index].data?.length ?? 0) > 0) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              (sectionList?[index].screenLayout ?? "") == "banner"
                  ? const SizedBox.shrink()
                  : Row(
                      spacing: 20,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 3,
                            children: [
                              _buildTitle(
                                title:
                                    sectionList?[index].title.toString() ?? "",
                                shortTitle: sectionList?[index]
                                        .shortTitle
                                        ?.toString() ??
                                    "",
                                onTap: () {
                                  if ((sectionList?[index].viewAll ?? 0).toString() == "1") {
                                    Navigator.of(context).push(PageRouteBuilder(
                                      pageBuilder: (context, animation,
                                          secondaryAnimation) {
                                        return Webviewall(
                                          screenLayOut: sectionList?[index]
                                                  .screenLayout ??
                                              "",
                                          type: sectionList?[index]
                                                  .contentType
                                                  .toString() ??
                                              "",
                                          sectionID: sectionList?[index]
                                                  .id
                                                  .toString() ??
                                              "",
                                          title: sectionList?[index]
                                                  .title
                                                  .toString() ??
                                              "",
                                        );
                                      },
                                      transitionDuration:
                                          const Duration(milliseconds: 150),
                                      transitionsBuilder: (context, animation,
                                          secondaryAnimation, child) {
                                        return AnimatedBuilder(
                                          animation: animation,
                                          builder: (context, child) {
                                            return ClipPath(
                                              clipper: CircularRevealClipper(
                                                  progress: animation.value),
                                              child: child,
                                            );
                                          },
                                          child: child,
                                        );
                                      },
                                    ));
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
              setSectionData(sectionList: sectionList, index: index),
              const SizedBox(height: 10),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget setSectionData(
      {required List<list.Result>? sectionList, required int index}) {
    /* video_type =>  1-video,  2-show,  3-language,  4-category */

    /* screen_layout =>  landscape, potrait, square */
    if ((sectionList?[index].screenLayout ?? "") == "banner") {
      if (sectionList?[index].contentType.toString() == "1") {
        return SizedBox.shrink();
      } else if (sectionList?[index].contentType.toString() == "2") {
        return _buildBannerData(sectionList?[index].data, index,
            sectionList?[index].contentType ?? 0);
      } else {
        return SizedBox.shrink();
      }
    } else if ((sectionList?[index].screenLayout ?? "") == "author") {
      return _buildAuthorData(sectionList?[index].data, index);
    } else if ((sectionList?[index].screenLayout ?? "") == "category") {
      return categoryData(sectionList?[index].data, index);
    } else if ((sectionList?[index].screenLayout ?? "") == "language") {
      return languageData(sectionList?[index].data, index);
    } else if ((sectionList?[index].screenLayout ?? "") == "square") {
      return _buildSquare(sectionList?[index].data, index,
          sectionList?[index].contentType ?? 0);
    } else if ((sectionList?[index].screenLayout ?? "") == "portrait") {
      return _buildPortraitData(sectionList?[index].data, index,
          sectionList?[index].contentType ?? 0);
    } else if ((sectionList?[index].screenLayout ?? "") == "horizontal_view") {
      return _buildHorizontalData(sectionList?[index].data, index,
          sectionList?[index].contentType ?? 0);
    } else {
      return SizedBox.shrink();
    }
  }

/* Banner Data show */
  Widget _buildBannerData(
      List<Datum>? sectionDataList, int sectionIndex, int? contentType) {
    if (MediaQuery.sizeOf(context).width > 1000) {
      return _buildBanner(sectionDataList, contentType);
    } else {
      return _buildBannerMobile(sectionDataList, contentType);
    }
  }

  Widget _buildBanner(List<Datum>? sectionDataList, int? contentType) {
    const double maxContentWidth = 1400;
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600 && screenWidth < 1024;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: Container(
          height: isTablet ? 420 : 520,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorPrimary.withOpacity( 0.04),
                const Color(0xFFF8FAFC),
                colorPrimary.withOpacity( 0.02),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // ── Left content ──
              Expanded(
                flex: 5,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    isTablet ? 32 : 48,
                    32,
                    isTablet ? 24 : 32,
                    32,
                  ),
                  child: AnimatedBuilder(
                    animation: homeProvider,
                    builder: (context, _) {
                      final index = homeProvider.pageIndex;
                      final current = (sectionDataList != null &&
                              sectionDataList.isNotEmpty &&
                              index < sectionDataList.length)
                          ? sectionDataList[index]
                          : null;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Category badge
                          if (current?.categoryName != null &&
                              current!.categoryName!.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: colorPrimary.withOpacity( 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                current.categoryName!,
                                style: TextStyle(
                                  color: colorPrimary,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          const SizedBox(height: 20),

                          // Title
                          Text(
                            current?.title ?? "",
                            style: TextStyle(
                              color: const Color(0xFF0F172A),
                              fontSize: isTablet ? 28 : 36,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),

                          // Description
                          if (current?.description != null &&
                              current!.description!.isNotEmpty)
                            Text(
                              current.description!.replaceAll(
                                  RegExp(r'<[^>]*>'), ''),
                              style: TextStyle(
                                color: const Color(0xFF64748B),
                                fontSize: isTablet ? 14 : 15,
                                height: 1.6,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          const SizedBox(height: 24),

                          // Author & Rating row
                          if (current?.authorName != null &&
                              current!.authorName!.isNotEmpty)
                            Row(
                              children: [
                                Icon(Icons.person_rounded,
                                    size: 16, color: const Color(0xFF94A3B8)),
                                const SizedBox(width: 6),
                                Text(
                                  current.authorName!,
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if ((current.avgReviews ?? 0) > 0) ...[
                                  const SizedBox(width: 16),
                                  Icon(Icons.star_rounded,
                                      size: 16, color: Color(0xFFF59E0B)),
                                  const SizedBox(width: 4),
                                  Text(
                                    current.avgReviews.toString(),
                                    style: const TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          const SizedBox(height: 24),

                          // CTA Button
                          _HeroButton(
                            label: "more_info",
                            onTap: () {
                              if (current == null) return;
                              _navigateToDetail(
                                  current, contentType, true);
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              // ── Right carousel ──
              Expanded(
                flex: 5,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: isTablet ? 16 : 24,
                    horizontal: isTablet ? 8 : 16,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: CarouselSlider.builder(
                          itemCount: sectionDataList?.length ?? 0,
                          itemBuilder: (context, index, realIndex) {
                            final item = sectionDataList?[index];
                            return _HeroCard(
                              item: item,
                              contentType: contentType,
                              onTap: () {
                                if (item == null) return;
                                _navigateToDetail(
                                    item, contentType, false);
                              },
                            );
                          },
                          options: CarouselOptions(
                            height: double.infinity,
                            enlargeCenterPage: true,
                            viewportFraction: isTablet ? 0.35 : 0.28,
                            enableInfiniteScroll: true,
                            autoPlay: true,
                            autoPlayInterval:
                                const Duration(seconds: 4),
                            autoPlayAnimationDuration:
                                const Duration(milliseconds: 800),
                            enlargeStrategy:
                                CenterPageEnlargeStrategy.height,
                            onPageChanged: (index, reason) {
                              homeProvider.setPageIndex(index);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Indicators ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 8,
                        children:
                            List.generate(sectionDataList?.length ?? 0,
                                (index) {
                          final isActive =
                              homeProvider.pageIndex == index;
                          return AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 250),
                            width: isActive ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? colorPrimary
                                  : const Color(0xFFCBD5E1),
                              borderRadius:
                                  BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(dynamic item, int? contentType, bool isFromHome) {
    if (contentType == 2) {
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => WebDetails(
          categoryId: item.categoryId.toString(),
          authorId: item.authorId.toString(),
          contentId: item.id.toString(),
          name: item.title.toString(),
          type: item.type.toString(),
          isFromHome: isFromHome,
        ),
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ));
    } else {
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => WebMagazineDetails(
          contentId: item.id.toString(),
          categoryId: item.categoryId.toString(),
          name: item.title.toString(),
          isFromHome: isFromHome,
        ),
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ));
    }
  }

  Widget _buildBannerMobile(List<Datum>? sectionDataList, int? contentType) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CarouselSlider.builder(
            itemCount: sectionDataList?.length ?? 0,
            options: CarouselOptions(
              height: 220,
              enlargeCenterPage: true,
              viewportFraction: 0.85,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 4),
              autoPlayAnimationDuration:
                  const Duration(milliseconds: 800),
              enableInfiniteScroll: true,
              onPageChanged: (index, reason) {
                homeProvider.setPageIndex(index);
              },
            ),
            itemBuilder: (BuildContext context, int index, int realIndex) {
              final item = sectionDataList?[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity( 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // Image
                      MyNetworkImage(
                        imagePath: item?.landscapeImg ?? "",
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 220,
                      ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.center,
                            colors: [
                              Colors.black.withOpacity( 0.7),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                      // Text content
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              item?.title ?? "",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item?.authorName ?? "",
                              style: TextStyle(
                                color:
                                    Colors.white.withOpacity( 0.8),
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 6,
            children: List.generate(
              sectionDataList?.length ?? 0,
              (index) {
                final isActive = homeProvider.pageIndex == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: isActive ? 24 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isActive
                        ? colorPrimary
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero card widget for desktop carousel ──
  Widget _HeroCard({dynamic item, int? contentType, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity( 0.1),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: MyNetworkImage(
            imagePath: item?.landscapeImg ?? "",
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }

  // ── Hero CTA button ──
  Widget _HeroButton({required String label, VoidCallback? onTap}) {
    return StatefulBuilder(
      builder: (context, setLocalState) {
        bool hovered = false;
        return MouseRegion(
          onEnter: (_) => setLocalState(() => hovered = true),
          onExit: (_) => setLocalState(() => hovered = false),
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: hovered ? colorPrimary : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorPrimary, width: 1.5),
                boxShadow: hovered
                    ? [
                        BoxShadow(
                          color: colorPrimary.withOpacity( 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MyText(
                    color: hovered ? white : colorPrimary,
                    multilanguage: true,
                    text: label,
                    fontsize: Dimens.medium16TextSize,
                    fontsizeWeb: Dimens.medium16TextSize,
                    fontwaight: FontWeight.w600,
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: hovered ? white : colorPrimary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /* ── Category Cards ── */

  Widget categoryData(List<Datum>? sectionDataList, int sectionIndex) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxContentWidth = 1400;
    final isMobile = screenWidth < 600;
    final double cardWidth = isMobile ? (screenWidth / 3) - 24 : 140.0;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          physics: const BouncingScrollPhysics(),
          child: Row(
            spacing: isMobile ? 12 : 16,
            children: List.generate(
              sectionDataList?.length ?? 0,
              (position) {
                final data = sectionDataList?[position];

                return _CategoryCard(
                  data: data,
                  width: cardWidth,
                  onTap: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (_, __, ___) => Webcategorywisedata(
                        catagoryid: data?.id.toString(),
                        catagoryname: data?.name.toString(),
                        name: data?.name.toString(),
                      ),
                      transitionDuration: const Duration(milliseconds: 200),
                      transitionsBuilder: (_, a, __, c) =>
                          FadeTransition(opacity: a, child: c),
                    ));
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _CategoryCard({dynamic data, double width = 140, VoidCallback? onTap}) {
    return StatefulBuilder(
      builder: (context, setLocalState) {
        bool hovered = false;
        return MouseRegion(
          onEnter: (_) => setLocalState(() => hovered = true),
          onExit: (_) => setLocalState(() => hovered = false),
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: width,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hovered ? colorPrimary.withOpacity( 0.3) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: hovered
                        ? colorPrimary.withOpacity( 0.08)
                        : Colors.black.withOpacity( 0.04),
                    blurRadius: hovered ? 16 : 8,
                    offset: Offset(0, hovered ? 6.0 : 2.0),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    height: width * 0.8,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: MyNetworkImage(
                        imagePath: data?.image ?? "",
                        fit: BoxFit.contain,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    data?.name ?? "",
                    style: TextStyle(
                      color: hovered ? colorPrimary : const Color(0xFF0F172A),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget languageData(List<Datum>? sectionDataList, int sectionIndex) {
    const double maxContentWidth = 1400;
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth =
        screenWidth > maxContentWidth ? maxContentWidth : screenWidth - 40;

    return Center(
      child: SizedBox(
        width: containerWidth,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(
              sectionDataList?.length ?? 0,
              (position) {
                final data = sectionDataList?[position];

                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return Weblanguagewisedata(
                          catagoryid: data?.id.toString(),
                          catagoryname: data?.name.toString(),
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 150),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            return ClipPath(
                              clipper: CircularRevealClipper(
                                  progress: animation.value),
                              child: child,
                            );
                          },
                          child: child,
                        );
                      },
                    ));
                  },
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    width: 160,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 10),
                    decoration: BoxDecoration(
                      color: Utils.getRandomLightColor(),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: MyNetworkImage(
                            imagePath: data?.image ?? "",
                            fit: BoxFit.cover,
                            width: double.infinity,
                            radius: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        MyText(
                          text: data?.name ?? "",
                          color: black,
                          fontsize: Dimens.medium14TextSize,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                          textalign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  /*========================== Square View Started =========================*/

  Widget _buildSquare(
      List<Datum>? sectionDataList, int sectionIndex, int? contentType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        if (MediaQuery.of(context).size.width > 1000)
          _buildWebSquare(_scrollController, sectionDataList, contentType)
        else
          _buildMobileSquare(sectionDataList, contentType)
      ],
    );
  }

  Widget _buildWebSquare(ScrollController controller,
      List<Datum>? sectionDataList, int? contentType) {
    const double maxContentWidth = 1400;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: LayoutBuilder(builder: (context, constraints) {
          num totalContentWidth = (185 + 20) * (sectionDataList?.length ?? 0);
          double viewportWidth = constraints.maxWidth;

          bool canScroll = totalContentWidth > viewportWidth;

          return Row(
            spacing: 30,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (canScroll)
                _buildArrowButton(Icons.arrow_back_ios_new, () {
                  controller.animateTo(
                    controller.offset - _scrollAmount,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }),
              Flexible(
                fit: FlexFit.loose,
                child: SingleChildScrollView(
                  controller: controller,
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    spacing: 20,
                    children:
                        List.generate(sectionDataList?.length ?? 0, (position) {
                      const double cardHeight = 410;
                      final data = sectionDataList?[position];
                      final accessInfo = getAccessInfo(
                        accessType: data?.accessType.toString(),
                        isBuy: data?.isBuy.toString(),
                        isSubscription: Constant.isSubscription ?? 0,
                        price: data?.price?.toString(),
                      );
                      return _SquareCard(
                          data: data,
                          accessInfo: accessInfo,
                          width: 200,
                          onTap: () {
                            if (contentType == 1) {
                              Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder: (_, __, ___) => WebAudioBookDetails(
                                  categoryId: data?.categoryId.toString(),
                                  authorId: data?.authorId.toString(),
                                  contentId: data?.id.toString(),
                                  name: data?.title.toString(),
                                  isFromHome: true,
                                ),
                                transitionDuration: const Duration(milliseconds: 200),
                                transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                              ));
                            } else if (contentType == 2) {
                              Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder: (_, __, ___) => WebDetails(
                                  categoryId: data?.categoryId.toString(),
                                  authorId: data?.authorId.toString(),
                                  contentId: data?.id.toString(),
                                  name: data?.title.toString(),
                                  type: data?.type.toString(),
                                  isFromHome: true,
                                ),
                                transitionDuration: const Duration(milliseconds: 200),
                                transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                              ));
                            } else {
                              Navigator.of(context).push(PageRouteBuilder(
                                pageBuilder: (_, __, ___) => WebMagazineDetails(
                                  contentId: data?.id.toString(),
                                  categoryId: data?.categoryId.toString(),
                                  name: data?.title.toString(),
                                  isFromHome: true,
                                ),
                                transitionDuration: const Duration(milliseconds: 200),
                                transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                              ));
                            }
                          },
                        );
                      }),
                  ),
                ),
              ),
              if (canScroll)
                _buildArrowButton(Icons.arrow_forward_ios, () {
                  controller.animateTo(
                    controller.offset + _scrollAmount,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                }),
            ],
          );
        }),
      ),
    );
  }

/* Mobile view Square */
  Widget _buildMobileSquare(List<Datum>? sectionDataList, int? contentType) {
    const double cardHeight = 340; // thoduk nanu
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        physics: const BouncingScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16, // thoduk ochu spacing
          children: List.generate(sectionDataList?.length ?? 0, (position) {
            final accessInfo = getAccessInfo(
              accessType: sectionDataList?[position].accessType.toString(),
              isBuy: sectionDataList?[position].isBuy.toString(),
              isSubscription: Constant.isSubscription ?? 0,
              price: sectionDataList?[position].price?.toString(),
            );

            return _SquareCard(
              data: sectionDataList?[position],
              accessInfo: accessInfo,
              width: 155,
              onTap: () {
                if (contentType == 1) {
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (_, __, ___) => WebAudioBookDetails(
                      categoryId: sectionDataList?[position].categoryId.toString(),
                      authorId: sectionDataList?[position].authorId.toString(),
                      contentId: sectionDataList?[position].id.toString(),
                      name: sectionDataList?[position].title.toString(),
                      isFromHome: true,
                    ),
                    transitionDuration: const Duration(milliseconds: 200),
                    transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                  ));
                } else if (contentType == 2) {
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (_, __, ___) => WebDetails(
                      categoryId: sectionDataList?[position].categoryId.toString(),
                      authorId: sectionDataList?[position].authorId.toString(),
                      contentId: sectionDataList?[position].id.toString(),
                      name: sectionDataList?[position].title.toString(),
                      type: sectionDataList?[position].type.toString(),
                      isFromHome: true,
                    ),
                    transitionDuration: const Duration(milliseconds: 200),
                    transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                  ));
                } else {
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (_, __, ___) => WebMagazineDetails(
                      contentId: sectionDataList?[position].id.toString(),
                      categoryId: sectionDataList?[position].categoryId.toString(),
                      name: sectionDataList?[position].title.toString(),
                      isFromHome: true,
                    ),
                    transitionDuration: const Duration(milliseconds: 200),
                    transitionsBuilder: (_, a, __, c) => FadeTransition(opacity: a, child: c),
                  ));
                }
              },
            );         }),
        ),
      ),
    );
  }

/* ═══════════════════════════════════════════
   SHARED CONTENT CARD
   ═══════════════════════════════════════════ */
  Widget _ContentCard({
    dynamic data,
    int? contentType,
    AccessInfo? accessInfo,
    double width = 185,
    bool isHorizontal = false,
    VoidCallback? onTap,
  }) {
    return StatefulBuilder(
      builder: (context, setLocalState) {
        bool hovered = false;
        final isFree = accessInfo?.priceText?.toLowerCase() == "free";
        final hasPrice = accessInfo != null && accessInfo.priceText.isNotEmpty && !isFree;

        return MouseRegion(
          onEnter: (_) => setLocalState(() => hovered = true),
          onExit: (_) => setLocalState(() => hovered = false),
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: width,
              transform: hovered
                  ? Matrix4.translationValues(0, -6, 0)
                  : Matrix4.identity(),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hovered
                      ? colorPrimary.withOpacity(0.15)
                      : const Color(0xFFF1F4F9),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: hovered
                        ? Colors.black.withOpacity(0.1)
                        : Colors.black.withOpacity(0.04),
                    blurRadius: hovered ? 20 : 8,
                    offset: Offset(0, hovered ? 8 : 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Cover Image ──
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(15)),
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Container(
                            color: const Color(0xFFF1F5F9),
                            child: MyNetworkImage(
                              imagePath: data?.portraitImg ?? "",
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                      ),
                      // Access badge
                      if (accessInfo != null)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: accessInfo.badgeBg.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              accessInfo.badgeLabel,
                              style: TextStyle(
                                color: accessInfo.badgeTextColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      // Hover overlay
                      if (hovered)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(15)),
                              color: Colors.black.withOpacity(0.06),
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.remove_red_eye_outlined,
                                        size: 16, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text(
                                      "View",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // ── Content ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          data?.title ?? "",
                          style: TextStyle(
                            color: const Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        // Author
                        if (data?.authorName != null &&
                            (data.authorName ?? "").isNotEmpty)
                          Text(
                            data.authorName,
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 8),

                        // Rating row
                        Row(
                          children: [
                            Icon(Icons.star_rounded,
                                size: 15,
                                color: const Color(0xFFF59E0B)),
                            const SizedBox(width: 4),
                            Text(
                              (data?.avgReviews ?? 0) > 0
                                  ? data!.avgReviews.toString()
                                  : "0",
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "(${Utils.kmbGenerator(data?.totalReviews ?? 0)})",
                              style: const TextStyle(
                                color: Color(0xFFCBD5E1),
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const Spacer(),
                            // Category as small text
                            if (data?.categoryName != null &&
                                (data.categoryName ?? "").isNotEmpty)
                              Flexible(
                                child: Text(
                                  data.categoryName,
                                  style: const TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateContent(dynamic data, int? contentType) {
    if (contentType == 1) {
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => WebAudioBookDetails(
          categoryId: data?.categoryId.toString(),
          authorId: data?.authorId.toString(),
          contentId: data?.id.toString(),
          name: data?.title.toString(),
          isFromHome: true,
        ),
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ));
    } else if (contentType == 2) {
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => WebDetails(
          categoryId: data?.categoryId.toString(),
          authorId: data?.authorId.toString(),
          contentId: data?.id.toString(),
          name: data?.title.toString(),
          type: data?.type.toString(),
          isFromHome: true,
        ),
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ));
    } else {
      Navigator.of(context).push(PageRouteBuilder(
        pageBuilder: (_, __, ___) => WebMagazineDetails(
          contentId: data?.id.toString(),
          categoryId: data?.categoryId.toString(),
          name: data?.title.toString(),
          isFromHome: true,
        ),
        transitionDuration: const Duration(milliseconds: 200),
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c),
      ));
    }
  }

/* ═══════════════════════════════════════════
   SQUARE CARD (for horizontal-scroll sections)
   ═══════════════════════════════════════════ */
  Widget _SquareCard({
    dynamic data,
    AccessInfo? accessInfo,
    double width = 200,
    VoidCallback? onTap,
  }) {
    return StatefulBuilder(
      builder: (context, setLocalState) {
        bool hovered = false;
        final isFree = accessInfo?.priceText?.toLowerCase() == "free";
        final hasPrice = accessInfo != null && accessInfo.priceText.isNotEmpty && !isFree;

        return MouseRegion(
          onEnter: (_) => setLocalState(() => hovered = true),
          onExit: (_) => setLocalState(() => hovered = false),
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: width,
              transform: hovered ? Matrix4.translationValues(0, -4, 0) : Matrix4.identity(),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hovered ? colorPrimary.withOpacity(0.15) : const Color(0xFFF1F4F9),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: hovered ? Colors.black.withOpacity(0.1) : Colors.black.withOpacity(0.04),
                    blurRadius: hovered ? 20 : 8,
                    offset: Offset(0, hovered ? 8 : 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Cover image with badges
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Container(
                            color: const Color(0xFFF1F5F9),
                            child: MyNetworkImage(
                              imagePath: data?.portraitImg ?? "",
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                      ),
                      if (accessInfo != null)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: accessInfo.badgeBg.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              accessInfo.badgeLabel,
                              style: TextStyle(
                                color: accessInfo.badgeTextColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      if (hovered)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                              color: Colors.black.withOpacity(0.06),
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text("View", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data?.title ?? "",
                          style: const TextStyle(
                            color: Color(0xFF0F172A),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        if (data?.authorName != null && (data.authorName ?? "").isNotEmpty)
                          Text(
                            data.authorName,
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12, fontWeight: FontWeight.w400),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star_rounded, size: 15, color: const Color(0xFFF59E0B)),
                            const SizedBox(width: 4),
                            Text(
                              (data?.avgReviews ?? 0) > 0 ? data!.avgReviews.toString() : "0",
                              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "(${Utils.kmbGenerator(data?.totalReviews ?? 0)})",
                              style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11, fontWeight: FontWeight.w400),
                            ),
                            const Spacer(),
                            if (data?.categoryName != null && (data.categoryName ?? "").isNotEmpty)
                              Flexible(
                                child: Text(
                                  data.categoryName,
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w400),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _Badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

/* =================== Portrait data started ====================== */

  Widget _buildPortraitData(
      List<Datum>? sectionDataList, int sectionIndex, int? contentType) {
    final isDesktop = MediaQuery.of(context).size.width > 800;
    const double maxContentWidth = 1400;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 20),
          child: ResponsiveGridList(
            minItemWidth: isDesktop ? 175 : 155,
            minItemsPerRow: isDesktop ? 3 : 2,
            maxItemsPerRow: isDesktop
                ? Utils.customCrossAxisCount(
                    context: context,
                    height1600: 8, height1200: 6,
                    height800: 4, height400: 3,
                  )
                : 2,
            horizontalGridMargin: 0,
            verticalGridMargin: 0,
            verticalGridSpacing: 12,
            horizontalGridSpacing: 12,
            listViewBuilderOptions: ListViewBuilderOptions(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
            ),
            children: List.generate(
              sectionDataList?.length ?? 0,
              (position) {
                final data = sectionDataList?[position];
                final info = getAccessInfo(
                  accessType: data?.accessType.toString(),
                  isBuy: data?.isBuy.toString(),
                  isSubscription: Constant.isSubscription ?? 0,
                  price: data?.price?.toString(),
                );
                return _ContentCard(
                  data: data,
                  contentType: contentType,
                  accessInfo: info,
                  width: isDesktop ? 175 : 155,
                  onTap: () => _navigateContent(data, contentType),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

/* ===================================Author Data show============================ */
  Widget _buildAuthorData(List<Datum>? sectionDataList, int sectionIndex) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        if (MediaQuery.of(context).size.width > 800)
          _buildWebAuthor(sectionDataList)
        else
          _buildMobileAuthor(sectionDataList)
      ],
    );
  }

  Widget _buildWebAuthor(List<Datum>? sectionDataList) {
    const double maxContentWidth = 1400;
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth =
        screenWidth > maxContentWidth ? maxContentWidth : screenWidth - 40;

    return Center(
      child: SizedBox(
        width: containerWidth,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          physics: BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 20,
            children: List.generate(
              sectionDataList?.length ?? 0,
              (position) {
                final data = sectionDataList?[position];
                return InkWell(
                  splashColor: transparent,
                  focusColor: transparent,
                  hoverColor: transparent,
                  highlightColor: transparent,
                  onTap: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return WebAuthor(
                          autherUserID: data?.id.toString(),
                          name:
                              "${data?.firstName ?? ""} ${data?.lastName ?? ""}"
                                  .trim(),
                        );
                      },
                      transitionDuration: Duration(milliseconds: 150),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            return ClipPath(
                              clipper: CircularRevealClipper(
                                  progress: animation.value),
                              child: child,
                            );
                          },
                          child: child,
                        );
                      },
                    ));
                  },
                  child: Container(
                    width: 200,
                    padding: const EdgeInsets.fromLTRB(0, 16, 6, 16),
                    alignment: Alignment.center,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      spacing: 4,
                      children: [
                        // ✅ Circular image with border
                        Container(
                          width: 180, // slightly smaller than before
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: colorPrimary, width: 3),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: ClipOval(
                            child: InteractiveNetworkIcon(
                              imagePath: data?.image ?? "",
                              height: 180,
                              width: 180,
                              iconFit: BoxFit.contain,
                              withBG: true,
                              bgColor: transparent,
                              bgHoverColor: transparent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        MyText(
                          color: colorPrimary,
                          text:
                              "${data?.firstName ?? ""} ${data?.lastName ?? ""}"
                                  .trim(),
                          fontsize: Dimens.medium18TextSize,
                          fontsizeWeb: Dimens.medium18TextSize,
                          maxline: 3,
                          fontwaight: FontWeight.w600,
                          textalign: TextAlign.start,
                          fontstyle: FontStyle.normal,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

/* Mobile view Author */
  Widget _buildMobileAuthor(List<Datum>? sectionDataList) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        physics: BouncingScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 20,
          children: List.generate(
            sectionDataList?.length ?? 0,
            (position) {
              final data = sectionDataList?[position];
              return InkWell(
                splashColor: transparent,
                focusColor: transparent,
                hoverColor: transparent,
                highlightColor: transparent,
                onTap: () {
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return WebAuthor(
                        autherUserID: data?.id.toString(),
                        name: "${data?.firstName ?? ""} ${data?.lastName ?? ""}"
                            .trim(),
                      );
                    },
                    transitionDuration: Duration(milliseconds: 150),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          return ClipPath(
                            clipper: CircularRevealClipper(
                                progress: animation.value),
                            child: child,
                          );
                        },
                        child: child,
                      );
                    },
                  ));
                },
                child: Container(
                  width: 150,
                  padding: const EdgeInsets.fromLTRB(6, 16, 6, 16),
                  alignment: Alignment.center,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 8,
                    children: [
                      // Circular image with border
                      Container(
                        height: 120,
                        width: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: colorPrimary, width: 2),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: MyNetworkImage(
                          imagePath: data?.image ?? "",
                          fit: BoxFit.fill,
                        ),
                      ),
                      const SizedBox(height: 10),
                      MyText(
                        color: colorPrimary,
                        text: "${data?.firstName ?? ""} ${data?.lastName ?? ""}"
                            .trim(),
                        fontsize: Dimens.medium18TextSize,
                        fontsizeWeb: Dimens.medium16TextSize,
                        maxline: 3,
                        fontwaight: FontWeight.w600,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

/*============================= Horizontail data Started ==========================*/
  Widget _buildHorizontalData(
      List<Datum>? sectionDataList, int sectionIndex, int? contentType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        if (MediaQuery.of(context).size.width > 800)
          _buildWebHorizontil(sectionDataList, contentType)
        else
          _buildMobileHorizontail(sectionDataList, contentType)
      ],
    );
  }

  Widget _buildWebHorizontil(List<Datum>? sectionDataList, int? contentType) {
    const double maxContentWidth = 1400;
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth =
        screenWidth > maxContentWidth ? maxContentWidth : screenWidth - 40;

    return Center(
      child: SizedBox(
        width: containerWidth,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.zero,
          physics: BouncingScrollPhysics(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start, // items start from left
            spacing: 20,
            children: List.generate(
              sectionDataList?.length ?? 0,
              (position) {
                final data = sectionDataList?[position];

                final accessInfo = getAccessInfo(
                  accessType: data?.accessType.toString(),
                  isBuy: data?.isBuy.toString(),
                  isSubscription: Constant.isSubscription ?? 0,
                  price: data?.price?.toString(),
                );

                return InkWell(
                  splashColor: transparent,
                  focusColor: transparent,
                  hoverColor: transparent,
                  highlightColor: transparent,
                  onTap: () {
                    if (contentType == 1) {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return WebAudioBookDetails(
                            authorId: data?.authorId.toString(),
                            categoryId: data?.categoryId.toString(),
                            contentId: data?.id.toString(),
                            name: data?.title.toString(),
                            isFromHome: true,
                          );
                        },
                        transitionDuration: Duration(milliseconds: 150),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return AnimatedBuilder(
                            animation: animation,
                            builder: (context, child) {
                              return ClipPath(
                                clipper: CircularRevealClipper(
                                    progress: animation.value),
                                child: child,
                              );
                            },
                            child: child,
                          );
                        },
                      ));
                    } else if (contentType == 2) {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return WebDetails(
                            categoryId: data?.categoryId.toString(),
                            authorId: data?.authorId.toString(),
                            contentId: data?.id.toString(),
                            name: data?.title.toString(),
                            type: data?.type.toString(),
                            isFromHome: true,
                          );
                        },
                        transitionDuration: Duration(milliseconds: 150),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return AnimatedBuilder(
                            animation: animation,
                            builder: (context, child) {
                              return ClipPath(
                                clipper: CircularRevealClipper(
                                    progress: animation.value),
                                child: child,
                              );
                            },
                            child: child,
                          );
                        },
                      ));
                    } else {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return WebMagazineDetails(
                            contentId: data?.id.toString(),
                            categoryId: data?.categoryId.toString(),
                            name: data?.title.toString(),
                            isFromHome: true,
                          );
                        },
                        transitionDuration: Duration(milliseconds: 150),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return AnimatedBuilder(
                            animation: animation,
                            builder: (context, child) {
                              return ClipPath(
                                clipper: CircularRevealClipper(
                                    progress: animation.value),
                                child: child,
                              );
                            },
                            child: child,
                          );
                        },
                      ));
                    }
                  },
                  child: SizedBox(
                    width: 375,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 4,
                      children: [
                        InteractiveNetworkIcon(
                          imagePath: data?.portraitImg.toString() ?? "",
                          height: 200,
                          iconFit: BoxFit.contain,
                          withBG: true,
                          bgColor: transparent,
                          bgHoverColor: transparent,
                          width: double.infinity,
                          bgRadius: BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16)),
                        ),
                        MyText(
                          text: data?.title.toString() ?? "",
                          fontsize: Dimens.medium18TextSize,
                          fontsizeWeb: Dimens.medium18TextSize,
                          maxline: 3,
                          fontwaight: FontWeight.w500,
                          textalign: TextAlign.start,
                          fontstyle: FontStyle.normal,
                        ),
                        MyText(
                          text: data?.categoryName.toString() ?? "",
                          fontsize: Dimens.medium18TextSize,
                          fontsizeWeb: Dimens.medium18TextSize,
                          maxline: 3,
                          color: colorPrimary,
                          fontwaight: FontWeight.w500,
                          textalign: TextAlign.start,
                          fontstyle: FontStyle.normal,
                        ),
                        MyText(
                          text: "By ${data?.authorName.toString() ?? ""}",
                          fontsize: Dimens.medium16TextSize,
                          fontsizeWeb: Dimens.medium16TextSize,
                          maxline: 2,
                          color: colorPrimary,
                          fontwaight: FontWeight.w400,
                          textalign: TextAlign.start,
                          fontstyle: FontStyle.normal,
                        ),
                        Row(
                          children: [
                            MyText(
                              text: data?.avgReviews.toString() ?? "",
                              fontsize: Dimens.medium12TextSize,
                              maxline: 1,
                              fontwaight: FontWeight.w400,
                            ),
                            const SizedBox(width: 5),
                            RatingBar.readOnly(
                              filledIcon: Icons.star,
                              emptyIcon: Icons.star_border,
                              initialRating: double.tryParse(
                                      data?.avgReviews.toString() ?? "0") ??
                                  0,
                              emptyColor: gray,
                              filledColor: colorPrimary,
                              maxRating: 5,
                              size: 10,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: MyText(
                                text:
                                    "(${Utils.kmbGenerator(data?.totalReviews ?? 0)})",
                                fontsize: Dimens.medium12TextSize,
                                maxline: 1,
                                fontwaight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6),
                        MyText(
                          text: accessInfo.priceText,
                          fontsizeWeb: Dimens.medium20TextSize,
                          fontsize: Dimens.medium13TextSize,
                          color: accessInfo.badgeTextColor,
                          maxline: 1,
                          multilanguage: false,
                          fontstyle: FontStyle.normal,
                          isfont: 2,
                          fontwaight: FontWeight.bold,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMobileHorizontail(
      List<Datum>? sectionDataList, int? contentType) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        physics: BouncingScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          spacing: 20,
          children: List.generate(
            sectionDataList?.length ?? 0,
            (position) {
              final accessInfo = getAccessInfo(
                accessType: sectionDataList?[position].accessType.toString(),
                isBuy: sectionDataList?[position].isBuy.toString(),
                isSubscription: Constant.isSubscription ?? 0,
                price: sectionDataList?[position].price?.toString(),
              );
              return InkWell(
                splashColor: transparent,
                focusColor: transparent,
                hoverColor: transparent,
                highlightColor: transparent,
                onTap: () {
                  if (contentType == 1) {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return WebAudioBookDetails(
                          authorId:
                              sectionDataList?[position].authorId.toString(),
                          categoryId:
                              sectionDataList?[position].categoryId.toString(),
                          contentId: sectionDataList?[position].id.toString(),
                          name: sectionDataList?[position].title.toString(),
                          isFromHome: true,
                        );
                      },
                      transitionDuration: Duration(milliseconds: 150),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            return ClipPath(
                              clipper: CircularRevealClipper(
                                  progress: animation.value),
                              child: child,
                            );
                          },
                          child: child,
                        );
                      },
                    ));
                  } else if (contentType == 2) {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return WebDetails(
                          categoryId:
                              sectionDataList?[position].categoryId.toString(),
                          authorId:
                              sectionDataList?[position].authorId.toString(),
                          contentId: sectionDataList?[position].id.toString(),
                          name: sectionDataList?[position].title.toString(),
                          type: sectionDataList?[position].type.toString(),
                          isFromHome: true,
                        );
                      },
                      transitionDuration: Duration(milliseconds: 150),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            return ClipPath(
                              clipper: CircularRevealClipper(
                                  progress: animation.value),
                              child: child,
                            );
                          },
                          child: child,
                        );
                      },
                    ));
                  } else {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return WebMagazineDetails(
                          contentId: sectionDataList?[position].id.toString(),
                          categoryId:
                              sectionDataList?[position].categoryId.toString(),
                          name: sectionDataList?[position].title.toString(),
                          isFromHome: true,
                        );
                      },
                      transitionDuration: Duration(milliseconds: 150),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            return ClipPath(
                              clipper: CircularRevealClipper(
                                  progress: animation.value),
                              child: child,
                            );
                          },
                          child: child,
                        );
                      },
                    ));
                  }
                },
                child: SizedBox(
                  width: 375,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      InteractiveNetworkIcon(
                        imagePath: contentType == 1
                            ? (sectionDataList?[position]
                                    .portraitImg
                                    .toString() ??
                                "")
                            : sectionDataList?[position]
                                    .portraitImg
                                    .toString() ??
                                "",
                        height: 200,
                          iconFit: BoxFit.contain,
                        withBG: true,
                        bgColor: transparent,
                        bgHoverColor: transparent,
                        width: MediaQuery.sizeOf(context).width,
                        bgRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16)),
                      ),
                      MyText(
                          text:
                              sectionDataList?[position].title.toString() ?? "",
                          fontsize: Dimens.medium18TextSize,
                          fontsizeWeb: Dimens.medium18TextSize,
                          maxline: 3,
                          fontwaight: FontWeight.w500,
                          textalign: TextAlign.start,
                          fontstyle: FontStyle.normal),
                      MyText(
                          text: sectionDataList?[position]
                                  .categoryName
                                  .toString() ??
                              "",
                          fontsize: Dimens.medium18TextSize,
                          fontsizeWeb: Dimens.medium18TextSize,
                          maxline: 3,
                          color: colorPrimary,
                          fontwaight: FontWeight.w500,
                          textalign: TextAlign.start,
                          fontstyle: FontStyle.normal),
                      MyText(
                          text:
                              "By ${sectionDataList?[position].authorName.toString() ?? ""}",
                          fontsize: Dimens.medium16TextSize,
                          fontsizeWeb: Dimens.medium16TextSize,
                          maxline: 2,
                          color: colorPrimary,
                          fontwaight: FontWeight.w400,
                          textalign: TextAlign.start,
                          fontstyle: FontStyle.normal),
                      Row(
                        children: [
                          MyText(
                            text: sectionDataList?[position]
                                    .avgReviews
                                    .toString() ??
                                "",
                            fontsize: Dimens.medium12TextSize,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                          ),
                          const SizedBox(width: 5),
                          RatingBar.readOnly(
                            filledIcon: Icons.star,
                            emptyIcon: Icons.star_border,
                            initialRating: double.parse(
                                sectionDataList?[position]
                                        .avgReviews
                                        .toString() ??
                                    ""),
                            emptyColor: gray,
                            filledColor: colorPrimary,
                            maxRating: 5,
                            size: 10,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: MyText(
                              text:
                                  "(${Utils.kmbGenerator(sectionDataList?[position].totalReviews ?? 0)})",
                              fontsize: Dimens.medium12TextSize,
                              maxline: 1,
                              fontwaight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      MyText(
                        text: accessInfo.priceText,
                        fontsize: Dimens.medium20TextSize,
                        color: accessInfo.badgeTextColor,
                        maxline: 1,
                        multilanguage: false,
                        fontstyle: FontStyle.normal,
                        isfont: 2,
                        fontwaight: FontWeight.bold,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Arrow Button Widget
  Widget _buildArrowButton(IconData icon, VoidCallback onTap) {
    return InteractiveContainer(child: (isHovered) {
      return InkWell(
        onTap: onTap,
        hoverColor: transparent,
        splashColor: transparent,
        focusColor: transparent,
        highlightColor: transparent,
        borderRadius: BorderRadius.circular(5),
        child: AnimatedScale(
          scale: isHovered ? 1.05 : 1,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
            decoration: BoxDecoration(
              color: white,
              border: Border.all(
                width: 1,
                color: isHovered ? colorPrimary : colorPrimary,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon,
                size: 20, color: isHovered ? colorPrimary : colorPrimary),
          ),
        ),
      );
    });
  }

/*================================ Shimmer widget ========================== */

/*category shimmer */
  Widget categoryshimmer(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxContentWidth = 1400;
    final isMobile = screenWidth < 600;

    final itemWidth = isMobile ? (screenWidth / 3) - 20 : 160.0;
    const shimmerItemCount = 8;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          child: Row(
            children: List.generate(
              shimmerItemCount,
              (position) {
                return Container(
                  margin: const EdgeInsets.all(8),
                  width: itemWidth,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AspectRatio(
                        aspectRatio: 1,
                        child: CustomWidget.roundcorner(
                          height: double.infinity,
                          width: double.infinity,
                          shapeBorder: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                        ),
                      ),
                      const SizedBox(height: 8),
                      CustomWidget.roundrectborder(
                        height: isMobile ? 12 : 14,
                        width: itemWidth * 0.8,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
/* build square  */

  // Widget _buildSquareshimmer() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     spacing: 20,
  //     children: [
  //       if (MediaQuery.of(context).size.width > 1000)
  //         buildWebSquareShimmer()
  //       else
  //         buildMobileSquareShimmer()
  //     ],
  //   );
  // }

  // Widget buildWebSquareShimmer() {
  //   const double desktopPadding = 150.0;
  //   const double cardWidth = 200.0;
  //   const double cardHeight = 410.0;
  //   const double imagePlaceholderHeight = 243.0;

  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(desktopPadding, 0, desktopPadding, 0),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       mainAxisAlignment: MainAxisAlignment.start,
  //       children: [
  //         Flexible(
  //           fit: FlexFit.loose,
  //           child: SingleChildScrollView(
  //             scrollDirection: Axis.horizontal,
  //             physics: const BouncingScrollPhysics(),
  //             child: Row(
  //               spacing: 20,
  //               children: List.generate(6, (index) {
  //                 return Container(
  //                   width: cardWidth,
  //                   height: cardHeight,
  //                   padding: const EdgeInsets.fromLTRB(6, 16, 6, 16),
  //                   decoration: BoxDecoration(
  //                     color: white,
  //                     border: Border.all(width: 1, color: gray),
  //                   ),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       const CustomWidget.roundcorner(
  //                         width: double.infinity,
  //                         height: imagePlaceholderHeight,
  //                       ),
  //                       const SizedBox(height: 6),
  //                       const CustomWidget.roundrectborder(
  //                         height: 14,
  //                         width: 100,
  //                       ),
  //                       const SizedBox(height: 4),
  //                       const CustomWidget.roundrectborder(
  //                         height: 16,
  //                         width: 140,
  //                       ),
  //                       const SizedBox(height: 2),
  //                       const CustomWidget.roundrectborder(
  //                         height: 16,
  //                         width: 100,
  //                       ),
  //                       const SizedBox(height: 4),
  //                       const CustomWidget.roundrectborder(
  //                         height: 12,
  //                         width: 120,
  //                       ),
  //                       const SizedBox(height: 6),
  //                       Row(
  //                         children: const [
  //                           CustomWidget.roundrectborder(
  //                             height: 12,
  //                             width: 30,
  //                           ),
  //                           SizedBox(width: 5),
  //                           CustomWidget.roundrectborder(
  //                             height: 12,
  //                             width: 60,
  //                           ),
  //                         ],
  //                       ),
  //                       const SizedBox(height: 6),
  //                       const CustomWidget.roundrectborder(
  //                         height: 18,
  //                         width: 80,
  //                       ),
  //                     ],
  //                   ),
  //                 );
  //               }),
  //             ),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget buildMobileSquareShimmer() {
  //   const double cardHeight = 400;
  //   return Padding(
  //     padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
  //     child: SingleChildScrollView(
  //       scrollDirection: Axis.horizontal,
  //       physics: const BouncingScrollPhysics(),
  //       child: Row(
  //         spacing: 20,
  //         children: List.generate(6, (index) {
  //           return Container(
  //             width: 185,
  //             height: cardHeight,
  //             padding: const EdgeInsets.fromLTRB(6, 16, 6, 16),
  //             decoration: BoxDecoration(
  //               color: white,
  //               border: Border.all(width: 1, color: gray),
  //               borderRadius: const BorderRadius.all(Radius.circular(10)),
  //             ),
  //             child: Column(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 const CustomWidget.roundcorner(
  //                   width: double.infinity,
  //                   height: 243,
  //                 ),
  //                 const SizedBox(height: 6),
  //                 const CustomWidget.roundrectborder(
  //                   height: 14,
  //                   width: 100,
  //                 ),
  //                 const SizedBox(height: 6),
  //                 const CustomWidget.roundrectborder(
  //                   height: 16,
  //                   width: 140,
  //                 ),
  //                 const SizedBox(height: 6),
  //                 const CustomWidget.roundrectborder(
  //                   height: 12,
  //                   width: 120,
  //                 ),
  //                 const SizedBox(height: 6),
  //                 Row(
  //                   children: const [
  //                     CustomWidget.roundrectborder(
  //                       height: 12,
  //                       width: 30,
  //                     ),
  //                     SizedBox(width: 5),
  //                     CustomWidget.roundrectborder(
  //                       height: 12,
  //                       width: 60,
  //                     ),
  //                   ],
  //                 ),
  //                 const SizedBox(height: 6),
  //                 const CustomWidget.roundrectborder(
  //                   height: 18,
  //                   width: 80,
  //                 ),
  //               ],
  //             ),
  //           );
  //         }),
  //       ),
  //     ),
  //   );
  // }

  /* potratait shimmer */

  Widget _buildPortraitshimmer() {
    return Padding(
      padding: (MediaQuery.of(context).size.width > 1000)
          ? const EdgeInsets.fromLTRB(150, 0, 150, 0)
          : const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          if (MediaQuery.of(context).size.width > 800)
            buildWebPortraitShimmer()
          else
            buildMobilePortraitShimmer()
        ],
      ),
    );
  }

  Widget buildWebPortraitShimmer() {
    const double maxContentWidth = 1400;
    const double imagePlaceholderHeight = 243;
    const int shimmerItemCount = 8;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: ResponsiveGridList(
          minItemWidth: 185,
          minItemsPerRow: 3,
          maxItemsPerRow: Utils.customCrossAxisCount(
            context: context,
            height1600: 8,
            height1200: 6,
            height800: 4,
            height400: 3,
          ),
          horizontalGridMargin: 0,
          verticalGridMargin: 0,
          verticalGridSpacing: 0,
          horizontalGridSpacing: 0,
          listViewBuilderOptions: ListViewBuilderOptions(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
          ),
          children: List.generate(shimmerItemCount, (index) {
            return Container(
              width: 185,
              padding: const EdgeInsets.fromLTRB(6, 16, 6, 16),
              decoration: BoxDecoration(
                color: white,
                border:
                    Border.all(width: 1, color: gray, style: BorderStyle.solid),
                borderRadius: const BorderRadius.all(Radius.circular(0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomWidget.roundcorner(
                    width: double.infinity,
                    height: imagePlaceholderHeight,
                  ),
                  const SizedBox(height: 4),
                  const CustomWidget.roundrectborder(height: 16, width: 80),
                  const SizedBox(height: 4),
                  const CustomWidget.roundrectborder(height: 16, width: 140),
                  const SizedBox(height: 2),
                  const CustomWidget.roundrectborder(height: 16, width: 100),
                  const SizedBox(height: 4),
                  const CustomWidget.roundrectborder(height: 14, width: 100),
                  const SizedBox(height: 4),
                  Row(
                    children: const [
                      CustomWidget.roundrectborder(height: 14, width: 20),
                      SizedBox(width: 5),
                      CustomWidget.roundrectborder(height: 10, width: 60),
                      SizedBox(width: 5),
                      Expanded(
                        child:
                            CustomWidget.roundrectborder(height: 12, width: 40),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const CustomWidget.roundrectborder(height: 18, width: 80),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget buildMobilePortraitShimmer() {
    return ResponsiveGridList(
      minItemWidth: 185,
      minItemsPerRow: 2,
      maxItemsPerRow: 2,
      horizontalGridMargin: 0,
      verticalGridMargin: 0,
      verticalGridSpacing: 0,
      horizontalGridSpacing: 0,
      listViewBuilderOptions: ListViewBuilderOptions(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        physics: NeverScrollableScrollPhysics(),
      ),
      children: List.generate(6, (index) {
        return Container(
          width: 185,
          padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
          decoration: BoxDecoration(
            color: white,
            border: Border.all(width: 1, color: gray),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              const CustomWidget.roundcorner(
                width: double.infinity,
                height: 220,
              ),

              const CustomWidget.roundrectborder(height: 14, width: 80),

              const CustomWidget.roundrectborder(height: 16, width: 140),

              const CustomWidget.roundrectborder(height: 12, width: 100),

              Row(
                children: const [
                  CustomWidget.roundrectborder(height: 12, width: 30),
                  SizedBox(width: 5),
                  CustomWidget.roundrectborder(height: 12, width: 60),
                ],
              ),

              /// price shimmer
              const CustomWidget.roundrectborder(height: 18, width: 80),
            ],
          ),
        );
      }),
    );
  }

/* horizontal shimmer  */

  Widget _buildHorizontalshimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        if (MediaQuery.of(context).size.width > 800)
          buildWebHorizontalShimmer()
        else
          buildMobileHorizontalShimmer()
      ],
    );
  }

  Widget buildWebHorizontalShimmer({int count = 4}) {
    const double maxContentWidth = 1400;
    final screenWidth = MediaQuery.of(context).size.width;
    final containerWidth =
        screenWidth > maxContentWidth ? maxContentWidth : screenWidth - 40;

    return Center(
      child: SizedBox(
        width: containerWidth,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: List.generate(count, (index) {
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: SizedBox(
                  width: 375,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const CustomWidget.roundcorner(
                        width: double.infinity,
                        height: 200,
                      ),
                      const SizedBox(height: 4),
                      const CustomWidget.roundrectborder(
                          height: 18, width: 220),
                      const SizedBox(height: 4),
                      const CustomWidget.roundrectborder(
                          height: 18, width: 180),
                      const SizedBox(height: 4),
                      const CustomWidget.roundrectborder(
                          height: 18, width: 100),
                      const SizedBox(height: 4),
                      const CustomWidget.roundrectborder(
                          height: 16, width: 140),
                      const SizedBox(height: 4),
                      Row(
                        children: const [
                          CustomWidget.roundrectborder(height: 12, width: 30),
                          SizedBox(width: 5),
                          CustomWidget.roundrectborder(height: 12, width: 60),
                          SizedBox(width: 5),
                          CustomWidget.roundrectborder(height: 12, width: 50),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const CustomWidget.roundrectborder(height: 24, width: 80),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget buildMobileHorizontalShimmer({int count = 4}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(count, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 20),
              child: SizedBox(
                width: 375,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 6,
                  children: [
                    const CustomWidget.roundcorner(
                      width: double.infinity,
                      height: 200,
                    ),
                    const CustomWidget.roundrectborder(height: 18, width: 220),
                    const CustomWidget.roundrectborder(height: 16, width: 100),
                    const CustomWidget.roundrectborder(height: 14, width: 140),
                    Row(
                      children: const [
                        CustomWidget.roundrectborder(height: 12, width: 30),
                        SizedBox(width: 5),
                        CustomWidget.roundrectborder(height: 12, width: 60),
                        SizedBox(width: 5),
                        CustomWidget.roundrectborder(height: 12, width: 50),
                      ],
                    ),
                    const CustomWidget.roundrectborder(height: 20, width: 80),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
  /* Banner shimmer */

  Widget buildbannershimmer(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth > 1000;

    if (isDesktop) {
      return _buildBannerShimmerDesktop(context);
    } else {
      return _buildBannerShimmerMobile(context);
    }
  }

  Widget _buildBannerShimmerDesktop(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const shimmerItemCount = 4;
    const double maxContentWidth = 1400;
    final bool isMobile = screenWidth < 600;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: maxContentWidth),
        child: SizedBox(
          height: isMobile ? 350 : 500,
          width: double.infinity,
          child: Stack(
            alignment: Alignment.center,
            children: [
              /// ===== BACKGROUND IMAGE SHIMMER =====
              CustomWidget.rectangular(
                height: isMobile ? 350 : 500,
                width: double.infinity,
              ),

              /// ===== FOREGROUND CONTENT =====
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    /// ===== LEFT SECTION SHIMMER (Title + Button) =====
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomWidget.roundrectborder(height: 24, width: 300),
                          const SizedBox(height: 20),
                          CustomWidget.roundrectborder(height: 24, width: 250),
                          const SizedBox(height: 30),
                          CustomWidget.roundcorner(
                            height: 40,
                            width: 150,
                            shapeBorder: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(20),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 40),

                    /// ===== RIGHT SECTION SHIMMER (Carousel Placeholder) =====
                    Expanded(
                      flex: 5,
                      child: Center(
                        child: SizedBox(
                          height: 260,
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            physics: const NeverScrollableScrollPhysics(),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                                  List.generate(shimmerItemCount, (index) {
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: CustomWidget.roundcorner(
                                    height: 240,
                                    width: 250,
                                    shapeBorder: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(12),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// ===== INDICATOR DOTS SHIMMER =====
              Positioned(
                bottom: 60,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: maxContentWidth),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: List.generate(shimmerItemCount, (index) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: CustomWidget.circular(height: 10, width: 10),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBannerShimmerMobile(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const shimmerItemCount = 3; // Based on your original mobile shimmer

    return SizedBox(
      width: screenWidth,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: CustomWidget.roundcorner(
              height: 200,
              width: screenWidth, // Full width on mobile
              shapeBorder: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                Radius.circular(10),
              )),
            ),
          ),
          const SizedBox(height: 10),
          // Indicator Dots Shimmer (Matching the style in _buildBannerMobile)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              shimmerItemCount,
              (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: CustomWidget.circular(height: 10, width: 10),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
