import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:yourappname/provider/categorywisedataprovider.dart';
import 'package:yourappname/provider/themeprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webpages/webaudiobookdetails.dart';
import 'package:yourappname/webpages/webdetails.dart';
import 'package:yourappname/webpages/webmagazinedetails.dart' hide SizedBox, Container, Row;
import 'package:yourappname/webwidget/footerweb.dart';
import 'package:yourappname/webwidget/webappbar.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

const _indigo = Color(0xFF4E45B8);

class Webcategorywisedata extends StatefulWidget {
  final String? catagoryid;
  final String? catagoryname, name;
  const Webcategorywisedata(
      {super.key, this.catagoryid, this.catagoryname, required this.name});

  @override
  State<Webcategorywisedata> createState() => _WebcategorywisedataState();
}

class _WebcategorywisedataState extends State<Webcategorywisedata> {
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
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxContentWidth = 1400;
    final contentWidth =
        screenWidth > maxContentWidth ? maxContentWidth : screenWidth - 20;

    return Consumer<CategoryWiseDataProvider>(
      builder: (context, provider, child) {
        return WebAppBar(
          widget: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: contentWidth,
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth <= 1000 ? 10 : 0),
                    child: Utils.buildWebDetailsAppBar(
                        context: context,
                        title1: "Category",
                        multilanguage: false,
                        isHome: true),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: SizedBox(width: contentWidth, child: _buildTab()),
                ),
                SizedBox(height: 20),
                Center(
                    child: SizedBox(
                        width: contentWidth, child: _buildTabbarData())),
                SizedBox(height: 20),
                if (categoryWiseDataProvider.loadMore)
                  Utils.pageLoader(context)
                else
                  SizedBox.shrink(),
                SizedBox(height: 20),
                FooterWeb(),
              ],
            ),
          ),
        );
      },
    );
  }

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
                      ? colorPrimary
                      : transparent
                  : categoryWiseDataProvider.currentIndex == index
                      ? _indigo
                      : transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                width: 1,
                style: BorderStyle.solid,
                color: Constant.isDarkMode
                    ? categoryWiseDataProvider.currentIndex == index
                        ? _indigo
                        : gray
                    : _indigo,
              )),
          child: Row(
            children: [
              Icon(
                color: Constant.isDarkMode
                    ? categoryWiseDataProvider.currentIndex == index
                        ? _indigo
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
                        ? _indigo
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
      return commanListShimmer(context);
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

  Widget _buildCommanWidget(List? commanList) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 🖥️ WEB VIEW (Horizontal Scroll)
    if (screenWidth > 1000) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(commanList?.length ?? 0, (index) {
            final bookData = commanList?[index];
            final accessInfo = getAccessInfo(
              accessType: bookData.accessType.toString(),
              isBuy: bookData.isBuy.toString(),
              isSubscription: Constant.isSubscription ?? 0,
              price: bookData.price?.toString(),
            );

            return InkWell(
              onTap: () {
                _handleCommonTap(bookData);
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: InkWell(
                  onTap: () => _handleCommonTap(bookData),
                  child: Container(
                    width: 180,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: white,
                      border: Border.all(width: 1, color: gray),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyNetworkImage(
                          imagePath: bookData?.portraitImg ?? "",
                          height: 220,
                          width: 180,
                          fit: BoxFit.cover,
                          radius: 10,
                        ),
                        const SizedBox(height: 6),
                        MyText(
                          text: bookData?.title ?? "",
                          fontsize: Dimens.medium14TextSize,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                        ),
                        MyText(
                          text: "By ${bookData?.authorName ?? ""}",
                          fontsize: Dimens.medium12TextSize,
                          maxline: 1,
                          fontwaight: FontWeight.w400,
                        ),
                        MyText(
                          text: bookData?.categoryName ?? "",
                          fontsize: Dimens.medium12TextSize,
                          maxline: 1,
                          fontwaight: FontWeight.w400,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            MyText(
                              text: bookData?.avgReviews.toString() ?? "0",
                              fontsize: Dimens.medium12TextSize,
                            ),
                            const SizedBox(width: 5),
                            RatingBar.readOnly(
                              filledIcon: Icons.star,
                              emptyIcon: Icons.star_border,
                              initialRating: double.parse(
                                  bookData?.avgReviews.toString() ?? "0"),
                              emptyColor: gray,
                              filledColor: _indigo,
                              maxRating: 5,
                              size: 10,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: MyText(
                                text:
                                    "(${Utils.kmbGenerator(bookData?.totalReviews ?? 0)})",
                                fontsize: Dimens.medium12TextSize,
                                maxline: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        MyText(
                          text: accessInfo.priceText,
                          color: accessInfo.badgeTextColor,
                          fontsize: Dimens.medium14TextSize,
                          maxline: 1,
                          fontwaight: FontWeight.w600,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      );
    }

    // 📱 MOBILE VIEW (Responsive Grid)
    else {
      return ResponsiveGridList(
        minItemWidth: 120,
        minItemsPerRow: 3,
        maxItemsPerRow: 6,
        listViewBuilderOptions: ListViewBuilderOptions(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
        ),
        children: List.generate(commanList?.length ?? 0, (index) {
          final bookDataList = commanList?[index];
          final accessInfo = getAccessInfo(
            accessType: bookDataList.accessType.toString(),
            isBuy: bookDataList.isBuy.toString(),
            isSubscription: Constant.isSubscription ?? 0,
            price: bookDataList.price?.toString(),
          );
          return InkWell(
            onTap: () {
              _handleCommonTap(bookDataList);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyNetworkImage(
                  imagePath: bookDataList?.portraitImg ?? "",
                  radius: 10,
                  height: 100,
                  width: MediaQuery.sizeOf(context).width,
                  fit: BoxFit.cover,
                ),
                const SizedBox(height: 7),
                MyText(
                  text: bookDataList?.title ?? "",
                  fontsize: Dimens.medium14TextSize,
                  maxline: 1,
                  fontstyle: FontStyle.italic,
                  fontwaight: FontWeight.w500,
                ),
                const SizedBox(height: 2),
                MyText(
                  text: "By ${bookDataList?.authorName ?? ""}",
                  fontsize: Dimens.medium12TextSize,
                  maxline: 1,
                  fontwaight: FontWeight.w400,
                ),
                const SizedBox(height: 2),
                MyText(
                  text: bookDataList?.categoryName ?? "",
                  fontsize: Dimens.medium12TextSize,
                  maxline: 1,
                  fontwaight: FontWeight.w400,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    MyText(
                      text: bookDataList?.avgReviews.toString() ?? "0",
                      fontsize: Dimens.medium12TextSize,
                      maxline: 1,
                    ),
                    const SizedBox(width: 5),
                    RatingBar.readOnly(
                      filledIcon: Icons.star,
                      emptyIcon: Icons.star_border,
                      initialRating: double.parse(
                          bookDataList?.avgReviews.toString() ?? "0"),
                      emptyColor: gray,
                      filledColor: _indigo,
                      maxRating: 5,
                      size: 10,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: MyText(
                        text:
                            "(${Utils.kmbGenerator(bookDataList?.totalReviews ?? 0)})",
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
                  fontsize: Dimens.medium14TextSize,
                  maxline: 1,
                  multilanguage: false,
                  fontwaight: FontWeight.w600,
                ),
              ],
            ),
          );
        }),
      );
    }
  }

  void _handleCommonTap(bookData) {
    if (categoryWiseDataProvider.currentIndex == "1") {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              WebAudioBookDetails(
            contentId: bookData?.id.toString(),
            authorId: bookData?.authorId.toString(),
            categoryId: bookData?.categoryId.toString(),
            name: bookData?.title.toString(),
            isFromHome: true,
          ),
          transitionDuration: Duration(milliseconds: 100),
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
        ),
      );
    } else if (categoryWiseDataProvider.currentIndex == "2") {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => WebDetails(
            contentId: bookData?.id.toString(),
            authorId: bookData?.authorId.toString(),
            categoryId: bookData?.categoryId.toString(),
            name: bookData?.title.toString(),
          ),
          transitionDuration: Duration(milliseconds: 100),
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
        ),
      );
    } else {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              WebMagazineDetails(
            contentId: bookData?.id.toString(),
            categoryId: bookData?.categoryId.toString(),
            name: bookData?.title.toString(),
          ),
          transitionDuration: Duration(milliseconds: 100),
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
        ),
      );
    }
  }

  Widget commanListShimmer(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 🖥️ WEB VIEW SHIMMER (Horizontal Scroll)
    if (screenWidth > 1000) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(6, (index) {
            return Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Container(
                width: 180,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: white,
                  border:
                      Border.all(width: 1, color: gray.withOpacity( 0.3)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidget.roundrectborder(
                        width: 180, height: 220), // Image
                    const SizedBox(height: 6),
                    CustomWidget.roundrectborder(
                        width: 120, height: 18), // Title
                    const SizedBox(height: 4),
                    CustomWidget.roundrectborder(
                        width: 100, height: 14), // Author
                    const SizedBox(height: 4),
                    CustomWidget.roundrectborder(
                        width: 80, height: 14), // Category
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CustomWidget.circular(width: 10, height: 10), // Star
                        const SizedBox(width: 4),
                        CustomWidget.circular(width: 10, height: 10),
                        const SizedBox(width: 4),
                        CustomWidget.circular(width: 10, height: 10),
                        const SizedBox(width: 4),
                        CustomWidget.circular(width: 10, height: 10),
                        const SizedBox(width: 4),
                        CustomWidget.circular(width: 10, height: 10),
                      ],
                    ),
                    const SizedBox(height: 8),
                    CustomWidget.roundrectborder(
                        width: 80, height: 20), // Price
                  ],
                ),
              ),
            );
          }),
        ),
      );
    }
    // 📱 MOBILE VIEW SHIMMER (Responsive Grid)
    else {
      return ResponsiveGridList(
        minItemWidth: 120,
        minItemsPerRow: 3,
        maxItemsPerRow: 6,
        listViewBuilderOptions: ListViewBuilderOptions(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
        ),
        children: List.generate(9, (index) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomWidget.roundrectborder(
                width: double.infinity,
                height: 100,
              ), // Image
              const SizedBox(height: 7),
              CustomWidget.roundrectborder(width: 100, height: 16), // Title
              const SizedBox(height: 4),
              CustomWidget.roundrectborder(width: 80, height: 14), // Author
              const SizedBox(height: 4),
              CustomWidget.roundrectborder(width: 80, height: 14), // Category
              const SizedBox(height: 6),
              Row(
                children: [
                  CustomWidget.circular(width: 10, height: 10),
                  const SizedBox(width: 4),
                  CustomWidget.circular(width: 10, height: 10),
                  const SizedBox(width: 4),
                  CustomWidget.circular(width: 10, height: 10),
                  const SizedBox(width: 4),
                  CustomWidget.circular(width: 10, height: 10),
                  const SizedBox(width: 4),
                  CustomWidget.circular(width: 10, height: 10),
                ],
              ),
              const SizedBox(height: 8),
              CustomWidget.roundrectborder(width: 70, height: 18), // Price
            ],
          );
        }),
      );
    }
  }
}
