// ignore_for_file: unrelated_type_equality_checks

import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:yourappname/pages/bookepubshow.dart';
import 'package:yourappname/provider/magazinedetailsprovider.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/provider/releteditemprovider.dart';
import 'package:yourappname/subscription/allpayment.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/icons/ri.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';

class WebMagazineDetails extends StatefulWidget {
  final String? contentId, categoryId, type, name;
  final bool? isFromHome;
  const WebMagazineDetails(
      {super.key,
      this.contentId,
      this.categoryId,
      this.type,
      this.name,
      this.isFromHome});

  @override
  State<WebMagazineDetails> createState() => _WebMagazineDetailsState();
}

class _WebMagazineDetailsState extends State<WebMagazineDetails> {
  final commentController = TextEditingController();
  double addrating = 0.0;

  late MagazineDetailsProvider magazineDetailsProvider;
  final editcommentController = TextEditingController();
  double? ratingGiven;

  @override
  void initState() {
    magazineDetailsProvider =
        Provider.of<MagazineDetailsProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getApiData();
    });
    super.initState();
  }

  getApiData() async {
    magazineDetailsProvider.setLoading(true);
    magazineDetailsProvider.clearCommentData();
    magazineDetailsProvider.getMagazineDetails("3", widget.contentId ?? "");
    magazineDetailsProvider.getComment("3", widget.contentId ?? "", 1);
    magazineDetailsProvider.getRelatedItems(
        "3", widget.categoryId ?? "", widget.contentId ?? "", 0);
  }

  @override
  void dispose() {
    magazineDetailsProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxContentWidth = 1400;
    final contentWidth =
        screenWidth > maxContentWidth ? maxContentWidth : screenWidth - 20;
    return Consumer<MagazineDetailsProvider>(
        builder: (context, magazineDetailsProvider, child) {
      return WebAppBar(
          widget: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
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
                    multilanguage: false),
              ),
            ),
            Center(
              child: SizedBox(width: contentWidth, child: buildWeb()),
            ),
            Center(
                child:
                    SizedBox(width: contentWidth, child: _buildReletedData())),
            FooterWeb()
          ],
        ),
      ));
    });
  }

  /* Web details data  */
  Widget buildWeb() {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1000) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: parentContainerWeb(),
          ),
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              color: white,
              child: rightLayout(),
            ),
          ),
        ],
      );
    } else {
      return Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            parentContainerWeb(),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              color: white,
              child: rightLayout(),
            ),
          ],
        ),
      );
    }
  }

  Widget parentContainerWeb() {
    if (magazineDetailsProvider.loading) {
      return parentContainerWithShimmer();
    }

    final result = magazineDetailsProvider.magazineDetailModel.result;
    if (magazineDetailsProvider.magazineDetailModel.status == 200 &&
        result != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            alignment: Alignment.center,
            color: colorPrimary.withOpacity( 0.1),
            width: MediaQuery.of(context).size.width,
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
                      imagePath: result.landscapeImg ?? "",
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          detailsTabData(),
          const SizedBox(height: 16),
          childItem(),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget detailsTabData() {
    return Row(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 24,
            children: [
              InkWell(
                splashColor: transparent,
                focusColor: transparent,
                hoverColor: transparent,
                highlightColor: transparent,
                onTap: () {
                  magazineDetailsProvider.setDetailsTab("1");
                },
                child: Container(
                  padding: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 1,
                        color: magazineDetailsProvider.tabDetails == "1"
                            ? black
                            : transparent,
                      ),
                    ),
                  ),
                  child: MyText(
                    color: black,
                    text: "description",
                    multilanguage: true,
                    fontsize: Dimens.medium16TextSize,
                    fontsizeWeb: Dimens.medium16TextSize,
                    fontwaight: FontWeight.w600,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.left,
                  ),
                ),
              ),
              InkWell(
                splashColor: transparent,
                focusColor: transparent,
                hoverColor: transparent,
                highlightColor: transparent,
                onTap: () {
                  magazineDetailsProvider.setDetailsTab("2");
                },
                child: Container(
                  padding: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        width: 1,
                        color: magazineDetailsProvider.tabDetails == "2"
                            ? black
                            : transparent,
                      ),
                    ),
                  ),
                  child: MyText(
                    color: black,
                    text: "reviews",
                    multilanguage: true,
                    fontsize: Dimens.medium16TextSize,
                    fontsizeWeb: Dimens.medium16TextSize,
                    fontwaight: FontWeight.w600,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.left,
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Consumer<MagazineDetailsProvider>(
              builder: (context, provider, child) {
                return InkWell(
                  onTap: () {
                    final bookDe = provider.magazineDetailModel.result;
                    if (Utils.checkLoginUser(context)) {
                      provider.getBookMark("3", bookDe?.id ?? "");
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
                      (provider.magazineDetailModel.result?.isBookmark == 1)
                          ? Icons.bookmark
                          : Icons.bookmark_outline_rounded,
                      color: colorPrimary,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        SizedBox(
          width: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            InkWell(
              onTap: () {
                if (Utils.checkLoginUser(context)) {
                  final base =
                      (Constant.website ?? "https://vitabu.online").replaceAll(RegExp(r'/$'), '');
                  final mag = magazineDetailsProvider.magazineDetailModel.result;
                  final shareUrl =
                      "$base/?content_type=3&content_id=${mag?.id ?? ''}&category_id=${mag?.categoryId ?? ''}&author_id=${mag?.authorId ?? ''}&name=${Uri.encodeComponent(mag?.title ?? '')}";
                  SharePlus.instance.share(ShareParams(
                      text:
                          "${Constant.appName}\n${magazineDetailsProvider.magazineDetailModel.result?.title ?? ''}\n$shareUrl"));
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: white,
                  border: Border.all(color: gray, width: 1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.share, size: 20, color: colorPrimary),
              ),
            )
          ],
        ),
      ],
    );
  }

  Widget childItem() {
    final result = magazineDetailsProvider.magazineDetailModel.result;
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 20,
        children: [
          if (magazineDetailsProvider.tabDetails == "1") ...[
            MyText(
              text: "about_this_book",
              maxline: 1,
              multilanguage: true,
              fontsize: Dimens.medium16TextSize,
              fontsizeWeb: Dimens.medium16TextSize,
              fontwaight: FontWeight.w700,
              color: colorPrimary,
            ),
            ReadMoreText(
              result?.description ?? "",
              trimLines: 3,
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: Dimens.medium15TextSize,
                fontWeight: FontWeight.w400,
                color: black,
              ),
              trimCollapsedText: 'Read More',
              colorClickableText: black,
              trimMode: TrimMode.Line,
              trimExpandedText: 'Read less',
              lessStyle: TextStyle(
                fontSize: Dimens.medium16TextSize,
                fontWeight: FontWeight.w600,
                color: colorPrimary,
              ),
              moreStyle: TextStyle(
                fontSize: Dimens.medium16TextSize,
                fontWeight: FontWeight.w600,
                color: colorPrimary,
              ),
            ),
          ] else if (magazineDetailsProvider.tabDetails == "2") ...[
            commentDataWeb(context, widget.type ?? "", widget.contentId ?? ""),
          ],
        ],
      ),
    );
  }

  Widget commentDataWeb(BuildContext context, contentType, contentId) {
    final provider = Provider.of<MagazineDetailsProvider>(context);

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
                        if (provider.deletecommentLoading &&
                            provider.deleteItemIndex == index)
                          const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: colorPrimary,
                              strokeWidth: 1,
                            ),
                          )
                        else
                          InkWell(
                            onTap: () async {
                              await provider.getDeleteComment(
                                  index, commentItem.id.toString());
                            },
                            child: const Icon(
                              Icons.delete,
                              size: 20,
                              color: colorPrimary,
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
          color: colorPrimary,
          fontsize: Dimens.medium16TextSize,
          fontsizeWeb: Dimens.medium16TextSize,
          fontwaight: FontWeight.w400,
        ),
      );
    }
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

  Widget parentContainerWithShimmer() {
    final screenWidth = MediaQuery.of(context).size.width;

    double textWidth = screenWidth * 0.55;
    if (screenWidth < 600) {
      textWidth = screenWidth * 0.9;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.center,
          color: colorPrimary.withOpacity( 0.1),
          width: MediaQuery.of(context).size.width,
          child: AspectRatio(
            aspectRatio: 4 / 3,
            child: const CustomWidget.roundcorner(
              height: double.infinity,
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: CustomWidget.roundrectborder(
            width: textWidth * 0.9,
            height: 22,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomWidget.roundrectborder(
                width: textWidth,
                height: 16,
              ),
              const SizedBox(height: 10),
              CustomWidget.roundrectborder(
                width: textWidth * 0.9,
                height: 16,
              ),
              const SizedBox(height: 10),
              CustomWidget.roundrectborder(
                width: textWidth * 0.8,
                height: 16,
              ),
              const SizedBox(height: 10),
              CustomWidget.roundrectborder(
                width: textWidth * 0.7,
                height: 16,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget rightLayout() {
    return Consumer<MagazineDetailsProvider>(
      builder: (context, magazineDetailsProvider, child) {
        if (magazineDetailsProvider.loading) {
          return rightLayoutShimmer();
        }

        final magDe = magazineDetailsProvider.magazineDetailModel.result;

        if (magazineDetailsProvider.magazineDetailModel.status != 200 ||
            magDe == null) {
          return const SizedBox.shrink();
        }

        /// 🔐 ACCESS LOGIC (SAME AS BOOK)
        bool isFreeAccess = false;
        bool goToSubscription = false;
        bool goToPayment = false;

        if (magDe.accessType.toString() == "0") {
          isFreeAccess = true;
        } else if (magDe.accessType.toString() == "1") {
          if (magDe.isBuy.toString() == "1") {
            isFreeAccess = true;
          } else {
            goToPayment = true;
          }
        } else if (magDe.accessType.toString() == "2") {
          if (Constant.isSubscription == 1) {
            isFreeAccess = true;
          } else {
            goToSubscription = true;
          }
        }

        final accessInfo = getAccessInfo(
          accessType: magDe.accessType.toString(),
          isBuy: magDe.isBuy.toString(),
          isSubscription: Constant.isSubscription ?? 0,
          price: magDe.price?.toString(),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 20,
          children: [
            /// 🔹 TOP BADGES (SAME AS BOOK)
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorPrimary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: MyText(
                    text: accessInfo.badgeLabel,
                    fontsizeWeb: Dimens.medium18TextSize,
                    fontsize: Dimens.medium13TextSize,
                    color: white,
                    maxline: 1,
                    multilanguage: true,
                    fontwaight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(width: 2, color: colorPrimary),
                  ),
                  child: MyText(
                    text: "magazine",
                    multilanguage: true,
                    color: colorPrimary,
                    fontsize: Dimens.medium14TextSize,
                    fontsizeWeb: Dimens.medium20TextSize,
                    fontwaight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            MyText(
              text: magDe.title ?? "",
              color: black,
              fontsize: Dimens.medium20TextSize,
              fontsizeWeb: Dimens.text28Size,
              fontwaight: FontWeight.w600,
              maxline: 2,
              overflow: TextOverflow.ellipsis,
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
                      backgroundColor: colorPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      String ex = Utils.getEx(magDe.fullMagazine ?? "");
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
                            itemId: magDe.id.toString(),
                            itemTitle: magDe.title.toString(),
                            price: magDe.price.toString(),
                            autherid: magDe.authorId.toString(),
                            contentType: "3",
                            subaccount: magDe.authorSubaccount,
                          ),
                        );
                        getApiData();
                        return;
                      }

                      if (isFreeAccess) {
                        if (ex == "pdf") {
                          Utils.push(
                            context,
                            WebPdfReadingPage(
                              bookID: magDe.id.toString(),
                              name: magDe.title.toString(),
                              pdfUrl: magDe.fullMagazine.toString(),
                              autherid: magDe.authorId.toString(),
                              contentType: '3',
                              issubscription: magDe.isSubscription ?? 0,
                            ),
                          );
                        } else {
                          Utils.push(
                            context,
                            BookEpubShow(
                              ePubUrl: magDe.fullMagazine.toString(),
                            ),
                          );
                        }
                      }
                    },
                    icon: Icon(
                      (magDe.accessType == 1 && magDe.isBuy == 0)
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
                      overflow: TextOverflow.ellipsis,
                      fontwaight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

            /// 🔹 REVIEW SECTION (SAME PLACE AS BOOK)
            writeReviewData(),
          ],
        );
      },
    );
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
                          Constant.isDarkMode ? colorPrimary : colorPrimary,
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
                        backgroundColor: colorPrimary,
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

  Widget rightLayoutShimmer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomWidget.roundcorner(width: 60, height: 20),
        const SizedBox(height: 8),
        CustomWidget.roundrectborder(width: double.infinity, height: 28),
        const SizedBox(height: 8),
        CustomWidget.roundrectborder(width: 100, height: 28),
        const Divider(thickness: 1, color: gray, height: 20),
        Row(
          spacing: 20,
          children: [
            CustomWidget.roundcorner(width: 120, height: 50),
            CustomWidget.roundcorner(width: 120, height: 50),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomWidget.roundrectborder(width: 120, height: 20),
                const SizedBox(height: 8),
                CustomWidget.roundrectborder(width: 100, height: 20),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomWidget.roundrectborder(width: 140, height: 20),
                const SizedBox(height: 8),
                CustomWidget.roundrectborder(width: 100, height: 20),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),
        CustomWidget.roundrectborder(width: double.infinity, height: 100),
      ],
    );
  }

  Widget writeReviewData() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 10,
      children: [
        MyText(
            color: black,
            multilanguage: true,
            text: "write_review",
            fontsize: Dimens.medium12TextSize,
            fontsizeWeb: Dimens.medium16TextSize,
            fontwaight: FontWeight.w400,
            maxline: 2,
            overflow: TextOverflow.ellipsis,
            textalign: TextAlign.left,
            fontstyle: FontStyle.normal),
        RatingBar(
          filledIcon: Icons.star,
          emptyIcon: Icons.star_border,
          filledColor: colorPrimary,
          emptyColor: colorPrimary,
          onRatingChanged: (value) {
            ratingGiven = value;
          },
          size: 25,
          initialRating: addrating,
          maxRating: 5,
        ),
        TextFormField(
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
              borderSide: BorderSide(color: colorPrimary, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
              borderSide: BorderSide(color: colorPrimary, width: 1),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
              borderSide: BorderSide(color: colorPrimary, width: 1),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
              borderSide: BorderSide(color: colorPrimary, width: 1),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomRight,
          child: InteractiveContainer(child: (isHovered) {
            return InkWell(
                hoverColor: transparent,
                splashColor: transparent,
                focusColor: transparent,
                highlightColor: transparent,
                onTap: () async {
                  if (Utils.checkLoginUser(context)) {
                    await magazineDetailsProvider.getAddComment(
                        "3",
                        widget.contentId ?? "",
                        commentController.text,
                        ratingGiven);

                    ratingGiven = 0.0;
                    commentController.clear();
                    FocusManager.instance.primaryFocus?.unfocus();

                    // magazineDetailsProvider.clearMagazineContnt();
                    magazineDetailsProvider.setLoading(false);
                    magazineDetailsProvider.getMagazineDetails(
                        "3", widget.contentId ?? "");
                  }
                },
                borderRadius: BorderRadius.circular(5),
                child: AnimatedScale(
                  scale: isHovered ? 1.05 : 1,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeInOut,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                    decoration: BoxDecoration(
                      color: isHovered ? colorPrimary : colorPrimary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: magazineDetailsProvider.addcommentloading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: white,
                              strokeWidth: 1,
                            ),
                          )
                        : MyText(
                            color: white,
                            multilanguage: true,
                            text: "submit",
                            textalign: TextAlign.left,
                            fontsize: Dimens.medium14TextSize,
                            fontsizeWeb: Dimens.medium14TextSize,
                            maxline: 1,
                            fontwaight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                            fontstyle: FontStyle.normal),
                  ),
                ));
          }),
        )
      ],
    );
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
    final provider =
        Provider.of<MagazineDetailsProvider>(context, listen: false);
    final items = provider.bookModel.result;

    if (provider.bookModel.status != 200 || items == null || items.isEmpty) {
      return const SizedBox.shrink();
    }

    // 🔹 Only builds section if related items exist
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
            children: [
              MyText(
                text: "similar_magazine",
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
                          type: "3",
                          categoryId: widget.categoryId ?? "",
                          name: widget.name ?? "",
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
                          color: isHovered ? colorPrimary : colorPrimary,
                          fontsize: Dimens.medium16TextSize,
                          fontsizeWeb: Dimens.medium16TextSize,
                          fontwaight: FontWeight.w400,
                        ),
                        Icon(
                          Icons.arrow_forward_ios_sharp,
                          size: 20,
                          color: isHovered ? colorPrimary : colorPrimary,
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
  }

  Widget relatedItems() {
    return Consumer<MagazineDetailsProvider>(
      builder: (context, provider, child) {
        if (provider.releteditemsloading) {
          return relatedItemsShimmer(); // Show shimmer while loading
        }

        final items = provider.bookModel.result;
        if (provider.bookModel.status != 200 ||
            items == null ||
            items.isEmpty) {
          return const SizedBox.shrink();
        }

        // Scroll Controller
        final ScrollController controller = ScrollController();
        const double scrollAmount = 250;

        return StatefulBuilder(
          builder: (context, setState) {
            // Listen for scroll changes
            controller.addListener(() {
              setState(() {});
            });

            bool canScrollLeft = controller.hasClients && controller.offset > 0;
            bool canScrollRight = controller.hasClients &&
                controller.offset < controller.position.maxScrollExtent;

            final screenWidth = MediaQuery.of(context).size.width;
            EdgeInsets dynamicPadding = canScrollRight
                ? (screenWidth > 1000
                    ? const EdgeInsets.fromLTRB(60, 0, 60, 0)
                    : const EdgeInsets.fromLTRB(0, 0, 0, 0))
                : (screenWidth > 1000
                    ? const EdgeInsets.symmetric(horizontal: 0)
                    : const EdgeInsets.symmetric(horizontal: 0));

            return Padding(
              padding: dynamicPadding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Left Arrow
                  canScrollLeft
                      ? _buildArrowButton(Icons.arrow_back_ios_new, () {
                          if (controller.hasClients) {
                            controller.animateTo(
                              (controller.offset - scrollAmount).clamp(
                                0.0,
                                controller.position.maxScrollExtent,
                              ),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        })
                      : const SizedBox.shrink(),

                  Flexible(
                    fit: FlexFit.loose,
                    child: SingleChildScrollView(
                      controller: controller,
                      physics: const BouncingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        spacing: 20,
                        children: List.generate(
                          items.length,
                          (index) {
                            final item = items[index];
                            final accessInfo = getAccessInfo(
                              accessType: item.accessType.toString(),
                              isBuy: item.isBuy.toString(),
                              isSubscription: Constant.isSubscription ?? 0,
                              price: item.price?.toString(),
                            );
                            return InkWell(
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                        secondaryAnimation) {
                                      return WebMagazineDetails(
                                        categoryId: item.categoryId.toString(),
                                        contentId: item.id.toString(),
                                        name: item.title.toString(),
                                      );
                                    },
                                    transitionDuration:
                                        const Duration(milliseconds: 200),
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
                                  ),
                                );
                              },
                              child: Container(
                                width: 185,
                                height: 380,
                                padding: const EdgeInsets.fromLTRB(6, 6, 6, 5),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: white,
                                  border: Border.all(width: 1, color: gray),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(0)),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 4,
                                  children: [
                                    MyNetworkImage(
                                      imagePath: item.portraitImg.toString(),
                                      fit: BoxFit.cover,
                                      height: 243,
                                      width: 179,
                                    ),
                                    MyText(
                                      text: item.title.toString(),
                                      fontsize: Dimens.medium16TextSize,
                                      maxline: 2,
                                      fontwaight: FontWeight.w500,
                                    ),
                                    MyText(
                                      color: yello,
                                      text: magazineDetailsProvider.bookModel
                                              .result?[index].categoryName
                                              .toString() ??
                                          "",
                                      fontsize: Dimens.medium12TextSize,
                                      fontsizeWeb: Dimens.medium15TextSize,
                                      maxline: 2,
                                      overflow: TextOverflow.ellipsis,
                                      fontwaight: FontWeight.w500,
                                      textalign: TextAlign.start,
                                      fontstyle: FontStyle.normal,
                                    ),
                                    MyText(
                                      color: gray,
                                      text: magazineDetailsProvider.bookModel
                                              .result?[index].authorName
                                              .toString() ??
                                          "",
                                      fontsize: Dimens.medium12TextSize,
                                      fontsizeWeb: Dimens.medium15TextSize,
                                      maxline: 2,
                                      overflow: TextOverflow.ellipsis,
                                      fontwaight: FontWeight.w500,
                                      textalign: TextAlign.start,
                                      fontstyle: FontStyle.normal,
                                    ),
                                    MyText(
                                      text: accessInfo.priceText,
                                      color: accessInfo.badgeTextColor,
                                      fontsize: Dimens.medium18TextSize,
                                      maxline: 1,
                                      fontwaight: FontWeight.w500,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Right Arrow
                  canScrollRight
                      ? _buildArrowButton(Icons.arrow_forward_ios, () {
                          if (controller.hasClients) {
                            controller.animateTo(
                              (controller.offset + scrollAmount).clamp(
                                0.0,
                                controller.position.maxScrollExtent,
                              ),
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        })
                      : const SizedBox.shrink(),
                ],
              ),
            );
          },
        );
      },
    );
  }

// Arrow button widget (reuse)
  Widget _buildArrowButton(IconData icon, VoidCallback onTap) {
    return InteractiveContainer(
      child: (isHovered) => InkWell(
        hoverColor: transparent,
        splashColor: transparent,
        focusColor: transparent,
        highlightColor: transparent,
        onTap: onTap,
        borderRadius: BorderRadius.circular(5),
        child: AnimatedScale(
          scale: isHovered ? 1.05 : 1,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeInOut,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
            decoration: BoxDecoration(
              color: white,
              border: Border.all(
                  width: 1,
                  color: isHovered ? colorPrimary : colorPrimary,
                  style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              icon,
              size: 20,
              color: isHovered ? colorPrimary : colorPrimary,
            ),
          ),
        ),
      ),
    );
  }

  Widget relatedItemsShimmer() {
    return Padding(
      padding: (MediaQuery.of(context).size.width > 1000)
          ? const EdgeInsets.symmetric(horizontal: 0, vertical: 0)
          : const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          spacing: 20,
          children: List.generate(
            5,
            (index) => Container(
              width: 185,
              padding: const EdgeInsets.fromLTRB(6, 16, 6, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  CustomWidget.roundcorner(width: 179, height: 243),
                  const SizedBox(height: 6),
                  CustomWidget.roundrectborder(width: 120, height: 16),
                  const SizedBox(height: 4),
                  CustomWidget.roundrectborder(width: 150, height: 18),
                  const SizedBox(height: 4),
                  CustomWidget.roundrectborder(width: 100, height: 16),
                  const SizedBox(height: 4),
                  CustomWidget.roundrectborder(width: 50, height: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
