import 'package:yourappname/provider/reviewviewprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class ReviewViewAll extends StatefulWidget {
  final String? type, contentId;
  const ReviewViewAll({super.key, required this.type, required this.contentId});

  @override
  State<ReviewViewAll> createState() => _ReviewViewAllState();
}

class _ReviewViewAllState extends State<ReviewViewAll> {
  final ScrollController _scrollController = ScrollController();
  late ReviewViewProvider reviewViewProvider;

  @override
  void initState() {
    reviewViewProvider =
        Provider.of<ReviewViewProvider>(context, listen: false);
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
        (reviewViewProvider.currentPageComment ?? 0) <
            (reviewViewProvider.totalPageComment ?? 0)) {
      reviewViewProvider.setCommentLoadMore(true);
      getApi((reviewViewProvider.currentPageComment ?? 0));
    }
  }

  getApi(nextPage) {
    reviewViewProvider.setLoading(true);
    reviewViewProvider.getComment(
        widget.type ?? "", widget.contentId ?? "", (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollController.removeListener(_scrollListener);
    reviewViewProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.cusstomAppBar(
          name: "review", multilanguage: true, context: context),
      body: Consumer<ReviewViewProvider>(
          builder: (context, reviewViewProvider, child) {
        return _buildMain();
      }),
    );
  }

  Widget _buildMain() {
    if (reviewViewProvider.commentloading &&
        !reviewViewProvider.commentloadmore) {
      return commentShimmer();
    } else {
      if (reviewViewProvider.commentList != null &&
          (reviewViewProvider.commentList?.length ?? 0) > 0) {
        return SingleChildScrollView(
          controller: _scrollController,
          padding: EdgeInsets.fromLTRB(16, 10, 16, 10),
          physics: BouncingScrollPhysics(),
          child: Column(
            children: [
              _reviewListData(),
              if (reviewViewProvider.commentloadmore)
                Utils.pageLoader(context)
              else
                const SizedBox.shrink(),
              const SizedBox(height: 30),
            ],
          ),
        );
      } else {
        return NoData();
      }
    }
  }

  Widget _reviewListData() {
    return AlignedGridView.count(
      crossAxisCount: 1,
      itemCount: reviewViewProvider.commentList?.length ?? 0,
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 14,
      crossAxisSpacing: 0,
      reverse: true,
      itemBuilder: (context, index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                MyNetworkImage(
                    imagePath: reviewViewProvider.commentList?[index].userImage,
                    fit: BoxFit.fill,
                    height: 30,
                    width: 30,
                    radius: 200),
                const SizedBox(width: 10),
                MyText(
                  text:
                      "${reviewViewProvider.commentList?[index].firstName ?? ""} ${reviewViewProvider.commentList?[index].lastName ?? ""}",
                  maxline: 1,
                  fontsize: Dimens.medium14TextSize,
                  fontwaight: FontWeight.w700,
                ),
              ],
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: MyText(
                    text: reviewViewProvider.commentList?[index].review ?? "",
                    maxline: 1,
                    fontsize: Dimens.medium14TextSize,
                    fontwaight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 15),
                if (reviewViewProvider.commentList?[index].userId.toString() ==
                    Constant.userID)
                  if (reviewViewProvider.deletecommentLoading &&
                      reviewViewProvider.deleteItemIndex == index)
                    const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: colorAccent,
                        strokeWidth: 1,
                      ),
                    )
                  else
                    InkWell(
                        onTap: () async {
                          await reviewViewProvider.getDeleteComment(
                              index,
                              reviewViewProvider.commentList?[index].id
                                      .toString() ??
                                  "");
                        },
                        child: const Icon(
                          Icons.delete,
                          size: 20,
                          color: colorPrimary,
                        )),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget commentShimmer() {
    return AlignedGridView.count(
      shrinkWrap: true,
      crossAxisCount: 1,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      itemCount: 15,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              const CustomWidget.circular(height: 40, width: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidget.rectangular(
                      height: 10,
                      width: MediaQuery.sizeOf(context).width * 0.35,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    CustomWidget.rectangular(
                      height: 7,
                      width: MediaQuery.sizeOf(context).width * 0.15,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: CustomWidget.rectangular(
                        height: 6,
                        width: MediaQuery.sizeOf(context).width * 0.2,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
