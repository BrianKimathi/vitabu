import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:yourappname/pages/audiobookdetails.dart';
import 'package:yourappname/pages/bookdetails.dart';
import 'package:yourappname/pages/magazinedetails.dart';
import 'package:yourappname/provider/categorywisedataprovider.dart';
import 'package:yourappname/provider/themeprovider.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class CategoryWiseData extends StatefulWidget {
  final String? catagoryid;
  final String? catagoryname;
  const CategoryWiseData(
      {super.key, required this.catagoryid, required this.catagoryname});

  @override
  State<CategoryWiseData> createState() => _CategoryWiseDataState();
}

class _CategoryWiseDataState extends State<CategoryWiseData> {
  final ScrollController _scrollController = ScrollController();
  late CategoryWiseDataProvider categoryWiseDataProvider;

  @override
  void initState() {
    categoryWiseDataProvider =
        Provider.of<CategoryWiseDataProvider>(context, listen: false);
    _scrollController.addListener(_bookScrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData(categoryWiseDataProvider.currentIndex, 0);
    });
    super.initState();
  }

  _bookScrollListener() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (categoryWiseDataProvider.isMorePage ?? false) &&
        (categoryWiseDataProvider.currentPage ?? 0) <
            (categoryWiseDataProvider.totalPage ?? 0)) {
      categoryWiseDataProvider.setLoadMore(true);
      _fetchData(categoryWiseDataProvider.currentIndex,
          categoryWiseDataProvider.currentPage ?? 0);
    }
  }

  _fetchData(type, int? nextPage) {
    categoryWiseDataProvider.setLoading(true);
    if (type == "1") {
      categoryWiseDataProvider.getSectionAudio(
          type, widget.catagoryid, (nextPage ?? 0) + 1);
    } else if (type == "2") {
      categoryWiseDataProvider.getSectionBook(
          type, widget.catagoryid, (nextPage ?? 0) + 1);
    } else {
      categoryWiseDataProvider.getSectionMagazine(
          type, widget.catagoryid, (nextPage ?? 0) + 1);
    }
  }

  @override
  void dispose() {
    categoryWiseDataProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: transparent,
        title: MyText(
          text: "${widget.catagoryname}",
          fontsize: Dimens.largeTextSize,
          fontwaight: FontWeight.w700,
        ),
        leading: Utils.backButton(context),
      ),
      body: Consumer<CategoryWiseDataProvider>(
          builder: (context, bookProvider, child) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 15, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTab(),
              const SizedBox(height: 10),
              Expanded(child: _buildTabbarData()),
              if (bookProvider.loadMore)
                Utils.pageLoader(context)
              else
                const SizedBox.shrink(),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  // New Tab bar Started
  Widget _buildTab() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _titleBuild("2", FontAwesomeIcons.book, "books", () {
              categoryWiseDataProvider.setTab("2");
              categoryWiseDataProvider.clearData();
              _fetchData(categoryWiseDataProvider.currentIndex, 0);
            }),
            _titleBuild("3", FontAwesomeIcons.newspaper, "magazines", () {
              categoryWiseDataProvider.setTab("3");
              categoryWiseDataProvider.clearData();
              _fetchData(categoryWiseDataProvider.currentIndex, 0);
            }),
            _titleBuild("1", Icons.audio_file_rounded, "audio_book", () {
              categoryWiseDataProvider.setTab("1");
              categoryWiseDataProvider.clearData();
              _fetchData(categoryWiseDataProvider.currentIndex, 0);
            }),
          ],
        ));
  }

  Widget _titleBuild(index, iconData, title, onTap) {
    return Consumer<ThemeProvider>(builder: (context, themeProvider, child) {
      return InkWell(
        splashColor: transparent,
        hoverColor: transparent,
        focusColor: transparent,
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(right: 10),
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
              color: Constant.isDarkMode
                  ? categoryWiseDataProvider.currentIndex == index
                      ? colorPrimaryDark
                      : transparent
                  : categoryWiseDataProvider.currentIndex == index
                      ? colorPrimary
                      : transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                width: 1,
                style: BorderStyle.solid,
                color: Constant.isDarkMode
                    ? categoryWiseDataProvider.currentIndex == index
                        ? colorPrimary
                        : gray
                    : colorPrimary,
              )),
          child: Row(
            children: [
              Icon(
                color: Constant.isDarkMode
                    ? categoryWiseDataProvider.currentIndex == index
                        ? colorPrimary
                        : white
                    : categoryWiseDataProvider.currentIndex == index
                        ? white
                        : black,
                iconData,
                size: 16,
              ),
              SizedBox(width: 6),
              MyText(
                color: Constant.isDarkMode
                    ? categoryWiseDataProvider.currentIndex == index
                        ? colorPrimary
                        : white
                    : categoryWiseDataProvider.currentIndex == index
                        ? white
                        : black,
                text: title,
                multilanguage: true,
                fontwaight: FontWeight.w500,
                fontsize: Dimens.medium14TextSize,
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTabbarData() {
    if (categoryWiseDataProvider.loading &&
        !categoryWiseDataProvider.loadMore) {
      return autherShimmer();
    } else {
      return categoryWiseDataProvider.currentIndex == "1"
          ? _buildAudio()
          : categoryWiseDataProvider.currentIndex == "2"
              ? _buildBoook()
              : _buildMagazine();
    }
  }

  Widget _buildAudio() {
    if (categoryWiseDataProvider.audioList != null &&
        (categoryWiseDataProvider.audioList?.length ?? 0) > 0) {
      return SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(top: 12),
        physics: BouncingScrollPhysics(),
        child: _buildCommanWidget(categoryWiseDataProvider.audioList ?? []),
      );
    } else {
      return NoData();
    }
  }

  Widget _buildBoook() {
    if (categoryWiseDataProvider.bookList != null &&
        (categoryWiseDataProvider.bookList?.length ?? 0) > 0) {
      return SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(top: 12),
        physics: BouncingScrollPhysics(),
        child: _buildCommanWidget(categoryWiseDataProvider.bookList ?? []),
      );
    } else {
      return NoData();
    }
  }

  Widget _buildMagazine() {
    if (categoryWiseDataProvider.magazineList != null &&
        (categoryWiseDataProvider.magazineList?.length ?? 0) > 0) {
      return SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(top: 12),
        physics: BouncingScrollPhysics(),
        child: _buildCommanWidget(categoryWiseDataProvider.magazineList ?? []),
      );
    } else {
      return NoData();
    }
  }

  Widget _buildCommanWidget(commanList) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ResponsiveGridList(
        minItemWidth: 140,
        minItemsPerRow: 2,
        maxItemsPerRow: 5,
        listViewBuilderOptions: ListViewBuilderOptions(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics()),
        children: List.generate(
          commanList?.length ?? 0,
          (index) {
            final bookDataList = commanList?[index];
            final accessInfo = getAccessInfo(
              accessType: bookDataList?.accessType.toString(),
              isBuy: bookDataList?.isBuy.toString(),
              isSubscription: Constant.isSubscription ?? 0,
              price: bookDataList?.price?.toString(),
            );

            return Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  if (categoryWiseDataProvider.currentIndex == "1") {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) {
                            return AudioBookDetails(
                              contentId: bookDataList?.id.toString(),
                              authorId: bookDataList?.authorId.toString(),
                              categoryId: bookDataList?.categoryId.toString(),
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
                  } else if (categoryWiseDataProvider.currentIndex == "2") {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) {
                            return BookDetails(
                              contentId: bookDataList?.id.toString(),
                              authorId: bookDataList?.authorId.toString(),
                              categoryId: bookDataList?.categoryId.toString(),
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
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) {
                            return MagazineDetails(
                              contentId: bookDataList?.id.toString(),
                              categoryId: bookDataList?.categoryId.toString(),
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
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: MyNetworkImage(
                            imagePath: bookDataList?.portraitImg.toString() ?? "",
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: accessInfo.badgeBg.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Text(
                              accessInfo.badgeLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: accessInfo.badgeTextColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            bookDataList?.title.toString() ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "By ${bookDataList?.authorName.toString() ?? ''}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 3),
                              Text(
                                bookDataList?.avgReviews.toString() ?? "0.0",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.grey[300] : const Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "(${Utils.kmbGenerator(bookDataList?.totalReviews ?? 0)})",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isDark ? Colors.grey[500] : const Color(0xFF9CA3AF),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                accessInfo.priceText,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: accessInfo.priceText == "Free" ? Colors.green : colorPrimary,
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
            );
          },
        ));
  }

  Widget autherShimmer() {
    return AlignedGridView.count(
      crossAxisCount: 3,
      itemCount: 25,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      addRepaintBoundaries: true,
      addAutomaticKeepAlives: true,
      itemBuilder: (context, index) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomWidget.roundrectborder(
                height: 120, width: MediaQuery.sizeOf(context).width),
            SizedBox(height: 5),
            CustomWidget.roundrectborder(height: 16, width: 120),
            SizedBox(height: 5),
            Row(children: [
              CustomWidget.circular(height: 20, width: 20),
              Expanded(
                  child: CustomWidget.roundrectborder(height: 15, width: 50))
            ]),
            SizedBox(height: 5),
            CustomWidget.roundrectborder(height: 20, width: 120),
          ],
        );
      },
    );
  }
}
