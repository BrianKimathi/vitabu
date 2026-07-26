import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:yourappname/pages/audiobookdetails.dart';
import 'package:yourappname/pages/bookdetails.dart';
import 'package:yourappname/pages/magazinedetails.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:yourappname/provider/searchprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class Search extends StatefulWidget {
  final String? showType;
  const Search({super.key, required this.showType});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
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
      /* Book, audio book and magazine both pagenation */
      if (widget.showType == "all") {
        _fetchData(
            searchProvider.currentIndex, searchProvider.currentPage ?? 0);
      }
      /* Audio book open the search page only audio book pagenation */
      else if (widget.showType == "audiobook") {
        _fetchData("1", searchProvider.currentPage ?? 0);
      }
      /* Magazine  open the search page only Magazine  data pagenation */
      else if (widget.showType == "magazine") {
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
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: transparent,
        centerTitle: false,
        titleSpacing: 0,
        leading: Utils.backButton(context),
        title: search(),
      ),
      body: Consumer<SearchProvider>(
        builder: (context, searchProvider, child) {
          if (widget.showType == "all") {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 20,
                children: [
                  _buildTab(),
                  Expanded(child: _buildBookData()),
                ],
              ),
            );
          } else {
            return Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                child: _buildBookData());
          }
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
          cursorColor: Constant.isDarkMode ? colorPrimary : colorPrimaryDark,
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
                      searchProvider.setTab("2");
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
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: Constant.isDarkMode
                ? searchProvider.currentIndex == index
                    ? colorPrimaryDark
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
            )),
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
      return _alsolikeShimmer();
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
        }
      }
      /* Audio Book  open the search page only Audio Book  search UI */
      else if (widget.showType == "audiobook") {
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
      }
      /* Magazine  open the search page only Magazine  search UI */
      else if (widget.showType == "magazine") {
        if ((searchProvider.magazineList?.length ?? 0) > 0 &&
            searchProvider.magazineList != null) {
          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                searchBooklist(searchProvider.magazineList ?? []),
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
        return SizedBox.shrink();
      }
    }
  }

  Widget searchBooklist(commanList) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ResponsiveGridList(
        minItemWidth: 140,
        minItemsPerRow: 2,
        maxItemsPerRow: 5,
        listViewBuilderOptions: ListViewBuilderOptions(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics()),
        children: List.generate(
          commanList?.length ?? 0,
          (position) {
            final allDataList = commanList?[position];
            final accessInfo = getAccessInfo(
              accessType: allDataList?.accessType.toString(),
              isBuy: allDataList?.isBuy.toString(),
              isSubscription: Constant.isSubscription ?? 0,
              price: allDataList?.price?.toString(),
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
                  if (widget.showType == "all") {
                    if (searchProvider.currentIndex == "1") {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) {
                              return AudioBookDetails(
                                contentId: allDataList?.id.toString(),
                                authorId: allDataList?.authorId.toString(),
                                categoryId: allDataList?.categoryId.toString(),
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
                    } else if (searchProvider.currentIndex == "2") {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) {
                              return BookDetails(
                                contentId: allDataList?.id.toString(),
                                authorId: allDataList?.authorId.toString() ?? "",
                                categoryId: allDataList?.categoryId.toString(),
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
                                contentId: allDataList?.id.toString(),
                                categoryId: allDataList?.categoryId.toString(),
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
                  } else if (widget.showType == "audiobook") {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) {
                            return AudioBookDetails(
                              contentId: allDataList?.id.toString(),
                              authorId: allDataList?.authorId.toString(),
                              categoryId: allDataList?.categoryId.toString(),
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
                              contentId: allDataList?.id.toString(),
                              categoryId: allDataList?.categoryId.toString(),
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
                            imagePath: allDataList?.portraitImg ?? "",
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
                            allDataList?.title.toString() ?? "",
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
                            "By ${allDataList?.authorName.toString() ?? ''}",
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
                                allDataList?.avgReviews.toString() ?? "0.0",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.grey[300] : const Color(0xFF374151),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "(${Utils.kmbGenerator(allDataList?.totalReviews ?? 0)})",
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

  Widget _alsolikeShimmer() {
    return AlignedGridView.count(
      crossAxisCount: 2,
      itemCount: 25,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
      addRepaintBoundaries: true,
      addAutomaticKeepAlives: true,
      itemBuilder: (context, position) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            CustomWidget.roundrectborder(
              height: 220,
              // width: 160,
            ),
            SizedBox(height: 5),
            Padding(
              padding: EdgeInsets.only(left: 5.0),
              child: CustomWidget.roundrectborder(
                height: 16,
                width: 120,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              spacing: 3,
              children: [
                CustomWidget.circular(height: 16, width: 20),
                Expanded(
                    child: CustomWidget.roundrectborder(height: 15, width: 50))
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: EdgeInsets.only(left: 5.0),
              child: CustomWidget.roundrectborder(
                height: 16,
                width: 120,
              ),
            ),
            SizedBox(height: 5)
          ],
        );
      },
    );
  }
}
