import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:yourappname/pages/audiobookdetails.dart';
import 'package:yourappname/pages/bookdetails.dart';
import 'package:yourappname/pages/magazinedetails.dart';
import 'package:yourappname/provider/languagewisedataprovider.dart';
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

class LanguageWiseData extends StatefulWidget {
  final String? catagoryid;
  final String? catagoryname;
  const LanguageWiseData(
      {super.key, required this.catagoryid, required this.catagoryname});

  @override
  State<LanguageWiseData> createState() => _LanguageWiseDataState();
}

class _LanguageWiseDataState extends State<LanguageWiseData> {
  final ScrollController _scrollController = ScrollController();
  late LanguageWiseDataProvider languageWiseDataProvider;

  @override
  void initState() {
    languageWiseDataProvider =
        Provider.of<LanguageWiseDataProvider>(context, listen: false);
    _scrollController.addListener(_bookScrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData(languageWiseDataProvider.currentIndex, 0);
    });
    super.initState();
  }

  _bookScrollListener() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (languageWiseDataProvider.isMorePage ?? false) &&
        (languageWiseDataProvider.currentPage ?? 0) <
            (languageWiseDataProvider.totalPage ?? 0)) {
      languageWiseDataProvider.setLoadMore(true);
      _fetchData(languageWiseDataProvider.currentIndex,
          languageWiseDataProvider.currentPage ?? 0);
    }
  }

  _fetchData(type, int? nextPage) {
    languageWiseDataProvider.setLoading(true);
    if (type == "1") {
      languageWiseDataProvider.getSectionAudio(
          type, widget.catagoryid, (nextPage ?? 0) + 1);
    } else if (type == "2") {
      languageWiseDataProvider.getSectionBook(
          type, widget.catagoryid, (nextPage ?? 0) + 1);
    } else {
      languageWiseDataProvider.getSectionMagazine(
          type, widget.catagoryid, (nextPage ?? 0) + 1);
    }
  }

  @override
  void dispose() {
    languageWiseDataProvider.clearProvider();
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
      body: Consumer<LanguageWiseDataProvider>(
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
            _titleBuild("1", Icons.audio_file_rounded, "audio_book", () {
              languageWiseDataProvider.setTab("1");
              languageWiseDataProvider.clearData();
              _fetchData(languageWiseDataProvider.currentIndex, 0);
            }),
            _titleBuild("2", FontAwesomeIcons.book, "books", () {
              languageWiseDataProvider.setTab("2");
              languageWiseDataProvider.clearData();
              _fetchData(languageWiseDataProvider.currentIndex, 0);
            }),
            _titleBuild("3", FontAwesomeIcons.newspaper, "magazines", () {
              languageWiseDataProvider.setTab("3");
              languageWiseDataProvider.clearData();
              _fetchData(languageWiseDataProvider.currentIndex, 0);
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
                  ? languageWiseDataProvider.currentIndex == index
                      ? colorPrimaryDark
                      : transparent
                  : languageWiseDataProvider.currentIndex == index
                      ? colorPrimary
                      : transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                width: 1,
                style: BorderStyle.solid,
                color: Constant.isDarkMode
                    ? languageWiseDataProvider.currentIndex == index
                        ? colorPrimary
                        : gray
                    : colorPrimary,
              )),
          child: Row(
            children: [
              Icon(
                color: Constant.isDarkMode
                    ? languageWiseDataProvider.currentIndex == index
                        ? colorPrimary
                        : white
                    : languageWiseDataProvider.currentIndex == index
                        ? white
                        : black,
                iconData,
                size: 16,
              ),
              SizedBox(width: 6),
              MyText(
                color: Constant.isDarkMode
                    ? languageWiseDataProvider.currentIndex == index
                        ? colorPrimary
                        : white
                    : languageWiseDataProvider.currentIndex == index
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
    if (languageWiseDataProvider.loading &&
        !languageWiseDataProvider.loadMore) {
      return autherShimmer();
    } else {
      return languageWiseDataProvider.currentIndex == "1"
          ? _buildAudio()
          : languageWiseDataProvider.currentIndex == "2"
              ? _buildBoook()
              : _buildMagazine();
    }
  }

  Widget _buildAudio() {
    if (languageWiseDataProvider.audioList != null &&
        (languageWiseDataProvider.audioList?.length ?? 0) > 0) {
      return SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(top: 12),
        physics: BouncingScrollPhysics(),
        child: _buildCommanWidget(languageWiseDataProvider.audioList ?? []),
      );
    } else {
      return NoData();
    }
  }

  Widget _buildBoook() {
    if (languageWiseDataProvider.bookList != null &&
        (languageWiseDataProvider.bookList?.length ?? 0) > 0) {
      return SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(top: 12),
        physics: BouncingScrollPhysics(),
        child: _buildCommanWidget(languageWiseDataProvider.bookList ?? []),
      );
    } else {
      return NoData();
    }
  }

  Widget _buildMagazine() {
    if (languageWiseDataProvider.magazineList != null &&
        (languageWiseDataProvider.magazineList?.length ?? 0) > 0) {
      return SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(top: 12),
        physics: BouncingScrollPhysics(),
        child: _buildCommanWidget(languageWiseDataProvider.magazineList ?? []),
      );
    } else {
      return NoData();
    }
  }

  Widget _buildCommanWidget(commanList) {
    return ResponsiveGridList(
        minItemWidth: 120,
        minItemsPerRow: 3,
        maxItemsPerRow: 6,
        listViewBuilderOptions: ListViewBuilderOptions(
            shrinkWrap: true, physics: NeverScrollableScrollPhysics()),
        children: List.generate(
          commanList?.length ?? 0,
          (index) {
            final bookDataList = commanList?[index];
            final accessInfo = getAccessInfo(
              accessType: bookDataList.accessType.toString(),
              isBuy: bookDataList.isBuy.toString(),
              isSubscription: Constant.isSubscription ?? 0,
              price: bookDataList.price?.toString(),
            );

            return InkWell(
              onTap: () {
                if (languageWiseDataProvider.currentIndex == "1") {
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
                } else if (languageWiseDataProvider.currentIndex == "2") {
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
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return MagazineDetails(
                            contentId: bookDataList?.id.toString(),
                            categoryId: bookDataList?.categoryId.toString(),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyNetworkImage(
                      imagePath: bookDataList?.portraitImg.toString() ?? "",
                      radius: 10,
                      height: 100,
                      width: MediaQuery.sizeOf(context).width,
                      fit: BoxFit.cover),
                  const SizedBox(height: 7),
                  MyText(
                    text: bookDataList?.title.toString() ?? "",
                    fontsize: Dimens.medium14TextSize,
                    maxline: 1,
                    fontstyle: FontStyle.italic,
                    fontwaight: FontWeight.w500,
                  ),
                  const SizedBox(height: 2),
                  MyText(
                    text: "By ${bookDataList?.authorName.toString() ?? ""}",
                    fontsize: Dimens.medium12TextSize,
                    maxline: 1,
                    fontwaight: FontWeight.w400,
                  ),
                  const SizedBox(height: 2),
                  MyText(
                    text: bookDataList?.categoryName.toString() ?? "",
                    fontsize: Dimens.medium12TextSize,
                    maxline: 1,
                    fontwaight: FontWeight.w400,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      MyText(
                        text: bookDataList?.avgReviews.toString() ?? "",
                        fontsize: Dimens.medium12TextSize,
                        maxline: 1,
                        fontwaight: FontWeight.w400,
                      ),
                      const SizedBox(width: 5),
                      RatingBar.readOnly(
                        filledIcon: Icons.star,
                        emptyIcon: Icons.star_border,
                        initialRating: double.parse(
                            bookDataList?.avgReviews.toString() ?? ""),
                        emptyColor: gray,
                        filledColor: colorAccent,
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
                  SizedBox(height: 6),
                  MyText(
                    text: accessInfo.priceText,
                    fontsize: Dimens.medium13TextSize,
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
