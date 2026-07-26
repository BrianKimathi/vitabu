import 'package:yourappname/pages/auther.dart';
import 'package:yourappname/pages/bookepubshow.dart';
import 'package:yourappname/pages/pdf/pdfreadingpage.dart';
import 'package:yourappname/pages/reviewviewall.dart';
import 'package:yourappname/provider/releteditemprovider.dart';
import 'package:yourappname/subscription/allpayment.dart';
import 'package:yourappname/subscription/subscription.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/pages/releteditem.dart';
import 'package:yourappname/provider/magazinedetailsprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
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
import 'package:iconify_flutter/icons/ri.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';

class MagazineDetails extends StatefulWidget {
  final String? contentId, categoryId;
  const MagazineDetails(
      {super.key, required this.contentId, required this.categoryId});

  @override
  State<MagazineDetails> createState() => _MagazineDetailsState();
}

class _MagazineDetailsState extends State<MagazineDetails> {
  late MagazineDetailsProvider magazineDetailsProvider;
  final commentController = TextEditingController();
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
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: transparent,
        leading: Utils.backButton(context),
        title: const MyText(
          text: 'magazine_details',
          fontsize: Dimens.medium18TextSize,
          multilanguage: true,
          fontwaight: FontWeight.w600,
        ),
        actions: const [SizedBox()],
      ),
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
        child: Consumer<MagazineDetailsProvider>(
          builder: (context, magazineDetailsProvider, child) {
            final bookDe = magazineDetailsProvider.magazineDetailModel.result;

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
                  child: _buildButton(
                    ontap: () async {
                      String ex = Utils.getEx(bookDe?.fullMagazine ?? "");
                      if (Utils.checkLoginUser(context)) {
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
                              contentType: "3",
                              subaccount: bookDe?.authorSubaccount,
                            ),
                          );
                          getApiData();
                          return;
                        }

                        if (isFreeAccess) {
                          if (ex == "pdf") {
                            Utils.push(
                              context,
                              PdfReadingPage(
                                bookID: bookDe?.id.toString(),
                                name: bookDe?.title.toString(),
                                pdfUrl: bookDe?.fullMagazine.toString(),
                                issubscription: bookDe?.isSubscription ?? 0,
                                autherid: bookDe?.authorId.toString(),
                                contentType: '3',
                              ),
                            );
                          } else {
                            Utils.push(
                              context,
                              BookEpubShow(
                                ePubUrl: bookDe?.fullMagazine.toString(),
                              ),
                            );
                          }
                        }
                      }
                    },
                    containerColor: colorAccent,
                    textColor: white,
                    buttonName: goToSubscription
                        ? "unlock_full_access"
                        : (goToPayment ? "buy_now" : "read_books"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: _buildButton(
                    ontap: () {
                      if (Utils.checkLoginUser(context)) {
                        magazineDetailsProvider.getBookMark(
                          "3",
                          widget.contentId,
                        );
                      }
                    },
                    containerColor: colorPrimary,
                    textColor: white,
                    buttonName: magazineDetailsProvider.magazineDetailModel.result?.isBookmark == 0
                        ? "add_to_library"
                        : "remove_to_library",
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: Consumer<MagazineDetailsProvider>(
        builder: (context, magazineDetailsProvider, child) {
          if (magazineDetailsProvider.loading) {
            return _shimmer();
          } else {
            if (magazineDetailsProvider.magazineDetailModel.status == 200 &&
                magazineDetailsProvider.magazineDetailModel.result != null) {
              final bookDe = magazineDetailsProvider.magazineDetailModel.result;

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
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        MyNetworkImage(
                          imagePath: magazineDetailsProvider
                                  .magazineDetailModel.result?.portraitImg
                                  .toString() ??
                              "",
                          fit: BoxFit.cover,
                          radius: 12,
                          height: MediaQuery.sizeOf(context).height * 0.24,
                          width: MediaQuery.sizeOf(context).width * 0.38,
                        ),
                        SizedBox(width: 20),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MyText(
                              text: magazineDetailsProvider
                                      .magazineDetailModel.result?.title
                                      .toString() ??
                                  "",
                              fontsize: Dimens.largeTextSize,
                              maxline: 2,
                              fontwaight: FontWeight.w600,
                            ),
                            SizedBox(height: 8),
                            InkWell(
                              onTap: () {
                                final res = magazineDetailsProvider.magazineDetailModel.result;
                                if (res?.customAuthorName == null || res!.customAuthorName!.isEmpty) {
                                  Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => Auther(
                                        autherUserID: res?.authorId.toString() ?? ""),
                                  ));
                                }
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    text: "By ${ (magazineDetailsProvider.magazineDetailModel.result?.customAuthorName != null && magazineDetailsProvider.magazineDetailModel.result!.customAuthorName!.isNotEmpty) ? magazineDetailsProvider.magazineDetailModel.result!.customAuthorName! : (magazineDetailsProvider.magazineDetailModel.result?.authorName.toString() ?? "") }",
                                    fontsize: Dimens.medium14TextSize,
                                    maxline: 2,
                                    color: colorAccent,
                                    fontwaight: FontWeight.w400,
                                    fontstyle: FontStyle.normal,
                                    isfont: 3,
                                  ),
                                  if (magazineDetailsProvider.magazineDetailModel.result?.bsnb != null && magazineDetailsProvider.magazineDetailModel.result!.bsnb!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: MyText(
                                        text: "BSNB: ${magazineDetailsProvider.magazineDetailModel.result?.bsnb}",
                                        fontsize: Dimens.medium12TextSize,
                                        color: gray,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            MyText(
                              text: magazineDetailsProvider
                                      .magazineDetailModel.result?.categoryName
                                      .toString() ??
                                  "",
                              fontsize: Dimens.medium14TextSize,
                              maxline: 2,
                              fontwaight: FontWeight.w500,
                              color: gray,
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: double.parse(magazineDetailsProvider
                                          .magazineDetailModel
                                          .result
                                          ?.avgReviews
                                          .toString() ??
                                      ""),
                                  unratedColor: ligthDark,
                                  itemCount: 5,
                                  itemSize: 22.0,
                                  itemBuilder: (context, index) {
                                    return const Icon(
                                      Icons.star,
                                      color: colorAccent,
                                    );
                                  },
                                ),
                                Expanded(
                                  child: MyText(
                                    text:
                                        "(${Utils.kmbGenerator(magazineDetailsProvider.magazineDetailModel.result?.totalReviews ?? 0)})",
                                    fontsize: Dimens.medium12TextSize,
                                    fontwaight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: goToSubscription
                                    ? colorPrimary.withOpacity(0.1)
                                    : (goToPayment
                                        ? colorAccent.withOpacity(0.1)
                                        : green.withOpacity(0.1)),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: MyText(
                                text: goToSubscription
                                    ? "unlock_full_access"
                                    : (goToPayment
                                        ? "${Constant.currencySymbol}${bookDe?.price}"
                                        : "read_books"),
                                fontsize: Dimens.medium14TextSize,
                                isfont: 3,
                                multilanguage: false,
                                fontstyle: FontStyle.normal,
                                overflow: TextOverflow.ellipsis,
                                maxline: 1,
                                fontwaight: FontWeight.w600,
                                color: goToSubscription
                                    ? colorPrimary
                                    : (goToPayment ? colorAccent : green),
                              ),
                            ),
                          ],
                        )),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildShareButton(
                      contentType: "3",
                      contentId: magazineDetailsProvider
                          .magazineDetailModel.result?.id ?? '',
                      categoryId: magazineDetailsProvider
                          .magazineDetailModel.result?.categoryId ?? '',
                      authorId: magazineDetailsProvider
                          .magazineDetailModel.result?.authorId ?? '',
                      title: magazineDetailsProvider
                          .magazineDetailModel.result?.title ?? '',
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                            const MyText(
                              text: 'magazine_introduction',
                              fontsize: Dimens.appbarTextSize,
                              multilanguage: true,
                              fontwaight: FontWeight.w600,
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ReadMoreText(
                          magazineDetailsProvider
                                  .magazineDetailModel.result?.description ??
                              "",
                          trimMode: TrimMode.Line,
                          trimLines: 4,
                          style: Utils.googleFontStyle(
                              2,
                              Dimens.medium14TextSize,
                              FontStyle.normal,
                              Theme.of(context).textTheme.bodyLarge!.color ??
                                  black,
                              FontWeight.w500),
                          colorClickableText: colorPrimaryDark,
                          trimCollapsedText: 'Show more',
                          trimExpandedText: 'Show less',
                          lessStyle: Utils.googleFontStyle(
                              2,
                              Dimens.medium16TextSize,
                              FontStyle.normal,
                              colorAccent,
                              FontWeight.w500),
                          moreStyle: Utils.googleFontStyle(
                              2,
                              Dimens.medium16TextSize,
                              FontStyle.normal,
                              colorAccent,
                              FontWeight.w500),
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
                                  icon: Icons.menu_book_rounded,
                                  iconColor: const Color(0xFF3B82F6),
                                  value: "${magazineDetailsProvider.magazineDetailModel.result?.totalRead ?? "0"}",
                                  label: "Reads",
                                ),
                                _buildVerticalDivider(),
                                _buildModernStatItem(
                                  context,
                                  icon: Icons.star_rounded,
                                  iconColor: const Color(0xFFF59E0B),
                                  value: "${magazineDetailsProvider.magazineDetailModel.result?.avgReviews ?? "0.0"}",
                                  label: "${magazineDetailsProvider.magazineDetailModel.result?.totalReviews ?? "0"} Reviews",
                                ),
                                _buildVerticalDivider(),
                                _buildModernStatItem(
                                  context,
                                  icon: Icons.category_rounded,
                                  iconColor: const Color(0xFF8B5CF6),
                                  value: magazineDetailsProvider.magazineDetailModel.result?.categoryName ?? "Magazine",
                                  label: "Category",
                                ),
                                if ((magazineDetailsProvider.magazineDetailModel.result?.languageName ?? "") != "") ...[
                                  _buildVerticalDivider(),
                                  _buildModernStatItem(
                                    context,
                                    icon: Icons.translate_rounded,
                                    iconColor: const Color(0xFF10B981),
                                    value: magazineDetailsProvider.magazineDetailModel.result?.languageName ?? "English",
                                    label: "Language",
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        commentData(),
                        const SizedBox(height: 15),
                        (Constant.userID == null || Constant.userID == "")
                            ? const SizedBox.shrink()
                            : InkWell(
                                onTap: () async {
                                  if (Utils.checkLoginUser(context)) {
                                    if (goToSubscription) {
                                      showSubscribeDialog(context);
                                      return;
                                    }
                                    if (goToPayment) {
                                      await Utils.push(
                                        context,
                                        AllPayment(
                                          issubscription: 0,
                                          itemId: magazineDetailsProvider
                                              .magazineDetailModel.result?.id
                                              .toString(),
                                          itemTitle: magazineDetailsProvider
                                              .magazineDetailModel.result?.title
                                              .toString(),
                                          price: magazineDetailsProvider
                                              .magazineDetailModel.result?.price
                                              .toString(),
                                          autherid: magazineDetailsProvider
                                              .magazineDetailModel
                                              .result
                                              ?.authorId
                                              .toString(),
                                          contentType: "3",
                                          subaccount: magazineDetailsProvider
                                              .magazineDetailModel.result?.authorSubaccount,
                                        ),
                                      );
                                      getApiData();
                                      return;
                                    } else {
                                      if (isFreeAccess) {
                                        showAddCommentBottomshit();
                                      }
                                    }
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                                  decoration: BoxDecoration(
                                      color: colorAccent,
                                      borderRadius: BorderRadius.circular(5)),
                                  child: MyText(
                                    color: white,
                                    text: 'add_review',
                                    fontsize: Dimens.medium14TextSize,
                                    multilanguage: true,
                                    fontwaight: FontWeight.w700,
                                  ),
                                ),
                              ),
                        const SizedBox(height: 15),
                        _buildReletedData(),
                        const SizedBox(height: 15),
                      ],
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }
        },
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

  Widget _buildShareButton({
    required String contentType,
    required dynamic contentId,
    required dynamic categoryId,
    required dynamic authorId,
    required String title,
  }) {
    return InkWell(
      onTap: () {
        final mag = magazineDetailsProvider.magazineDetailModel.result;
        final shareUrl =
            "https://console.vitabu.online/share?content_type=$contentType&content_id=$contentId&name=${Uri.encodeComponent(title)}&image=${Uri.encodeComponent(mag?.portraitImg ?? '')}";
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

  Widget _shimmer() {
    return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomWidget.roundcorner(
                height: MediaQuery.sizeOf(context).height * 0.15,
                width: MediaQuery.sizeOf(context).width * 0.31,
              ),
              SizedBox(width: 20),
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomWidget.roundcorner(
                      height: 20, width: MediaQuery.sizeOf(context).width),
                  SizedBox(height: 4),
                  CustomWidget.roundcorner(height: 18, width: 250),
                  SizedBox(height: 3),
                  CustomWidget.roundcorner(height: 16, width: 200),
                  SizedBox(height: 5),
                  CustomWidget.roundcorner(height: 16, width: 150),
                  SizedBox(height: 5),
                  CustomWidget.roundcorner(height: 16, width: 200),
                  SizedBox(height: 5),
                  CustomWidget.roundcorner(height: 16, width: 150),
                ],
              ))
            ],
          ),
          const SizedBox(height: 10),
          const CustomWidget.roundcorner(height: 15, width: 150),
          const SizedBox(
            height: 20,
          ),
          const CustomWidget.roundcorner(height: 10, width: 200),
          const SizedBox(
            height: 5,
          ),
          const CustomWidget.roundcorner(height: 10, width: 200),
          const SizedBox(
            height: 5,
          ),
          const CustomWidget.roundcorner(height: 10, width: 200),
          const SizedBox(
            height: 5,
          ),
          const SizedBox(
            height: 30,
          ),
          const Row(
            children: [
              CustomWidget.roundcorner(height: 20, width: 200),
              Expanded(
                child: SizedBox(
                  width: 15,
                ),
              ),
              CustomWidget.roundcorner(height: 15, width: 80),
              SizedBox(
                width: 4,
              ),
              CustomWidget.roundcorner(height: 15, width: 16),
            ],
          ),
          const SizedBox(
            height: 15,
          ),
          commentShimmer(),
          const SizedBox(height: 15),
          const CustomWidget.roundcorner(height: 15, width: 100),
          const SizedBox(height: 15),
          _bookshimmer(),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                CustomWidget.roundcorner(height: 50, width: 100),
                CustomWidget.roundcorner(height: 50, width: 100),
              ],
            ),
          )
        ]));
  }

  Widget _buildButton({
    required Function()? ontap,
    required String? buttonName,
    required Color? containerColor,
    required Color? textColor,
  }) {
    return Expanded(
      child: InkWell(
        splashColor: transparent,
        hoverColor: transparent,
        focusColor: transparent,
        onTap: ontap,
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: containerColor ?? colorAccent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: (containerColor ?? colorAccent).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Center(
            child: MyText(
              color: textColor ?? white,
              text: buttonName!,
              fontsize: Dimens.medium14TextSize,
              multilanguage: true,
              fontwaight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget commentData() {
    if (magazineDetailsProvider.commentloading) {
      return commentShimmer();
    } else {
      if ((magazineDetailsProvider.commentList?.length ?? 0) > 0 &&
          magazineDetailsProvider.commentList != null) {
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
                      "(${Utils.kmbGenerator(magazineDetailsProvider.magazineDetailModel.result?.totalReviews ?? 0)})",
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
                          contentId: magazineDetailsProvider
                                  .magazineDetailModel.result?.id
                                  .toString() ??
                              "",
                          type: "3",
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
              itemCount: magazineDetailsProvider.commentList?.length ?? 0,
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
                            imagePath: magazineDetailsProvider
                                .commentList?[index].userImage,
                            fit: BoxFit.fill,
                            height: 30,
                            width: 30,
                            radius: 200),
                        const SizedBox(width: 10),
                        MyText(
                          text:
                              "${magazineDetailsProvider.commentList?[index].firstName ?? ""} ${magazineDetailsProvider.commentList?[index].lastName ?? ""}",
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
                            text: magazineDetailsProvider
                                    .commentList?[index].review ??
                                "",
                            maxline: 1,
                            fontsize: Dimens.medium14TextSize,
                            fontwaight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(width: 15),
                        if (magazineDetailsProvider.commentList?[index].userId
                                .toString() ==
                            Constant.userID)
                          if (magazineDetailsProvider.deletecommentLoading &&
                              magazineDetailsProvider.deleteItemIndex == index)
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
                                  await magazineDetailsProvider
                                      .getDeleteComment(
                                          index,
                                          magazineDetailsProvider
                                                  .commentList?[index].id
                                                  .toString() ??
                                              "");
                                },
                                child: const Icon(
                                  Icons.delete,
                                  size: 20,
                                  color: colorAccent,
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
        return Consumer<MagazineDetailsProvider>(
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
                                await magazineDetailsProvider.getAddComment(
                                    "3",
                                    widget.contentId ?? "",
                                    commentController.text,
                                    ratingGiven);

                                ratingGiven = 0.0;
                                commentController.clear();
                                FocusManager.instance.primaryFocus?.unfocus();

                                if (!context.mounted) return;
                                Navigator.of(context).pop();

                                /* Magazine Details page Api Call any changes the review  */
                                // magazineDetailsProvider.clearMagazineContnt();
                                magazineDetailsProvider.setLoading(false);
                                magazineDetailsProvider.getMagazineDetails(
                                    "3", widget.contentId ?? "");
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
            const CustomWidget.circular(height: 50, width: 50),
            const SizedBox(
              width: 10,
            ),
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

// Releted Item Data Started
  Widget _buildReletedData() {
    if (magazineDetailsProvider.releteditemsloading) {
      return _bookshimmer();
    }
    if (magazineDetailsProvider.bookModel.status == 200 &&
        (magazineDetailsProvider.bookModel.result?.length ?? 0) > 0) {
      return Column(
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
                        text: "similar_magazine",
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
                      Provider.of<ReletedItemProvider>(context, listen: false);
                  Navigator.of(context).pushReplacement(PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return ReletedItem(
                        contentId: widget.contentId ?? "",
                        type: "3",
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
                  /* API Call */
                  reletedItemProvider.clearProvider();
                  reletedItemProvider.setLoading(false);
                  reletedItemProvider.getSectionMagazine(
                      "3", widget.categoryId ?? "", widget.contentId ?? "", 0);
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
        children: List.generate(
          magazineDetailsProvider.bookModel.result?.length ?? 0,
          (position) {
            return InkWell(
              onTap: () {
                Navigator.of(context).pushReplacement(PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return MagazineDetails(
                      categoryId: magazineDetailsProvider
                              .bookModel.result?[position].categoryId
                              .toString() ??
                          "",
                      contentId: magazineDetailsProvider
                              .bookModel.result?[position].id
                              .toString() ??
                          "",
                    );
                  },
                  transitionDuration: Duration(milliseconds: 150),
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
                margin: const EdgeInsets.only(right: 14),
                width: 130,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyNetworkImage(
                        imagePath: magazineDetailsProvider
                                .bookModel.result?[position].portraitImg
                                .toString() ??
                            "",
                        height: 160,
                        width: 130,
                        radius: 12,
                        fit: BoxFit.cover),
                    const SizedBox(height: 7),
                    MyText(
                      text: magazineDetailsProvider
                              .bookModel.result?[position].title
                              .toString() ??
                          "",
                      fontsize: Dimens.medium14TextSize,
                      maxline: 2,
                      fontwaight: FontWeight.w600,
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
