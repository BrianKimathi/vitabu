import 'dart:io';

import 'package:yourappname/pages/auther.dart';
import 'package:yourappname/pages/bookepubshow.dart';
import 'package:yourappname/pages/pdf/pdfreadingpage.dart';
import 'package:yourappname/pages/releteditem.dart';
import 'package:yourappname/pages/reviewviewall.dart';
import 'package:yourappname/provider/bookdetailsprovider.dart';
import 'package:yourappname/provider/releteditemprovider.dart';
import 'package:yourappname/subscription/allpayment.dart';
import 'package:yourappname/subscription/subscription.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/customebutton.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:iconify_flutter/icons/ri.dart';
import 'package:iconify_flutter/icons/uil.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:share_plus/share_plus.dart';

class BookDetails extends StatefulWidget {
  final String? contentId, categoryId, authorId;
  const BookDetails(
      {super.key,
      required this.contentId,
      required this.categoryId,
      required this.authorId});

  @override
  State<BookDetails> createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  BookDetailsProvider bookDetailsProvider = BookDetailsProvider();
  double? ratingGiven;
  final commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    bookDetailsProvider =
        Provider.of<BookDetailsProvider>(context, listen: false);
    printLog("My Category Ids is ${widget.categoryId}");
    getApi();
  }

  Future getApi() async {
    await bookDetailsProvider.getBookDetails("2", widget.contentId);
    await fetchTabData(0);
    await fetchreviewData(0);
    await bookDetailsProvider.getRelatedItems(
        "2", widget.categoryId ?? "", widget.contentId ?? "", 1);
  }

  Future fetchTabData(int? pageNo) async {
    await bookDetailsProvider.getChapterbyBook(
        widget.contentId ?? "", ((pageNo ?? 0) + 1));
  }

  Future fetchreviewData(int? pageNo) async {
    await bookDetailsProvider.getComment(
        "2", widget.contentId ?? "", ((pageNo ?? 0) + 1));
  }

  @override
  void dispose() {
    bookDetailsProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 14,
          bottom: MediaQuery.of(context).padding.bottom + 14,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E2E) : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: Consumer<BookDetailsProvider>(
          builder: (context, bookDetailsProvider, child) {
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

            return Row(
              children: [
                Expanded(
                  flex: 2,
                  child: CustomeButton(
                    text: goToSubscription
                        ? "unlock_full_access"
                        : (goToPayment ? "buy_now" : "read_books"),
                    fontsize: 14,
                    fontWeight: FontWeight.w700,
                    textColor: white,
                    color: colorAccent,
                    borderColor: colorAccent,
                    radius: 12,
                    onTap: () async {
                      if (!Utils.checkLoginUser(context)) return;

                      if (goToSubscription) {
                        showSubscribeDialog(context);
                        return;
                      }

                      if (goToPayment) {
                        await Utils.push(
                          context,
                          AllPayment(
                            issubscription: 0,
                            itemId: bookDe?.id.toString(),
                            itemTitle: bookDe?.title.toString(),
                            price: bookDe?.price.toString(),
                            autherid: bookDe?.authorId.toString(),
                            contentType: "2",
                          ),
                        );
                        getApi();
                        return;
                      }

                      if (isFreeAccess) {
                        String ex = Utils.getEx(bookDe?.fullNovel ?? "");
                        if (ex == "pdf") {
                          Utils.push(
                            context,
                            PdfReadingPage(
                              bookID: bookDe?.id.toString(),
                              name: bookDe?.title.toString(),
                              pdfUrl: bookDe?.fullNovel.toString(),
                              issubscription: bookDe?.isSubscription ?? 0,
                              autherid: bookDe?.authorId.toString(),
                              contentType: '2',
                            ),
                          );
                        } else {
                          Utils.push(
                            context,
                            BookEpubShow(
                              ePubUrl: bookDe?.fullNovel.toString(),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: CustomeButton(
                    text: "add_review",
                    color: colorPrimary,
                    borderColor: colorPrimary,
                    fontsize: 14,
                    fontWeight: FontWeight.w600,
                    textColor: white,
                    radius: 12,
                    onTap: () async {
                      if (Utils.checkLoginUser(context)) {
                        if (goToSubscription) {
                          showSubscribeDialog(context);
                          return;
                        }
                        if ((bookDetailsProvider.bookDetailModel.result?.accessType.toString() ?? "") == "1" &&
                            (bookDetailsProvider.bookDetailModel.result?.isBuy.toString() ?? "") == "0") {
                          await Navigator.of(context).push(PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) {
                              return AllPayment(
                                issubscription: 0,
                                itemId: bookDetailsProvider.bookDetailModel.result?.id.toString(),
                                itemTitle: bookDetailsProvider.bookDetailModel.result?.title.toString(),
                                price: bookDetailsProvider.bookDetailModel.result?.price.toString(),
                                autherid: bookDetailsProvider.bookDetailModel.result?.authorId.toString(),
                                contentType: "3",
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
                          getApi();
                        } else {
                          showAddCommentBottomshit();
                        }
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: Consumer<BookDetailsProvider>(
        builder: (context, bookDetailsProvider, child) {
          return SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _detailsPage(),
                  const SizedBox(height: 20),
                  _buildEpisodeList(),
                  const SizedBox(height: 20),
                  _buildReletedData(),
                  const SizedBox(height: 40),
                ],
              ));
        },
      ),
    );
  }

  Widget _detailsPage() {
    if (bookDetailsProvider.loading) {
      return _detailsShimmer();
    } else {
      if (bookDetailsProvider.bookDetailModel.status == 200 &&
          bookDetailsProvider.bookDetailModel.result != null) {
        final bookDe = bookDetailsProvider.bookDetailModel.result;

        bool isSubscriptionType = bookDe?.accessType.toString() == "2";
        bool isSubscribed = Constant.isSubscription == 1;
        bool isPaidType = bookDe?.accessType.toString() == "1";
        bool isBought = bookDe?.isBuy.toString() == "1";

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
        return Column(
          children: [
            SizedBox(
              height: Platform.isIOS ? 400 : 375,
              child: Stack(
                children: [
                  Opacity(
                    opacity: 0.6,
                    child: MyNetworkImage(
                      imagePath: bookDe?.landscapeImg ?? "",
                      height: 336,
                      width: MediaQuery.sizeOf(context).width,
                      fit: BoxFit.fill,
                      radius: 0,
                    ),
                  ),
                  Positioned(
                    child: Container(
                      height: 336,
                      width: MediaQuery.sizeOf(context).width,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                        black.withOpacity(0.35),
                        black.withOpacity(0.8),
                      ])),
                    ),
                  ),
                  Positioned(
                    top: 28,
                    left: 10,
                    right: 10,
                    child: SafeArea(
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                splashColor: transparent,
                                focusColor: transparent,
                                hoverColor: transparent,
                                onTap: () {
                                  if (Navigator.canPop(context)) {
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: Container(
                                  height: 30,
                                  width: 30,
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: ligthDark,
                                  ),
                                  child: Icon(Icons.arrow_back_ios,
                                      size: 16, color: white),
                                ),
                              ),
                              Stack(
                                children: [
                                  MyNetworkImage(
                                    imagePath: bookDe?.portraitImg ?? "",
                                    height: 200,
                                    width: 150,
                                    fit: BoxFit.fill,
                                    radius: 0,
                                  ),
                                  if (goToSubscription)
                                    Positioned(
                                        bottom: 40,
                                        top: 40,
                                        left: 40,
                                        right: 40,
                                        child: Container(
                                            decoration: BoxDecoration(
                                                color: colorPrimaryDark,
                                                shape: BoxShape.circle),
                                            child: Icon(
                                              Icons.lock,
                                              color: Constant.isDarkMode
                                                  ? white
                                                  : black,
                                              size: 30,
                                            )))
                                ],
                              ),
                            ],
                          ),
                           SizedBox(height: Platform.isIOS ? 20 : 30),
                          InkWell(
                            splashColor: transparent,
                            focusColor: transparent,
                            hoverColor: transparent,
                            onTap: () async {
                              String ex = Utils.getEx(bookDe?.fullNovel ?? "");
                              if (!Utils.checkLoginUser(context)) return;

                              if (goToSubscription) {
                                showSubscribeDialog(context);
                                return;
                              }

                              if (goToPayment) {
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
                                if (ex == "pdf") {
                                  Utils.push(
                                    context,
                                    PdfReadingPage(
                                      bookID: bookDe?.id.toString(),
                                      name: bookDe?.title.toString(),
                                      pdfUrl: bookDe?.fullNovel.toString(),
                                      issubscription:
                                          bookDe?.isSubscription ?? 0,
                                      autherid: bookDe?.authorId.toString(),
                                      contentType: '2',
                                    ),
                                  );
                                } else {
                                  Utils.push(
                                    context,
                                    BookEpubShow(
                                      ePubUrl: bookDe?.fullNovel.toString(),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                              height: 56,
                              width: MediaQuery.sizeOf(context).width - 150,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colorAccent,
                                    colorPrimaryDark,
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorAccent.withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    goToSubscription
                                        ? Icons.lock_outline
                                        : (goToPayment
                                            ? Icons.shopping_cart_outlined
                                            : Icons.menu_book_rounded),
                                    color: white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  MyText(
                                    color: white,
                                    text: goToSubscription
                                        ? "unlock_full_access"
                                        : (goToPayment
                                            ? "buy_now"
                                            : "read_books"),
                                    maxline: 1,
                                    multilanguage: true,
                                    fontsize: Dimens.medium18TextSize,
                                    fontwaight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 20,
                    children: [
                      Expanded(
                        child: MyText(
                          text: bookDe?.title ?? "",
                          maxline: 2,
                          fontstyle: FontStyle.normal,
                          isfont: 3,
                          overflow: TextOverflow.ellipsis,
                          multilanguage: false,
                          fontsize: Dimens.medium20TextSize,
                          fontwaight: FontWeight.w600,
                        ),
                      ),
                      InkWell(
                        splashColor: transparent,
                        hoverColor: transparent,
                        focusColor: transparent,
                        onTap: () {
                          if (Utils.checkLoginUser(context)) {
                            bookDetailsProvider.getBookMark(
                                "2", bookDe?.id ?? "");
                          }
                        },
                        child: Icon(
                          bookDe?.isBookmark == 1
                              ? Icons.bookmark
                              : Icons.bookmark_outline_rounded,
                          size: 25,
                          color: Theme.of(context).canvasColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () {
                      if (bookDe?.customAuthorName == null || bookDe!.customAuthorName!.isEmpty) {
                        Navigator.of(context).push(PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) {
                            return Auther(
                              autherUserID: bookDe?.authorId.toString() ?? "",
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
                      }
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      spacing: 20,
                      children: [
                        if (bookDe?.customAuthorName == null || bookDe!.customAuthorName!.isEmpty)
                          MyNetworkImage(
                            imagePath: bookDe?.authorImage ?? "",
                            height: 40,
                            width: 40,
                            fit: BoxFit.fill,
                            radius: 200,
                          ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              MyText(
                                text: (bookDe?.customAuthorName != null && bookDe!.customAuthorName!.isNotEmpty)
                                    ? bookDe!.customAuthorName!
                                    : (bookDe?.authorName ?? ""),
                                maxline: 2,
                                multilanguage: false,
                                fontsize: Dimens.medium16TextSize,
                                fontwaight: FontWeight.w400,
                              ),
                              if (bookDe?.bsnb != null && bookDe!.bsnb!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: MyText(
                                    text: "BSNB: ${bookDe?.bsnb}",
                                    fontsize: Dimens.medium12TextSize,
                                    color: gray,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (isSubscriptionType && !isSubscribed)
                    _subscriptionIncludedCard(context)
                  else
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: colorAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: MyText(
                          text: isSubscriptionType && isSubscribed
                              ? "Free"
                              : (isPaidType && !isBought
                                  ? "${Constant.currencySymbol} ${bookDe?.price ?? ""}"
                                  : "Free"),
                          maxline: 2,
                          multilanguage: false,
                          fontsize: Dimens.titleTextSize,
                          fontwaight: FontWeight.w700,
                          color: colorAccent,
                        ),
                      ),
                    ),
                  const SizedBox(height: 12),
                  _buildShareButton(
                    contentType: "2",
                    contentId: bookDe?.id ?? '',
                    categoryId: bookDe?.categoryId ?? '',
                    authorId: bookDe?.authorId ?? '',
                    title: bookDe?.title ?? '',
                    image: bookDe?.portraitImg ?? '',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: colorAccent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const MyText(
                        text: "about_this_book",
                        maxline: 1,
                        multilanguage: true,
                        fontsize: Dimens.medium18TextSize,
                        fontwaight: FontWeight.w700,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
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
                    colorClickableText: colorPrimaryDark,
                    trimCollapsedText: 'Show more',
                    trimExpandedText: 'Show less',
                    lessStyle: Utils.googleFontStyle(2, Dimens.medium16TextSize,
                        FontStyle.normal, colorAccent, FontWeight.w700),
                    moreStyle: Utils.googleFontStyle(2, Dimens.medium16TextSize,
                        FontStyle.normal, colorAccent, FontWeight.w700),
                  ),
                  const SizedBox(height: 20),
                  // Modern Divided Stats Grid Bar
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Constant.isDarkMode
                          ? const Color(0xFF1E1E2E)
                          : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Constant.isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.black.withOpacity(0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
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
                          _buildModernStatItem(
                            context,
                            icon: Icons.visibility_rounded,
                            iconColor: const Color(0xFF3B82F6),
                            value: "${bookDe?.totalRead ?? "0"}",
                            label: "Reads",
                          ),
                          _buildVerticalDivider(),
                          _buildModernStatItem(
                            context,
                            icon: Icons.star_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            value: "${bookDe?.avgReviews ?? "0.0"}",
                            label: "${bookDe?.totalReviews ?? "0"} Reviews",
                          ),
                          _buildVerticalDivider(),
                          _buildModernStatItem(
                            context,
                            icon: Icons.category_rounded,
                            iconColor: const Color(0xFF8B5CF6),
                            value: bookDe?.categoryName ?? "Book",
                            label: "Category",
                          ),
                          if ((bookDe?.languageName ?? "") != "") ...[
                            _buildVerticalDivider(),
                            _buildModernStatItem(
                              context,
                              icon: Icons.translate_rounded,
                              iconColor: const Color(0xFF10B981),
                              value: bookDe?.languageName ?? "English",
                              label: "Language",
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildShareButton(
                    contentType: "2",
                    contentId: bookDe?.id ?? '',
                    categoryId: bookDe?.categoryId ?? '',
                    authorId: bookDe?.authorId ?? '',
                    title: bookDe?.title ?? '',
                  ),
                  const SizedBox(height: 20),
                  commentData(),
                ],
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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: Constant.isDarkMode
                ? [const Color(0xFF1A2E1A), const Color(0xFF0D1F0D)]
                : [const Color(0xFFE8F8F0), const Color(0xFFD0F0E0)],
          ),
          border: Border.all(
            color: green.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: green.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [green, const Color(0xFF02A040)],
                ),
              ),
              child: const Icon(
                Icons.check,
                size: 20,
                color: white,
              ),
            ),
            const SizedBox(width: 14),
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
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    color: Constant.isDarkMode ? white : black,
                    multilanguage: true,
                  ),
                  const SizedBox(height: 3),
                  MyText(
                    text: "readbooksde",
                    fontsize: Dimens.medium12TextSize,
                    fontwaight: FontWeight.w400,
                    fontstyle: FontStyle.normal,
                    isfont: 2,
                    maxline: 2,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.start,
                    color: Constant.isDarkMode
                        ? const Color(0xFFAAAAAA)
                        : const Color(0xFF666666),
                    multilanguage: true,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: green,
                borderRadius: BorderRadius.circular(20),
              ),
              child: MyText(
                text: "selectplan",
                isfont: 3,
                fontstyle: FontStyle.normal,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                fontsize: Dimens.medium12TextSize,
                fontwaight: FontWeight.w600,
                color: white,
                multilanguage: true,
              ),
            ),
          ],
        ),
      ),
    );
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
                        Constant.isDarkMode ? colorPrimaryDark : colorPrimary,
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
                      backgroundColor: colorAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Utils.push(context, Subscription());
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
              color: colorPrimary,
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

  Widget _statChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Constant.isDarkMode
            ? const Color(0xFF2A2A40)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Constant.isDarkMode
              ? const Color(0xFF3A3A4E)
              : const Color(0xFFE8E8F0),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: colorAccent),
          const SizedBox(width: 6),
          MyText(
            text: text,
            maxline: 1,
            multilanguage: false,
            fontsize: Dimens.medium13TextSize,
            fontwaight: FontWeight.w500,
            color: Constant.isDarkMode ? white : black,
          ),
        ],
      ),
    );
  }

  Widget _dot() {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: Constant.isDarkMode
            ? const Color(0xFF4A4A5E)
            : const Color(0xFFD0D0D8),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildShareButton({
    required String contentType,
    required dynamic contentId,
    required dynamic categoryId,
    required dynamic authorId,
    required String title,
    String? image,
  }) {
    final isDark = Constant.isDarkMode;
    return InkWell(
      onTap: () {
        final shareUrl =
            "https://console.vitabu.online/share?content_type=$contentType&content_id=$contentId&name=${Uri.encodeComponent(title)}&image=${Uri.encodeComponent(image ?? '')}";
        SharePlus.instance.share(
          ShareParams(
            text: "Hey! I am reading $title on Vitabu:\n$shareUrl",
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [colorPrimary, colorPrimaryDark],
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: colorPrimary.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.share_rounded, size: 20, color: Colors.white),
            const SizedBox(width: 10),
            const Text(
              "Share",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailsShimmer() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomWidget.circular(height: 30, width: 30),
                CustomWidget.roundcorner(height: 200, width: 130),
                CustomWidget.circular(height: 30, width: 30),
              ],
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidget.roundcorner(
                        height: 20, width: MediaQuery.sizeOf(context).width),
                    const SizedBox(height: 6),
                    CustomWidget.roundcorner(height: 20, width: 200),
                  ],
                )),
                SizedBox(width: 20),
                const CustomWidget.circular(height: 30, width: 30),
              ],
            ),
            const SizedBox(height: 20),
            const Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CustomWidget.circular(height: 40, width: 40),
                SizedBox(width: 20),
                CustomWidget.roundcorner(height: 18, width: 160)
              ],
            ),
            const SizedBox(height: 20),
            const Align(
                alignment: Alignment.topLeft,
                child: CustomWidget.roundcorner(height: 18, width: 200)),
            SizedBox(height: 10),
            CustomWidget.roundcorner(
                height: 18, width: MediaQuery.sizeOf(context).width),
            SizedBox(height: 8),
            CustomWidget.roundcorner(
                height: 18, width: MediaQuery.sizeOf(context).width),
            SizedBox(height: 8),
            CustomWidget.roundcorner(
                height: 18, width: MediaQuery.sizeOf(context).width),
            SizedBox(height: 8),
            const CustomWidget.roundcorner(height: 18, width: 200),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Column(
                  children: [
                    CustomWidget.roundcorner(height: 18, width: 50),
                    SizedBox(height: 8),
                    CustomWidget.roundcorner(height: 14, width: 60),
                  ],
                ),
                Container(height: 40, width: 2, color: colorPrimary),
                const Column(
                  children: [
                    CustomWidget.roundcorner(height: 18, width: 50),
                    SizedBox(height: 8),
                    CustomWidget.roundcorner(height: 14, width: 60),
                  ],
                ),
                Container(height: 40, width: 2, color: colorPrimary),
                const Column(
                  children: [
                    CustomWidget.roundcorner(height: 18, width: 50),
                    SizedBox(height: 8),
                    CustomWidget.roundcorner(height: 14, width: 60),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

// Episode List Data Started
  Widget _buildEpisodeList() {
    if (bookDetailsProvider.bookChapterLoading) {
      return chapterShimmer();
    } else {
      if (bookDetailsProvider.chaptersList != null &&
          (bookDetailsProvider.chaptersList?.length ?? 0) > 0) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: colorAccent,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  MyText(
                    text:
                        "${Utils.kmbGenerator(bookDetailsProvider.bookDetailModel.result?.totalChapters ?? 0)} Chapters",
                    maxline: 1,
                    multilanguage: false,
                    fontsize: Dimens.medium20TextSize,
                    fontwaight: FontWeight.w700,
                  ),
                ],
              ),
              episodeList(),
              if (bookDetailsProvider.loadMore)
                chapterShimmer()
              else
                SizedBox.fromSize(),
              if (bookDetailsProvider.chapterModel.morePage == true)
                Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    hoverColor: transparent,
                    splashColor: transparent,
                    focusColor: transparent,
                    highlightColor: transparent,
                    onTap: () async {
                      if ((bookDetailsProvider.currentPage ?? 0) <
                          (bookDetailsProvider.totalPage ?? 0)) {
                        bookDetailsProvider.setLoadMore(true);
                        await bookDetailsProvider.getChapterbyBook(
                            widget.contentId ?? "",
                            ((bookDetailsProvider.currentPage ?? 0) + 1));
                      }
                    },
                    child: MyText(
                      text: "more",
                      maxline: 1,
                      multilanguage: true,
                      fontsize: Dimens.medium16TextSize,
                      fontwaight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget episodeList() {
    return ResponsiveGridList(
        minItemWidth: 300,
        minItemsPerRow: 1,
        maxItemsPerRow: 2,
        listViewBuilderOptions: ListViewBuilderOptions(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics()),
        children: List.generate(
          bookDetailsProvider.chaptersList?.length ?? 0,
          (index) {
            final chapterDe = bookDetailsProvider.chaptersList?[index];
            int displayIndex = index + 1;
            return InkWell(
              onTap: () async {
                String ex = Utils.getEx(chapterDe?.chapter ?? "");
                if (Utils.checkLoginUser(context)) {
                  if ((chapterDe?.isChapterPaid.toString() ?? "") == "1" &&
                      (chapterDe?.isBuy.toString() ?? "") == "0") {
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
                    getApi();
                  } else {
                    if (ex == "pdf") {
                      Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          printLog(
                              "chapterid :===========>>> ${chapterDe?.id}");
                          return PdfReadingPage(
                            bookID: chapterDe?.novelId.toString(),
                            name: chapterDe?.title.toString(),
                            pdfUrl: chapterDe?.chapter.toString(),
                            chapterID: chapterDe?.id.toString(),
                            issubscription: 0,
                            autherid: bookDetailsProvider
                                .bookModel.result?[0].authorId
                                .toString(),
                            contentType: '2',
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
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Constant.isDarkMode
                      ? const Color(0xFF1E1E2E)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Constant.isDarkMode
                        ? const Color(0xFF2D2D44)
                        : const Color(0xFFF0F0F5),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Constant.isDarkMode
                          ? Colors.black.withOpacity(0.2)
                          : Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Chapter number badge
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colorAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: MyText(
                          text: displayIndex.toString(),
                          fontsize: Dimens.medium14TextSize,
                          fontwaight: FontWeight.w600,
                          color: colorAccent,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Chapter info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            text: chapterDe?.title ?? "",
                            fontsize: Dimens.medium15TextSize,
                            fontwaight: FontWeight.w500,
                            color: Constant.isDarkMode ? white : black,
                            maxline: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if ((chapterDe?.description ?? "").isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: MyText(
                                text: chapterDe?.description ?? "",
                                fontsize: Dimens.medium12TextSize,
                                fontwaight: FontWeight.w400,
                                color: gray,
                                maxline: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Play/Lock icon
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: ((chapterDe?.isChapterPaid.toString() ?? "") == "1" &&
                                (chapterDe?.isBuy.toString() ?? "") == "0")
                            ? colorPrimary
                            : colorAccent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Iconify(
                          ((chapterDe?.isChapterPaid.toString() ?? "") == "1" &&
                                  (chapterDe?.isBuy.toString() ?? "") == "0")
                              ? Uil.lock
                              : Ph.play_bold,
                          size: 20,
                          color: ((chapterDe?.isChapterPaid.toString() ?? "") ==
                                      "1" &&
                                  (chapterDe?.isBuy.toString() ?? "") == "0")
                              ? white
                              : colorAccent,
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ));
  }

  Widget chapterShimmer() {
    return AlignedGridView.count(
      crossAxisCount: 1,
      itemCount: 3,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Row(
            children: [
              const CustomWidget.circular(height: 30, width: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CustomWidget.roundcorner(height: 18, width: 200),
                    const SizedBox(height: 4),
                    CustomWidget.roundcorner(
                        height: 14, width: MediaQuery.sizeOf(context).width),
                  ],
                ),
              ),
              const CustomWidget.circular(height: 30, width: 30),
            ],
          ),
        );
      },
    );
  }

/* END Chapter Data */
// Releted Item Data Started
  Widget _buildReletedData() {
    if (bookDetailsProvider.releteditemsloading) {
      return _bookshimmer();
    }
    if (bookDetailsProvider.bookModel.status == 200 &&
        (bookDetailsProvider.bookModel.result?.length ?? 0) > 0) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: colorAccent,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: MyText(
                          text: "similar_book",
                          maxline: 1,
                          multilanguage: true,
                          fontsize: Dimens.medium20TextSize,
                          fontwaight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () {
                    final reletedItemProvider =
                        Provider.of<ReletedItemProvider>(context,
                            listen: false);
                    Navigator.of(context).pushReplacement(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return ReletedItem(
                          contentId: widget.contentId ?? "",
                          type: "2",
                          categoryId: widget.categoryId ?? "",
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
                  child: Row(
                    children: [
                      MyText(
                        color: Theme.of(context).primaryColor,
                        text: 'more',
                        textalign: TextAlign.center,
                        fontsize: Dimens.medium12TextSize,
                        fontwaight: FontWeight.w700,
                        multilanguage: true,
                        maxline: 1,
                        overflow: TextOverflow.ellipsis,
                        fontstyle: FontStyle.normal,
                      ),
                      SizedBox(width: 5),
                      Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 10,
                          color: Theme.of(context).cardColor,
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 14),
            reletedItems(),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget reletedItems() {
    return SingleChildScrollView(
      physics: AlwaysScrollableScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          bookDetailsProvider.bookModel.result?.length ?? 0,
          (index) {
            return InkWell(
              onTap: () {
                Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return BookDetails(
                          categoryId: bookDetailsProvider
                                  .bookModel.result?[index].categoryId
                                  .toString() ??
                              "",
                          authorId: bookDetailsProvider
                                  .bookModel.result?[index].authorId
                                  .toString() ??
                              "",
                          contentId: bookDetailsProvider
                                  .bookModel.result?[index].id
                                  .toString() ??
                              "",
                        );
                      },
                      transitionDuration: Duration(milliseconds: 200),
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
                margin: const EdgeInsets.only(right: 5),
                width: 130,
                child: Column(
                  children: [
                    MyNetworkImage(
                        imagePath: bookDetailsProvider
                                .bookModel.result?[index].portraitImg
                                .toString() ??
                            "",
                        height: 190,
                        width: 130,
                        radius: 12,
                        fit: BoxFit.cover),
                    const SizedBox(height: 7),
                    MyText(
                      text: bookDetailsProvider.bookModel.result?[index].title
                              .toString() ??
                          "",
                      fontsize: Dimens.medium14TextSize,
                      maxline: 2,
                      fontwaight: FontWeight.w500,
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

/* Review list Show */

  Widget commentData() {
    if (bookDetailsProvider.commentloading) {
      return commentShimmer();
    } else {
      if ((bookDetailsProvider.commentList?.length ?? 0) > 0 &&
          bookDetailsProvider.commentList != null) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Row(
              children: [
                MyText(
                  text: "review",
                  multilanguage: true,
                  maxline: 1,
                  fontsize: Dimens.medium18TextSize,
                  fontwaight: FontWeight.w500,
                ),
                const SizedBox(width: 10),
                MyText(
                  text:
                      "(${Utils.kmbGenerator(bookDetailsProvider.bookDetailModel.result?.totalReviews ?? 0)})",
                  multilanguage: false,
                  maxline: 1,
                  fontsize: Dimens.medium18TextSize,
                  fontwaight: FontWeight.w500,
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return ReviewViewAll(
                          contentId: bookDetailsProvider
                                  .bookDetailModel.result?.id
                                  .toString() ??
                              "",
                          type: "2",
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
                  },
                  child: MyText(
                    color: Theme.of(context).textTheme.bodyLarge!.color,
                    text: "viewall",
                    multilanguage: true,
                    maxline: 1,
                    fontsize: Dimens.medium16TextSize,
                    fontwaight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            AlignedGridView.count(
              crossAxisCount: 1,
              itemCount: bookDetailsProvider.commentList?.length ?? 0,
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
                            imagePath: bookDetailsProvider
                                .commentList?[index].userImage,
                            fit: BoxFit.fill,
                            height: 30,
                            width: 30,
                            radius: 200),
                        const SizedBox(width: 10),
                        MyText(
                          text:
                              "${bookDetailsProvider.commentList?[index].firstName ?? ""} ${bookDetailsProvider.commentList?[index].lastName ?? ""}",
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
                            text: bookDetailsProvider
                                    .commentList?[index].review ??
                                "",
                            maxline: 1,
                            fontsize: Dimens.medium14TextSize,
                            fontwaight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 15),
                        if (bookDetailsProvider.commentList?[index].userId
                                .toString() ==
                            Constant.userID)
                          if (bookDetailsProvider.deletecommentLoading &&
                              bookDetailsProvider.deleteItemIndex == index)
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
                                  await bookDetailsProvider.getDeleteComment(
                                      index,
                                      bookDetailsProvider.commentList?[index].id
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
            ),
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  showAddCommentBottomshit() {
    return showModalBottomSheet(
      backgroundColor: transparent,
      isScrollControlled: true,
      context: context,
      builder: (context) {
        return Consumer<BookDetailsProvider>(
            builder: (context, bookDetailsProvider, child) {
          return Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(35), topRight: Radius.circular(35)),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                        padding: EdgeInsets.fromLTRB(20, 30, 20, 20),
                        child: Stack(children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                MyText(
                                    text: "add_new_comment",
                                    multilanguage: true,
                                    fontsize: Dimens.medium14TextSize,
                                    fontwaight: FontWeight.w700)
                              ]),
                          InkWell(
                              onTap: () {
                                commentController.clear();
                                ratingGiven = 0.0;

                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.close,
                                color: colorAccent,
                                size: 24,
                              ))
                        ])),
                    Container(height: 2, color: colorAccent),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          MyText(
                            text: "your_rate",
                            multilanguage: true,
                            fontsize: Dimens.medium14TextSize,
                            fontwaight: FontWeight.w700,
                          ),
                          /* Add Rating */
                          Container(
                            margin: const EdgeInsets.fromLTRB(20, 20, 20, 25),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              spacing: 10,
                              children: [
                                MyText(
                                  text: "give_ratings",
                                  multilanguage: true,
                                  textalign: TextAlign.center,
                                  fontsize: Dimens.medium16TextSize,
                                  maxline: 1,
                                  fontwaight: FontWeight.w500,
                                  overflow: TextOverflow.ellipsis,
                                  fontstyle: FontStyle.normal,
                                ),
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
                                    onRatingUpdate: (value) {
                                      ratingGiven = value;
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /* Add Review */
                          const SizedBox(height: 7),
                          const MyText(
                            text: "story_development",
                            multilanguage: true,
                            fontsize: Dimens.medium14TextSize,
                            fontwaight: FontWeight.w500,
                          ),
                          const SizedBox(height: 30),
                          _discriptionField(),
                          const SizedBox(height: 30),
                          InkWell(
                            onTap: () async {
                              if (Utils.checkLoginUser(context)) {
                                await bookDetailsProvider.getAddComment(
                                    "2",
                                    widget.contentId ?? "",
                                    commentController.text,
                                    ratingGiven);

                                ratingGiven = 0.0;
                                commentController.clear();
                                FocusManager.instance.primaryFocus?.unfocus();

                                if (!context.mounted) return;

                                Navigator.of(context).pop();
                              }
                            },
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                constraints: BoxConstraints(maxWidth: 200),
                                decoration: BoxDecoration(
                                    color: colorAccent,
                                    borderRadius: BorderRadius.circular(5)),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                                  child: bookDetailsProvider.addcommentloading
                                      ? SizedBox(
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
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        });
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
          borderSide: BorderSide(color: colorAccent, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
          borderSide: BorderSide(color: colorAccent, width: 1),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
          borderSide: BorderSide(color: colorAccent, width: 1),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(6.0)),
          borderSide: BorderSide(color: colorAccent, width: 1),
        ),
      ),
    );
  }

  Widget commentShimmer() {
    return AlignedGridView.count(
      shrinkWrap: true,
      crossAxisCount: 1,
      crossAxisSpacing: 15,
      mainAxisSpacing: 20,
      itemCount: 3,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Row(
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
        );
      },
    );
  }

  Widget _bookshimmer() {
    return AlignedGridView.count(
      shrinkWrap: true,
      crossAxisCount: 3,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      itemCount: 3,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (BuildContext context, int position) {
        return Column(
          children: [
            CustomWidget.roundcorner(
              height: MediaQuery.sizeOf(context).height * 0.172,
              shapeBorder: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8))),
            ),
            const SizedBox(
              height: 10,
            ),
            const CustomWidget.rectangular(height: 5)
          ],
        );
      },
    );
  }

  Widget _buildModernStatItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: Constant.isDarkMode
          ? const Color(0xFF334155)
          : const Color(0xFFE2E8F0),
    );
  }
}
