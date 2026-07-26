import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:yourappname/pages/audiobookdetails.dart';
import 'package:yourappname/pages/bookdetails.dart';
import 'package:yourappname/pages/magazinedetails.dart';
import 'package:yourappname/provider/profileprovider.dart';
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
import 'package:readmore/readmore.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class Auther extends StatefulWidget {
  final String? autherUserID;
  const Auther({super.key, required this.autherUserID});

  @override
  State<Auther> createState() => _AutherState();
}

class _AutherState extends State<Auther> {
  late ProfileProvider profileProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getAPI();
    });
    super.initState();
  }

  getAPI() {
    profileProvider.setLoding(true);
    profileProvider.getProfile(widget.autherUserID ?? "");
    _fetchData(profileProvider.selectedType ?? "", 0);
  }

  _scrollListener() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (profileProvider.currentPage ?? 0) < (profileProvider.totalPage ?? 0)) {
      profileProvider.setLoadMore(true);

      _fetchData(
          profileProvider.selectedType ?? "", profileProvider.currentPage ?? 0);
    }
  }

  _fetchData(type, int? nextPage) {
    if (type == "1") {
      profileProvider.getSectionAudio(
          type, widget.autherUserID, (nextPage ?? 0) + 1);
    } else if (type == "2") {
      profileProvider.getSectionBook(
          type, widget.autherUserID, (nextPage ?? 0) + 1);
    } else {
      profileProvider.getSectionMagazine(
          type, widget.autherUserID, (nextPage ?? 0) + 1);
    }
  }

  @override
  void dispose() {
    profileProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: transparent,
        leading: Utils.backButton(context),
        actions: [
          Container(
            padding: const EdgeInsets.all(8),
            margin: EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
                color: Constant.isDarkMode ? colorPrimaryDark : transparent,
                borderRadius: BorderRadius.circular(44),
                border: Border.all(
                    width: 1,
                    color:
                        Constant.isDarkMode ? colorPrimaryDark : colorPrimary,
                    style: BorderStyle.solid)),
            child: MyText(
              color: colorPrimary,
              text: "author",
              multilanguage: true,
              fontsize: Dimens.smallTextSize,
              fontwaight: FontWeight.w600,
            ),
          )
        ],
      ),
      body:
          Consumer<ProfileProvider>(builder: (context, profileProvider, child) {
        return SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAutherProfile(),
              const SizedBox(height: 10),
              _buildTab(),
              const SizedBox(height: 20),
              _buildTabbarData(),
              const SizedBox(height: 20),
            ],
          ),
        );
      }),
    );
  }

  Widget addBookButton() {
    return InkWell(
      onTap: () {},
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5), color: colorPrimary),
          child: const MyText(
            text: 'add_books',
            fontsize: Dimens.medium14TextSize,
            multilanguage: true,
            fontwaight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget addMagazineButton() {
    return InkWell(
      onTap: () {},
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          padding: const EdgeInsets.fromLTRB(25, 10, 25, 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5), color: colorPrimary),
          child: const MyText(
            text: 'add_magazine',
            fontsize: Dimens.medium14TextSize,
            multilanguage: true,
            fontwaight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget shimmer() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CustomWidget.circular(
                height: 100,
                width: 100,
              ),
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomWidget.roundrectborder(
                  height: 10,
                  width: 80,
                ),
                Icon(
                  Icons.verified,
                  color: ligthDark,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: [
                    CustomWidget.roundrectborder(height: 20, width: 20),
                    SizedBox(height: 5),
                    CustomWidget.roundrectborder(height: 20, width: 40)
                  ]),
                  Column(children: [
                    CustomWidget.roundrectborder(height: 20, width: 20),
                    SizedBox(height: 5),
                    CustomWidget.roundrectborder(height: 20, width: 40)
                  ]),
                  Column(children: [
                    CustomWidget.roundrectborder(height: 20, width: 20),
                    SizedBox(height: 5),
                    CustomWidget.roundrectborder(height: 20, width: 40)
                  ])
                ]),
            const SizedBox(height: 20),
            CustomWidget.roundrectborder(
                height: 16, width: MediaQuery.of(context).size.width),
            SizedBox(height: 4),
            CustomWidget.roundrectborder(
                height: 16, width: MediaQuery.of(context).size.width),
            SizedBox(height: 4),
            CustomWidget.roundrectborder(
                height: 16, width: MediaQuery.of(context).size.width),
            SizedBox(height: 4),
            CustomWidget.roundrectborder(
                height: 16, width: MediaQuery.of(context).size.width),
            SizedBox(height: 4),
            CustomWidget.roundrectborder(
                height: 16, width: MediaQuery.of(context).size.width),
            SizedBox(height: 4),
            CustomWidget.roundrectborder(
                height: 16, width: MediaQuery.of(context).size.width),
            SizedBox(height: 4),
            CustomWidget.roundrectborder(
                height: 16, width: MediaQuery.of(context).size.width),
            SizedBox(height: 4),
            CustomWidget.roundrectborder(height: 16, width: 250),
            SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildAutherProfile() {
    if (profileProvider.loading) {
      return shimmer();
    } else {
      if (profileProvider.profileModel.status == 200 &&
          profileProvider.profileModel.result != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: MyNetworkImage(
                  width: 100,
                  height: 100,
                  radius: 200,
                  fit: BoxFit.fill,
                  imagePath:
                      profileProvider.profileModel.result?[0].image ?? ""),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  fit: FlexFit.loose,
                  child: MyText(
                    text:
                        "${profileProvider.profileModel.result?[0].firstName ?? ""} ${profileProvider.profileModel.result?[0].lastName ?? ""}",
                    fontsize: Dimens.medium15TextSize,
                    fontwaight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 10),
                const Icon(
                  Icons.verified,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildUserDe(
                    title: profileProvider.profileModel.result?[0].totalNovels
                            .toString() ??
                        "",
                    subTitle: "book"),
                _buildUserDe(
                    title: profileProvider
                            .profileModel.result?[0].totalAudioBooks
                            .toString() ??
                        "",
                    subTitle: "audio_book"),
                _buildUserDe(
                    title: profileProvider
                            .profileModel.result?[0].totalMagazines
                            .toString() ??
                        "",
                    subTitle: "magazine"),
              ],
            ),
            const SizedBox(height: 20),
            ReadMoreText(
              profileProvider.profileModel.result?[0].description ?? "",
              trimLines: 5,
              trimMode: TrimMode.Line,
              textAlign: TextAlign.justify,
              isExpandable: true,
              trimCollapsedText: "Read More",
              trimExpandedText: "Read Less",
              moreStyle: Utils.googleFontStyle(2, Dimens.medium15TextSize,
                  FontStyle.normal, colorAccent, FontWeight.w700),
              lessStyle: Utils.googleFontStyle(2, Dimens.medium15TextSize,
                  FontStyle.normal, colorAccent, FontWeight.w700),
              style: Utils.googleFontStyle(2, Dimens.medium15TextSize,
                  FontStyle.normal, gray, FontWeight.w500),
            ),
          ],
        );
      } else {
        return SizedBox.shrink();
      }
    }
  }

  Widget autherBookShimmer() {
    return AlignedGridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        itemCount: 10,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (BuildContext context, int position) {
          return Container(
            height: MediaQuery.sizeOf(context).height * 0.17,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                boxShadow: [
                  BoxShadow(
                      blurRadius: 5,
                      color: colorPrimary.withOpacity( 0.49))
                ]),
            child: Column(
              children: [
                const CustomWidget.roundcorner(
                    height: 80,
                    shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(5)))),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(5),
                          bottomRight: Radius.circular(5))),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomWidget.rectangular(
                        height: 6,
                        width: 60,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: CustomWidget.rectangular(
                              height: 12,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: CustomWidget.rectangular(
                              height: 12,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Widget _buildUserDe({String? title, String? subTitle}) {
    return Column(
      children: [
        MyText(
          text: title ?? "",
          fontsize: Dimens.medium16TextSize,
          fontwaight: FontWeight.w500,
        ),
        MyText(
          text: subTitle ?? "",
          multilanguage: true,
          fontsize: Dimens.medium14TextSize,
          fontwaight: FontWeight.w400,
        )
      ],
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
              profileProvider.setType("1");
              profileProvider.clearData();
              _fetchData(profileProvider.selectedType, 0);
            }),
            _titleBuild("2", FontAwesomeIcons.book, "books", () {
              profileProvider.setType("2");
              profileProvider.clearData();
              _fetchData(profileProvider.selectedType, 0);
            }),
            _titleBuild("3", FontAwesomeIcons.newspaper, "magazines", () {
              profileProvider.setType("3");
              profileProvider.clearData();
              _fetchData(profileProvider.selectedType, 0);
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
                ? profileProvider.selectedType == index
                    ? colorPrimaryDark
                    : transparent
                : profileProvider.selectedType == index
                    ? colorPrimary
                    : transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              width: 1,
              style: BorderStyle.solid,
              color: Constant.isDarkMode
                  ? profileProvider.selectedType == index
                      ? colorPrimary
                      : gray
                  : colorPrimary,
            )),
        child: Row(
          children: [
            Icon(
              color: Constant.isDarkMode
                  ? profileProvider.selectedType == index
                      ? colorPrimary
                      : white
                  : profileProvider.selectedType == index
                      ? white
                      : black,
              iconData,
              size: 16,
            ),
            SizedBox(width: 6),
            MyText(
              color: Constant.isDarkMode
                  ? profileProvider.selectedType == index
                      ? colorPrimary
                      : white
                  : profileProvider.selectedType == index
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

  Widget _buildTabbarData() {
    if (profileProvider.contentLoading && !profileProvider.loadMore) {
      return autherShimmer();
    } else {
      if (profileProvider.selectedType == "1") {
        if (profileProvider.audioList != null &&
            (profileProvider.audioList?.length ?? 0) > 0) {
          return Column(
            children: [
              _buildBookMagazine(profileProvider.audioList ?? []),
              if (profileProvider.loadMore)
                Utils.pageLoader(context)
              else
                const SizedBox.shrink(),
              const SizedBox(height: 30),
            ],
          );
        } else {
          return NoData();
        }
      } else if (profileProvider.selectedType == "2") {
        if (profileProvider.bookList != null &&
            (profileProvider.bookList?.length ?? 0) > 0) {
          return Column(
            children: [
              _buildBookMagazine(profileProvider.bookList ?? []),
              if (profileProvider.loadMore)
                Utils.pageLoader(context)
              else
                const SizedBox.shrink(),
              const SizedBox(height: 30),
            ],
          );
        } else {
          return NoData();
        }
      } else {
        if (profileProvider.magazineList != null &&
            (profileProvider.magazineList?.length ?? 0) > 0) {
          return Column(
            children: [
              _buildBookMagazine(profileProvider.magazineList ?? []),
              if (profileProvider.loadMore)
                Utils.pageLoader(context)
              else
                const SizedBox.shrink(),
              const SizedBox(height: 30),
            ],
          );
        } else {
          return NoData();
        }
      }
    }
  }

  Widget _buildBookMagazine(commanList) {
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
                if (profileProvider.selectedType == "1") {
                  Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return AudioBookDetails(
                            contentId: bookDataList?.id.toString() ?? "",
                            authorId: bookDataList?.authorId.toString() ?? "",
                            categoryId:
                                bookDataList?.categoryId.toString() ?? "",
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
                } else if (profileProvider.selectedType == "2") {
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
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
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
