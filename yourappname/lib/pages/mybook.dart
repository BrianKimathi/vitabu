import 'package:yourappname/pages/audiobookdetails.dart';
import 'package:yourappname/pages/bookdetails.dart';
import 'package:yourappname/pages/magazinedetails.dart';
import 'package:yourappname/provider/walletprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class MyBook extends StatefulWidget {
  const MyBook({super.key});

  @override
  State<MyBook> createState() => _MyBookState();
}

class _MyBookState extends State<MyBook> {
  final ScrollController _scrollController = ScrollController();
  late WalletProvider walletProvider;

  @override
  void initState() {
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getApi();
    });
    super.initState();
  }

  getApi() {
    walletProvider.setLoading(true);
    fetchTransactionthistory("1", 0);
    walletProvider.setTab("1");
  }

  _scrollListener() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if ((walletProvider.currentPage ?? 0) < (walletProvider.totalPage ?? 0)) {
        walletProvider.setLoadMore(true);
        fetchTransactionthistory(
            walletProvider.currentIndex, walletProvider.currentPage ?? 0);
      }
    }
  }

  fetchTransactionthistory(type, int? nextPage) {
    walletProvider.setLoading(true);
    walletProvider.getTransactionHistory(type, (nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    walletProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.isDarkMode ? appbarcolor : white,
      appBar: Utils.cusstomAppBar(
          name: "my_books", multilanguage: true, context: context),
      body: Consumer<WalletProvider>(builder: (context, walletProvider, child) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 00, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [
              _buildTab(),
              Expanded(
                child: _buildMain(),
              )
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
              walletProvider.setTab("1");
              walletProvider.clearData();
              fetchTransactionthistory(walletProvider.currentIndex, 0);
            }),
            _titleBuild("2", FontAwesomeIcons.book, "books", () {
              walletProvider.setTab("2");
              walletProvider.clearData();
              fetchTransactionthistory(walletProvider.currentIndex, 0);
            }),
            _titleBuild("3", FontAwesomeIcons.newspaper, "magazines", () {
              walletProvider.setTab("3");
              walletProvider.clearData();
              fetchTransactionthistory(walletProvider.currentIndex, 0);
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
                ? walletProvider.currentIndex == index
                    ? colorPrimaryDark
                    : transparent
                : walletProvider.currentIndex == index
                    ? colorPrimary
                    : transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              width: 1,
              style: BorderStyle.solid,
              color: Constant.isDarkMode
                  ? walletProvider.currentIndex == index
                      ? colorPrimary
                      : gray
                  : colorPrimary,
            )),
        child: Row(
          children: [
            Icon(
              color: Constant.isDarkMode
                  ? walletProvider.currentIndex == index
                      ? colorPrimary
                      : white
                  : walletProvider.currentIndex == index
                      ? white
                      : black,
              iconData,
              size: 16,
            ),
            SizedBox(width: 6),
            MyText(
              color: Constant.isDarkMode
                  ? walletProvider.currentIndex == index
                      ? colorPrimary
                      : white
                  : walletProvider.currentIndex == index
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

  Widget _buildMain() {
    if (walletProvider.loading && !walletProvider.loadMore) {
      return shimmerBookMark();
    } else {
      if (walletProvider.transactionHistory != null &&
          (walletProvider.transactionHistory?.length ?? 0) > 0) {
        return SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildData(),
                const SizedBox(height: 10),
                if (walletProvider.loadMore)
                  Utils.pageLoader(context)
                else
                  const SizedBox.shrink(),
                const SizedBox(height: 30),
              ],
            ));
      } else {
        return const NoData();
      }
    }
  }

  Widget _buildData() {
    return ResponsiveGridList(
      minItemWidth: 175,
      minItemsPerRow: 2,
      maxItemsPerRow: 4,
      listViewBuilderOptions: ListViewBuilderOptions(
          shrinkWrap: true, physics: NeverScrollableScrollPhysics()),
      children: List.generate(
        walletProvider.transactionHistory?.length ?? 0,
        (index) {
          final bookMark = walletProvider.transactionHistory?[index];

          return InkWell(
            onTap: () {
              if (walletProvider.currentIndex == "1") {
                Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return AudioBookDetails(
                          contentId: bookMark?.contentId.toString(),
                          authorId: bookMark?.authorId.toString(),
                          categoryId: bookMark?.categoryId.toString(),
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
              } else if (walletProvider.currentIndex == "2") {
                Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return BookDetails(
                          contentId: bookMark?.contentId.toString(),
                          authorId: bookMark?.authorId.toString() ?? "",
                          categoryId: bookMark?.categoryId.toString(),
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
                          contentId: bookMark?.contentId.toString(),
                          categoryId: bookMark?.categoryId.toString(),
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
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).canvasColor),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyNetworkImage(
                    imagePath:
                        ((bookMark?.subContentId.toString() ?? "") == "0")
                            ? bookMark?.contentImage ?? ""
                            : bookMark?.subContentImage ?? "",
                    height: 200,
                    width: MediaQuery.sizeOf(context).width,
                    fit: BoxFit.fill,
                    radius: 10,
                  ),
                  SizedBox(height: 8),
                  MyText(
                    text: ((bookMark?.subContentId.toString() ?? "") == "0")
                        ? "Book : ${bookMark?.contentName ?? ""}"
                        : "Episode : ${bookMark?.subContentName ?? ""}",
                    fontsize: Dimens.medium16TextSize,
                    maxline: 2,
                    fontwaight: FontWeight.w600,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget shimmerBookMark() {
    return AlignedGridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 20,
      itemCount: 5,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomWidget.roundcorner(height: 254),
            SizedBox(height: 6),
            CustomWidget.roundcorner(height: 16, width: 200),
            SizedBox(height: 4),
            CustomWidget.roundcorner(height: 16, width: 150),
          ],
        );
      },
    );
  }
}
