// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:yourappname/pages/bookepubshow.dart';
import 'package:yourappname/provider/bookdetailsprovider.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/provider/releteditemprovider.dart';
import 'package:yourappname/provider/reviewviewprovider.dart';
import 'package:yourappname/subscription/allpayment.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webpages/webauthor.dart';
import 'package:yourappname/webpages/webpdfviewer.dart';
import 'package:yourappname/webpages/webprofile.dart' hide SizedBox, Container, Row;
import 'package:yourappname/webpages/webreleteddata.dart';
import 'package:yourappname/webwidget/footerweb.dart';
import 'package:yourappname/webwidget/interactivecontainer.dart';
import 'package:yourappname/webwidget/webappbar.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/icons/ri.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

const _indigo = Color(0xFF4E45B8);

class WebDetails extends StatefulWidget {
  final String? contentId, categoryId, authorId, name, type;
  final bool? isFromHome;
  const WebDetails(
      {super.key,
      required this.contentId,
      required this.categoryId,
      required this.authorId,
      required this.name,
      this.type,
      this.isFromHome});

  @override
  State<WebDetails> createState() => _WebDetailsState();
}

class _WebDetailsState extends State<WebDetails> {
  late ReviewViewProvider reviewViewProvider;
  BookDetailsProvider bookDetailsProvider = BookDetailsProvider();
  ScrollController controller = ScrollController();
  final ScrollController _scrollController = ScrollController();
  double? ratingGiven;
  final commentController = TextEditingController();
  dynamic strDeviceToken;
  String? platformType;

  @override
  void initState() {
    super.initState();
    reviewViewProvider =
        Provider.of<ReviewViewProvider>(context, listen: false);
    bookDetailsProvider =
        Provider.of<BookDetailsProvider>(context, listen: false);
    _scrollController.addListener(_scrollListener);
    printLog("My Category Ids is ${widget.categoryId}");
    webReadBookLog('WEB_DETAILS_INIT',
        'contentId=${widget.contentId} categoryId=${widget.categoryId} authorId=${widget.authorId} name=${widget.name} type=${widget.type} isFromHome=${widget.isFromHome}');
    _getDeviceToken();
    getApi();
    bookDetailsProvider.getRelatedItems(
        "2", widget.categoryId ?? "", widget.contentId ?? "", 1);
  }

  _scrollListener() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (reviewViewProvider.currentPageComment ?? 0) <
            (reviewViewProvider.totalPageComment ?? 0)) {
      reviewViewProvider.setCommentLoadMore(true);
      fetchreviewData((reviewViewProvider.currentPageComment ?? 0));
    }
  }

  Future getApi() async {
    bookDetailsProvider.clearCommentData();
    webReadBookLog(
        'WEB_DETAILS_getApi_START', 'contentId=${widget.contentId}');
    await bookDetailsProvider.getBookDetails("2", widget.contentId);
    webReadBookLog('WEB_DETAILS_getApi_AFTER_BOOK_DETAIL',
        'provider.loading=${bookDetailsProvider.loading} status=${bookDetailsProvider.bookDetailModel.status} hasResult=${bookDetailsProvider.bookDetailModel.result != null}');
    await fetchTabData(1);
    await fetchreviewData(0);
    webReadBookLog('WEB_DETAILS_getApi_COMPLETE', 'chapters=${bookDetailsProvider.chaptersList?.length}');
  }

  void _webLogReadBookButton(
    String layoutLabel, {
    required dynamic bookDe,
    required String ex,
    required bool goToSubscription,
    required bool goToPayment,
    required bool isFreeAccess,
  }) {
    webReadBookLog(
      'READ_BOOK_BTN_$layoutLabel',
      'userId=${Constant.userID} bookId=${bookDe?.id} extension=$ex '
      'isFreeAccess=$isFreeAccess goToSubscription=$goToSubscription goToPayment=$goToPayment '
      'fullNovel=${webReadBookFormatPdfUrl(bookDe?.fullNovel?.toString())}',
    );
  }

  bool _hasReadableFileUrl(dynamic rawUrl) {
    final url = (rawUrl?.toString() ?? '').trim();
    return url.isNotEmpty;
  }

  void _showMissingBookFileError(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Book file is missing. Please upload the file again in admin panel.',
        ),
      ),
    );
  }

/* Chapter data */
  Future fetchTabData(int? pageNo) async {
    await bookDetailsProvider.getChapterbyBook(
        widget.contentId ?? "", (pageNo ?? 1));
  }

/*Review Data */
  Future fetchreviewData(int? pageNo) async {
    await bookDetailsProvider.getComment(
        "2", widget.contentId ?? "", ((pageNo ?? 0) + 1));
  }

  _getDeviceToken() async {
    if (kIsWeb) {
      platformType = "3";
      strDeviceToken = "123";
    } else if (Platform.isAndroid) {
      platformType = "1";
      strDeviceToken = await FirebaseMessaging.instance.getToken();
    } else if (Platform.isIOS) {
      platformType = "2";
      strDeviceToken = OneSignal.User.pushSubscription.id.toString();
    }
  }

  @override
  void dispose() {
    bookDetailsProvider.clearProvider();
    _scrollController.removeListener(_scrollListener);
    reviewViewProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxContentWidth = 1400;
    final contentWidth =
        screenWidth > maxContentWidth ? maxContentWidth : screenWidth - 20;

    return WebAppBar(
      widget: Consumer<BookDetailsProvider>(
        builder: (context, bookDetailsProvider, child) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              spacing: 20,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: contentWidth,
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth <= 1000 ? 10 : 0),
                    child: Utils.buildWebDetailsAppBar(
                      context: context,
                      isHome: true,
                      title2: widget.name ?? "",
                      multilanguage: false,
                      isFromHomeRedirect: widget.isFromHome ?? false,
                    ),
                  ),
                ),
                Center(
                    child: SizedBox(
                        width: contentWidth,
                        child: buildResponsiveLayout(context))),
                Center(
                    child: SizedBox(
                        width: contentWidth, child: _buildReletedData())),
                FooterWeb(),
              ],
            ),
          );
        },
      ),
    );
  }

/* Web details data  */
  Widget buildResponsiveLayout(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth > 1000) {
      return SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 5, child: parentConainerWeb()),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: rightLayout(),
              ),
            ),
          ],
        ),
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 20,
        children: [
          parentConainerMobile(),
          Container(
            padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
            color: white,
            child: rightLayoutMobile(),
          ),
        ],
      );
    }
  }

/* Image Section Details */
  Widget parentConainerWeb() {
    if (bookDetailsProvider.loading) {
      return webParentContainerShimmer(context);
    } else {
      if (bookDetailsProvider.bookDetailModel.status == 200 &&
          bookDetailsProvider.bookDetailModel.result != null) {
        final bookDe = bookDetailsProvider.bookDetailModel.result;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            Container(
              alignment: Alignment.center,
              color: const Color(0xFFF8FAFC),
              width: MediaQuery.of(context).size.width * 0.42,
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: AnimatedScale(
                  scale: 1,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: InkWell(
                      onTap: () async {},
                      child: MyNetworkImage(
                        fit: BoxFit.fill,
                        radius: 20,
                        imagePath: bookDe?.landscapeImg ?? "",
                      ),
                    ),
                  ),
                ),
              ),
            ),
            detailsTabData(),
            const SizedBox(height: 20),
            childItem(),
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

/* Mobile Screen */
  Widget parentConainerMobile() {
    if (bookDetailsProvider.loading) {
      return mobileParentContainerShimmer(context);
    } else {
      if (bookDetailsProvider.bookDetailModel.status == 200 &&
          bookDetailsProvider.bookDetailModel.result != null) {
        final bookDe = bookDetailsProvider.bookDetailModel.result;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            FractionallySizedBox(
              widthFactor: 1.0,
              child: Container(
                alignment: Alignment.center,
                color: const Color(0xFFF8FAFC),
                child: AspectRatio(
                  aspectRatio: 5 / 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      onTap: () async {},
                      child: MyNetworkImage(
                        fit: BoxFit.contain,
                        radius: 16,
                        imagePath: bookDe?.landscapeImg ?? "",
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // 🔹 Details
            detailsTabData(),
            const SizedBox(height: 16),
            childItem(),
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget detailsTabData() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              spacing: 24,
              children: [
                _buildTab("1", "description"),
                _buildTab("2", "chapters"),
                _buildTab("3", "reviews", onTap: () => fetchreviewData(0)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Consumer<BookDetailsProvider>(builder: (context, provider, child) {
              return InkWell(
                onTap: () {
                  final bookDe = provider.bookDetailModel.result;
                  if (Utils.checkLoginUser(context)) {
                    provider.getBookMark("2", bookDe?.id ?? "");
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: white,
                    border: Border.all(color: gray, width: 1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                      provider.bookDetailModel.result?.isBookmark == 1
                          ? Icons.bookmark
                          : Icons.bookmark_outline_rounded,
                      color: const Color(0xFF475569)),
                ),
              );
            }),
            const SizedBox(width: 10),
            InkWell(
              onTap: () {
                if (Utils.checkLoginUser(context)) {
                  final base = (Constant.website ?? "https://vitabu.online")
                      .replaceAll(RegExp(r'/$'), '');
                  final bookDe = bookDetailsProvider.bookDetailModel.result;
                  final shareUrl =
                      "$base/?content_type=2&content_id=${bookDe?.id ?? ''}&category_id=${bookDe?.categoryId ?? ''}&author_id=${bookDe?.authorId ?? ''}&name=${Uri.encodeComponent(bookDe?.title ?? '')}";
                  SharePlus.instance.share(ShareParams(
                      text:
                          "${Constant.appName}\n${bookDetailsProvider.bookDetailModel.result?.title ?? ''}\n$shareUrl"));
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: white,
                  border: Border.all(color: gray, width: 1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.share, size: 20, color: const Color(0xFF475569)),
              ),
            ),
          ],
        ),
      ],
    );
  }

// Helper to build a tab
  Widget _buildTab(String tabId, String text, {VoidCallback? onTap}) {
    bool isSelected = bookDetailsProvider.tabDetails == tabId;
    return InkWell(
      splashColor: transparent,
      focusColor: transparent,
      hoverColor: transparent,
      highlightColor: transparent,
      onTap: () {
        bookDetailsProvider.setDetailsTab(tabId);
        if (onTap != null) onTap();
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom:
                BorderSide(width: 2, color: isSelected ? black : transparent),
          ),
        ),
        child: MyText(
          color: black,
          text: text,
          multilanguage: true,
          fontsize: Dimens.medium16TextSize,
          fontsizeWeb: Dimens.medium16TextSize,
          fontwaight: FontWeight.w600,
          maxline: 1,
          overflow: TextOverflow.ellipsis,
          textalign: TextAlign.left,
        ),
      ),
    );
  }

  Widget childItem() {
    final bookDe = bookDetailsProvider.bookDetailModel.result;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 20,
        children: [
          if (bookDetailsProvider.tabDetails == "1") ...[
            // About This Book
            MyText(
              text: "about_this_book",
              maxline: 1,
              multilanguage: true,
              fontsize: Dimens.medium16TextSize,
              fontsizeWeb: Dimens.medium16TextSize,
              fontwaight: FontWeight.w700,
              color: _indigo,
            ),
            ReadMoreText(
              bookDe?.description ?? "",
              trimMode: TrimMode.Line,
              trimLines: 4,
              style: Utils.googleFontStyle(
                  2,
                  Dimens.medium14TextSize,
                  FontStyle.normal,
                  Theme.of(context).textTheme.bodyLarge!.color ?? black,
                  FontWeight.w500),
              colorClickableText: _indigo,
              trimCollapsedText: 'Show more',
              trimExpandedText: 'Show less',
              lessStyle: Utils.googleFontStyle(2, Dimens.medium16TextSize,
                  FontStyle.normal, _indigo, FontWeight.w700),
              moreStyle: Utils.googleFontStyle(2, Dimens.medium16TextSize,
                  FontStyle.normal, _indigo, FontWeight.w700),
            ),
          ] else if (bookDetailsProvider.tabDetails == "2") ...[
            courseEpisodes(),
          ] else if (bookDetailsProvider.tabDetails == "3") ...[
            commentDataWeb(context, "2", widget.contentId ?? "")
          ],
        ],
      ),
    );
  }

  Widget courseEpisodes() {
    final totalChapters =
        bookDetailsProvider.bookDetailModel.result?.totalChapters ?? 0;
    final currentPage = bookDetailsProvider.currentPage ?? 1;
    final totalPage = bookDetailsProvider.totalPage ?? 1;
    final isLoading = bookDetailsProvider.bookChapterLoading;

    if (isLoading && !bookDetailsProvider.loadMore) {
      return chapterShimmer();
    } else {
      if (bookDetailsProvider.chaptersList != null &&
          (bookDetailsProvider.chaptersList?.length ?? 0) > 0) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            MyText(
              text: "${Utils.kmbGenerator(totalChapters)} Chapters",
              maxline: 1,
              multilanguage: false,
              fontsize: Dimens.medium20TextSize,
              fontwaight: FontWeight.w700,
            ),

            episodeList(),

            if (bookDetailsProvider.loadMore) chapterShimmer(),

            if (totalPage > 1)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.end, // Align to the right
                  children: [
                    if (currentPage > 1)
                      InteractiveContainer(
                        child: (isHovered) => InkWell(
                          splashColor: transparent,
                          hoverColor: transparent,
                          onTap: isLoading
                              ? null
                              : () async {
                                  // Disable onTap when loading
                                  final prevPage = currentPage - 1;
                                  bookDetailsProvider.setbookloading(true);
                                  bookDetailsProvider.clearChapterData();
                                  await fetchTabData(prevPage);
                                },
                          child: AnimatedScale(
                            scale: isHovered ? 1.1 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isHovered
                                    ? _indigo
                                    : _indigo.withOpacity( 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.arrow_back_ios_new,
                                size: 20,
                                color: isHovered ? Colors.white : _indigo,
                              ),
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(width: 20),

                    // Page Index Display (e.g., 1 / 5)
                    MyText(
                      text: "$currentPage / $totalPage",
                      multilanguage: false,
                      fontsize: Dimens.medium16TextSize,
                      fontwaight: FontWeight.w500,
                      color: _indigo,
                    ),

                    const SizedBox(width: 20),

                    // ➡️ Right Arrow (Show only if currentPage < totalPage)
                    if (currentPage < totalPage)
                      InteractiveContainer(
                        child: (isHovered) => InkWell(
                          splashColor: transparent,
                          hoverColor: transparent,
                          onTap: isLoading
                              ? null
                              : () async {
                                  final nextPage = currentPage + 1;
                                  bookDetailsProvider.setbookloading(true);
                                  bookDetailsProvider.clearChapterData();
                                  await fetchTabData(nextPage);
                                },
                          child: AnimatedScale(
                            scale: isHovered ? 1.1 : 1.0,
                            duration: const Duration(milliseconds: 150),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isHovered
                                    ? _indigo
                                    : _indigo.withOpacity( 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                                color: isHovered ? Colors.white : _indigo,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            // --- END UPDATED PAGINATION CONTROLS ---
          ],
        );
      } else {
        return Center(
          child: MyText(
            text: "oopsnothingtoshowhere",
            multilanguage: true,
            color: _indigo,
            fontsize: Dimens.medium16TextSize,
            fontsizeWeb: Dimens.medium16TextSize,
            fontwaight: FontWeight.w400,
          ),
        );
      }
    }
  }

  Widget episodeList() {
    return Consumer<BookDetailsProvider>(
        builder: (context, bookDetailsProvider, child) {
      return ResponsiveGridList(
        minItemWidth: 300,
        minItemsPerRow: 1,
        maxItemsPerRow: 1,
        listViewBuilderOptions: ListViewBuilderOptions(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
        ),
        children: List.generate(
          bookDetailsProvider.chaptersList?.length ?? 0,
          (index) {
            final chapterDe = bookDetailsProvider.chaptersList?[index];
            int displayIndex = index + 1;
            bool accessType =
                (chapterDe?.isChapterPaid.toString() ?? "") == "1" &&
                    (chapterDe?.isBuy.toString() ?? "") == "0";

            return InkWell(
              onTap: () async {
                String ex = Utils.getEx(chapterDe?.chapter ?? "");
                if (Utils.checkLoginUser(context)) {
                  if ((chapterDe?.isChapterPaid.toString() ?? "") == "1" &&
                      (chapterDe?.isBuy.toString() ?? "") == "0") {
                    if ((chapterDe?.isChapterPaid.toString() ?? "") == "1" &&
                        (chapterDe?.isBuy.toString() ?? "") == "0") {
                      final result =
                          await Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return AllPayment(
                            issubscription: 0,
                            itemId: chapterDe?.novelId.toString(),
                            itemTitle: chapterDe?.title.toString(),
                            price: chapterDe?.price.toString(),
                            autherid: widget.authorId ?? "",
                            contentType: "2",
                            subContentId: chapterDe?.id.toString(),
                            subaccount: bookDetailsProvider.bookDetailModel.result?.authorSubaccount,
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

                      if (result == true) {
                        await bookDetailsProvider.getChapterbyBook(
                            widget.contentId ?? "", 0);
                      }
                    }
                  } else {
                    if (ex == "pdf") {
                      final bookDe = bookDetailsProvider.bookDetailModel.result;
                      webReadBookLog('READ_CHAPTER_PDF_PUSH',
                          'novelId=${chapterDe?.novelId} chapterId=${chapterDe?.id} pdfUrl=${webReadBookFormatPdfUrl(chapterDe?.chapter?.toString())}');
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return WebPdfReadingPage(
                            bookID: chapterDe?.novelId.toString(),
                            name: chapterDe?.title.toString(),
                            pdfUrl: chapterDe?.chapter.toString(),
                            chapterID: chapterDe?.id.toString(),
                            contentType: '2',
                            autherid: bookDe?.authorId.toString(),
                            issubscription: 0,
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
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return BookEpubShow(
                            ePubUrl: chapterDe?.chapter.toString(),
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
                  }
                }
              },
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    text: displayIndex.toString(),
                    fontsize: Dimens.medium16TextSize,
                    fontwaight: FontWeight.w400,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyText(
                          text: chapterDe?.title ?? "",
                          fontsize: Dimens.medium18TextSize,
                          fontwaight: FontWeight.bold,
                          color: black,
                        ),
                        const SizedBox(height: 6),
                        MyText(
                          text:
                              accessType ? "subscribe_unlock" : "free_to_play",
                          fontsize: Dimens.medium14TextSize,
                          multilanguage: true,
                          color: _indigo,
                          fontwaight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: accessType ? _indigo : _indigo,
                      shape: BoxShape.circle,
                    ),
                    child: accessType
                        ? const Icon(Icons.lock_rounded, size: 22, color: white)
                        : Icon(Icons.play_arrow_rounded,
                            size: 22, color: _indigo),
                  ),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget rightLayout() {
    if (bookDetailsProvider.loading) {
      return rightLayoutShimmer();
    } else {
      if (bookDetailsProvider.bookDetailModel.status == 200 &&
          bookDetailsProvider.bookDetailModel.result != null) {
        printLog(
            "bookname check ====>> ${bookDetailsProvider.bookDetailModel.result?.title} ");
        printLog(
            "isbuy check ====>> ${bookDetailsProvider.bookDetailModel.result?.isBuy} ");
        final bookDe = bookDetailsProvider.bookDetailModel.result;

        bool isFreeAccess = false;
        bool goToSubscription = false;
        bool goToPayment = false;

        if (bookDe?.accessType.toString() == "0") {
          isFreeAccess = true;
        } else if (bookDe?.accessType.toString() == "1") {
          if (bookDe?.isBuy.toString() == "1") {
            isFreeAccess = true;
          } else {
            goToPayment = true;
          }
        } else if (bookDe?.accessType.toString() == "2") {
          if (Constant.isSubscription == 1) {
            isFreeAccess = true;
          } else {
            goToSubscription = true;
          }
        }
        final accessInfo = getAccessInfo(
          accessType: bookDe?.accessType.toString(),
          isBuy: bookDe?.isBuy.toString(),
          isSubscription: Constant.isSubscription ?? 0,
          price: bookDe?.price?.toString(),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            Row(
              children: [
                // Access badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    accessInfo.badgeLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _indigo,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "novel",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ),
              ],
            ),
            MyText(
              text: bookDe?.title ?? "",
              color: black,
              fontsize: Dimens.medium20TextSize,
              fontsizeWeb: Dimens.text28Size,
              fontwaight: FontWeight.w600,
              maxline: 2,
            ),
            MyText(
              text: accessInfo.priceText,
              color: black,
              fontsize: Dimens.medium20TextSize,
              fontsizeWeb: Dimens.text28Size,
              fontwaight: FontWeight.w600,
              maxline: 2,
            ),
            const Divider(thickness: 1),
            if (goToSubscription) _subscriptionIncludedCard(context),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: _indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      String ex = Utils.getEx(bookDe?.fullNovel ?? "");
                      _webLogReadBookButton(
                        'wide_layout',
                        bookDe: bookDe,
                        ex: ex,
                        goToSubscription: goToSubscription,
                        goToPayment: goToPayment,
                        isFreeAccess: isFreeAccess,
                      );
                      if (!Utils.checkLoginUser(context)) {
                        webReadBookLog('READ_BOOK_ABORT', 'reason=not_logged_in');
                        return;
                      }

                      if (goToSubscription) {
                        webReadBookLog('READ_BOOK_ROUTE', 'action=show_subscribe_dialog');
                        showSubscribeDialog(context);
                        return;
                      }

                      if (goToPayment) {
                        webReadBookLog('READ_BOOK_ROUTE', 'action=AllPayment bookId=${bookDe?.id}');
                        await Utils.push(
                          context,
                          AllPayment(
                            issubscription: 0,
                            itemId: bookDe?.id.toString(),
                            itemTitle: bookDe?.title.toString(),
                            price: bookDe?.price.toString(),
                            autherid: bookDe?.authorId.toString(),
                            contentType: "2",
                            subaccount: bookDe?.authorSubaccount,
                          ),
                        );
                        getApi();
                        return;
                      }

                      if (isFreeAccess) {
                        final fileUrl = (bookDe?.fullNovel?.toString() ?? '').trim();
                        if (!_hasReadableFileUrl(fileUrl)) {
                          webReadBookLog(
                            'READ_BOOK_ABORT',
                            'reason=missing_full_novel path=wide_layout',
                          );
                          _showMissingBookFileError(context);
                          return;
                        }
                        if (ex == "pdf") {
                          webReadBookLog('READ_BOOK_ROUTE',
                              'action=WebPdfReadingPage wide_layout pdfUrl=${webReadBookFormatPdfUrl(fileUrl)}');
                          Utils.push(
                            context,
                            WebPdfReadingPage(
                              bookID: bookDe?.id.toString(),
                              name: bookDe?.title.toString(),
                              pdfUrl: fileUrl,
                              issubscription: bookDe?.isSubscription ?? 0,
                              autherid: bookDe?.authorId.toString(),
                              contentType: '2',
                            ),
                          );
                        } else {
                          webReadBookLog('READ_BOOK_ROUTE',
                              'action=BookEpubShow wide_layout url=${webReadBookFormatPdfUrl(fileUrl)}');
                          Utils.push(
                            context,
                            BookEpubShow(
                              ePubUrl: fileUrl,
                            ),
                          );
                        }
                      } else {
                        webReadBookLog('READ_BOOK_ABORT',
                            'reason=no_free_access path=wide_layout isFreeAccess=false');
                      }
                    },
                    icon: Icon(
                      (bookDetailsProvider.bookDetailModel.result?.accessType ==
                                  1 &&
                              bookDetailsProvider
                                      .bookDetailModel.result?.isBuy ==
                                  0)
                          ? FontAwesomeIcons.cartShopping
                          : FontAwesomeIcons.book,
                      color: white,
                    ),
                    label: MyText(
                      text: goToSubscription
                          ? "unlock_full_access"
                          : (goToPayment ? "buy_now" : "read_books"),
                      multilanguage: true,
                      color: white,
                      fontsize: Dimens.medium14TextSize,
                      fontsizeWeb: Dimens.medium16TextSize,
                      maxline: 2,
                      isfont: 3,
                      overflow: TextOverflow.ellipsis,
                      fontwaight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      backgroundColor: white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: _indigo, width: 2),
                      ),
                    ),
                    onPressed: () async {
                      if (Utils.checkLoginUser(context)) {
                        if (goToSubscription) {
                          showSubscribeDialog(context);
                          return;
                        }
                        if ((bookDetailsProvider
                                        .bookDetailModel.result?.accessType
                                        .toString() ??
                                    "") ==
                                "1" &&
                            (bookDetailsProvider.bookDetailModel.result?.isBuy
                                        .toString() ??
                                    "") ==
                                "0") {
                          await Navigator.of(context).push(PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return AllPayment(
                                issubscription: 0,
                                itemId: bookDetailsProvider
                                    .bookDetailModel.result?.id
                                    .toString(),
                                itemTitle: bookDetailsProvider
                                    .bookDetailModel.result?.title
                                    .toString(),
                                price: bookDetailsProvider
                                    .bookDetailModel.result?.price
                                    .toString(),
                                autherid: bookDetailsProvider
                                    .bookDetailModel.result?.authorId
                                    .toString(),
                                contentType: "2",
                                subaccount: bookDetailsProvider
                                    .bookDetailModel.result?.authorSubaccount,
                              );
                            },
                            transitionDuration: Duration(milliseconds: 150),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
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
                          getApi();
                        } else {
                          showAddCommentDialog();
                        }
                      }
                    },
                    icon: Icon(
                      Icons.rate_review,
                      color: _indigo,
                    ),
                    label: MyText(
                      text: "add_review",
                      multilanguage: true,
                      color: _indigo,
                      fontsize: Dimens.medium14TextSize,
                      fontsizeWeb: Dimens.medium16TextSize,
                      fontwaight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            // Modern Divided Stats Bar (Web)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Constant.isDarkMode
                    ? const Color(0xFF1E1E2E)
                    : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Constant.isDarkMode
                      ? const Color(0xFF2D2D44)
                      : const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.visibility_rounded, size: 18, color: Color(0xFF3B82F6)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${bookDe?.totalRead ?? "0"}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Constant.isDarkMode ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const Text(
                            "Reads",
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 32, color: const Color(0xFFE2E8F0)),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF59E0B)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${bookDe?.avgReviews ?? "0.0"}",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Constant.isDarkMode ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            "${bookDe?.totalReviews ?? "0"} Reviews",
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 32, color: const Color(0xFFE2E8F0)),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.category_rounded, size: 18, color: Color(0xFF8B5CF6)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bookDe?.categoryName ?? "Book",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Constant.isDarkMode ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),
                          const Text(
                            "Category",
                            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            InkWell(
              focusColor: transparent,
              highlightColor: transparent,
              hoverColor: transparent,
              onTap: () {
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return WebAuthor(
                      autherUserID: bookDe?.authorId.toString(),
                      name: bookDe?.authorName ?? "",
                    );
                  },
                  transitionDuration: Duration(milliseconds: 100),
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
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    MyNetworkImage(
                      imagePath: bookDe?.authorImage ?? "",
                      height: 70,
                      width: 70,
                      radius: 30,
                      fit: BoxFit.cover,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          Text(
                            bookDe?.authorName ?? "",
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.person_rounded, size: 14, color: const Color(0xFF94A3B8)),
                              const SizedBox(width: 4),
                              Text(
                                Locales.string(context, "author"),
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  void showSubscribeDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          backgroundColor: Constant.isDarkMode ? black : white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        size: 25,
                        color: gray,
                      ),
                    ),
                  ),

                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          Constant.isDarkMode ? _indigo : _indigo,
                    ),
                    child: Icon(
                      Icons.lock,
                      size: 26,
                      color: Constant.isDarkMode ? black : white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// TITLE
                  MyText(
                    text: "subscribe_to_read",
                    fontsize: Dimens.medium20TextSize,
                    fontwaight: FontWeight.w700,
                    fontstyle: FontStyle.normal,
                    isfont: 3,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    multilanguage: true,
                    color: Constant.isDarkMode ? white : black,
                  ),

                  const SizedBox(height: 6),

                  Align(
                    alignment: Alignment.center,
                    child: RichText(
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text:
                                "${Locales.string(context, 'subscription_descstart')} ",
                            style: TextStyle(
                              fontSize: Dimens.medium15TextSize,
                              fontWeight: FontWeight.bold,
                              color: Constant.isDarkMode ? white : black,
                            ),
                          ),
                          TextSpan(
                            text: Locales.string(context, 'subscription_desc'),
                            style: TextStyle(
                              fontSize: Dimens.medium13TextSize,
                              fontWeight: FontWeight.w400,
                              color: gray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  _featureRow(
                    icon: Bi.book,
                    title: "unlimited_books",
                    sub: "unlimited_books_desc",
                  ),
                  const SizedBox(height: 14),

                  _featureRow(
                    icon: Ri.device_line,
                    title: "all_devices",
                    sub: "all_devices_desc",
                  ),
                  const SizedBox(height: 14),

                  _featureRow(
                    icon: Mdi.star_outline,
                    title: "premium_features",
                    sub: "premium_features_desc",
                  ),

                  const SizedBox(height: 22),

                  /// BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 47,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      onPressed: () {
                        final profileProvider = Provider.of<ProfileProvider>(
                            context,
                            listen: false);

                        if (Utils.checkLoginUser(context)) {
                          Utils.push(context, const WebProfile());
                        } else {
                          profileProvider.setWebSelect("4", "subscriptionplan");
                        }
                      },
                      child: MyText(
                        text: "view_subscription_plans",
                        fontsize: Dimens.medium14TextSize,
                        fontwaight: FontWeight.w600,
                        multilanguage: true,
                        isfont: 3,
                        fontstyle: FontStyle.normal,
                        maxline: 2,
                        overflow: TextOverflow.ellipsis,
                        color: white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// FOOTER
                  MyText(
                    text: "subscription_footer",
                    fontsize: Dimens.medium11TextSize,
                    fontwaight: FontWeight.w400,
                    multilanguage: true,
                    color: gray,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _featureRow({
    required String icon,
    required String title,
    required String sub,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: Color(0xFFC4CCCC),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Iconify(
              icon,
              size: 22,
              color: _indigo,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                text: title,
                fontsize: Dimens.medium14TextSize,
                fontwaight: FontWeight.w700,
                multilanguage: true,
                fontstyle: FontStyle.normal,
                isfont: 3,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                color: Constant.isDarkMode ? white : black,
              ),
              const SizedBox(height: 2),
              MyText(
                text: sub,
                fontstyle: FontStyle.normal,
                isfont: 3,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                fontsize: Dimens.medium13TextSize,
                fontwaight: FontWeight.w400,
                multilanguage: true,
                color:
                    Constant.isDarkMode ? gray : black.withOpacity( 0.6),
              ),
            ],
          ),
        ),
      ],
    );
  }

/* Mobile view Right layout */
  Widget rightLayoutMobile() {
    if (bookDetailsProvider.loading) {
      return rightLayoutMobileShimmer();
    } else {
      if (bookDetailsProvider.bookDetailModel.status == 200 &&
          bookDetailsProvider.bookDetailModel.result != null) {
        final bookDe = bookDetailsProvider.bookDetailModel.result;
        bool isFreeAccess = false;
        bool goToSubscription = false;
        bool goToPayment = false;

        if (bookDe?.accessType.toString() == "0") {
          isFreeAccess = true;
        } else if (bookDe?.accessType.toString() == "1") {
          if (bookDe?.isBuy.toString() == "1") {
            isFreeAccess = true;
          } else {
            goToPayment = true;
          }
        } else if (bookDe?.accessType.toString() == "2") {
          if (Constant.isSubscription == 1) {
            isFreeAccess = true;
          } else {
            goToSubscription = true;
          }
        }
        final accessInfo = getAccessInfo(
          accessType: bookDe?.accessType.toString(),
          isBuy: bookDe?.isBuy.toString(),
          isSubscription: Constant.isSubscription ?? 0,
          price: bookDe?.price?.toString(),
        );
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 16,
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                    decoration: BoxDecoration(
                      color: _indigo,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: MyText(
                      text: accessInfo.badgeLabel,
                      multilanguage: true,
                      color: white,
                      fontsize: Dimens.medium12TextSize,
                      fontwaight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(width: 2, color: _indigo)),
                    child: MyText(
                      text: "novel",
                      multilanguage: true,
                      color: _indigo,
                      fontsize: Dimens.medium12TextSize,
                      fontwaight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            MyText(
              text: bookDe?.title ?? "",
              color: black,
              fontsize: Dimens.medium18TextSize,
              fontwaight: FontWeight.w600,
              maxline: 2,
            ),

            MyText(
              text: accessInfo.priceText,
              color: black,
              fontsize: Dimens.medium20TextSize,
              fontwaight: FontWeight.w600,
              maxline: 2,
            ),
            const Divider(thickness: 1),

            if (goToSubscription) _subscriptionIncludedCard(context),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: _indigo,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final bookDe = bookDetailsProvider.bookDetailModel.result;
                      String ex = Utils.getEx(bookDe?.fullNovel ?? "");
                      _webLogReadBookButton(
                        'narrow_layout',
                        bookDe: bookDe,
                        ex: ex,
                        goToSubscription: goToSubscription,
                        goToPayment: goToPayment,
                        isFreeAccess: isFreeAccess,
                      );

                      if (!Utils.checkLoginUser(context)) {
                        webReadBookLog('READ_BOOK_ABORT', 'reason=not_logged_in narrow');
                        return;
                      }

                      if (goToSubscription) {
                        webReadBookLog('READ_BOOK_ROUTE', 'action=show_subscribe_dialog narrow');
                        showSubscribeDialog(context);
                        return;
                      }

                      if (goToPayment) {
                        webReadBookLog('READ_BOOK_ROUTE', 'action=AllPayment narrow bookId=${bookDe?.id}');
                        await Utils.push(
                          context,
                          AllPayment(
                            issubscription: 0,
                            itemId: bookDe?.id.toString(),
                            itemTitle: bookDe?.title.toString(),
                            price: bookDe?.price.toString(),
                            autherid: bookDe?.authorId.toString(),
                            contentType: "2",
                            subaccount: bookDe?.authorSubaccount,
                          ),
                        );
                        getApi();
                        return;
                      }

                      if (isFreeAccess) {
                        final fileUrl = (bookDe?.fullNovel?.toString() ?? '').trim();
                        if (!_hasReadableFileUrl(fileUrl)) {
                          webReadBookLog(
                            'READ_BOOK_ABORT',
                            'reason=missing_full_novel path=narrow_layout',
                          );
                          _showMissingBookFileError(context);
                          return;
                        }
                        if (ex == "pdf") {
                          webReadBookLog('READ_BOOK_ROUTE',
                              'action=WebPdfReadingPage narrow_layout pdfUrl=${webReadBookFormatPdfUrl(fileUrl)}');
                          Utils.push(
                            context,
                            WebPdfReadingPage(
                              bookID: bookDe?.id.toString(),
                              name: bookDe?.title.toString(),
                              pdfUrl: fileUrl,
                              issubscription: bookDe?.isSubscription ?? 0,
                              autherid: bookDe?.authorId.toString(),
                              contentType: '2',
                            ),
                          );
                        } else {
                          webReadBookLog('READ_BOOK_ROUTE',
                              'action=BookEpubShow narrow_layout url=${webReadBookFormatPdfUrl(fileUrl)}');
                          Utils.push(
                            context,
                            BookEpubShow(
                              ePubUrl: fileUrl,
                            ),
                          );
                        }
                      } else {
                        webReadBookLog('READ_BOOK_ABORT',
                            'reason=no_free_access path=narrow_layout isFreeAccess=false');
                      }
                    },
                    icon: Icon(
                      ((bookDe?.accessType.toString() ?? "") == "1" &&
                              (bookDe?.isBuy.toString() ?? "") == "0")
                          ? FontAwesomeIcons.cartShopping
                          : FontAwesomeIcons.book,
                      color: white,
                      size: 18,
                    ),
                    label: MyText(
                      text: goToSubscription
                          ? "unlock_full_access"
                          : (goToPayment ? "buy_now" : "read_books"),
                      multilanguage: true,
                      color: white,
                      fontsize: Dimens.medium14TextSize,
                      fontwaight: FontWeight.w500,
                    ),
                  ),
                ),
                SizedBox(
                  width: 16,
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      backgroundColor: white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: _indigo, width: 2),
                      ),
                    ),
                    onPressed: () async {
                      if (Utils.checkLoginUser(context)) {
                        if (goToSubscription) {
                          showSubscribeDialog(context);
                          return;
                        }
                        if ((bookDetailsProvider
                                        .bookDetailModel.result?.accessType
                                        .toString() ??
                                    "") ==
                                "1" &&
                            (bookDetailsProvider.bookDetailModel.result?.isBuy
                                        .toString() ??
                                    "") ==
                                "0") {
                          await Navigator.of(context).push(PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return AllPayment(
                                issubscription: 0,
                                itemId: bookDetailsProvider
                                    .bookDetailModel.result?.id
                                    .toString(),
                                itemTitle: bookDetailsProvider
                                    .bookDetailModel.result?.title
                                    .toString(),
                                price: bookDetailsProvider
                                    .bookDetailModel.result?.price
                                    .toString(),
                                autherid: bookDetailsProvider
                                    .bookDetailModel.result?.authorId
                                    .toString(),
                                contentType: "2",
                                subaccount: bookDetailsProvider
                                    .bookDetailModel.result?.authorSubaccount,
                              );
                            },
                            transitionDuration: Duration(milliseconds: 150),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
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
                          getApi();
                        } else {
                          showAddCommentDialog();
                        }
                      }
                    },
                    icon: Icon(
                      Icons.rate_review,
                      color: _indigo,
                      size: 18,
                    ),
                    label: MyText(
                      text: "add_review",
                      multilanguage: true,
                      color: _indigo,
                      fontsize: Dimens.medium14TextSize,
                      fontwaight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    Row(
                      spacing: 6,
                      children: [
                        const Icon(Icons.table_rows_rounded,
                            size: 18, color: black),
                        MyText(
                          text: "${bookDe?.totalRead ?? 0} Reads",
                          color: black,
                          fontsize: Dimens.medium12TextSize,
                          fontwaight: FontWeight.w500,
                        ),
                      ],
                    ),
                    Row(
                      spacing: 6,
                      children: [
                        const Icon(Icons.live_tv_rounded,
                            size: 18, color: black),
                        MyText(
                          text: bookDe?.categoryName ?? "",
                          color: black,
                          fontsize: Dimens.medium12TextSize,
                          fontwaight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    Row(
                      spacing: 6,
                      children: [
                        const Icon(Icons.article_rounded,
                            size: 18, color: Colors.black),
                        RatingBarIndicator(
                          rating: (bookDe?.totalReviews ?? 0).toDouble(),
                          itemBuilder: (context, index) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 30,
                          unratedColor: gray,
                          direction: Axis.horizontal,
                        ),
                        MyText(
                          text: "(${bookDe?.totalReviews ?? 0} Reviews)",
                          color: black,
                          fontsize: Dimens.medium12TextSize,
                        ),
                      ],
                    ),
                    Row(
                      spacing: 6,
                      children: [
                        const Icon(Icons.volume_up_rounded,
                            size: 18, color: black),
                        MyText(
                          text: bookDe?.languageName ?? "",
                          color: black,
                          fontsize: Dimens.medium12TextSize,
                          fontwaight: FontWeight.w500,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),

            // Author Section
            InkWell(
              focusColor: transparent,
              highlightColor: transparent,
              hoverColor: transparent,
              onTap: () {
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return WebAuthor(
                      autherUserID: bookDe?.authorId.toString(),
                      name: bookDe?.authorName ?? "",
                    );
                  },
                  transitionDuration: Duration(milliseconds: 100),
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
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  spacing: 12,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyNetworkImage(
                      imagePath: bookDe?.authorImage ?? "",
                      height: 60,
                      width: 60,
                      radius: 30,
                      fit: BoxFit.cover,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 4,
                        children: [
                          MyText(
                            text: bookDe?.authorName ?? "",
                            color: const Color(0xFF0F172A),
                            fontsize: Dimens.medium14TextSize,
                            fontwaight: FontWeight.w600,
                          ),
                          MyText(
                            text: bookDe?.categoryName ?? "",
                            color: const Color(0xFF94A3B8),
                            fontsize: Dimens.smallTextSize,
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget _subscriptionIncludedCard(BuildContext context) {
    return InkWell(
      onTap: () {
        showSubscribeDialog(context);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: green),
            color: Constant.isDarkMode
                ? transparent
                : Color(0xFFA4F4CF).withOpacity( 0.3)),
        child: Row(
          children: [
            Container(
              height: 26,
              width: 26,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: green,
              ),
              child: Icon(
                Icons.check,
                size: 20,
                color: Constant.isDarkMode ? black : white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    text: "includedsub",
                    fontsize: Dimens.medium14TextSize,
                    fontwaight: FontWeight.w600,
                    fontstyle: FontStyle.normal,
                    isfont: 2,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    color: Constant.isDarkMode ? white : black,
                    multilanguage: true,
                  ),
                  const SizedBox(height: 2),
                  MyText(
                    text: "readbooksde",
                    fontsize: Dimens.medium13TextSize,
                    fontwaight: FontWeight.w400,
                    fontstyle: FontStyle.normal,
                    isfont: 2,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.start,
                    color: Constant.isDarkMode ? white : black,
                    multilanguage: true,
                  ),
                ],
              ),
            ),
            InkWell(
              onTap: () {
                showSubscribeDialog(context);
              },
              child: MyText(
                text: "selectplan",
                isfont: 3,
                fontstyle: FontStyle.normal,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                fontsize: Dimens.medium13TextSize,
                fontwaight: FontWeight.w600,
                color: green,
                multilanguage: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget commentDataWeb(BuildContext context, contentType, contentId) {
    final provider = Provider.of<BookDetailsProvider>(context);

    if (provider.commentloading && (provider.commentList?.isEmpty ?? true)) {
      return commentShimmerWeb();
    } else if ((provider.commentList?.length ?? 0) > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              MyText(
                text: "Review",
                fontsize: Dimens.medium18TextSize,
                fontwaight: FontWeight.w500,
              ),
              const SizedBox(width: 10),
              MyText(
                text: "(${provider.totalRowsComment ?? 0})",
                fontsize: Dimens.medium18TextSize,
                fontwaight: FontWeight.w500,
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Review List
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.commentList?.length ?? 0,
            itemBuilder: (context, index) {
              final commentItem = provider.commentList![index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      MyNetworkImage(
                        imagePath: commentItem.userImage,
                        fit: BoxFit.fill,
                        height: 30,
                        width: 30,
                        radius: 200,
                      ),
                      const SizedBox(width: 10),
                      MyText(
                        text:
                            "${commentItem.firstName} ${commentItem.lastName}",
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
                          text: commentItem.review ?? "",
                          maxline: 1,
                          fontsize: Dimens.medium14TextSize,
                          fontwaight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(width: 15),
                      if (commentItem.userId.toString() == Constant.userID)
                        if (bookDetailsProvider.deletecommentLoading &&
                            bookDetailsProvider.deleteItemIndex == index)
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: _indigo,
                              strokeWidth: 1,
                            ),
                          )
                        else
                          InkWell(
                            onTap: () async {
                              await bookDetailsProvider.getDeleteComment(
                                  index, commentItem.id.toString());
                            },
                            child: const Icon(
                              Icons.delete,
                              size: 20,
                              color: _indigo,
                            ),
                          ),
                    ],
                  ),
                  const Divider(),
                ],
              );
            },
          ),

          // Pagination Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if ((provider.currentPageComment ?? 1) > 1)
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    provider.getComment(contentType, contentId,
                        (provider.currentPageComment ?? 1) - 1);
                  },
                ),
              if ((provider.morePageComment ?? false))
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    provider.getComment(contentType, contentId,
                        (provider.currentPageComment ?? 1) + 1);
                  },
                ),
            ],
          )
        ],
      );
    } else {
      return Center(
        child: MyText(
          text: "oopsnothingtoshowhere",
          multilanguage: true,
          color: _indigo,
          fontsize: Dimens.medium16TextSize,
          fontsizeWeb: Dimens.medium16TextSize,
          fontwaight: FontWeight.w400,
        ),
      );
    }
  }

  /* Similar book data  */
  Widget _buildReletedData() {
    // if (MediaQuery.of(context).size.width > 1000) {
    return _buildWebData();
    // } else {
    //   return _buildMobilerelatedData();
    // }
  }

  Widget _buildWebData() {
    if (bookDetailsProvider.releteditemsloading) {
      return relatedItemsShimmer();
    }
    if (bookDetailsProvider.bookModel.status == 200 &&
        (bookDetailsProvider.bookModel.result?.length ?? 0) > 0) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: (MediaQuery.of(context).size.width > 1000)
                ? const EdgeInsets.fromLTRB(0, 0, 0, 0)
                : const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 20,
              children: [
                MyText(
                  text: "similar_book",
                  maxline: 1,
                  multilanguage: true,
                  fontsize: Dimens.text30Size,
                  fontsizeWeb: Dimens.text30Size,
                  fontwaight: FontWeight.w500,
                ),
                InteractiveContainer(child: (isHovered) {
                  return InkWell(
                    splashColor: transparent,
                    focusColor: transparent,
                    hoverColor: transparent,
                    highlightColor: transparent,
                    onTap: () async {
                      final reletedItemProvider =
                          Provider.of<ReletedItemProvider>(context,
                              listen: false);
                      Navigator.of(context).pushReplacement(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return Webreleteddata(
                            contentId: widget.contentId ?? "",
                            type: "2",
                            categoryId: widget.categoryId ?? "",
                            name: widget.name ?? "",
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

                      reletedItemProvider.clearProvider();
                      reletedItemProvider.setLoading(false);
                      reletedItemProvider.getSectionBook("2",
                          widget.categoryId ?? "", widget.contentId ?? "", 0);
                    },
                    child: AnimatedScale(
                      scale: isHovered ? 1.05 : 1,
                      duration: const Duration(milliseconds: 150),
                      curve: Curves.easeInOut,
                      child: Row(
                        spacing: 6,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          MyText(
                            text: "more",
                            maxline: 1,
                            multilanguage: true,
                            color: isHovered ? _indigo : _indigo,
                            fontsize: Dimens.medium16TextSize,
                            fontsizeWeb: Dimens.medium16TextSize,
                            fontwaight: FontWeight.w400,
                          ),
                          Icon(
                            Icons.arrow_forward_ios_sharp,
                            size: 20,
                            color: isHovered ? _indigo : _indigo,
                          )
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 14),
          relatedItems(),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget relatedItems() {
    final screenWidth = MediaQuery.of(context).size.width;
    const double cardWidth = 195.0;

    return Padding(
      padding: EdgeInsets.zero,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: SingleChildScrollView(
                          controller: controller,
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            spacing: 18,
                            children: List.generate(
                              bookDetailsProvider.bookModel.result?.length ?? 0,
                              (index) {
                                final data =
                                    bookDetailsProvider.bookModel.result?[index];
                                final accessInfo = getAccessInfo(
                                  accessType: data?.accessType?.toString(),
                                  isBuy: data?.isBuy?.toString(),
                                  isSubscription: Constant.isSubscription ?? 0,
                                  price: data?.price?.toString(),
                                );

                                return StatefulBuilder(
                                  builder: (context, setLocalState) {
                                    bool hovered = false;
                                    final isFree =
                                        accessInfo.priceText.toLowerCase() ==
                                            "free";
                                    final hasPrice =
                                        accessInfo.priceText.isNotEmpty &&
                                            !isFree;

                                    return MouseRegion(
                                      onEnter: (_) =>
                                          setLocalState(() => hovered = true),
                                      onExit: (_) =>
                                          setLocalState(() => hovered = false),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.pushReplacement(
                                            context,
                                            PageRouteBuilder(
                                              pageBuilder: (context, animation,
                                                  secondaryAnimation) {
                                                return WebDetails(
                                                  categoryId: data?.categoryId
                                                          ?.toString() ??
                                                      "",
                                                  authorId: data?.authorId
                                                          ?.toString() ??
                                                      "",
                                                  contentId: data?.id
                                                          ?.toString() ??
                                                      "",
                                                  name: data?.title
                                                          ?.toString() ??
                                                      "",
                                                );
                                              },
                                              transitionDuration: const Duration(
                                                  milliseconds: 200),
                                              transitionsBuilder: (context,
                                                  animation,
                                                  secondaryAnimation,
                                                  child) {
                                                return AnimatedBuilder(
                                                  animation: animation,
                                                  builder: (context, child) {
                                                    return ClipPath(
                                                      clipper:
                                                          CircularRevealClipper(
                                                              progress: animation
                                                                  .value),
                                                      child: child,
                                                    );
                                                  },
                                                  child: child,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        child: AnimatedContainer(
                                          duration:
                                              const Duration(milliseconds: 300),
                                          width: cardWidth,
                                          transform: hovered
                                              ? Matrix4.translationValues(
                                                  0, -6, 0)
                                              : Matrix4.identity(),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            border: Border.all(
                                              color: hovered
                                                  ? colorPrimary
                                                      .withOpacity(0.15)
                                                  : const Color(0xFFF1F4F9),
                                              width: 1,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: hovered
                                                    ? Colors.black
                                                        .withOpacity(0.1)
                                                    : Colors.black
                                                        .withOpacity(0.04),
                                                blurRadius: hovered ? 20 : 8,
                                                offset: Offset(
                                                    0, hovered ? 8 : 2),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius:
                                                        const BorderRadius
                                                            .vertical(
                                                            top: Radius.circular(
                                                                15)),
                                                    child: AspectRatio(
                                                      aspectRatio: 3 / 4,
                                                      child: Container(
                                                        color: const Color(
                                                            0xFFF1F5F9),
                                                        child: MyNetworkImage(
                                                          imagePath:
                                                              data?.portraitImg ??
                                                                  "",
                                                          fit: BoxFit.cover,
                                                          width: double.infinity,
                                                          height:
                                                              double.infinity,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Positioned(
                                                    top: 8,
                                                    left: 8,
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 8,
                                                          vertical: 4),
                                                      decoration: BoxDecoration(
                                                        color: accessInfo.badgeBg
                                                            .withOpacity(0.95),
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                6),
                                                      ),
                                                      child: Text(
                                                        accessInfo.badgeLabel,
                                                        style: TextStyle(
                                                          color: accessInfo
                                                              .badgeTextColor,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          letterSpacing: 0.3,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  if (hovered)
                                                    Positioned.fill(
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .vertical(
                                                                  top: Radius
                                                                      .circular(
                                                                          15)),
                                                          color: Colors.black
                                                              .withOpacity(0.06),
                                                        ),
                                                        child: Center(
                                                          child: Container(
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 16,
                                                                vertical: 8),
                                                            decoration: BoxDecoration(
                                                              color: Colors.black
                                                                  .withOpacity(0.6),
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      20),
                                                            ),
                                                            child: const Row(
                                                              mainAxisSize:
                                                                  MainAxisSize.min,
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .remove_red_eye_outlined,
                                                                    size: 16,
                                                                    color: Colors
                                                                        .white),
                                                                SizedBox(
                                                                    width: 6),
                                                                Text(
                                                                  "View",
                                                                  style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize: 13,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              Padding(
                                                padding: const EdgeInsets
                                                    .fromLTRB(14, 12, 14, 14),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      data?.title ?? "",
                                                      style: const TextStyle(
                                                        color:
                                                            Color(0xFF0F172A),
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        height: 1.3,
                                                      ),
                                                      maxLines: 2,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                    const SizedBox(height: 6),
                                                    if (data?.authorName !=
                                                            null &&
                                                        (data!.authorName ?? "")
                                                            .isNotEmpty)
                                                      Text(
                                                        data?.authorName ?? "",
                                                        style: const TextStyle(
                                                          color:
                                                              Color(0xFF94A3B8),
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                      ),
                                                    const SizedBox(height: 8),
                                        Row(
                                          children: [
                                            const Icon(Icons.star_rounded,
                                                size: 15,
                                                color: Color(0xFFF59E0B)),
                                            const SizedBox(width: 4),
                                            Text(
                                              (data?.avgReviews ?? 0) > 0
                                                  ? data!.avgReviews.toString()
                                                  : "0",
                                              style: const TextStyle(
                                                color: Color(0xFF0F172A),
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              "(${Utils.kmbGenerator(data?.totalReviews ?? 0)})",
                                              style: const TextStyle(
                                                color: Color(0xFFCBD5E1),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            const Spacer(),
                                            if (data?.categoryName != null &&
                                                (data!.categoryName ?? "").isNotEmpty)
                                              Flexible(
                                                child: Text(
                                                  data?.categoryName ?? "",
                                                  style: const TextStyle(
                                                    color: Color(0xFF94A3B8),
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
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
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

/* Shimmer  */

  Widget webParentContainerShimmer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        Container(
          alignment: Alignment.center,
          color: _indigo.withOpacity( 0.1),
          width: MediaQuery.of(context).size.width * 0.42,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: const CustomWidget.roundcorner(
              height: double.infinity,
            ),
          ),
        ),
        const CustomWidget.roundrectborder(
          height: 20,
          width: 180,
        ),
        const SizedBox(height: 10),
        const CustomWidget.roundrectborder(
          height: 16,
          width: 140,
        ),
        const SizedBox(height: 10),
        const CustomWidget.roundrectborder(
          height: 16,
          width: 100,
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const CustomWidget.circular(height: 50, width: 50),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CustomWidget.roundrectborder(height: 14, width: 120),
                SizedBox(height: 8),
                CustomWidget.roundrectborder(height: 14, width: 80),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget mobileParentContainerShimmer(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        FractionallySizedBox(
          widthFactor: 1.0,
          child: AspectRatio(
            aspectRatio: 5 / 4,
            child: const CustomWidget.roundcorner(
              height: double.infinity,
            ),
          ),
        ),
        const CustomWidget.roundrectborder(
          height: 20,
          width: 160,
        ),
        const SizedBox(height: 10),
        const CustomWidget.roundrectborder(
          height: 16,
          width: 120,
        ),
        const SizedBox(height: 10),
        const CustomWidget.roundrectborder(
          height: 16,
          width: 100,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const CustomWidget.circular(height: 50, width: 50),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                CustomWidget.roundrectborder(height: 14, width: 100),
                SizedBox(height: 8),
                CustomWidget.roundrectborder(height: 14, width: 80),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget rightLayoutShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        const CustomWidget.roundcorner(width: 60, height: 24),
        const CustomWidget.roundrectborder(width: 180, height: 20),
        const CustomWidget.roundrectborder(width: 100, height: 18),
        const Divider(thickness: 1),
        Row(
          children: const [
            Expanded(child: CustomWidget.roundcorner(height: 50)),
            SizedBox(width: 16),
            Expanded(child: CustomWidget.roundcorner(height: 50)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: const [
            CustomWidget.roundrectborder(width: 140, height: 18),
            CustomWidget.roundrectborder(width: 120, height: 18),
            CustomWidget.roundrectborder(width: 160, height: 18),
            CustomWidget.roundrectborder(width: 100, height: 18),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _indigo.withOpacity( 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            spacing: 16,
            children: const [
              CustomWidget.circular(height: 70, width: 70),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    CustomWidget.roundrectborder(width: 120, height: 18),
                    CustomWidget.roundrectborder(width: 80, height: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget rightLayoutMobileShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 16,
      children: [
        const CustomWidget.roundcorner(width: 60, height: 20),
        const CustomWidget.roundrectborder(width: 180, height: 20),
        const CustomWidget.roundrectborder(width: 100, height: 18),
        const Divider(thickness: 1),
        Row(
          children: const [
            Expanded(child: CustomWidget.roundcorner(height: 50)),
            SizedBox(width: 16),
            Expanded(child: CustomWidget.roundcorner(height: 50)),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: const [
                CustomWidget.roundrectborder(width: 80, height: 16),
                CustomWidget.roundrectborder(width: 60, height: 16),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 10,
              children: const [
                CustomWidget.roundrectborder(width: 100, height: 16),
                CustomWidget.roundrectborder(width: 60, height: 16),
              ],
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _indigo.withOpacity( 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            spacing: 12,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              CustomWidget.circular(width: 60, height: 60),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    CustomWidget.roundrectborder(width: 120, height: 16),
                    CustomWidget.roundrectborder(width: 80, height: 14),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget episodeListShimmer() {
    return ResponsiveGridList(
      minItemWidth: 300,
      minItemsPerRow: 1,
      maxItemsPerRow: 1,
      listViewBuilderOptions: ListViewBuilderOptions(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
      ),
      children: List.generate(
        5,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              CustomWidget.circular(width: 30, height: 30),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidget.roundrectborder(
                        width: double.infinity, height: 18),
                    SizedBox(height: 6),
                    CustomWidget.roundrectborder(width: 200, height: 14),
                  ],
                ),
              ),
              SizedBox(width: 20),
              CustomWidget.circular(width: 30, height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget chapterShimmer() {
    return ResponsiveGridList(
      minItemWidth: 300,
      minItemsPerRow: 1,
      maxItemsPerRow: 1,
      listViewBuilderOptions: ListViewBuilderOptions(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
      children: List.generate(5, (index) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomWidget.roundrectborder(
              width: 30,
              height: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomWidget.roundcorner(
                    width: double.infinity,
                    height: 20,
                  ),
                  const SizedBox(height: 6),
                  CustomWidget.roundrectborder(
                    width: 150,
                    height: 16,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 20),
            CustomWidget.circular(
              width: 40,
              height: 40,
            ),
          ],
        );
      }),
    );
  }

  Widget commentShimmerWeb() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(3, (index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CustomWidget.circular(
                  width: 30,
                  height: 30,
                ),
                const SizedBox(width: 10),
                const CustomWidget.roundrectborder(
                  width: 120,
                  height: 15,
                ),
              ],
            ),
            const SizedBox(height: 5),
            const CustomWidget.roundrectborder(
              width: double.infinity,
              height: 14,
            ),
            const SizedBox(height: 5),
            const Divider(),
          ],
        );
      }),
    );
  }

  Widget relatedItemsShimmer() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 20,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(4, (index) {
          return Container(
            width: 185,
            padding: const EdgeInsets.fromLTRB(6, 16, 6, 16),
            decoration: BoxDecoration(
              color: white,
              border: Border.all(width: 1, color: gray),
              borderRadius: const BorderRadius.all(Radius.circular(0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                const CustomWidget.rectangular(
                  height: 243,
                  width: 179,
                ),
                const CustomWidget.roundrectborder(
                  height: 15,
                  width: 140,
                ),
                const CustomWidget.roundrectborder(
                  height: 15,
                  width: 100,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  showAddCommentDialog() {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Consumer<BookDetailsProvider>(
          builder: (context, bookDetailsProvider, child) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              backgroundColor: Theme.of(context).cardColor,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 400, // 👈 small dialog
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          children: [
                            Center(
                              child: MyText(
                                text: "add_new_comment",
                                multilanguage: true,
                                fontsize: Dimens.medium14TextSize,
                                fontwaight: FontWeight.w700,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: InkWell(
                                onTap: () {
                                  commentController.clear();
                                  ratingGiven = 0.0;
                                  Navigator.pop(context);
                                },
                                child: const Icon(
                                  Icons.close,
                                  color: _indigo,
                                  size: 24,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Container(height: 2, color: _indigo),
                        const SizedBox(height: 15),
                        MyText(
                          text: "your_rate",
                          multilanguage: true,
                          fontsize: Dimens.medium14TextSize,
                          fontwaight: FontWeight.w700,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            MyText(
                              text: "give_ratings",
                              multilanguage: true,
                              fontsize: Dimens.medium16TextSize,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RatingBar(
                                initialRating: 0.0,
                                direction: Axis.horizontal,
                                allowHalfRating: false,
                                itemSize: 30,
                                itemCount: 5,
                                ratingWidget: RatingWidget(
                                  full: const Icon(Icons.star),
                                  half: const Icon(Icons.star_half),
                                  empty: const Icon(Icons.star_border,
                                      color: gray),
                                ),
                                onRatingUpdate: (value) => ratingGiven = value,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _discriptionField(),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: InkWell(
                            onTap: () async {
                              if (Utils.checkLoginUser(context)) {
                                await bookDetailsProvider.getAddComment(
                                  "2",
                                  widget.contentId ?? "",
                                  commentController.text,
                                  ratingGiven,
                                );
                                // ✅ Reset refresh logic
                                bookDetailsProvider.clearCommentData();
                                await bookDetailsProvider.getComment(
                                    "2", widget.contentId ?? "", 1);
                                ratingGiven = 0.0;
                                commentController.clear();
                                if (!context.mounted) return;
                                Navigator.pop(context);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: _indigo,
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: bookDetailsProvider.addcommentloading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: white,
                                        strokeWidth: 1,
                                      ),
                                    )
                                  : MyText(
                                      text: 'submit',
                                      color: white,
                                      fontsize: Dimens.largeTextSize,
                                      multilanguage: true,
                                      fontwaight: FontWeight.w600,
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _discriptionField() {
    return TextFormField(
      textAlign: TextAlign.left,
      obscureText: false,
      keyboardType: TextInputType.multiline,
      controller: commentController,
      textInputAction: TextInputAction.newline,
      minLines: 2,
      maxLines: 5,
      cursorColor: Constant.isDarkMode ? white : black,
      style: GoogleFonts.roboto(
          fontSize: Dimens.medium14TextSize, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: "Add a book review here",
        hintStyle: GoogleFonts.roboto(
            fontSize: Dimens.medium14TextSize,
            color: gray,
            fontWeight: FontWeight.w500),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
          borderSide: BorderSide(color: _indigo, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
          borderSide: BorderSide(color: _indigo, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
          borderSide: BorderSide(color: _indigo, width: 1),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
          borderSide: BorderSide(color: _indigo, width: 1),
        ),
      ),
    );
  }
}
