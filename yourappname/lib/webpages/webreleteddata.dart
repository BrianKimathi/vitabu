import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:yourappname/provider/bookdetailsprovider.dart';
import 'package:yourappname/provider/magazinedetailsprovider.dart';
import 'package:yourappname/provider/releteditemprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webpages/webaudiobookdetails.dart' hide SizedBox, Container, Row;
import 'package:yourappname/webpages/webdetails.dart' hide SizedBox, Container, Row;
import 'package:yourappname/webpages/webmagazinedetails.dart' hide SizedBox, Container, Row;
import 'package:yourappname/webwidget/footerweb.dart' hide SizedBox, Container, Row;
import 'package:yourappname/webwidget/webappbar.dart' hide SizedBox, Container, Row;
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class Webreleteddata extends StatefulWidget {
  final String? contentId, type, categoryId, name;
  const Webreleteddata({
    super.key,
    required this.contentId,
    required this.type,
    required this.categoryId,
    required this.name,
  });

  @override
  State<Webreleteddata> createState() => _WebreleteddataState();
}

class _WebreleteddataState extends State<Webreleteddata> {
  final ScrollController _scrollController = ScrollController();
  late ReletedItemProvider reletedItemProvider;

  @override
  void initState() {
    super.initState();
    printLog("type == ${widget.type}");
    reletedItemProvider =
        Provider.of<ReletedItemProvider>(context, listen: false);
    _scrollController.addListener(_scrollListener);
    getApi(0);
  }

  _scrollListener() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (reletedItemProvider.currentPage ?? 0) <
            (reletedItemProvider.totalPage ?? 0)) {
      reletedItemProvider.setLoadMore(true);
      getApi((reletedItemProvider.currentPage ?? 0));
    }
  }

// new API ADD
  Future getApi(nextPage) async {
    // reletedItemProvider.setLoading(true);
    if (widget.type == "1") {
      await reletedItemProvider.getSectionAudio(widget.type, widget.categoryId,
          widget.contentId, (nextPage ?? 0) + 1);
    } else if (widget.type == "2") {
      await reletedItemProvider.getSectionBook(widget.type, widget.categoryId,
          widget.contentId, (nextPage ?? 0) + 1);
    } else {
      await reletedItemProvider.getSectionMagazine(widget.type,
          widget.categoryId, widget.contentId, (nextPage ?? 0) + 1);
    }
  }

  @override
  void dispose() {
    reletedItemProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxContentWidth = 1400;
    final contentWidth =
        screenWidth > maxContentWidth ? maxContentWidth : screenWidth - 20;

    return WebAppBar(
      widget: Consumer<ReletedItemProvider>(
          builder: (context, homeProvider, child) {
        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.vertical,
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: contentWidth,
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth <= 1000 ? 10 : 0),
                  child: Utils.buildWebDetailsAppBar(
                      context: context,
                      title2: widget.name.toString(),
                      isHome: false,
                      multilanguage: false),
                ),
              ),
              Center(
                child: SizedBox(width: contentWidth, child: _buildTabbarData()),
              ),
              if (reletedItemProvider.loadmore)
                Utils.pageLoader(context)
              else
                const SizedBox.shrink(),
              const SizedBox(height: 30),
              FooterWeb()
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTabbarData() {
    if (reletedItemProvider.loading && !reletedItemProvider.loadmore) {
      return buildShimmer();
    } else {
      return widget.type == "1"
          ? _buildAudio()
          : widget.type == "2"
              ? _buildBoook()
              : _buildMagazine();
    }
  }

  Widget _buildAudio() {
    if (reletedItemProvider.audioList != null &&
        (reletedItemProvider.audioList?.length ?? 0) > 0) {
      return SingleChildScrollView(
        padding: EdgeInsets.only(top: 12),
        physics: BouncingScrollPhysics(),
        child: buildCommonWidget(reletedItemProvider.audioList ?? []),
      );
    } else {
      return NoData();
    }
  }

  Widget _buildBoook() {
    if (reletedItemProvider.bookList != null &&
        (reletedItemProvider.bookList?.length ?? 0) > 0) {
      return SingleChildScrollView(
        padding: EdgeInsets.only(top: 12),
        physics: BouncingScrollPhysics(),
        child: buildCommonWidget(reletedItemProvider.bookList ?? []),
      );
    } else {
      return NoData();
    }
  }

  Widget _buildMagazine() {
    if (reletedItemProvider.magazineList != null &&
        (reletedItemProvider.magazineList?.length ?? 0) > 0) {
      return SingleChildScrollView(
        padding: EdgeInsets.only(top: 12),
        physics: BouncingScrollPhysics(),
        child: buildCommonWidget(reletedItemProvider.magazineList ?? []),
      );
    } else {
      return NoData();
    }
  }

  Widget buildCommonWidget(List<dynamic>? commanList) {
    final screenWidth = MediaQuery.sizeOf(context).width;

    const double cardWidth = 185.0;
    const double spacing = 15.0;

    int crossAxisCount =
        ((screenWidth + spacing) / (cardWidth + spacing)).floor();

    crossAxisCount = crossAxisCount.clamp(1, 6);

    if (screenWidth < 600) {
      crossAxisCount = 2;
    }

    return AlignedGridView.count(
      crossAxisCount: crossAxisCount,
      itemCount: commanList?.length ?? 0,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      itemBuilder: (context, position) {
        final allDataList = commanList?[position];
        final accessInfo = getAccessInfo(
          accessType: allDataList.accessType.toString(),
          isBuy: allDataList.isBuy.toString(),
          isSubscription: Constant.isSubscription ?? 0,
          price: allDataList.price?.toString(),
        );
        return StatefulBuilder(
          builder: (context, setLocalState) {
            bool hovered = false;

            return MouseRegion(
              onEnter: (_) => setLocalState(() => hovered = true),
              onExit: (_) => setLocalState(() => hovered = false),
              child: GestureDetector(
                onTap: () {
                  if (widget.type == "1") {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return WebAudioBookDetails(
                          categoryId: allDataList?.categoryId.toString() ?? "",
                          contentId: allDataList?.id.toString() ?? "",
                          authorId: allDataList?.authorId.toString(),
                          name: allDataList?.title.toString() ?? "",
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 150),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            return ClipPath(
                              clipper:
                                  CircularRevealClipper(progress: animation.value),
                              child: child,
                            );
                          },
                          child: child,
                        );
                      },
                    ));
                  } else if (widget.type == "2") {
                    final bookDetailsProvider =
                        Provider.of<BookDetailsProvider>(context, listen: false);
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return WebDetails(
                          categoryId: allDataList?.categoryId.toString() ?? "",
                          authorId: allDataList?.authorId.toString() ?? "",
                          contentId: allDataList?.id.toString() ?? "",
                          name: allDataList?.title.toString() ?? "",
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 150),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            return ClipPath(
                              clipper:
                                  CircularRevealClipper(progress: animation.value),
                              child: child,
                            );
                          },
                          child: child,
                        );
                      },
                    ));
                    bookDetailsProvider.clearProvider();
                  } else {
                    final magazineDetailsProvider =
                        Provider.of<MagazineDetailsProvider>(context, listen: false);
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return WebMagazineDetails(
                          contentId: allDataList?.id.toString() ?? "",
                          categoryId: allDataList?.categoryId.toString() ?? "",
                          name: allDataList?.title.toString() ?? "",
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 150),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) {
                            return ClipPath(
                              clipper:
                                  CircularRevealClipper(progress: animation.value),
                              child: child,
                            );
                          },
                          child: child,
                        );
                      },
                    ));
                    magazineDetailsProvider.clearProvider();
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
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
                      // Cover Image
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
                                  imagePath: allDataList?.portraitImg ?? "",
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            ),
                          ),
                          // Access badge
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

                      // Content Info
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              allDataList?.title ?? "",
                              style: const TextStyle(
                                color: Color(0xFF0F172A),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),

                            // Author
                            if (allDataList?.authorName != null &&
                                (allDataList?.authorName ?? "").isNotEmpty)
                              Text(
                                allDataList?.authorName ?? "",
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
                                const Icon(Icons.star_rounded,
                                    size: 15, color: Color(0xFFF59E0B)),
                                const SizedBox(width: 4),
                                Text(
                                  (allDataList?.avgReviews ?? 0) > 0
                                      ? allDataList!.avgReviews.toString()
                                      : "0",
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "(${Utils.kmbGenerator(allDataList?.totalReviews ?? 0)})",
                                  style: const TextStyle(
                                    color: Color(0xFFCBD5E1),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const Spacer(),
                                if (allDataList?.categoryName != null &&
                                    (allDataList?.categoryName ?? "").isNotEmpty)
                                  Flexible(
                                    child: Text(
                                      allDataList?.categoryName ?? "",
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
      },
    );
  }

  Widget buildShimmer() {
    final screenWidth = MediaQuery.sizeOf(context).width;

    const double cardWidth = 185.0;
    const double spacing = 15.0;

    int crossAxisCount =
        ((screenWidth + spacing) / (cardWidth + spacing)).floor();
    crossAxisCount = crossAxisCount.clamp(1, 6);

    if (screenWidth < 600) {
      crossAxisCount = 2;
    }

    return AlignedGridView.count(
      crossAxisCount: crossAxisCount,
      itemCount: 12, // number of shimmer cards
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      itemBuilder: (context, index) {
        return Container(
          width: cardWidth,
          padding: const EdgeInsets.fromLTRB(10, 16, 10, 16),
          decoration: BoxDecoration(
            color: white,
            border: Border.all(width: 1, color: gray, style: BorderStyle.solid),
            borderRadius: const BorderRadius.all(Radius.circular(0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔹 Image shimmer
              CustomWidget.roundrectborder(
                height: 243,
                width: double.infinity,
              ),
              const SizedBox(height: 10),

              // 🔹 Title shimmer
              CustomWidget.roundrectborder(height: 20, width: 120),
              const SizedBox(height: 5),

              // 🔹 Author shimmer
              CustomWidget.roundrectborder(height: 15, width: 100),
              const SizedBox(height: 5),

              // 🔹 Category shimmer
              CustomWidget.roundrectborder(height: 15, width: 80),
              const SizedBox(height: 5),

              // 🔹 Rating shimmer (stars + text)
              Row(
                children: [
                  CustomWidget.roundrectborder(height: 15, width: 20),
                  const SizedBox(width: 5),
                  ...List.generate(
                    5,
                    (i) => const Padding(
                      padding: EdgeInsets.only(right: 2),
                      child:
                          CustomWidget.roundrectborder(height: 12, width: 12),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: CustomWidget.roundrectborder(height: 15, width: 50),
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // 🔹 Price shimmer
              CustomWidget.roundrectborder(height: 20, width: 80),
            ],
          ),
        );
      },
    );
  }
}
