import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:yourappname/pages/audiobookdetails.dart';
import 'package:yourappname/pages/bookdetails.dart';
import 'package:yourappname/pages/magazinedetails.dart';
import 'package:yourappname/provider/bookdetailsprovider.dart';
import 'package:yourappname/provider/magazinedetailsprovider.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:yourappname/provider/releteditemprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class ReletedItem extends StatefulWidget {
  final String contentId, type, categoryId;
  const ReletedItem(
      {super.key,
      required this.contentId,
      required this.type,
      required this.categoryId});

  @override
  State<ReletedItem> createState() => _ReletedItemState();
}

class _ReletedItemState extends State<ReletedItem> {
  final ScrollController _scrollController = ScrollController();
  late ReletedItemProvider reletedItemProvider;

  @override
  void initState() {
    super.initState();
    printLog("type == ${widget.type}");
    reletedItemProvider =
        Provider.of<ReletedItemProvider>(context, listen: false);
    _scrollController.addListener(_scrollListener);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    getApi(0);
    // });
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
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: transparent,
        leading: Utils.backButton(context),
        title: MyText(
          text: "similar_book",
          maxline: 1,
          multilanguage: true,
          fontsize: Dimens.medium20TextSize,
          fontwaight: FontWeight.w700,
        ),
      ),
      body: Consumer<ReletedItemProvider>(
          builder: (context, reletedItemProvider, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTabbarData(),
            if (reletedItemProvider.loadmore)
              Utils.pageLoader(context)
            else
              const SizedBox.shrink(),
            const SizedBox(height: 20),
          ],
        );
      }),
    );
  }

  Widget _buildTabbarData() {
    if (reletedItemProvider.loading && !reletedItemProvider.loadmore) {
      return Expanded(child: shimmer());
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
        controller: _scrollController,
        padding: EdgeInsets.only(top: 12),
        physics: BouncingScrollPhysics(),
        child: _buildCommanWidget(reletedItemProvider.audioList ?? []),
      );
    } else {
      return NoData();
    }
  }

  Widget _buildBoook() {
    if (reletedItemProvider.bookList != null &&
        (reletedItemProvider.bookList?.length ?? 0) > 0) {
      return SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(top: 12),
        physics: BouncingScrollPhysics(),
        child: _buildCommanWidget(reletedItemProvider.bookList ?? []),
      );
    } else {
      return NoData();
    }
  }

  Widget _buildMagazine() {
    if (reletedItemProvider.magazineList != null &&
        (reletedItemProvider.magazineList?.length ?? 0) > 0) {
      return SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.only(top: 12),
        physics: BouncingScrollPhysics(),
        child: _buildCommanWidget(reletedItemProvider.magazineList ?? []),
      );
    } else {
      return NoData();
    }
  }

  Widget _buildCommanWidget(commanList) {
    return ResponsiveGridList(
        minItemWidth: 140,
        minItemsPerRow: 2,
        maxItemsPerRow: 4,
        horizontalGridMargin: 15,
        verticalGridMargin: 10,
        horizontalGridSpacing: 20,
        verticalGridSpacing: 20,
        listViewBuilderOptions: ListViewBuilderOptions(
            shrinkWrap: true, physics: NeverScrollableScrollPhysics()),
        children: List.generate(
          commanList?.length ?? 0,
          (position) {
            final allDataList = commanList?[position];
            final accessInfo = getAccessInfo(
              accessType: allDataList.accessType.toString(),
              isBuy: allDataList.isBuy.toString(),
              isSubscription: Constant.isSubscription ?? 0,
              price: allDataList.price?.toString(),
            );
            return InkWell(
              splashColor: transparent,
              hoverColor: transparent,
              focusColor: transparent,
              onTap: () {
                if (widget.type == "1") {
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return AudioBookDetails(
                        categoryId: allDataList?.categoryId.toString() ?? "",
                        contentId: allDataList?.id.toString() ?? "",
                        authorId: allDataList?.authorId.toString(),
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
                } else if (widget.type == "2") {
                  final bookDetailsProvider =
                      Provider.of<BookDetailsProvider>(context, listen: false);

                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return BookDetails(
                        categoryId: allDataList?.categoryId.toString() ?? "",
                        authorId: allDataList?.authorId.toString() ?? "",
                        contentId: allDataList?.id.toString() ?? "",
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
                  bookDetailsProvider.clearProvider();
                } else {
                  final magazineDetailsProvider =
                      Provider.of<MagazineDetailsProvider>(context,
                          listen: false);
                  Navigator.of(context).push(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return MagazineDetails(
                        contentId: allDataList?.id.toString() ?? "",
                        categoryId: allDataList?.categoryId.toString() ?? "",
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
                  magazineDetailsProvider.clearProvider();
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyNetworkImage(
                      imagePath: allDataList?.portraitImg.toString() ?? "",
                      height: 200,
                      width: MediaQuery.sizeOf(context).width,
                      radius: 10,
                      fit: BoxFit.cover),
                  const SizedBox(height: 7),
                  MyText(
                    text: allDataList?.title.toString() ?? "",
                    fontsize: Dimens.medium14TextSize,
                    maxline: 1,
                    fontstyle: FontStyle.italic,
                    fontwaight: FontWeight.w500,
                  ),
                  const SizedBox(height: 2),
                  MyText(
                    text: "By ${allDataList?.authorName.toString() ?? ""}",
                    fontsize: Dimens.medium12TextSize,
                    maxline: 1,
                    fontwaight: FontWeight.w400,
                  ),
                  const SizedBox(height: 2),
                  MyText(
                    text: allDataList?.categoryName.toString() ?? "",
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
                        initialRating: double.parse(
                            allDataList?.avgReviews.toString() ?? ""),
                        emptyColor: gray,
                        filledColor: colorAccent,
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

  Widget shimmer() {
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
      itemBuilder: (context, index) {
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
                height: 20,
                width: 120,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                CustomWidget.circular(
                  height: 20,
                  width: 20,
                ),
                Expanded(
                    child: CustomWidget.roundrectborder(
                  height: 15,
                  width: 50,
                ))
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Padding(
              padding: EdgeInsets.only(left: 5.0),
              child: CustomWidget.roundrectborder(
                height: 20,
                width: 120,
              ),
            ),
            SizedBox(
              height: 5,
            )
          ],
        );
      },
    );
  }
}
