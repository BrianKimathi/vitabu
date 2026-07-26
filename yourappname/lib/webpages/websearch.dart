import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:yourappname/provider/searchprovider.dart';
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
import 'package:flutter_locales/flutter_locales.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class Websearch extends StatefulWidget {
  final String? showType;
  const Websearch({super.key, required this.showType});

  @override
  State<Websearch> createState() => _WebsearchState();
}

class _WebsearchState extends State<Websearch> {
  final searchController = TextEditingController();
  late SearchProvider searchProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    printLog("My Show type is show ${widget.showType}");
    searchProvider = Provider.of<SearchProvider>(context, listen: false);
    _scrollController.addListener(_scrollListener);

    super.initState();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (searchProvider.currentPage ?? 0) < (searchProvider.totalPage ?? 0)) {
      searchProvider.setLoadMore(true);

      if (widget.showType == "all") {
        _fetchData(
            searchProvider.currentIndex, searchProvider.currentPage ?? 0);
      } else if (widget.showType == "audiobook") {
        _fetchData("1", searchProvider.currentPage ?? 0);
      } else if (widget.showType == "magazine") {
        _fetchData("3", searchProvider.currentPage ?? 0);
      } else {
        printLog("No Type Dta Here");
      }
    }
  }

  _fetchData(type, int? nextPage) {
    searchProvider.setLoading(true);
    if (type == "1") {
      searchProvider.getSectionAudio(
          type, searchController.text, (nextPage ?? 0) + 1);
    } else if (type == "2") {
      searchProvider.getSectionBook(
          type, searchController.text, (nextPage ?? 0) + 1);
    } else {
      searchProvider.getSectionMagazine(
          type, searchController.text, (nextPage ?? 0) + 1);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchProvider.clearProvider();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxContentWidth = 1400;
    final bool isWide = screenWidth > maxContentWidth;

    return WebAppBar(
      widget: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          return SingleChildScrollView(
            scrollDirection: Axis.vertical,
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
                      isHome: true,
                      title1: "search",
                      multilanguage: true,
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: isWide ? maxContentWidth : screenWidth - 20,
                    child: search(),
                  ),
                ),
                if (widget.showType == "all")
                  Center(
                    child: SizedBox(
                      width: isWide ? maxContentWidth : screenWidth - 20,
                      child: _buildTab(),
                    ),
                  ),
                Center(
                  child: SizedBox(
                    width: isWide ? maxContentWidth : screenWidth - 20,
                    child: _buildBookData(),
                  ),
                ),
                FooterWeb(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget search() {
    return Consumer<SearchProvider>(builder: (context, searchProvider, child) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: TextFormField(
          controller: searchController,
          cursorColor: Constant.isDarkMode ? colorPrimary : colorPrimary,
          autofocus: true,
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          onChanged: (value) async {
            if (value.length >= 3) {
              searchProvider.showSearchScreen(true);
              searchProvider.audioList?.clear();
              searchProvider.bookList?.clear();
              searchProvider.magazineList?.clear();
              searchProvider.setLoading(false);
              if (widget.showType == "all") {
                _fetchData(searchProvider.currentIndex, 0);
              } else if (widget.showType == "audiobook") {
                _fetchData("1", 0);
              } else if (widget.showType == "magazine") {
                _fetchData("3", 0);
              } else {
                printLog("No Type Selected");
              }
            } else {
              searchProvider.showSearchScreen(false);
              searchProvider.audioList?.clear();
              searchProvider.bookList?.clear();
              searchProvider.magazineList?.clear();
              searchProvider.setLoading(false);
            }
          },
          style: Utils.googleFontStyle(
              1,
              Dimens.medium14TextSize,
              FontStyle.normal,
              Constant.isDarkMode ? white : black,
              FontWeight.w500),
          decoration: InputDecoration(
            suffixIcon: searchProvider.isShow == true
                ? IconButton(
                    onPressed: () {
                      searchProvider.showSearchScreen(false);
                      searchProvider.audioList?.clear();
                      searchProvider.bookList?.clear();
                      searchProvider.magazineList?.clear();
                      searchProvider.setTab("1");
                      searchProvider.setLoading(false);
                      FocusManager.instance.primaryFocus?.unfocus();
                      searchController.clear();
                    },
                    icon: const Icon(
                      FontAwesomeIcons.xmark,
                      size: 20,
                      color: gray,
                    ))
                : const Icon(
                    Icons.search,
                    size: 20,
                    color: gray,
                  ),
            hintText: Locales.string(context, "search"),
            contentPadding: EdgeInsets.fromLTRB(15, 15, 15, 15),
            hintStyle: Utils.googleFontStyle(
                1,
                Dimens.medium14TextSize,
                FontStyle.normal,
                Constant.isDarkMode ? white : black,
                FontWeight.w500),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  width: 1, color: Constant.isDarkMode ? white : black),
              borderRadius: BorderRadius.circular(10.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  width: 1, color: Constant.isDarkMode ? white : black),
              borderRadius: BorderRadius.circular(10.0),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  width: 1, color: Constant.isDarkMode ? white : black),
              borderRadius: BorderRadius.circular(10.0),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(width: 1, color: white),
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      );
    });
  }

// New Tab bar Started
  /* Only title show the home page click and open the search page */
  Widget _buildTab() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _titleBuild("2", FontAwesomeIcons.book, "books", () {
              searchProvider.setTab("2");
              searchProvider.clearData();
              _fetchData(searchProvider.currentIndex, 0);
            }),
            _titleBuild("3", FontAwesomeIcons.newspaper, "magazines", () {
              searchProvider.setTab("3");
              searchProvider.clearData();
              _fetchData(searchProvider.currentIndex, 0);
            }),
            _titleBuild("1", Icons.audio_file_rounded, "audio_book", () {
              searchProvider.setTab("1");
              searchProvider.clearData();
              _fetchData(searchProvider.currentIndex, 0);
            }),
          ],
        ));
  }

  Widget _titleBuild(index, iconData, title, onTap) {
    return InkWell(
      splashColor: transparent,
      hoverColor: transparent,
      focusColor: transparent,
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 10, left: 10),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        decoration: BoxDecoration(
            color: Constant.isDarkMode
                ? searchProvider.currentIndex == index
                    ? colorPrimary
                    : transparent
                : searchProvider.currentIndex == index
                    ? colorPrimary
                    : transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              width: 1,
              style: BorderStyle.solid,
              color: Constant.isDarkMode
                  ? searchProvider.currentIndex == index
                      ? colorPrimary
                      : gray
                  : colorPrimary,
            ),
          ),
        child: Row(
          children: [
            Icon(
              color: Constant.isDarkMode
                  ? searchProvider.currentIndex == index
                      ? colorPrimary
                      : white
                  : searchProvider.currentIndex == index
                      ? white
                      : black,
              iconData,
              size: 16,
            ),
            SizedBox(width: 6),
            MyText(
              color: Constant.isDarkMode
                  ? searchProvider.currentIndex == index
                      ? colorPrimary
                      : white
                  : searchProvider.currentIndex == index
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
  }

/* Book Data Started */

  Widget _buildBookData() {
    if (searchProvider.loading && !searchProvider.loadMore) {
      return searchBooklistShimmer();
    } else {
      /* Book, audio book and magazine both UI Show */
      if (widget.showType == "all") {
        if (searchProvider.currentIndex == "1") {
          if ((searchProvider.audioList?.length ?? 0) > 0 &&
              searchProvider.audioList != null) {
            return SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  searchBooklist(searchProvider.audioList ?? []),
                  SizedBox(height: 20),
                  /* add pagination loader here */

                  if (searchProvider.loadMore)
                    Utils.pageLoader(context)
                  else
                    const SizedBox.shrink(),
                  const SizedBox(height: 20),
                ],
              ),
            );
          } else {
            return NoData();
          }
        } else if (searchProvider.currentIndex == "2") {
          if ((searchProvider.bookList?.length ?? 0) > 0 &&
              searchProvider.bookList != null) {
            return SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  searchBooklist(searchProvider.bookList ?? []),
                  const SizedBox(height: 20),
                  /* add pagination loader here */

                  if (searchProvider.loadMore)
                    Utils.pageLoader(context)
                  else
                    const SizedBox.shrink(),
                  const SizedBox(height: 20),
                ],
              ),
            );
          } else {
            return NoData();
          }
        } else {
          if ((searchProvider.magazineList?.length ?? 0) > 0 &&
              searchProvider.magazineList != null) {
            return SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  searchBooklist(searchProvider.magazineList ?? []),
                  const SizedBox(height: 20),
                  if (searchProvider.loadMore)
                    Utils.pageLoader(context)
                  else
                    const SizedBox.shrink(),
                  const SizedBox(height: 20),
                ],
              ),
            );
          } else {
            return NoData();
          }
        }
      } else if (widget.showType == "audiobook") {
        if ((searchProvider.audioList?.length ?? 0) > 0 &&
            searchProvider.audioList != null) {
          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                searchBooklist(searchProvider.audioList ?? []),
                SizedBox(height: 20),
                if (searchProvider.loadMore)
                  Utils.pageLoader(context)
                else
                  const SizedBox.shrink(),
                const SizedBox(height: 20),
              ],
            ),
          );
        } else {
          return NoData();
        }
      } else if (widget.showType == "magazine") {
        if ((searchProvider.magazineList?.length ?? 0) > 0 &&
            searchProvider.magazineList != null) {
          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                searchBooklist(searchProvider.magazineList ?? []),
                const SizedBox(height: 20),
                if (searchProvider.loadMore)
                  Utils.pageLoader(context)
                else
                  const SizedBox.shrink(),
                const SizedBox(height: 20),
              ],
            ),
          );
        } else {
          return NoData();
        }
      } else {
        return SizedBox.shrink();
      }
    }
  }

  Widget searchBooklist(commanList) {
    return ResponsiveGridList(
      minItemWidth: 200,
      minItemsPerRow: 2,
      maxItemsPerRow: 4,
      listViewBuilderOptions: ListViewBuilderOptions(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
      children: List.generate(
        commanList?.length ?? 0,
        (index) {
          final allDataList = commanList?[index];

          final accessInfo = getAccessInfo(
            accessType: allDataList.accessType.toString(),
            isBuy: allDataList.isBuy.toString(),
            isSubscription: Constant.isSubscription ?? 0,
            price: allDataList.price?.toString(),
          );

          return InkWell(
            onTap: () => _handleNavigation(allDataList),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyNetworkImage(
                  imagePath: allDataList?.portraitImg ?? "",
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  radius: 10,
                ),
                const SizedBox(height: 8),
                MyText(
                  text: allDataList?.title ?? "",
                  fontsize: Dimens.medium14TextSize,
                  maxline: 1,
                  fontstyle: FontStyle.italic,
                  fontwaight: FontWeight.w500,
                ),
                const SizedBox(height: 2),
                MyText(
                  text: "By ${allDataList?.authorName ?? ""}",
                  fontsize: Dimens.medium12TextSize,
                  maxline: 1,
                  fontwaight: FontWeight.w400,
                ),
                const SizedBox(height: 2),
                MyText(
                  text: allDataList?.categoryName ?? "",
                  fontsize: Dimens.medium12TextSize,
                  maxline: 1,
                  fontwaight: FontWeight.w400,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    MyText(
                      text: allDataList?.avgReviews.toString() ?? "",
                      fontsize: Dimens.medium12TextSize,
                      maxline: 1,
                      fontwaight: FontWeight.w400,
                    ),
                    const SizedBox(width: 5),
                    RatingBar.readOnly(
                      filledIcon: Icons.star,
                      emptyIcon: Icons.star_border,
                      initialRating: double.tryParse(
                              allDataList?.avgReviews.toString() ?? "0") ??
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
                            "(${Utils.kmbGenerator(allDataList?.totalReviews ?? 0)})",
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
                  color: accessInfo.badgeTextColor,
                  fontsize: Dimens.medium14TextSize,
                  maxline: 1,
                  fontwaight: FontWeight.w600,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

// Extract navigation logic to a separate method for clarity
  void _handleNavigation(dynamic allDataList) {
    if (widget.showType == "all") {
      if (searchProvider.currentIndex == "1") {
        _openPage(WebAudioBookDetails(
          contentId: allDataList?.id.toString(),
          authorId: allDataList?.authorId.toString(),
          categoryId: allDataList?.categoryId.toString(),
          name: allDataList?.title.toString(),
        ));
      } else if (searchProvider.currentIndex == "2") {
        _openPage(WebDetails(
          contentId: allDataList?.id.toString(),
          authorId: allDataList?.authorId.toString() ?? "",
          categoryId: allDataList?.categoryId.toString(),
          name: allDataList?.title.toString(),
        ));
      } else {
        _openPage(WebMagazineDetails(
          contentId: allDataList?.id.toString(),
          categoryId: allDataList?.categoryId.toString(),
          name: allDataList?.title.toString(),
        ));
      }
    } else if (widget.showType == "audiobook") {
      _openPage(WebAudioBookDetails(
        contentId: allDataList?.id.toString(),
        authorId: allDataList?.authorId.toString(),
        categoryId: allDataList?.categoryId.toString(),
        name: allDataList?.title.toString(),
      ));
    } else {
      _openPage(WebMagazineDetails(
        contentId: allDataList?.id.toString(),
        categoryId: allDataList?.categoryId.toString(),
        name: allDataList?.title.toString(),
      ));
    }
  }

  void _openPage(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
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
      ),
    );
  }

  Widget searchBooklistShimmer() {
    final screenWidth = MediaQuery.of(context).size.width;

    // Determine number of columns based on screen width
    int crossAxisCount = 2;
    if (screenWidth >= 1200) {
      crossAxisCount = 4;
    } else if (screenWidth >= 800) {
      crossAxisCount = 3;
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.6,
      ),
      itemCount: 8, // number of shimmer items
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image shimmer
            const CustomWidget.roundcorner(
              height: 180,
              width: double.infinity,
            ),
            const SizedBox(height: 8),

            // Title shimmer
            const CustomWidget.roundrectborder(
              height: 16,
              width: 120,
            ),
            const SizedBox(height: 4),

            // Author shimmer
            const CustomWidget.roundrectborder(
              height: 14,
              width: 100,
            ),
            const SizedBox(height: 4),

            // Category shimmer
            const CustomWidget.roundrectborder(
              height: 14,
              width: 80,
            ),
            const SizedBox(height: 4),

            // Rating shimmer
            Row(
              children: const [
                CustomWidget.roundrectborder(
                  height: 14,
                  width: 20,
                ),
                SizedBox(width: 5),
                CustomWidget.roundrectborder(
                  height: 14,
                  width: 50,
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Price shimmer
            const CustomWidget.roundrectborder(
              height: 16,
              width: 60,
            ),
          ],
        );
      },
    );
  }
}
