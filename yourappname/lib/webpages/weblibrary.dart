import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:yourappname/provider/mylibraryprovider.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/provider/themeprovider.dart';
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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class WebLibrary extends StatefulWidget {
  const WebLibrary({super.key});

  @override
  State<WebLibrary> createState() => _WebLibraryState();
}

class _WebLibraryState extends State<WebLibrary> {
  late MylibraryProvider mylibraryProvider;
  final ScrollController _bookController = ScrollController();
  late ThemeProvider themeProvider;
  late ProfileProvider profileProvider;
  @override
  void initState() {
    mylibraryProvider = Provider.of<MylibraryProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    _bookController.addListener(_bookScrollListener);
    getUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData(mylibraryProvider.currentIndex, 0);
    });
    super.initState();
  }

  getUser() {
    profileProvider.getProfile(Constant.userID);
  }

  _bookScrollListener() {
    if (!_bookController.hasClients) return;
    if (_bookController.offset >= _bookController.position.maxScrollExtent &&
        !_bookController.position.outOfRange &&
        (mylibraryProvider.currentPage ?? 0) <
            (mylibraryProvider.totalPage ?? 0)) {
      mylibraryProvider.setLoadMore(true);
      _fetchData(
          mylibraryProvider.currentIndex, mylibraryProvider.currentPage ?? 0);
    }
  }

  _fetchData(type, int? nextPage) {
    mylibraryProvider.setLoading(true);
    if (type == "1") {
      mylibraryProvider.getSectionAudio(type, (nextPage ?? 0) + 1);
    } else if (type == "2") {
      mylibraryProvider.getSectionBook(type, (nextPage ?? 0) + 1);
    } else {
      mylibraryProvider.getSectionMagazine(type, (nextPage ?? 0) + 1);
    }
  }

  @override
  void dispose() {
    mylibraryProvider.clearProvider();
    profileProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxContentWidth = 1400;
    final bool isWide = screenWidth > maxContentWidth;

    return WebAppBar(
      widget: Consumer<MylibraryProvider>(
        builder: (context, mylibraryProvider, child) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 20,
              children: [
                Center(
                  child: Container(
                    width: isWide ? maxContentWidth : screenWidth - 20,
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth <= 1000 ? 10 : 0),
                    child: Utils.buildWebDetailsAppBar(
                      context: context,
                      title1: "library",
                      multilanguage: true,
                      isHome: true,
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: isWide ? maxContentWidth : screenWidth - 20,
                    child: _buildTab(),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: isWide ? maxContentWidth : screenWidth - 20,
                    child: _buildTabData(),
                  ),
                ),
                if (mylibraryProvider.loadMore) Utils.pageLoader(context),
                FooterWeb(),
              ],
            ),
          );
        },
      ),
    );
  }

/* Tab BOOK/MAGAZINE/AUDIO */
  Widget _buildTab() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _titleBuild("1", Icons.audio_file_rounded, "audio_book", () {
              mylibraryProvider.setTab("1");
              mylibraryProvider.clearData();
              _fetchData(mylibraryProvider.currentIndex, 0);
            }),
            _titleBuild("2", FontAwesomeIcons.book, "books", () {
              mylibraryProvider.setTab("2");
              mylibraryProvider.clearData();
              _fetchData(mylibraryProvider.currentIndex, 0);
            }),
            _titleBuild("3", FontAwesomeIcons.newspaper, "magazines", () {
              mylibraryProvider.setTab("3");
              mylibraryProvider.clearData();
              _fetchData(mylibraryProvider.currentIndex, 0);
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
                  ? mylibraryProvider.currentIndex == index
                      ? colorPrimary
                      : transparent
                  : mylibraryProvider.currentIndex == index
                      ? colorPrimary
                      : transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                width: 1,
                style: BorderStyle.solid,
                color: Constant.isDarkMode
                    ? mylibraryProvider.currentIndex == index
                        ? colorPrimary
                        : gray
                    : colorPrimary,
              )),
          child: Row(
            children: [
              Icon(
                color: Constant.isDarkMode
                    ? mylibraryProvider.currentIndex == index
                        ? colorPrimary
                        : white
                    : mylibraryProvider.currentIndex == index
                        ? white
                        : black,
                iconData,
                size: 16,
              ),
              SizedBox(width: 6),
              MyText(
                color: Constant.isDarkMode
                    ? mylibraryProvider.currentIndex == index
                        ? colorPrimary
                        : white
                    : mylibraryProvider.currentIndex == index
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

  Widget _buildTabData() {
    if (mylibraryProvider.loading) {
      return mylibraryProvider.currentIndex == "1"
          ? buildAudioShimmer()
          : buildAudioShimmer();
    } else {
      return mylibraryProvider.currentIndex == "1"
          ? _buildAudio()
          : mylibraryProvider.currentIndex == "2"
              ? _buildBoook()
              : _buildMagazine();
    }
  }

  Widget _buildAudio() {
    if (mylibraryProvider.audioList != null &&
        (mylibraryProvider.audioList?.length ?? 0) > 0) {
      return SingleChildScrollView(
        controller: _bookController,
        padding: EdgeInsets.only(top: 12),
        physics: BouncingScrollPhysics(),
        child: buildAudioResponsive(),
      );
    } else {
      return NoData();
    }
  }

  Widget buildAudioResponsive() {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 1000) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Wrap(
          spacing: 20, // horizontal space between cards
          runSpacing: 20, // vertical space between rows
          children: List.generate(
            mylibraryProvider.audioList?.length ?? 0,
            (index) {
              final bookMark = mylibraryProvider.audioList?[index];

              final accessInfo = getAccessInfo(
                accessType: bookMark?.accessType.toString(),
                isBuy: bookMark?.isBuy.toString(),
                isSubscription: Constant.isSubscription ?? 0,
                price: bookMark?.price?.toString(),
              );

              return InkWell(
                onTap: () {
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return WebAudioBookDetails(
                        categoryId: bookMark?.categoryId.toString(),
                        authorId: bookMark?.authorId.toString(),
                        contentId: bookMark?.id.toString(),
                        name: bookMark?.title.toString(),
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
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          MyNetworkImage(
                            imagePath: bookMark?.portraitImg ?? "",
                            height: 220,
                            width: 180,
                            fit: BoxFit.cover,
                            radius: 10,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: InkWell(
                              onTap: () {
                                if (Utils.checkLoginUser(context)) {
                                  mylibraryProvider.getBookMark(
                                      index,
                                      mylibraryProvider.currentIndex,
                                      bookMark?.id ?? "");
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .cardColor
                                      .withOpacity( 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  bookMark?.isBookmark == 1
                                      ? Icons.bookmark
                                      : Icons.bookmark_outline_rounded,
                                  size: 20,
                                  color: Theme.of(context).canvasColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      MyText(
                        text: bookMark?.title ?? "",
                        fontsizeWeb: Dimens.medium14TextSize,
                        maxline: 1,
                        fontwaight: FontWeight.w500,
                      ),
                      MyText(
                        text: "By ${bookMark?.authorName ?? ""}",
                        fontsizeWeb: Dimens.medium12TextSize,
                        maxline: 1,
                        fontwaight: FontWeight.w400,
                      ),
                      MyText(
                        text: bookMark?.categoryName ?? "",
                        fontsizeWeb: Dimens.medium12TextSize,
                        maxline: 1,
                        fontwaight: FontWeight.w400,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          MyText(
                            text: bookMark?.avgReviews.toString() ?? "",
                            fontsize: Dimens.medium12TextSize,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                          ),
                          const SizedBox(width: 5),
                          RatingBar.readOnly(
                            filledIcon: Icons.star,
                            emptyIcon: Icons.star_border,
                            initialRating: double.parse(
                                bookMark?.avgReviews.toString() ?? "0"),
                            emptyColor: gray,
                            filledColor: colorPrimary,
                            maxRating: 5,
                            size: 10,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: MyText(
                              text:
                                  "(${Utils.kmbGenerator(bookMark?.totalReviews ?? 0)})",
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
      );
    }

    /*--- Mobile view ----*/
    else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: mylibraryProvider.audioList?.length ?? 0,
        itemBuilder: (context, index) {
          final bookMark = mylibraryProvider.audioList?[index];

          final accessInfo = getAccessInfo(
            accessType: bookMark?.accessType.toString(),
            isBuy: bookMark?.isBuy.toString(),
            isSubscription: Constant.isSubscription ?? 0,
            price: bookMark?.price?.toString(),
          );
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return WebAudioBookDetails(
                      categoryId: bookMark?.categoryId.toString(),
                      authorId: bookMark?.authorId.toString(),
                      contentId: bookMark?.id.toString(),
                      name: bookMark?.title.toString(),
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
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      MyNetworkImage(
                        imagePath: bookMark?.portraitImg ?? "",
                        height: 120,
                        width: 90,
                        fit: BoxFit.cover,
                        radius: 8,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () {
                            if (Utils.checkLoginUser(context)) {
                              mylibraryProvider.getBookMark(
                                  index,
                                  mylibraryProvider.currentIndex,
                                  bookMark?.id ?? "");
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .cardColor
                                    .withOpacity( 0.6),
                                shape: BoxShape.circle),
                            child: Icon(
                              bookMark?.isBookmark == 1
                                  ? Icons.bookmark
                                  : Icons.bookmark_outline_rounded,
                              size: 16,
                              color: Theme.of(context).canvasColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          text: bookMark?.title ?? "",
                          fontsize: Dimens.medium14TextSize,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                        ),
                        MyText(
                          text: "By ${bookMark?.authorName ?? ""}",
                          fontsize: Dimens.medium12TextSize,
                          maxline: 1,
                          fontwaight: FontWeight.w400,
                        ),
                        MyText(
                          text: bookMark?.categoryName ?? "",
                          fontsize: Dimens.medium12TextSize,
                          maxline: 1,
                          fontwaight: FontWeight.w400,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            MyText(
                              text: bookMark?.avgReviews.toString() ?? "",
                              fontsize: Dimens.medium12TextSize,
                              maxline: 1,
                              fontwaight: FontWeight.w400,
                            ),
                            const SizedBox(width: 5),
                            RatingBar.readOnly(
                              filledIcon: Icons.star,
                              emptyIcon: Icons.star_border,
                              initialRating: double.parse(
                                  bookMark?.avgReviews.toString() ?? "0"),
                              emptyColor: gray,
                              filledColor: colorPrimary,
                              maxRating: 5,
                              size: 10,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: MyText(
                                text:
                                    "(${Utils.kmbGenerator(bookMark?.totalReviews ?? 0)})",
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
                ],
              ),
            ),
          );
        },
      );
    }
  }

/* END */
/* Book Widget Started */
  Widget _buildBoook() {
    if (mylibraryProvider.bookList != null &&
        (mylibraryProvider.bookList?.length ?? 0) > 0) {
      return SingleChildScrollView(
        controller: _bookController,
        padding: EdgeInsets.only(top: 12),
        physics: BouncingScrollPhysics(),
        child: buildBookResponsive(),
      );
    } else {
      return NoData();
    }
  }

  Widget buildBookResponsive() {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 1000) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Wrap(
          spacing: 20, // horizontal gap
          runSpacing: 20, // vertical gap
          children: List.generate(
            mylibraryProvider.bookList?.length ?? 0,
            (index) {
              final bookMark = mylibraryProvider.bookList?[index];
              final accessInfo = getAccessInfo(
                accessType: bookMark?.accessType.toString(),
                isBuy: bookMark?.isBuy.toString(),
                isSubscription: Constant.isSubscription ?? 0,
                price: bookMark?.price?.toString(),
              );

              return InkWell(
                onTap: () {
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return WebDetails(
                        categoryId: bookMark?.categoryId.toString(),
                        authorId: bookMark?.authorId.toString(),
                        contentId: bookMark?.id.toString(),
                        name: bookMark?.title.toString(),
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
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          MyNetworkImage(
                            imagePath: bookMark?.portraitImg ?? "",
                            height: 220,
                            width: 180,
                            fit: BoxFit.cover,
                            radius: 10,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: InkWell(
                              onTap: () {
                                if (Utils.checkLoginUser(context)) {
                                  mylibraryProvider.getBookMark(
                                      index,
                                      mylibraryProvider.currentIndex,
                                      bookMark?.id ?? "");
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .cardColor
                                      .withOpacity( 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  bookMark?.isBookmark == 1
                                      ? Icons.bookmark
                                      : Icons.bookmark_outline_rounded,
                                  size: 20,
                                  color: Theme.of(context).canvasColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      MyText(
                        text: bookMark?.title ?? "",
                        fontsizeWeb: Dimens.medium14TextSize,
                        maxline: 1,
                        fontwaight: FontWeight.w500,
                      ),
                      MyText(
                        text: "By ${bookMark?.authorName ?? ""}",
                        fontsizeWeb: Dimens.medium12TextSize,
                        maxline: 1,
                        fontwaight: FontWeight.w400,
                      ),
                      MyText(
                        text: bookMark?.categoryName ?? "",
                        fontsizeWeb: Dimens.medium12TextSize,
                        maxline: 1,
                        fontwaight: FontWeight.w400,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          MyText(
                            text: bookMark?.avgReviews.toString() ?? "",
                            fontsize: Dimens.medium12TextSize,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                          ),
                          const SizedBox(width: 5),
                          RatingBar.readOnly(
                            filledIcon: Icons.star,
                            emptyIcon: Icons.star_border,
                            initialRating: double.parse(
                                bookMark?.avgReviews.toString() ?? "0"),
                            emptyColor: gray,
                            filledColor: colorPrimary,
                            maxRating: 5,
                            size: 10,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: MyText(
                              text:
                                  "(${Utils.kmbGenerator(bookMark?.totalReviews ?? 0)})",
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
      );
    }

    // 📱 Mobile layout
    else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: mylibraryProvider.bookList?.length ?? 0,
        itemBuilder: (context, index) {
          final bookMark = mylibraryProvider.bookList?[index];
          final accessInfo = getAccessInfo(
            accessType: bookMark?.accessType.toString(),
            isBuy: bookMark?.isBuy.toString(),
            isSubscription: Constant.isSubscription ?? 0,
            price: bookMark?.price?.toString(),
          );
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return WebDetails(
                      categoryId: bookMark?.categoryId.toString(),
                      authorId: bookMark?.authorId.toString(),
                      contentId: bookMark?.id.toString(),
                      name: bookMark?.title.toString(),
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
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      MyNetworkImage(
                        imagePath: bookMark?.portraitImg ?? "",
                        height: 120,
                        width: 90,
                        fit: BoxFit.cover,
                        radius: 8,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () {
                            if (Utils.checkLoginUser(context)) {
                              mylibraryProvider.getBookMark(
                                  index,
                                  mylibraryProvider.currentIndex,
                                  bookMark?.id ?? "");
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .cardColor
                                  .withOpacity( 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              bookMark?.isBookmark == 1
                                  ? Icons.bookmark
                                  : Icons.bookmark_outline_rounded,
                              size: 16,
                              color: Theme.of(context).canvasColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          text: bookMark?.title ?? "",
                          fontsize: Dimens.medium14TextSize,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                        ),
                        MyText(
                          text: "By ${bookMark?.authorName ?? ""}",
                          fontsize: Dimens.medium12TextSize,
                          maxline: 1,
                          fontwaight: FontWeight.w400,
                        ),
                        MyText(
                          text: bookMark?.categoryName ?? "",
                          fontsize: Dimens.medium12TextSize,
                          maxline: 1,
                          fontwaight: FontWeight.w400,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            MyText(
                              text: bookMark?.avgReviews.toString() ?? "",
                              fontsize: Dimens.medium12TextSize,
                              maxline: 1,
                              fontwaight: FontWeight.w400,
                            ),
                            const SizedBox(width: 5),
                            RatingBar.readOnly(
                              filledIcon: Icons.star,
                              emptyIcon: Icons.star_border,
                              initialRating: double.parse(
                                  bookMark?.avgReviews.toString() ?? "0"),
                              emptyColor: gray,
                              filledColor: colorPrimary,
                              maxRating: 5,
                              size: 10,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: MyText(
                                text:
                                    "(${Utils.kmbGenerator(bookMark?.totalReviews ?? 0)})",
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
                ],
              ),
            ),
          );
        },
      );
    }
  }

/* END */
/* Book Widget Started */
  Widget _buildMagazine() {
    if (mylibraryProvider.magazineList != null &&
        (mylibraryProvider.magazineList?.length ?? 0) > 0) {
      return SingleChildScrollView(
        controller: _bookController,
        padding: EdgeInsets.only(top: 12),
        physics: BouncingScrollPhysics(),
        child: buildMagazineResponsive(),
      );
    } else {
      return NoData();
    }
  }

  Widget buildMagazineResponsive() {
    final screenWidth = MediaQuery.of(context).size.width;

    // 🌐 Web Layout
    if (screenWidth > 1000) {
      return Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Wrap(
          spacing: 20,
          runSpacing: 20,
          children: List.generate(
            mylibraryProvider.magazineList?.length ?? 0,
            (index) {
              final bookMark = mylibraryProvider.magazineList?[index];
              final accessInfo = getAccessInfo(
                accessType: bookMark?.accessType.toString(),
                isBuy: bookMark?.isBuy.toString(),
                isSubscription: Constant.isSubscription ?? 0,
                price: bookMark?.price?.toString(),
              );

              return InkWell(
                onTap: () {
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return WebMagazineDetails(
                        contentId: bookMark?.id.toString(),
                        categoryId: bookMark?.categoryId.toString(),
                        name: bookMark?.title.toString(),
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
                      Stack(
                        alignment: Alignment.topRight,
                        children: [
                          MyNetworkImage(
                            imagePath: bookMark?.portraitImg ?? "",
                            height: 220,
                            width: 180,
                            fit: BoxFit.cover,
                            radius: 10,
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: InkWell(
                              onTap: () {
                                if (Utils.checkLoginUser(context)) {
                                  mylibraryProvider.getBookMark(
                                    index,
                                    mylibraryProvider.currentIndex,
                                    bookMark?.id ?? "",
                                  );
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .cardColor
                                      .withOpacity( 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  bookMark?.isBookmark == 1
                                      ? Icons.bookmark
                                      : Icons.bookmark_outline_rounded,
                                  size: 20,
                                  color: Theme.of(context).canvasColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      MyText(
                        text: bookMark?.title ?? "",
                        fontsizeWeb: Dimens.medium14TextSize,
                        maxline: 1,
                        fontwaight: FontWeight.w500,
                      ),
                      MyText(
                        text: "By ${bookMark?.authorName ?? ""}",
                        fontsizeWeb: Dimens.medium12TextSize,
                        maxline: 1,
                        fontwaight: FontWeight.w400,
                      ),
                      MyText(
                        text: bookMark?.categoryName ?? "",
                        fontsizeWeb: Dimens.medium12TextSize,
                        maxline: 1,
                        fontwaight: FontWeight.w400,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          MyText(
                            text: bookMark?.avgReviews.toString() ?? "",
                            fontsize: Dimens.medium12TextSize,
                            maxline: 1,
                            fontwaight: FontWeight.w400,
                          ),
                          const SizedBox(width: 5),
                          RatingBar.readOnly(
                            filledIcon: Icons.star,
                            emptyIcon: Icons.star_border,
                            initialRating: double.parse(
                                bookMark?.avgReviews.toString() ?? "0"),
                            emptyColor: gray,
                            filledColor: colorPrimary,
                            maxRating: 5,
                            size: 10,
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: MyText(
                              text:
                                  "(${Utils.kmbGenerator(bookMark?.totalReviews ?? 0)})",
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
      );
    }

    // 📱 Mobile Layout
    else {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: mylibraryProvider.magazineList?.length ?? 0,
        itemBuilder: (context, index) {
          final bookMark = mylibraryProvider.magazineList?[index];
          final accessInfo = getAccessInfo(
            accessType: bookMark?.accessType.toString(),
            isBuy: bookMark?.isBuy.toString(),
            isSubscription: Constant.isSubscription ?? 0,
            price: bookMark?.price?.toString(),
          );
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return WebMagazineDetails(
                      contentId: bookMark?.id.toString(),
                      categoryId: bookMark?.categoryId.toString(),
                      name: bookMark?.title.toString(),
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
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      MyNetworkImage(
                        imagePath: bookMark?.portraitImg ?? "",
                        height: 120,
                        width: 90,
                        fit: BoxFit.cover,
                        radius: 8,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: InkWell(
                          onTap: () {
                            if (Utils.checkLoginUser(context)) {
                              mylibraryProvider.getBookMark(
                                index,
                                mylibraryProvider.currentIndex,
                                bookMark?.id ?? "",
                              );
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .cardColor
                                  .withOpacity( 0.6),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              bookMark?.isBookmark == 1
                                  ? Icons.bookmark
                                  : Icons.bookmark_outline_rounded,
                              size: 16,
                              color: Theme.of(context).canvasColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          text: bookMark?.title ?? "",
                          fontsize: Dimens.medium14TextSize,
                          maxline: 1,
                          fontwaight: FontWeight.w500,
                        ),
                        MyText(
                          text: "By ${bookMark?.authorName ?? ""}",
                          fontsize: Dimens.medium12TextSize,
                          maxline: 1,
                          fontwaight: FontWeight.w400,
                        ),
                        MyText(
                          text: bookMark?.categoryName ?? "",
                          fontsize: Dimens.medium12TextSize,
                          maxline: 1,
                          fontwaight: FontWeight.w400,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            MyText(
                              text: bookMark?.avgReviews.toString() ?? "",
                              fontsize: Dimens.medium12TextSize,
                              maxline: 1,
                              fontwaight: FontWeight.w400,
                            ),
                            const SizedBox(width: 5),
                            RatingBar.readOnly(
                              filledIcon: Icons.star,
                              emptyIcon: Icons.star_border,
                              initialRating: double.parse(
                                  bookMark?.avgReviews.toString() ?? "0"),
                              emptyColor: gray,
                              filledColor: colorPrimary,
                              maxRating: 5,
                              size: 10,
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: MyText(
                                text:
                                    "(${Utils.kmbGenerator(bookMark?.totalReviews ?? 0)})",
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
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget buildAudioShimmer() {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 1000) {
      // Web: horizontal cards
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            5,
            (index) => Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomWidget.roundcorner(height: 243, width: 185),
                  const SizedBox(height: 8),
                  CustomWidget.roundrectborder(height: 14, width: 100),
                  const SizedBox(height: 4),
                  CustomWidget.roundrectborder(height: 16, width: 150),
                  const SizedBox(height: 4),
                  CustomWidget.roundrectborder(height: 14, width: 120),
                  const SizedBox(height: 6),
                  CustomWidget.roundrectborder(height: 20, width: 60),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      // Mobile: vertical list, image left + content right
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomWidget.roundcorner(height: 120, width: 90), // image
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomWidget.roundrectborder(
                          height: 20, width: double.infinity), // title
                      const SizedBox(height: 6),
                      CustomWidget.roundrectborder(
                          height: 14, width: 150), // author
                      const SizedBox(height: 4),
                      CustomWidget.roundrectborder(
                          height: 14, width: 100), // category
                      const SizedBox(height: 6),
                      CustomWidget.roundrectborder(
                          height: 18, width: 60), // price/free
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }
}
