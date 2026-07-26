import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:yourappname/provider/viewallprovider.dart';
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
import 'package:yourappname/webwidget/footerweb.dart';
import 'package:yourappname/webwidget/interactive_networkicon.dart';
import 'package:yourappname/webwidget/webappbar.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class Webviewall extends StatefulWidget {
  final String? type, sectionID, title, screenLayOut;
  const Webviewall(
      {super.key, this.type, this.sectionID, this.title, this.screenLayOut});

  @override
  State<Webviewall> createState() => _WebviewallState();
}

class _WebviewallState extends State<Webviewall> {
  final ScrollController _scrollController = ScrollController();
  late ViewAllProvider viewAllProvider;

  @override
  void initState() {
    printLog("type == ${widget.type}");
    viewAllProvider = Provider.of<ViewAllProvider>(context, listen: false);
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getApi(0);
    });
    super.initState();
  }

  _scrollListener() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (viewAllProvider.currentPage ?? 0) < (viewAllProvider.totalPage ?? 0)) {
      viewAllProvider.setLoadMore(true);
      getApi((viewAllProvider.currentPage ?? 0));
    }
  }

// new API ADD
  getApi(nextPage) {
    viewAllProvider.setLoading(true);
    if (widget.type == "1") {
      if (widget.screenLayOut == "square") {
        viewAllProvider.getSectionAudio(
            widget.sectionID ?? "", widget.type ?? "", (nextPage ?? 0) + 1);
      } else if (widget.screenLayOut == "portrait") {
        viewAllProvider.getSectionAudio(
            widget.sectionID ?? "", widget.type ?? "", (nextPage ?? 0) + 1);
      } else {
        viewAllProvider.getSectionAudio(
            widget.sectionID ?? "", widget.type ?? "", (nextPage ?? 0) + 1);
      }
    } else if (widget.type == "2") {
      if (widget.screenLayOut == "square") {
        viewAllProvider.getSectionBook(
            widget.sectionID ?? "", widget.type ?? "", (nextPage ?? 0) + 1);
      } else if (widget.screenLayOut == "portrait") {
        viewAllProvider.getSectionBook(
            widget.sectionID ?? "", widget.type ?? "", (nextPage ?? 0) + 1);
      } else {
        viewAllProvider.getSectionBook(
            widget.sectionID ?? "", widget.type ?? "", (nextPage ?? 0) + 1);
      }
    } else if (widget.type == "3") {
      if (widget.screenLayOut == "square") {
        viewAllProvider.getSectionMagazine(
            widget.sectionID ?? "", widget.type ?? "", (nextPage ?? 0) + 1);
      } else if (widget.screenLayOut == "portrait") {
        viewAllProvider.getSectionMagazine(
            widget.sectionID ?? "", widget.type ?? "", (nextPage ?? 0) + 1);
      } else {
        viewAllProvider.getSectionMagazine(
            widget.sectionID ?? "", widget.type ?? "", (nextPage ?? 0) + 1);
      }
    } else if (widget.type == "4") {
      viewAllProvider.getSectionCategory(
          widget.sectionID ?? "", widget.type ?? "", (nextPage ?? 0) + 1);
    } else if (widget.type == "5") {
      viewAllProvider.getSectionLanguage(
          widget.sectionID ?? "", widget.type ?? "", (nextPage ?? 0) + 1);
    } else {
      viewAllProvider.getSectionAuthor(
          widget.sectionID ?? "", widget.type ?? "", (nextPage ?? 0) + 1);
      printLog("Type ====jhkghjkhj");
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollController.removeListener(_scrollListener);
    viewAllProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxContentWidth = 1400;
    final contentWidth =
        screenWidth > maxContentWidth ? maxContentWidth : screenWidth - 20;

    return WebAppBar(
      widget:
          Consumer<ViewAllProvider>(builder: (context, homeProvider, child) {
        return SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.vertical,
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            spacing: 30,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: contentWidth,
                  padding: EdgeInsets.symmetric(
                      horizontal: screenWidth <= 1000 ? 10 : 0),
                  child: Utils.buildWebDetailsAppBar(
                      context: context,
                      title2: widget.title,
                      isHome: false,
                      multilanguage: false),
                ),
              ),
              Center(child: SizedBox(width: contentWidth, child: chackUi())),
              if (viewAllProvider.loadmore)
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

  /* Check ui */

  Widget chackUi() {
    if (widget.type == "1") {
      if (widget.screenLayOut.toString() == "square") {
        return squareAudio();
      } else if (widget.screenLayOut == "portrait") {
        return portraitviewAudio();
      } else {
        return horizontalviewAudio();
      }
    } else if (widget.type == "2") {
      if (widget.screenLayOut.toString() == "square") {
        return square();
      } else if (widget.screenLayOut == "portrait") {
        return portrait();
      } else {
        return horizontalView();
      }
    } else if (widget.type == "3") {
      if (widget.screenLayOut.toString() == "square") {
        return squareMagazine();
      } else if (widget.screenLayOut == "portrait") {
        return portraitMagazine();
      } else {
        return horizontalViewMagazine();
      }
    } else if (widget.type == "4" || widget.type == "5") {
      return categoryWebView();
    } else {
      return _buildWebViewAllAuthor();
    }
  }
  /* Ui start  */

/* =================================== Web View All Author ============================ */
  Widget _buildWebViewAllAuthor() {
    if (viewAllProvider.loading && !viewAllProvider.loadmore) {
      return authorshimmer();
    } else {
      if (viewAllProvider.authorList != null &&
          (viewAllProvider.authorList?.length ?? 0) > 0) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final crossAxisCount = (screenWidth ~/ 180).clamp(2, 6);

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: viewAllProvider.authorList?.length ?? 0,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 20,
                crossAxisSpacing: 20,
                childAspectRatio: 0.85,
              ),
              itemBuilder: (context, position) {
                final author = viewAllProvider.authorList?[position];
                return InkWell(
                  splashColor: transparent,
                  focusColor: transparent,
                  hoverColor: transparent,
                  highlightColor: transparent,
                  onTap: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return WebAuthor(
                          autherUserID: author?.id.toString(),
                          name:
                              "${author?.firstName ?? ""} ${author?.lastName ?? ""}",
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorPrimary,
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: InteractiveNetworkIcon(
                            imagePath: author?.image ?? "",
                            iconFit: BoxFit.cover,
                            withBG: false,
                            bgColor: transparent,
                            bgHoverColor: transparent,
                            height: 160,
                            width: 160,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      MyText(
                        color: black,
                        text:
                            "${author?.firstName ?? ""} ${author?.lastName ?? ""}",
                        fontsize: Dimens.medium18TextSize,
                        fontsizeWeb: Dimens.medium18TextSize,
                        maxline: 2,
                        fontwaight: FontWeight.w600,
                        textalign: TextAlign.center,
                        fontstyle: FontStyle.normal,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget authorshimmer() {
    return Builder(builder: (context) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final crossAxisCount = (maxWidth ~/ 180).clamp(2, 6);

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 8,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorPrimary.withOpacity( 0.5),
                        width: 3,
                      ),
                    ),
                    child: ClipOval(
                      child: CustomWidget.roundcorner(
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CustomWidget.roundrectborder(
                    width: 100,
                    height: 16,
                  ),
                ],
              );
            },
          );
        },
      );
    });
  }

// Weblanguagewisedata, and NoData.

  Widget categoryWebView() {
    if (viewAllProvider.loading && !viewAllProvider.loadmore) {
      return categoryShimmer();
    } else {
      final categories = viewAllProvider.categoryList;
      if (categories != null && categories.isNotEmpty) {
        return LayoutBuilder(builder: (context, constraints) {
          final double maxWidth = constraints.maxWidth;
          const double spacing = 20;
          const double minItemWidth = 160;

          final int crossAxisCount =
              ((maxWidth + spacing) / (minItemWidth + spacing)).floor();

          final double cardWidth =
              (maxWidth - (crossAxisCount - 1) * spacing) / crossAxisCount;

          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: const BouncingScrollPhysics(),
            child: Wrap(
              spacing: spacing,
              runSpacing: spacing,
              alignment: WrapAlignment.start,
              children: List.generate(categories.length, (index) {
                final cat = categories[index];
                final randomColor = Utils.getRandomLightColor();

                return InkWell(
                  onTap: () {
                    if (widget.type == "4") {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return Webcategorywisedata(
                              catagoryid: cat.id.toString(),
                              catagoryname: cat.name ?? "",
                              name: cat.name ?? "");
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
                    } else {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return Weblanguagewisedata(
                              catagoryid: cat.id.toString(),
                              catagoryname: cat.name ?? "");
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
                    }
                  },
                  child: Container(
                    width: cardWidth,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 10),
                    decoration: BoxDecoration(
                      color: randomColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: MyNetworkImage(
                            imagePath: cat.image ?? "",
                            fit: BoxFit.contain,
                            width: double.infinity,
                            radius: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        MyText(
                          text: cat.name ?? "",
                          color: black,
                          fontsize: Dimens.medium14TextSize,
                          maxline: 2,
                          fontwaight: FontWeight.w600,
                          textalign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          );
        });
      } else {
        return const NoData();
      }
    }
  }

  Widget categoryShimmer() {
    return LayoutBuilder(builder: (context, constraints) {
      final double maxWidth = constraints.maxWidth;

      const double spacing = 20;

      const double minItemWidth = 150;

      final int crossAxisCount =
          ((maxWidth + spacing) / (minItemWidth + spacing)).floor();

      final double cardWidth =
          (maxWidth - (crossAxisCount - 1) * spacing) / crossAxisCount;

      return SingleChildScrollView(
        scrollDirection: Axis.vertical,
        physics: const BouncingScrollPhysics(),
        child: Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.start,
          children: List.generate(12, (index) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomWidget.roundcorner(
                  width: cardWidth,
                  height: cardWidth,
                ),
                const SizedBox(height: 6),
                CustomWidget.roundrectborder(
                  width: cardWidth * 0.8,
                  height: 16,
                ),
              ],
            );
          }),
        ),
      );
    });
  }

  Widget square() {
    if (viewAllProvider.loading && !viewAllProvider.loadmore) {
      return squareShimmer();
    } else {
      if (viewAllProvider.bookList != null &&
          (viewAllProvider.bookList?.length ?? 0) > 0) {
        return ResponsiveGridList(
          minItemWidth: 160,
          minItemsPerRow: 2,
          maxItemsPerRow: 6,
          listViewBuilderOptions: ListViewBuilderOptions(
              shrinkWrap: true, physics: NeverScrollableScrollPhysics()),
          children: List.generate(
            viewAllProvider.bookList?.length ?? 0,
            (position) {
              final audio = viewAllProvider.bookList![position];
              final accessInfo = getAccessInfo(
                accessType: audio.accessType.toString(),
                isBuy: audio.isBuy.toString(),
                isSubscription: Constant.isSubscription ?? 0,
                price: audio.price?.toString(),
              );
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return WebDetails(
                        categoryId: audio.categoryId.toString(),
                        authorId: audio.authorId.toString(),
                        contentId: audio.id.toString(),
                        name: audio.title.toString(),
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
                  padding: const EdgeInsets.fromLTRB(6, 16, 6, 16),
                  decoration: BoxDecoration(
                    color: white,
                    border: Border.all(width: 1, color: gray),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InteractiveNetworkIcon(
                        imagePath: audio.portraitImg.toString(),
                        height: 243,
                        width: double.infinity,
                        iconFit: BoxFit.cover,
                        withBG: true,
                        bgColor: transparent,
                        bgHoverColor: transparent,
                      ),
                      const SizedBox(height: 6),
                      MyText(
                        color: colorPrimary,
                        text: audio.categoryName.toString(),
                        maxline: 2,
                        fontsize: Dimens.medium16TextSize,
                        fontwaight: FontWeight.w500,
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        text: audio.title.toString(),
                        fontsize: Dimens.medium16TextSize,
                        fontwaight: FontWeight.w500,
                        maxline: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        color: gray,
                        text: "By ${audio.authorName.toString()}",
                        fontsize: Dimens.medium14TextSize,
                        fontwaight: FontWeight.w400,
                        maxline: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          MyText(
                            text: audio.avgReviews.toString(),
                            fontsize: Dimens.medium14TextSize,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                          ),
                          const SizedBox(width: 5),
                          RatingBar.readOnly(
                            filledIcon: Icons.star,
                            emptyIcon: Icons.star_border,
                            initialRating:
                                double.tryParse(audio.avgReviews.toString()) ??
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
                                  "(${Utils.kmbGenerator(audio.totalReviews ?? 0)})",
                              fontsize: Dimens.medium14TextSize,
                              maxline: 1,
                              fontwaight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        text: accessInfo.priceText,
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
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget squareShimmer() {
    final double cardHeight =
        (MediaQuery.of(context).size.width > 800) ? 410 : 340;

    return ResponsiveGridList(
      minItemWidth: 160,
      minItemsPerRow: 2,
      maxItemsPerRow: (MediaQuery.of(context).size.width > 800) ? 6 : 3,
      listViewBuilderOptions: ListViewBuilderOptions(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
      ),
      children: List.generate(12, (index) {
        return Container(
          padding: (MediaQuery.of(context).size.width > 800)
              ? const EdgeInsets.fromLTRB(6, 16, 6, 16)
              : const EdgeInsets.fromLTRB(6, 12, 6, 12),
          width: (MediaQuery.of(context).size.width > 800) ? 200 : 160,
          height: cardHeight,
          decoration: BoxDecoration(
            color: white,
            border: Border.all(width: 1, color: gray, style: BorderStyle.solid),
            borderRadius: const BorderRadius.all(Radius.circular(0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomWidget.roundrectborder(
                height: (MediaQuery.of(context).size.width > 800) ? 243 : 200,
                width: double.infinity,
              ),

              const SizedBox(height: 6),

              CustomWidget.roundrectborder(
                  height: (MediaQuery.of(context).size.width > 800)
                      ? 16
                      : 12, // Dimens.medium16TextSize vs Dimens.medium12TextSize
                  width: 80),

              const SizedBox(height: 4),

              CustomWidget.roundrectborder(
                  height: (MediaQuery.of(context).size.width > 800)
                      ? 16
                      : 14, // Dimens.medium16TextSize vs Dimens.medium14TextSize
                  width: double.infinity),
              const SizedBox(height: 4),

              // ✅ Title Placeholder - Line 2 (Title maxline 2 છે, તેથી 2જી લાઇન ઉમેરી)
              CustomWidget.roundrectborder(
                  height: (MediaQuery.of(context).size.width > 800) ? 16 : 14,
                  width: 120),

              const SizedBox(height: 4),

              CustomWidget.roundrectborder(
                  height: (MediaQuery.of(context).size.width > 800)
                      ? 14
                      : 12, // Dimens.medium14TextSize vs Dimens.medium12TextSize
                  width: 100),

              const SizedBox(
                  height: 2), // Author Name અને Rating વચ્ચે 2નું SizedBox

              Row(
                children: [
                  CustomWidget.roundrectborder(
                      height: 12, width: 25), // Avg Reviews
                  const SizedBox(width: 5),
                  CustomWidget.roundrectborder(
                      height: 12, width: 50), // Rating stars
                  const SizedBox(width: 5),
                  const Expanded(
                    child: CustomWidget.roundrectborder(
                        height: 12), // Total Reviews count
                  ),
                ],
              ),

              const SizedBox(height: 4), // Rating અને Price વચ્ચે 4નું SizedBox

              CustomWidget.roundrectborder(
                  height: (MediaQuery.of(context).size.width > 800)
                      ? 18
                      : 16, // Dimens.medium18TextSize vs Dimens.medium16TextSize
                  width: 60),
            ],
          ),
        );
      }),
    );
  }

  // Protrait View Started
  Widget portrait() {
    if (viewAllProvider.loading && !viewAllProvider.loadmore) {
      return portShimmer();
    } else {
      if (viewAllProvider.bookList != null &&
          (viewAllProvider.bookList?.length ?? 0) > 0) {
        return ResponsiveGridList(
          minItemWidth: 140,
          minItemsPerRow: 3,
          maxItemsPerRow: 6,
          listViewBuilderOptions: ListViewBuilderOptions(
              shrinkWrap: true, physics: NeverScrollableScrollPhysics()),
          children: List.generate(
            viewAllProvider.bookList?.length ?? 0,
            (position) {
              final book = viewAllProvider.bookList?[position];
              final accessInfo = getAccessInfo(
                accessType: book?.accessType.toString(),
                isBuy: book?.isBuy.toString(),
                isSubscription: Constant.isSubscription ?? 0,
                price: book?.price?.toString(),
              );
              return InkWell(
                splashColor: transparent,
                focusColor: transparent,
                hoverColor: transparent,
                highlightColor: transparent,
                onTap: () {
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return WebDetails(
                        contentId: book?.id.toString(),
                        authorId: book?.authorId.toString() ?? "",
                        categoryId: book?.categoryId.toString(),
                        name: book?.title.toString(),
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
                  width: 185,
                  padding: (MediaQuery.of(context).size.width > 800)
                      ? const EdgeInsets.fromLTRB(6, 16, 6, 16)
                      : const EdgeInsets.fromLTRB(8, 12, 8, 12),
                  decoration: BoxDecoration(
                    color: white,
                    border: Border.all(
                        width: 1, color: gray, style: BorderStyle.solid),
                    borderRadius: const BorderRadius.all(Radius.circular(0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 3 / 4,
                        child: MyNetworkImage(
                          imagePath: book?.portraitImg.toString() ?? "",
                          radius: 0,
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      MyText(
                        color: colorPrimary,
                        text: book?.categoryName.toString() ?? "",
                        fontsize: Dimens.medium14TextSize,
                        maxline: 1,
                        fontwaight: FontWeight.w500,
                        textalign: TextAlign.start,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(height: 2),
                      MyText(
                        text: book?.title.toString() ?? "",
                        fontsize: Dimens.medium16TextSize,
                        maxline: 2,
                        fontwaight: FontWeight.w500,
                        textalign: TextAlign.start,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(height: 2),
                      MyText(
                        color: gray,
                        text: "By ${book?.authorName.toString() ?? ""}",
                        fontsize: Dimens.medium14TextSize,
                        maxline: 1,
                        fontwaight: FontWeight.w400,
                        textalign: TextAlign.start,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          MyText(
                            text: book?.avgReviews.toString() ?? "",
                            fontsize: Dimens.medium12TextSize,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                          ),
                          const SizedBox(width: 5),
                          RatingBar.readOnly(
                            filledIcon: Icons.star,
                            emptyIcon: Icons.star_border,
                            initialRating: double.parse(
                                book?.avgReviews.toString() ?? "0"),
                            emptyColor: gray,
                            filledColor: colorPrimary,
                            maxRating: 5,
                            size: 10,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: MyText(
                              text:
                                  "(${Utils.kmbGenerator(book?.totalReviews ?? 0)})",
                              fontsize: Dimens.medium12TextSize,
                              maxline: 1,
                              fontwaight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      MyText(
                        text: accessInfo.priceText,
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
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget horizontalView() {
    if (viewAllProvider.loading && !viewAllProvider.loadmore) {
      return shimmer();
    } else {
      if (viewAllProvider.bookList != null &&
          (viewAllProvider.bookList?.length ?? 0) > 0) {
        return ResponsiveGridList(
            minItemWidth: 140,
            minItemsPerRow: 2,
            maxItemsPerRow: 4,
            listViewBuilderOptions: ListViewBuilderOptions(
                shrinkWrap: true, physics: NeverScrollableScrollPhysics()),
            children: List.generate(
              viewAllProvider.bookList?.length ?? 0,
              (position) {
                final book = viewAllProvider.bookList![position];
                final accessInfo = getAccessInfo(
                  accessType: book.accessType.toString(),
                  isBuy: book.isBuy.toString(),
                  isSubscription: Constant.isSubscription ?? 0,
                  price: book.price?.toString(),
                );

                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return WebDetails(
                          contentId: book.id.toString(),
                          authorId: book.authorId.toString(),
                          categoryId: book.categoryId.toString(),
                          name: book.title.toString(),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InteractiveNetworkIcon(
                        imagePath: book.portraitImg.toString(),
                        height: 200,
                        iconFit: BoxFit.cover,
                        withBG: true,
                        bgColor: transparent,
                        bgHoverColor: transparent,
                        width: MediaQuery.sizeOf(context).width,
                        bgRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16)),
                      ),
                      const SizedBox(height: 4),

                      MyText(
                        text: book.title.toString(),
                        fontsize: Dimens.medium18TextSize,
                        maxline: 3,
                        fontwaight: FontWeight.w500,
                        textalign: TextAlign.start,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(height: 4),

                      MyText(
                        text: book.categoryName.toString(),
                        fontsize: Dimens.medium18TextSize,
                        maxline: 3,
                        color: colorPrimary,
                        fontwaight: FontWeight.w500,
                        textalign: TextAlign.start,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(height: 4),

                      MyText(
                        text: "By ${book.authorName.toString()}",
                        fontsize: Dimens.medium16TextSize,
                        maxline: 2,
                        color: colorPrimary,
                        fontwaight: FontWeight.w400,
                        textalign: TextAlign.start,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(height: 4),

                      // Rating Row
                      Row(
                        children: [
                          MyText(
                            text: book.avgReviews.toString(),
                            fontsize: Dimens.medium12TextSize,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                          ),
                          const SizedBox(width: 5),
                          RatingBar.readOnly(
                            filledIcon: Icons.star,
                            emptyIcon: Icons.star_border,
                            initialRating:
                                double.tryParse(book.avgReviews.toString()) ??
                                    0.0,
                            emptyColor: gray,
                            filledColor: colorPrimary,
                            maxRating: 5,
                            size: 10,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: MyText(
                              text:
                                  "(${Utils.kmbGenerator(book.totalReviews ?? 0)})",
                              fontsize: Dimens.medium12TextSize,
                              maxline: 1,
                              fontwaight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      MyText(
                        text: accessInfo.priceText,
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
                );
              },
            ));
      } else {
        return const NoData();
      }
    }
  }

  Widget portShimmer() {
    return ResponsiveGridList(
      minItemWidth: 140,
      minItemsPerRow: 3,
      maxItemsPerRow: 6,
      listViewBuilderOptions: ListViewBuilderOptions(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
      ),
      children: List.generate(12, (index) {
        return Container(
          padding: (MediaQuery.of(context).size.width > 800)
              ? const EdgeInsets.fromLTRB(6, 16, 6, 16)
              : const EdgeInsets.fromLTRB(8, 12, 8, 12),
          decoration: BoxDecoration(
            color: white,
            border: Border.all(width: 1, color: gray, style: BorderStyle.solid),
            borderRadius: const BorderRadius.all(Radius.circular(0)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              AspectRatio(
                aspectRatio: 3 / 4,
                child: CustomWidget.roundcorner(height: double.infinity),
              ),

              SizedBox(height: 8), // Gap after image

              CustomWidget.roundrectborder(height: 14, width: 70),

              SizedBox(height: 2),

              CustomWidget.roundrectborder(height: 16, width: double.infinity),
              SizedBox(height: 4),
              CustomWidget.roundrectborder(height: 16, width: double.infinity),

              SizedBox(height: 4),
              CustomWidget.roundrectborder(height: 14, width: 100),

              SizedBox(height: 4),
              Row(
                children: [
                  CustomWidget.roundrectborder(height: 12, width: 25),
                  SizedBox(width: 5),
                  CustomWidget.roundrectborder(height: 12, width: 50),
                  SizedBox(width: 5),
                  Expanded(
                    child: CustomWidget.roundrectborder(height: 12),
                  ),
                ],
              ),

              SizedBox(height: 6),

              // ✅ Price Shimmer (bold text)
              CustomWidget.roundrectborder(height: 18, width: 60),
            ],
          ),
        );
      }),
    );
  }

  Widget shimmer() {
    return ResponsiveGridList(
      minItemWidth: 140,
      minItemsPerRow: 2,
      maxItemsPerRow: 4,
      listViewBuilderOptions: ListViewBuilderOptions(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
      ),
      children: List.generate(8, (index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            CustomWidget.roundrectborder(
              height: 200,
            ),
            SizedBox(height: 4),

            CustomWidget.roundrectborder(
              height: 18,
              width: double.infinity,
            ),
            SizedBox(height: 4),
            CustomWidget.roundrectborder(
              height: 18,
              width: 150,
            ),

            SizedBox(height: 4), // Spacing adjusted

            CustomWidget.roundrectborder(
              height: 18,
              width: 100,
            ),

            SizedBox(height: 4), // Spacing adjusted

            CustomWidget.roundrectborder(
              height: 16,
              width: 80,
            ),

            SizedBox(height: 4), // Spacing adjusted

            Row(
              children: [
                CustomWidget.roundrectborder(
                    height: 12, width: 25), // Avg reviews text
                SizedBox(width: 5),
                CustomWidget.roundrectborder(height: 12, width: 50), // Stars
                SizedBox(width: 5),
                Expanded(
                  child: CustomWidget.roundrectborder(
                      height: 12), // Total reviews count
                ),
              ],
            ),

            SizedBox(height: 6),

            CustomWidget.roundrectborder(
              height: 18, // Increased height for larger/bolder price
              width: 60,
            ),
          ],
        );
      }),
    );
  }

  Widget portraitviewAudio() {
    if (viewAllProvider.loading && !viewAllProvider.loadmore) {
      return portShimmer();
    } else {
      if (viewAllProvider.bookList != null &&
          (viewAllProvider.audioList?.length ?? 0) > 0) {
        return ResponsiveGridList(
          minItemWidth: 140,
          minItemsPerRow: 3,
          maxItemsPerRow: 6,
          listViewBuilderOptions: ListViewBuilderOptions(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
          ),
          children: List.generate(
            viewAllProvider.audioList?.length ?? 0,
            (position) {
              final audio = viewAllProvider.audioList?[position];
              final accessInfo = getAccessInfo(
                accessType: audio?.accessType.toString(),
                isBuy: audio?.isBuy.toString(),
                isSubscription: Constant.isSubscription ?? 0,
                price: audio?.price?.toString(),
              );

              return InkWell(
                splashColor: transparent,
                focusColor: transparent,
                hoverColor: transparent,
                highlightColor: transparent,
                onTap: () {
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return WebAudioBookDetails(
                        categoryId: audio?.categoryId.toString() ?? "",
                        authorId: audio?.authorId.toString(),
                        contentId: audio?.id.toString() ?? "",
                        name: audio?.title.toString() ?? "",
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
                  padding: (MediaQuery.of(context).size.width > 800)
                      ? const EdgeInsets.fromLTRB(6, 16, 6, 16)
                      : const EdgeInsets.fromLTRB(8, 12, 8, 12),
                  decoration: BoxDecoration(
                    color: white,
                    border: Border.all(
                        width: 1, color: gray, style: BorderStyle.solid),
                    borderRadius: const BorderRadius.all(Radius.circular(0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 3 / 4,
                        child: MyNetworkImage(
                          imagePath: audio?.portraitImg.toString() ?? "",
                          radius: 0,
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 8), // Spacing from portrait()

                      MyText(
                        color: colorPrimary,
                        text: audio?.categoryName ?? "",
                        fontsize: Dimens.medium14TextSize,
                        maxline: 1,
                        fontwaight: FontWeight.w500,
                        textalign: TextAlign.start,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(height: 2),

                      MyText(
                        text: audio?.title ?? "",
                        fontsize: Dimens.medium16TextSize,
                        maxline: 2,
                        fontwaight: FontWeight.w500,
                        textalign: TextAlign.start,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(height: 2),
                      MyText(
                        color: gray, // Color changed to gray as in portrait()
                        text: "By ${audio?.authorName ?? ""}",
                        fontsize: Dimens.medium14TextSize,
                        maxline: 1,
                        fontwaight: FontWeight.w400,
                        textalign: TextAlign.start,
                      ),
                      const SizedBox(height: 4), // Spacing from portrait()

                      Row(
                        children: [
                          MyText(
                            text: audio?.avgReviews.toString() ?? "0",
                            fontsize: Dimens
                                .medium12TextSize, // Used Dimens.medium12TextSize
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                          ),
                          const SizedBox(width: 5),
                          RatingBar.readOnly(
                            filledIcon: Icons.star,
                            emptyIcon: Icons.star_border,
                            initialRating: double.tryParse(
                                    audio?.avgReviews.toString() ?? "0") ??
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
                                  "(${Utils.kmbGenerator(audio?.totalReviews ?? 0)})",
                              fontsize: Dimens.medium12TextSize,
                              maxline: 1,
                              fontwaight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      MyText(
                        text: accessInfo.priceText,
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
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget horizontalviewAudio() {
    if (viewAllProvider.loading && !viewAllProvider.loadmore) {
      return shimmer();
    } else {
      if (viewAllProvider.audioList != null &&
          (viewAllProvider.audioList?.length ?? 0) > 0) {
        return ResponsiveGridList(
            minItemWidth: 140,
            minItemsPerRow: 2,
            maxItemsPerRow: 4,
            listViewBuilderOptions: ListViewBuilderOptions(
                shrinkWrap: true, physics: NeverScrollableScrollPhysics()),
            children: List.generate(
              viewAllProvider.audioList?.length ?? 0,
              (position) {
                final audio = viewAllProvider.audioList?[position];
                final accessInfo = getAccessInfo(
                  accessType: audio?.accessType.toString(),
                  isBuy: audio?.isBuy.toString(),
                  isSubscription: Constant.isSubscription ?? 0,
                  price: audio?.price?.toString(),
                );

                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return WebAudioBookDetails(
                          categoryId: audio.categoryId.toString(),
                          authorId: audio.authorId.toString(),
                          contentId: audio.id.toString(),
                          name: audio.title.toString(),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InteractiveNetworkIcon(
                        imagePath: audio?.portraitImg.toString() ?? "",
                        height: 200,
                        iconFit: BoxFit.cover,
                        withBG: true,
                        bgColor: transparent,
                        bgHoverColor: transparent,
                        width: MediaQuery.sizeOf(context).width,
                        bgRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16)),
                      ),
                      const SizedBox(height: 4),

                      MyText(
                        text: audio?.title.toString() ?? "",
                        fontsize: Dimens.medium18TextSize,
                        maxline: 3,
                        fontwaight: FontWeight.w500,
                        textalign: TextAlign.start,
                        fontstyle: FontStyle.normal, // Italic દૂર કર્યું
                      ),
                      const SizedBox(height: 4),

                      MyText(
                        text: audio?.categoryName.toString() ?? "",
                        fontsize: Dimens.medium18TextSize,
                        maxline: 3,
                        color: colorPrimary, // કલર ઉમેર્યો
                        fontwaight: FontWeight.w500,
                        textalign: TextAlign.start,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(height: 4),

                      MyText(
                        text: "By ${audio?.authorName.toString()}",
                        fontsize: Dimens.medium16TextSize,
                        maxline: 2,
                        color: colorPrimary, // કલર ઉમેર્યો
                        fontwaight: FontWeight.w400,
                        textalign: TextAlign.start,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(height: 4),

                      // Rating Row
                      Row(
                        children: [
                          MyText(
                            text: audio?.avgReviews.toString() ?? "",
                            fontsize: Dimens.medium12TextSize,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                          ),
                          const SizedBox(width: 5),
                          RatingBar.readOnly(
                            filledIcon: Icons.star,
                            emptyIcon: Icons.star_border,
                            initialRating:
                                double.tryParse(audio!.avgReviews.toString()) ??
                                    0.0,
                            emptyColor: gray,
                            filledColor: colorPrimary,
                            maxRating: 5,
                            size: 10,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: MyText(
                              text:
                                  "(${Utils.kmbGenerator(audio.totalReviews ?? 0)})",
                              fontsize: Dimens.medium12TextSize,
                              maxline: 1,
                              fontwaight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      MyText(
                        text: accessInfo.priceText,
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
                );
              },
            ));
      } else {
        return const NoData();
      }
    }
  }

  Widget squareAudio() {
    if (viewAllProvider.loading && !viewAllProvider.loadmore) {
      return squareShimmer();
    } else {
      if (viewAllProvider.audioList != null &&
          (viewAllProvider.audioList?.length ?? 0) > 0) {
        return ResponsiveGridList(
          minItemWidth: 160,
          minItemsPerRow: 2,
          maxItemsPerRow: 6,
          listViewBuilderOptions: ListViewBuilderOptions(
              shrinkWrap: true, physics: NeverScrollableScrollPhysics()),
          children: List.generate(
            viewAllProvider.audioList?.length ?? 0,
            (position) {
              final audio = viewAllProvider.audioList![position];
              final accessInfo = getAccessInfo(
                accessType: audio.accessType.toString(),
                isBuy: audio.isBuy.toString(),
                isSubscription: Constant.isSubscription ?? 0,
                price: audio.price?.toString(),
              );
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return WebAudioBookDetails(
                        categoryId: audio.categoryId.toString(),
                        authorId: audio.authorId.toString(),
                        contentId: audio.id.toString(),
                        name: audio.title.toString(),
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
                  padding: const EdgeInsets.fromLTRB(6, 16, 6, 16),
                  decoration: BoxDecoration(
                    color: white,
                    border: Border.all(width: 1, color: gray),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InteractiveNetworkIcon(
                        imagePath: audio.portraitImg.toString(),
                        height: 243,
                        width: double.infinity,
                        iconFit: BoxFit.cover,
                        withBG: true,
                        bgColor: transparent,
                        bgHoverColor: transparent,
                      ),
                      const SizedBox(height: 6),
                      MyText(
                        color: colorPrimary,
                        text: audio.categoryName.toString(),
                        maxline: 2,
                        fontsize: Dimens.medium16TextSize, // Font size matched
                        fontwaight: FontWeight.w500,
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        text: audio.title.toString(),
                        fontsize: Dimens.medium16TextSize,
                        fontwaight: FontWeight.w500,
                        maxline: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        color: gray, // Color matched
                        text: "By ${audio.authorName.toString()}",
                        fontsize: Dimens.medium14TextSize,
                        fontwaight: FontWeight.w400,
                        maxline: 2, // Maxline matched
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          MyText(
                            text: audio.avgReviews.toString(),
                            fontsize:
                                Dimens.medium14TextSize, // Font size matched
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                          ),
                          const SizedBox(width: 5),
                          RatingBar.readOnly(
                            filledIcon: Icons.star,
                            emptyIcon: Icons.star_border,
                            initialRating:
                                double.tryParse(audio.avgReviews.toString()) ??
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
                                  "(${Utils.kmbGenerator(audio.totalReviews ?? 0)})",
                              fontsize:
                                  Dimens.medium14TextSize, // Font size matched
                              maxline: 1,
                              fontwaight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        text: accessInfo.priceText,
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
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget portraitMagazine() {
    if (viewAllProvider.loading && !viewAllProvider.loadmore) {
      return portShimmer();
    } else {
      if (viewAllProvider.magazineList != null &&
          (viewAllProvider.magazineList?.length ?? 0) > 0) {
        return ResponsiveGridList(
          minItemWidth: 140,
          minItemsPerRow: 3,
          maxItemsPerRow: 6,
          listViewBuilderOptions: ListViewBuilderOptions(
              shrinkWrap: true, physics: NeverScrollableScrollPhysics()),
          children: List.generate(
            viewAllProvider.magazineList?.length ?? 0,
            (position) {
              final magazine = viewAllProvider.magazineList![position];
              final accessInfo = getAccessInfo(
                accessType: magazine.accessType.toString(),
                isBuy: magazine.isBuy.toString(),
                isSubscription: Constant.isSubscription ?? 0,
                price: magazine.price?.toString(),
              );
              return InkWell(
                splashColor: transparent,
                focusColor: transparent,
                hoverColor: transparent,
                highlightColor: transparent,
                onTap: () {
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return WebMagazineDetails(
                        contentId: magazine.id.toString(),
                        categoryId: magazine.categoryId.toString(),
                        name: magazine.title.toString(),
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
                  padding: (MediaQuery.of(context).size.width > 800)
                      ? const EdgeInsets.fromLTRB(6, 16, 6, 16)
                      : const EdgeInsets.fromLTRB(8, 12, 8, 12),
                  decoration: BoxDecoration(
                    color: white,
                    border: Border.all(
                        width: 1, color: gray, style: BorderStyle.solid),
                    borderRadius: const BorderRadius.all(Radius.circular(0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AspectRatio(
                        aspectRatio: 3 / 4,
                        child: MyNetworkImage(
                          imagePath: magazine.portraitImg.toString(),
                          radius: 0,
                          height: double.infinity,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      MyText(
                        color: colorPrimary,
                        text: magazine.categoryName.toString(),
                        fontsize: Dimens.medium14TextSize,
                        maxline: 1,
                        fontwaight: FontWeight.w500,
                        textalign: TextAlign.start,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(height: 2),
                      MyText(
                        text: magazine.title.toString(),
                        fontsize: Dimens.medium16TextSize,
                        maxline: 2,
                        fontwaight: FontWeight.w500,
                        textalign: TextAlign.start,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(height: 2),
                      MyText(
                        color: gray,
                        text: "By ${magazine.authorName.toString()}",
                        fontsize: Dimens.medium14TextSize,
                        maxline: 1,
                        fontwaight: FontWeight.w400,
                        textalign: TextAlign.start,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          MyText(
                            text: magazine.avgReviews.toString(),
                            fontsize: Dimens.medium12TextSize,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                          ),
                          const SizedBox(width: 5),
                          RatingBar.readOnly(
                            filledIcon: Icons.star,
                            emptyIcon: Icons.star_border,
                            initialRating: double.tryParse(
                                    magazine.avgReviews.toString()) ??
                                0.0,
                            emptyColor: gray,
                            filledColor: colorPrimary,
                            maxRating: 5,
                            size: 10,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: MyText(
                              text:
                                  "(${Utils.kmbGenerator(magazine.totalReviews ?? 0)})",
                              fontsize: Dimens.medium12TextSize,
                              maxline: 1,
                              fontwaight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      MyText(
                        text: accessInfo.priceText,
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
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget horizontalViewMagazine() {
    if (viewAllProvider.loading && !viewAllProvider.loadmore) {
      return shimmer();
    } else {
      if (viewAllProvider.magazineList != null &&
          (viewAllProvider.magazineList?.length ?? 0) > 0) {
        return ResponsiveGridList(
            minItemWidth: 140,
            minItemsPerRow: 2,
            maxItemsPerRow: 4,
            listViewBuilderOptions: ListViewBuilderOptions(
                shrinkWrap: true, physics: NeverScrollableScrollPhysics()),
            children: List.generate(
              viewAllProvider.magazineList?.length ?? 0,
              (position) {
                final magazine = viewAllProvider.magazineList![position];
                final accessInfo = getAccessInfo(
                  accessType: magazine.accessType.toString(),
                  isBuy: magazine.isBuy.toString(),
                  isSubscription: Constant.isSubscription ?? 0,
                  price: magazine.price?.toString(),
                );

                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return WebMagazineDetails(
                          contentId: magazine.id.toString(),
                          categoryId: magazine.categoryId.toString(),
                          name: magazine.title.toString(),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ✅ InteractiveNetworkIcon નો ઉપયોગ MyNetworkImage ને બદલે
                      InteractiveNetworkIcon(
                        imagePath: magazine.portraitImg.toString(),
                        height: 200,
                        iconFit: BoxFit.cover,
                        withBG: true,
                        bgColor: transparent,
                        bgHoverColor: transparent,
                        width: MediaQuery.sizeOf(context).width,
                        bgRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16)),
                      ),
                      const SizedBox(
                          height: 4), // ✅ Spacing 7 થી ઘટાડીને 4 કર્યું

                      MyText(
                        text: magazine.title.toString(),
                        fontsize: Dimens.medium18TextSize,
                        maxline: 3,
                        fontwaight: FontWeight.w500,
                        textalign: TextAlign.start,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(height: 4),

                      MyText(
                        text: magazine.categoryName.toString(),
                        fontsize: Dimens.medium18TextSize,
                        maxline: 3,
                        color: colorPrimary, // કલર ઉમેર્યો
                        fontwaight: FontWeight.w500,
                        textalign: TextAlign.start,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        text: "By ${magazine.authorName.toString()}",
                        fontsize: Dimens.medium16TextSize,
                        maxline: 2,
                        color: colorPrimary, // કલર ઉમેર્યો
                        fontwaight: FontWeight.w400,
                        textalign: TextAlign.start,
                        fontstyle: FontStyle.normal,
                      ),
                      const SizedBox(
                          height: 4), // ✅ Spacing 2 થી વધારીને 4 કર્યું

                      Row(
                        children: [
                          MyText(
                            text: magazine.avgReviews.toString(),
                            fontsize: Dimens.medium12TextSize,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                          ),
                          const SizedBox(width: 5),
                          RatingBar.readOnly(
                            filledIcon: Icons.star,
                            emptyIcon: Icons.star_border,
                            initialRating: double.tryParse(
                                    magazine.avgReviews.toString()) ??
                                0.0,
                            emptyColor: gray,
                            filledColor: colorPrimary,
                            maxRating: 5,
                            size: 10,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: MyText(
                              text:
                                  "(${Utils.kmbGenerator(magazine.totalReviews ?? 0)})",
                              fontsize: Dimens.medium12TextSize,
                              maxline: 1,
                              fontwaight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // ✅ Price/Free Text - સ્ટાઇલ મેચ કરી
                      MyText(
                        text: accessInfo.priceText,
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
                );
              },
            ));
      } else {
        return const NoData();
      }
    }
  }

  Widget squareMagazine() {
    if (viewAllProvider.loading && !viewAllProvider.loadmore) {
      return squareShimmer();
    } else {
      if (viewAllProvider.magazineList != null &&
          (viewAllProvider.magazineList?.length ?? 0) > 0) {
        return ResponsiveGridList(
          minItemWidth: 160, // UI સ્ટાઇલ મેચ કરવા માટે minItemWidth સેટ કર્યું
          minItemsPerRow: 2,
          maxItemsPerRow: 6,
          listViewBuilderOptions: ListViewBuilderOptions(
              shrinkWrap: true, physics: NeverScrollableScrollPhysics()),
          children: List.generate(
            viewAllProvider.magazineList?.length ?? 0,
            (position) {
              final magazine = viewAllProvider.magazineList![position];
              final accessInfo = getAccessInfo(
                accessType: magazine.accessType.toString(),
                isBuy: magazine.isBuy.toString(),
                isSubscription: Constant.isSubscription ?? 0,
                price: magazine.price?.toString(),
              );
              return InkWell(
                onTap: () {
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return WebMagazineDetails(
                        contentId: magazine.id.toString(),
                        categoryId: magazine.categoryId.toString(),
                        name: magazine.title.toString(),
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
                  padding: const EdgeInsets.fromLTRB(6, 16, 6, 16),
                  decoration: BoxDecoration(
                    color: white,
                    border: Border.all(width: 1, color: gray),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InteractiveNetworkIcon(
                        imagePath: magazine.portraitImg.toString(),
                        height: 243, // Height matched
                        width: double.infinity,
                        iconFit: BoxFit.cover,
                        withBG: true,
                        bgColor: transparent,
                        bgHoverColor: transparent,
                      ),
                      const SizedBox(height: 6),
                      MyText(
                        color: colorPrimary,
                        text: magazine.categoryName.toString(),
                        maxline: 2,
                        fontsize: Dimens.medium16TextSize,
                        fontwaight: FontWeight.w500,
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        text: magazine.title.toString(),
                        fontsize: Dimens.medium16TextSize,
                        fontwaight: FontWeight.w500,
                        maxline: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        color: gray, // Color matched
                        text: "By ${magazine.authorName.toString()}",
                        fontsize: Dimens.medium14TextSize,
                        fontwaight: FontWeight.w400,
                        maxline: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Row(
                        children: [
                          MyText(
                            text: magazine.avgReviews.toString(),
                            fontsize: Dimens.medium14TextSize,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                          ),
                          const SizedBox(width: 5),
                          RatingBar.readOnly(
                            filledIcon: Icons.star,
                            emptyIcon: Icons.star_border,
                            initialRating: double.tryParse(
                                    magazine.avgReviews.toString()) ??
                                0.0,
                            emptyColor: gray,
                            filledColor: colorPrimary,
                            maxRating: 5,
                            size: 10,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: MyText(
                              text:
                                  "(${Utils.kmbGenerator(magazine.totalReviews ?? 0)})",
                              fontsize: Dimens.medium14TextSize,
                              maxline: 1,
                              fontwaight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        text: accessInfo.priceText,
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
        );
      } else {
        return const NoData();
      }
    }
  }
// END
}
