// ignore_for_file: use_build_context_synchronously

import 'package:custom_rating_bar/custom_rating_bar.dart';
import 'package:yourappname/pages/audiobookplaying.dart';
import 'package:yourappname/provider/audiodetailsprovider.dart';
import 'package:yourappname/provider/audioplayprovider.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/provider/releteditemprovider.dart';
import 'package:yourappname/subscription/allpayment.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webpages/webauthor.dart';
import 'package:yourappname/webpages/webprofile.dart' hide SizedBox, Container, Row;
import 'package:yourappname/webpages/webreleteddata.dart';
import 'package:yourappname/webwidget/footerweb.dart';
import 'package:yourappname/webwidget/interactivecontainer.dart';
import 'package:yourappname/webwidget/webappbar.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/widget/musicmaneger.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
// import 'package:yourappname/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/mdi.dart';
import 'package:iconify_flutter/icons/ri.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class WebAudioBookDetails extends StatefulWidget {
  final String? contentId, categoryId, authorId, name;
  final bool? isFromHome;
  const WebAudioBookDetails({
    super.key,
    required this.contentId,
    required this.categoryId,
    required this.authorId,
    required this.name,
    this.isFromHome,
  });

  @override
  State<WebAudioBookDetails> createState() => _WebAudioBookDetailsState();
}

class _WebAudioBookDetailsState extends State<WebAudioBookDetails> {
  late AudioDetailsProvider audioDetailsProvider;
  ScrollController controller = ScrollController();
  final double _scrollAmount = 200;
  // double? ratingGiven;
  final commentController = TextEditingController();
  final MusicManager musicManager = MusicManager();
  bool showAudioPlayer = false;
  double addrating = 0.0;
  bool isPlaying = false;
  bool isMuted = false;
  final ScrollController reletedbookcontroller = ScrollController();
  double currentPosition = 2;
  double totalDuration = 641;
  double volume = 0.3;
  String formatDuration(double seconds) {
    final duration = Duration(seconds: seconds.toInt());
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final secs = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$secs';
  }

  @override
  void initState() {
    super.initState();
    audioDetailsProvider =
        Provider.of<AudioDetailsProvider>(context, listen: false);
    printLog("My Category Ids is ${widget.categoryId}");
    getApi();
    fetchTabData(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      audioPlayer.playerStateStream.listen((playerState) {
        if (playerState.processingState == ProcessingState.completed) {
          audioDetailsProvider.setCompleteMusic(isCom: true, isPla: false);
          // audioDetailsProvider.setEpisodeCompleteMusic(
          //     isCom: true, isPla: false);
        }
      });
    });
  }

  String? currentTab;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (currentTab != null) {
      audioDetailsProvider.setDetailsTab(currentTab!);
    }
  }

  Future getApi() async {
    audioDetailsProvider.clearCommentData();
    await audioDetailsProvider.getBookDetails("1", widget.contentId);
    await fetchreviewData(0);

    await audioDetailsProvider.getRelatedItems(
        "1", widget.categoryId ?? "", widget.contentId ?? "", 0);
  }

  Future fetchTabData(int? pageNo) async {
    await audioDetailsProvider.getChapterbyBook(
        widget.contentId ?? "", ((pageNo ?? 0) + 1));
  }

  Future fetchreviewData(int? pageNo) async {
    await audioDetailsProvider.getComment(
        "1", widget.contentId ?? "", ((pageNo ?? 0) + 1));
  }

  /* All Content View Count Api Calling */
  Future addView(contentType, contentId, subContentId) async {
    if (Constant.userID != null) {
      await audioDetailsProvider.setView(contentType, contentId, subContentId);
    }
  }

  @override
  void dispose() {
    super.dispose();
    audioDetailsProvider.clearProvider();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxContentWidth = 1400;
    final contentWidth =
        screenWidth > maxContentWidth ? maxContentWidth : screenWidth - 20;
    return Consumer<AudioDetailsProvider>(
      builder: (context, audioDetailsProvider, child) {
        return WebAppBar(
          widget: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SingleChildScrollView(
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
                              // title1: "audio_book",
                              title2: widget.name ?? "",
                              multilanguage: false,
                              isFromHomeRedirect: widget.isFromHome ?? false),
                        ),
                      ),
                      buildWeb(),
                      Center(
                          child: SizedBox(
                              width: contentWidth, child: _buildReletedData())),
                      SizedBox(
                        height: 20,
                      ),
                      const FooterWeb(),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1400),
                      child: Utils.buildMusicPanel(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /* Web details data  */
  Widget buildWeb() {
    double screenWidth = MediaQuery.of(context).size.width;
    const double maxContentWidth = 1400;

    bool isMobile = screenWidth < 1000;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: Padding(
          padding: isMobile
              ? const EdgeInsets.symmetric(horizontal: 10, vertical: 0)
              : const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: isMobile
              ? parentContainerResponsive()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 5,
                      child: parentContainerResponsive(),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                        color: white,
                        child: Column(
                          spacing: 15,
                          children: [
                            courseEpisodes(),
                            _detailsPlayButton(
                              context: context,
                              color: Theme.of(context).primaryColor,
                              // isBuy: isBuy,
                              // isPaid: isPaid,
                              // showBuyButton: showBuyButton
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

/* Details Tabs */
  Widget detailsTabData() {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 900;
    if (!isMobile && audioDetailsProvider.tabDetails == "3") {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        audioDetailsProvider.setDetailsTab("1");
      });
    }

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
                _buildTab("2", "reviews", onTap: () => fetchreviewData(0)),
                if (isMobile)
                  _buildTab("3", "episodes", onTap: () => fetchTabData(0)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Consumer<AudioDetailsProvider>(
              builder: (context, provider, child) {
                return InkWell(
                  onTap: () {
                    final bookDe = provider.audioDetailModel.result;
                    if (Utils.checkLoginUser(context)) {
                      provider.getBookMark("1", bookDe?.id ?? "");
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
                      (provider.audioDetailModel.result?.isBookmark == 1)
                          ? Icons.bookmark
                          : Icons.bookmark_outline_rounded,
                      color: colorPrimary,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 10),
            InkWell(
              onTap: () {
                if (Utils.checkLoginUser(context)) {
                  final base = (Constant.website ?? "https://vitabu.online")
                      .replaceAll(RegExp(r'/$'), '');
                  final audioDe = audioDetailsProvider.audioDetailModel.result;
                  final shareUrl =
                      "$base/?content_type=1&content_id=${audioDe?.id ?? ''}&category_id=${audioDe?.categoryId ?? ''}&author_id=${audioDe?.authorId ?? ''}&name=${Uri.encodeComponent(audioDe?.title ?? '')}";
                  SharePlus.instance.share(ShareParams(
                      text:
                          "${Constant.appName}\n${audioDetailsProvider.audioDetailModel.result?.title ?? ''}\n$shareUrl"));
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
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTab(String tabId, String text, {VoidCallback? onTap}) {
    bool isSelected = audioDetailsProvider.tabDetails == tabId;
    return InkWell(
      splashColor: transparent,
      focusColor: transparent,
      hoverColor: transparent,
      highlightColor: transparent,
      onTap: () {
        currentTab = tabId;
        audioDetailsProvider.setDetailsTab(tabId);
        if (onTap != null) onTap();
        setState(() {});
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
    final bookDe = audioDetailsProvider.audioDetailModel.result;

    /// ===== ACCESS LOGIC (BOOK STYLE) =====
    bool isFreeAccess = false;
    bool goToPayment = false;
    bool goToSubscription = false;

    final accessType = bookDe?.accessType.toString();
    final isBuy = bookDe?.isBuy.toString() == "1";

    if (accessType == "0") {
      isFreeAccess = true;
    } else if (accessType == "1") {
      if (isBuy) {
        isFreeAccess = true;
      } else {
        goToPayment = true;
      }
    } else if (accessType == "2") {
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
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 900;

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 20,
        children: [
          if (audioDetailsProvider.tabDetails == "1") ...[
            // --- Book Details ---
            MyText(
              text: bookDe?.title ?? "",
              maxline: 1,
              multilanguage: false,
              fontsize: Dimens.medium16TextSize,
              fontsizeWeb: Dimens.medium16TextSize,
              fontwaight: FontWeight.w400,
              color: colorPrimary,
            ),
            if ((bookDe?.description ?? "").isNotEmpty)
              ReadMoreText(
                bookDe?.description ?? "",
                trimLines: 5,
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontSize: Dimens.medium16TextSize,
                    fontWeight: FontWeight.w400,
                    color: black),
                trimCollapsedText: 'Read More',
                colorClickableText: black,
                trimMode: TrimMode.Line,
                trimExpandedText: 'Read less',
                lessStyle: TextStyle(
                    fontSize: Dimens.medium16TextSize,
                    fontWeight: FontWeight.w600,
                    color: colorPrimary),
                moreStyle: TextStyle(
                    fontSize: Dimens.medium16TextSize,
                    fontWeight: FontWeight.w600,
                    color: colorPrimary),
              ),

            if (goToSubscription) _subscriptionIncludedCard(context),
            if ((bookDe?.authorName ?? "").isNotEmpty)
              GestureDetector(
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
                child: Row(
                  spacing: 10,
                  children: [
                    MyNetworkImage(
                      imagePath: bookDe?.authorImage ?? "",
                      height: 25,
                      width: 25,
                      fit: BoxFit.cover,
                      radius: 200,
                    ),
                    MyText(
                      color: black,
                      text: bookDe?.authorName ?? "",
                      maxline: 2,
                      overflow: TextOverflow.ellipsis,
                      multilanguage: false,
                      fontsize: Dimens.medium14TextSize,
                      fontsizeWeb: Dimens.medium14TextSize,
                      fontwaight: FontWeight.bold,
                    ),
                  ],
                ),
              ),
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Plays
                Column(
                  children: [
                    MyText(
                      text: bookDe?.totalPlayed.toString() ?? "0",
                      maxline: 1,
                      multilanguage: false,
                      fontsize: Dimens.medium18TextSize,
                      fontsizeWeb: Dimens.medium18TextSize,
                      fontwaight: FontWeight.w600,
                    ),
                    const SizedBox(height: 3),
                    const MyText(
                      text: "Plays",
                      maxline: 1,
                      multilanguage: true,
                      fontsize: Dimens.medium14TextSize,
                      fontsizeWeb: Dimens.medium18TextSize,
                      fontwaight: FontWeight.w400,
                    ),
                  ],
                ),

                // Divider
                Container(
                    height: 40,
                    width: 2,
                    color:
                        Constant.isDarkMode ? colorPrimary : colorPrimary),

                // Reviews
                Column(
                  children: [
                    MyText(
                      text: bookDe?.totalReviews.toString() ?? "0",
                      maxline: 1,
                      multilanguage: false,
                      fontsize: Dimens.medium18TextSize,
                      fontsizeWeb: Dimens.medium18TextSize,
                      fontwaight: FontWeight.w600,
                    ),
                    const SizedBox(height: 3),
                    const MyText(
                      text: "Reviews",
                      maxline: 1,
                      multilanguage: true,
                      fontsize: Dimens.medium14TextSize,
                      fontsizeWeb: Dimens.medium18TextSize,
                      fontwaight: FontWeight.w400,
                    ),
                  ],
                ),

                // Divider
                Container(
                    height: 40,
                    width: 2,
                    color:
                        Constant.isDarkMode ? colorPrimary : colorPrimary),

                // Category
                MyText(
                  text: bookDe?.categoryName.toString() ?? "",
                  maxline: 1,
                  multilanguage: false,
                  fontsize: Dimens.medium18TextSize,
                  fontsizeWeb: Dimens.medium18TextSize,
                  fontwaight: FontWeight.w600,
                ),

                if ((bookDe?.languageName ?? "").isNotEmpty)
                  Container(
                      height: 40,
                      width: 2,
                      color: Constant.isDarkMode
                          ? colorPrimary
                          : colorPrimary),

                if ((bookDe?.languageName ?? "").isNotEmpty)
                  MyText(
                    text: bookDe?.languageName ?? "",
                    maxline: 1,
                    multilanguage: false,
                    fontsize: Dimens.medium18TextSize,
                    fontsizeWeb: Dimens.medium18TextSize,
                    fontwaight: FontWeight.w600,
                  ),
              ],
            ),
            if (bookDe?.accessType == 1)
              Align(
                alignment: Alignment.centerLeft,
                child: MyText(
                  text: accessInfo.priceText,
                  maxline: 2,
                  multilanguage: false,
                  fontsizeWeb: Dimens.text28Size,
                  fontwaight: FontWeight.w700,
                  color: colorPrimary,
                ),
              ),
            if (isFreeAccess) writeReviewData(),
            const SizedBox(height: 6),

            if (isMobile)
              _detailsPlayButton(
                context: context,
                color: Theme.of(context).primaryColor,
              ),

            // Description

            // Author
          ] else if (audioDetailsProvider.tabDetails == "2") ...[
            commentDataWeb(context, "3", widget.contentId ?? "")
          ] else if (audioDetailsProvider.tabDetails == "3" && isMobile) ...[
            episodeList(),
          ],
        ],
      ),
    );
  }

  Widget parentContainerResponsive() {
    if (audioDetailsProvider.loading) {
      return _detailsShimmer();
    } else {
      if (audioDetailsProvider.audioDetailModel.status == 200 &&
          audioDetailsProvider.audioDetailModel.result != null) {
        final bookDe = audioDetailsProvider.audioDetailModel.result;
        final screenWidth = MediaQuery.of(context).size.width;
        final bool isMobile = screenWidth < 1000;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: isMobile ? 16 : 24,
          children: [
            if (isMobile)
              // ===== MOBILE VIEW =====
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FractionallySizedBox(
                    widthFactor: 1.0,
                    child: Center(
                      child: Container(
                        alignment: Alignment.center,
                        color: colorPrimary.withOpacity( 0.1),
                        child: AspectRatio(
                          aspectRatio: 5 / 4,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              onTap: () async {},
                              child: MyNetworkImage(
                                fit: BoxFit.contain,
                                radius: 24,
                                imagePath: bookDe?.landscapeImg ?? "",
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            else
              // ===== WEB VIEW =====
              Column(
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
                              imagePath: bookDe?.landscapeImg ?? "",
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

            // 🔹 Details Section
            detailsTabData(),
            SizedBox(height: isMobile ? 16 : 24),

            childItem(),
          ],
        );
      } else {
        return const SizedBox.shrink();
      }
    }
  }

  Widget _detailsShimmer() {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: isMobile ? 16 : 24,
      children: [
        // 🔹 Image shimmer
        if (isMobile)
          // ===== MOBILE SHIMMER =====
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FractionallySizedBox(
                widthFactor: 1.0,
                child: Center(
                  child: Container(
                    alignment: Alignment.center,
                    color: colorPrimary.withOpacity( 0.1),
                    child: AspectRatio(
                      aspectRatio: 5 / 4,
                      child: CustomWidget.roundcorner(
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          // ===== WEB SHIMMER =====
          Container(
            alignment: Alignment.center,
            color: colorPrimary.withOpacity( 0.1),
            width: MediaQuery.of(context).size.width * 0.42,
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: const CustomWidget.roundcorner(
                height: double.infinity,
              ),
            ),
          ),
        // 🔹 Title shimmer
        const CustomWidget.roundrectborder(width: 180, height: 18),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: const [
            CustomWidget.roundrectborder(width: double.infinity, height: 14),
            CustomWidget.roundrectborder(width: double.infinity, height: 14),
            CustomWidget.roundrectborder(width: 200, height: 14),
          ],
        ),

        // 🔹 Bottom row shimmer (icon + text)
        Row(
          spacing: 10,
          children: const [
            CustomWidget.circular(width: 25, height: 25),
            CustomWidget.roundrectborder(width: 100, height: 16),
          ],
        ),

        // 🔹 Category tags shimmer
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            CustomWidget.roundrectborder(width: 60, height: 16),
            CustomWidget.roundrectborder(width: 40, height: 16),
            CustomWidget.roundrectborder(width: 80, height: 16),
          ],
        ),

        // 🔹 Button shimmer
        const CustomWidget.roundcorner(width: 140, height: 40),

        // 🔹 Description shimmer
      ],
    );
  }

  Widget commentDataWeb(BuildContext context, contentType, contentId) {
    final provider = Provider.of<AudioDetailsProvider>(context);

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
                        if (audioDetailsProvider.deletecommentLoading &&
                            audioDetailsProvider.deleteItemIndex == index)
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
                              await audioDetailsProvider.getDeleteComment(
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

  Widget writeReviewData() {
    return StatefulBuilder(
      builder: (context, setInnerState) {
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
              key: ValueKey(addrating),
              filledIcon: Icons.star,
              emptyIcon: Icons.star_border,
              filledColor: colorPrimary,
              emptyColor: colorPrimary,
              onRatingChanged: (value) {
                setInnerState(() {
                  addrating = value;
                });
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
                  fontSize: Dimens.medium14TextSize,
                  fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: "Add an Audio review here",
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
                        await audioDetailsProvider.getAddComment(
                            "3",
                            widget.contentId ?? "",
                            commentController.text,
                            addrating);
                        // ✅ Reset refresh logic
                        audioDetailsProvider.clearCommentData();
                        await audioDetailsProvider.getComment(
                            "3", widget.contentId ?? "", 1);

                        // ✅ Clear fields and reset rating
                        setInnerState(() {
                          addrating = 0.0;
                          commentController.clear();
                        });

                        audioDetailsProvider.setLoading(false);
                      }
                    },
                    borderRadius: BorderRadius.circular(5),
                    child: AnimatedScale(
                      scale: isHovered ? 1.05 : 1,
                      duration: const Duration(milliseconds: 100),
                      curve: Curves.easeInOut,
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 25, vertical: 10),
                        decoration: BoxDecoration(
                          color: isHovered ? colorPrimary : colorPrimary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: audioDetailsProvider.addcommentloading
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
      },
    );
  }

  Widget courseEpisodes() {
    if (audioDetailsProvider.bookChapterLoading) {
      return chapterShimmer();
    } else {
      if (audioDetailsProvider.chaptersList != null &&
          (audioDetailsProvider.chaptersList?.length ?? 0) > 0) {
        final currentPage = audioDetailsProvider.currentPage ?? 1;
        final totalPage = audioDetailsProvider.totalPage ?? 1;
        final totalEpisodes =
            audioDetailsProvider.audioDetailModel.result?.totalEpisodes ?? 0;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              /// Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
                    decoration: BoxDecoration(
                      color: colorPrimary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      spacing: 4,
                      children: [
                        const MyText(
                          color: white,
                          text: "episodes",
                          maxline: 1,
                          multilanguage: true,
                          fontsize: Dimens.medium14TextSize,
                          fontsizeWeb: Dimens.medium14TextSize,
                          fontwaight: FontWeight.w700,
                        ),
                        Container(
                          padding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
                          decoration: BoxDecoration(
                            color: colorPrimary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: MyText(
                            text:
                                "${Utils.kmbGenerator(totalEpisodes)} Chapters",
                            maxline: 1,
                            multilanguage: false,
                            fontsize: Dimens.medium12TextSize,
                            fontsizeWeb: Dimens.medium12TextSize,
                            fontwaight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(width: 2, color: colorPrimary)),
                    child: MyText(
                      text: "audiobook",
                      multilanguage: true,
                      color: colorPrimary,
                      fontsize: Dimens.medium14TextSize,
                      fontsizeWeb: Dimens.medium20TextSize,
                      fontwaight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              /// Episode List
              episodeList(),

              if (audioDetailsProvider.loadMore) chapterShimmer(),

              if (totalEpisodes > 10)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (currentPage > 1)
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: colorPrimary, size: 22),
                        onPressed: () async {
                          if (currentPage > 1) {
                            audioDetailsProvider.setLoadMore(true);
                            await fetchTabData(currentPage - 1);
                          }
                        },
                      ),
                    const SizedBox(width: 8),
                    MyText(
                      text: "Page $currentPage / $totalPage",
                      multilanguage: false,
                      fontsize: Dimens.medium14TextSize,
                      fontwaight: FontWeight.w600,
                      color: colorPrimary,
                    ),
                    const SizedBox(width: 8),
                    if (currentPage < totalPage)
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_rounded,
                            color: colorPrimary, size: 22),
                        onPressed: () async {
                          if (currentPage < totalPage) {
                            audioDetailsProvider.setLoadMore(true);
                            await fetchTabData(currentPage + 1);
                          }
                        },
                      ),
                  ],
                ),
              SizedBox(
                height: 10,
              ),

              if (audioDetailsProvider.chapterModel.morePage == true &&
                  totalEpisodes > 10)
                Align(
                  alignment: Alignment.center,
                  child: InkWell(
                    hoverColor: transparent,
                    splashColor: transparent,
                    focusColor: transparent,
                    highlightColor: transparent,
                    onTap: () async {
                      if (currentPage < totalPage) {
                        audioDetailsProvider.setLoadMore(true);
                        await fetchTabData(currentPage + 1);
                      }
                    },
                    child: const MyText(
                      text: "more",
                      maxline: 1,
                      multilanguage: true,
                      fontsize: Dimens.medium20TextSize,
                      fontwaight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        );
      } else {
        return MyText(
          text: "no_audio_courses_available",
          multilanguage: true,
          fontsize: Dimens.text38Size,
          color: black.withOpacity( 0.6),
          textalign: TextAlign.center,
        );
      }
    }
  }

  Widget episodeList() {
    return Consumer<AudioDetailsProvider>(
      builder: (context, audioDetailsProvider, child) {
        final audioDe = audioDetailsProvider.audioDetailModel.result;
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
            audioDetailsProvider.chaptersList?.length ?? 0,
            (index) {
              final chapterDe = audioDetailsProvider.chaptersList?[index];
              int displayIndex = index + 1;

              final isLocked =
                  (chapterDe?.isEpisodePaid.toString() ?? "") == "1" &&
                      (chapterDe?.isBuy.toString() ?? "") == "0";

              return InkWell(
                onTap: () async {
                  final audioPlayProvider =
                      Provider.of<AudioPlayProvider>(context, listen: false);

                  if (Utils.checkLoginUser(context)) {
                    if (isLocked) {
                      final result =
                          await Navigator.of(context).push(PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) {
                          return AllPayment(
                            issubscription: 0,
                            itemId: chapterDe?.audioBookId.toString(),
                            itemTitle: chapterDe?.title.toString(),
                            price: chapterDe?.price.toString(),
                            autherid: widget.authorId ?? "",
                            contentType: "1",
                            subContentId: chapterDe?.id.toString(),
                            subaccount: audioDe?.authorSubaccount,
                          );
                        },
                        transitionDuration: Duration(milliseconds: 700),
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
                        if (!context.mounted) return;

                        audioDetailsProvider.chaptersList?.clear();
                        await audioDetailsProvider.setLoading(false);
                        await audioDetailsProvider.getChapterbyBook(
                            chapterDe?.audioBookId.toString(), 0);

                        final updatedChapterDe =
                            audioDetailsProvider.chaptersList?[index];
                        printLog(
                            "Payment Success! Updated isBuy: ${updatedChapterDe?.isBuy.toString()}");
                        playAudioEpisode(
                            context: context,
                            title: updatedChapterDe?.title ?? "",
                            episodeId: updatedChapterDe?.id.toString() ?? "",
                            podcastId:
                                updatedChapterDe?.audioBookId.toString() ?? "",
                            artistName: audioDetailsProvider
                                    .audioDetailModel.result?.authorName ??
                                "",
                            podcastEpisodeList:
                                audioDetailsProvider.chaptersList,
                            cPosition: index);

                        await audioPlayProvider.clearProvider();
                        await audioPlayProvider.setLoding(false);
                        await audioPlayProvider.getChapterbyBook(
                            updatedChapterDe?.audioBookId.toString() ?? "", 0);
                      }
                    } else {
                      playAudioEpisode(
                          context: context,
                          title: chapterDe?.title ?? "",
                          episodeId: chapterDe?.id.toString() ?? "",
                          podcastId: chapterDe?.audioBookId.toString() ?? "",
                          artistName: audioDetailsProvider
                                  .audioDetailModel.result?.authorName ??
                              "",
                          podcastEpisodeList: audioDetailsProvider.chaptersList,
                          cPosition: index);

                      await audioPlayProvider.clearProvider();
                      await audioPlayProvider.setLoding(false);
                      await audioPlayProvider.getChapterbyBook(
                          chapterDe?.audioBookId.toString() ?? "", 0);
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
                                isLocked ? "subscribe_unlock" : "free_to_play",
                            fontsize: Dimens.medium14TextSize,
                            multilanguage: true,
                            color: colorPrimary,
                            fontwaight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isLocked ? colorPrimary : colorPrimary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isLocked ? Icons.lock : Icons.play_arrow,
                        size: 25,
                        color: Theme.of(context).cardColor,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
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
                    width: 100,
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

  Widget _buildReletedData() {
    // if (MediaQuery.of(context).size.width > 1000) {
    return _buildWebData();
    // } else {
    //   return _buildMobilerelatedData();
    // }
  }

  Widget _buildWebData() {
    if (audioDetailsProvider.releteditemsloading) {
      return relatedItemsShimmer();
    }

    if (audioDetailsProvider.bookModel.status == 200 &&
        (audioDetailsProvider.bookModel.result?.length ?? 0) > 0) {
      return Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Column(
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

                    // "More" button (interactive)
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

                          Navigator.of(context).pushReplacement(
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) {
                                return Webreleteddata(
                                  contentId: widget.contentId ?? "",
                                  type: "1",
                                  categoryId: widget.categoryId ?? "",
                                  name: widget.name.toString(),
                                );
                              },
                              transitionDuration:
                                  const Duration(milliseconds: 100),
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

                          reletedItemProvider.clearProvider();
                          reletedItemProvider.setLoading(false);
                          reletedItemProvider.getSectionBook(
                            "1",
                            widget.categoryId ?? "",
                            widget.contentId ?? "",
                            0,
                          );
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
                              ),
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
          ),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget relatedItems() {
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
                      (controller.offset - _scrollAmount).clamp(
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
                  audioDetailsProvider.bookModel.result?.length ?? 0,
                  (index) {
                    final accessInfo = getAccessInfo(
                      accessType: audioDetailsProvider
                          .bookModel.result?[index].accessType
                          .toString(),
                      isBuy: audioDetailsProvider.bookModel.result?[index].isBuy
                          .toString(),
                      isSubscription: Constant.isSubscription ?? 0,
                      price: audioDetailsProvider.bookModel.result?[index].price
                          ?.toString(),
                    );

                    return InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) {
                              return WebAudioBookDetails(
                                categoryId: audioDetailsProvider
                                        .bookModel.result?[index].categoryId
                                        .toString() ??
                                    "",
                                authorId: audioDetailsProvider
                                        .bookModel.result?[index].authorId
                                        .toString() ??
                                    "",
                                contentId: audioDetailsProvider
                                        .bookModel.result?[index].id
                                        .toString() ??
                                    "",
                                name: audioDetailsProvider
                                        .bookModel.result?[index].title
                                        .toString() ??
                                    "",
                                isFromHome: false,
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
                        padding: const EdgeInsets.fromLTRB(6, 16, 6, 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: white,
                          border: Border.all(
                              width: 1, color: gray, style: BorderStyle.solid),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 4,
                          children: [
                            MyNetworkImage(
                              imagePath: audioDetailsProvider
                                      .bookModel.result?[index].portraitImg
                                      .toString() ??
                                  "",
                              fit: BoxFit.cover,
                              height: 243,
                              width: 179,
                            ),
                            MyText(
                              color: black,
                              text: audioDetailsProvider
                                      .bookModel.result?[index].title
                                      .toString() ??
                                  "",
                              fontsize: Dimens.medium12TextSize,
                              fontsizeWeb: Dimens.medium14TextSize,
                              maxline: 2,
                              overflow: TextOverflow.ellipsis,
                              fontwaight: FontWeight.w500,
                              textalign: TextAlign.start,
                              fontstyle: FontStyle.normal,
                            ),
                            MyText(
                              color: yello,
                              text: audioDetailsProvider
                                      .bookModel.result?[index].categoryName
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
                              text: audioDetailsProvider
                                      .bookModel.result?[index].authorName
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
                              fontsizeWeb: Dimens.medium16TextSize,
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
                      (controller.offset + _scrollAmount).clamp(
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
  }

  Widget _buildArrowButton(IconData icon, VoidCallback onTap) {
    return InteractiveContainer(child: (isHovered) {
      return InkWell(
        onTap: onTap,
        hoverColor: transparent,
        splashColor: transparent,
        focusColor: transparent,
        highlightColor: transparent,
        borderRadius: BorderRadius.circular(5),
        child: AnimatedScale(
          scale: isHovered ? 1.05 : 1,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
            decoration: BoxDecoration(
              color: white,
              border: Border.all(
                width: 1,
                color: isHovered ? colorPrimary : colorPrimary,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(icon,
                size: 20, color: isHovered ? colorPrimary : colorPrimary),
          ),
        ),
      );
    });
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

  Widget _detailsPlayButton({
    required BuildContext context,
    Color? textColor,
    Color? iconColor,
    Color? color,
  }) {
    final audioDe = audioDetailsProvider.audioDetailModel.result;

    /// ================= ACCESS TYPE LOGIC (BOOK STYLE) =================
    bool isFreeAccess = false;
    bool goToPayment = false;
    bool goToSubscription = false;

    final accessType = audioDe?.accessType.toString();
    final isBuy = audioDe?.isBuy.toString() == "1";

    // 0 = free, 1 = paid, 2 = subscription
    if (accessType == "0") {
      isFreeAccess = true;
    } else if (accessType == "1") {
      if (isBuy) {
        isFreeAccess = true;
      } else {
        goToPayment = true;
      }
    } else if (accessType == "2") {
      if (Constant.isSubscription == 1) {
        isFreeAccess = true;
      } else {
        goToSubscription = true;
      }
    }

    /// ==================================================================

    /// ================= BUY (PAID CONTENT) =================
    if (!audioDetailsProvider.isFirstClickDone && goToPayment) {
      return InkWell(
        splashColor: transparent,
        focusColor: transparent,
        hoverColor: transparent,
        onTap: () async {
          if (Utils.checkLoginUser(context)) {
            await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AllPayment(
                  issubscription: 0,
                  itemId: audioDe?.id.toString(),
                  itemTitle: audioDe?.title.toString(),
                  price: audioDe?.price.toString(),
                  autherid: audioDe?.authorId.toString(),
                  contentType: "1",
                  subaccount: audioDe?.authorSubaccount,
                ),
              ),
            );
            getApi();
          }
        },
        child: _audioButtonUI(
          context,
          color,
          iconColor,
          textColor,
          FontAwesomeIcons.headphones,
          "buy_audiobook",
        ),
      );
    }

    /// ================= SUBSCRIPTION CONTENT =================
    if (!audioDetailsProvider.isFirstClickDone && goToSubscription) {
      return InkWell(
        splashColor: transparent,
        focusColor: transparent,
        hoverColor: transparent,
        onTap: () {
          if (Utils.checkLoginUser(context)) {
            showSubscribeDialog(context);
          }
        },
        child: _audioButtonUI(
          context,
          color,
          iconColor,
          textColor,
          FontAwesomeIcons.headphones,
          "unlock_full_access",
        ),
      );
    }

    /// ================= FIRST PLAY (FREE ACCESS) =================
    if (!audioDetailsProvider.isFirstClickDone && isFreeAccess) {
      return InkWell(
        splashColor: transparent,
        focusColor: transparent,
        hoverColor: transparent,
        onTap: () async {
          final audioPlayProvider =
              Provider.of<AudioPlayProvider>(context, listen: false);

          audioDetailsProvider.setFirstMusicPlay(
            isFirst: true,
            isPla: true,
          );

          playAudio(
            artistId: audioDe?.authorId.toString() ?? "",
            artistName: audioDe?.authorName ?? "",
            audioUrl: audioDe?.fullAudio ?? "",
            title: audioDe?.title ?? "",
            episodeId: "0",
            description: audioDe?.description ?? "",
            image: audioDe?.portraitImg ?? "",
            contentId: audioDe?.id.toString() ?? "",
          );

          await audioPlayProvider.clearProvider();
          await audioPlayProvider.setLoding(false);
          await audioPlayProvider.getChapterbyBook(
            audioDe?.id.toString() ?? "",
            0,
          );
        },
        child: _audioButtonUI(
          context,
          color,
          iconColor,
          textColor,
          FontAwesomeIcons.headphones,
          "play_now",
        ),
      );
    }

    /// ================= PLAY / PAUSE =================
    return StreamBuilder(
      stream: audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playing = snapshot.data?.playing ?? false;

        return InkWell(
          splashColor: transparent,
          focusColor: transparent,
          hoverColor: transparent,
          onTap: () {
            if (audioDetailsProvider.isCompleted) {
              audioPlayer.seek(Duration.zero);
              audioPlayer.play();
              audioDetailsProvider.setCompleteMusic(isCom: false, isPla: true);
            } else {
              if (playing) {
                audioPlayer.pause();
                audioDetailsProvider.setPlayMusic(isPla: false);
              } else {
                audioPlayer.play();
                audioDetailsProvider.setPlayMusic(isPla: true);
              }
            }
          },
          child: _audioButtonUI(
            context,
            color,
            iconColor,
            textColor,
            playing ? Icons.pause : Icons.play_arrow,
            playing
                ? "pause_music"
                : (audioDetailsProvider.isCompleted
                    ? "play_again"
                    : "play_music"),
          ),
        );
      },
    );
  }

  Widget _audioButtonUI(
    BuildContext context,
    Color? color,
    Color? iconColor,
    Color? textColor,
    IconData icon,
    String text,
  ) {
    return Container(
      height: 56,
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: white, width: 1.5),
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: MyText(
              color: textColor ?? Theme.of(context).cardColor,
              text: text,
              maxline: 1,
              multilanguage: true,
              fontsize: Dimens.medium16TextSize,
              fontwaight: FontWeight.w600,
            ),
          ),
        ],
      ),
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

  /* PlayAudio Player Single Book Audio Play */
  Future<void> playAudio({
    required String audioUrl,
    required String title,
    required String episodeId,
    required String description,
    required String image,
    required String contentId,
    required String artistId,
    String? artistName,
  }) async {
    printLog("episode id : $audioUrl");
    printLog("podcast id : $title");
    printLog("episode image : $episodeId");

    printLog("contentName  : $description");
    printLog("Episode List  : $image");

    musicManager.setSingleAudio(
      artistId: artistId,
      audioUrl: audioUrl,
      title: title,
      episodeId: episodeId,
      description: description,
      image: image,
      isContinueWatching: false,
      contentId: contentId,
      artistName: artistName ?? "",
      extraDetails: {
        'author_subaccount': audioDetailsProvider.audioDetailModel.result?.authorSubaccount ?? "",
      },
    );
    addView("1", contentId, episodeId);
  }

/* PlayAudio Player Single Book Audio Play */
  Future<void> playAudioEpisode(
      {required BuildContext context,
      String? episodeId,
      int? cPosition,
      dynamic podcastEpisodeList,
      String? podcastId,
      String? artistName,
      String? artistId,
      title}) async {
    musicManager.setInitialPodcast(
      context,
      episodeId ?? "",
      cPosition ?? 0,
      podcastEpisodeList,
      podcastId ?? "",
      addView("1", podcastId, episodeId),
      false,
      artistId ?? "",
      0,
      artistName ?? "",
      subaccount: audioDetailsProvider.audioDetailModel.result?.authorSubaccount,
    );
  }

  Widget episodePlayButton({
    required BuildContext context,
    chapterDe,
    index,
    showBuyButton,
    isPaid,
    isBuy,
  }) {
    int displayIndex = index + 1;
    final episodeId = chapterDe?.id.toString() ?? "";

    // ✅ Use provider unlock logic
    bool isUnlocked = audioDetailsProvider.isEpisodeUnlocked(
      episodeId,
      isPaid,
      isBuy,
    );

    if (!audioDetailsProvider.isEpisodeFirstClickDone && !isUnlocked) {
      // 🔒 Locked Episode (Show Buy Button)
      return InkWell(
        onTap: () async {
          if (Utils.checkLoginUser(context)) {
            Navigator.of(context)
                .push(PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return AllPayment(
                  issubscription: 0,
                  itemId: chapterDe?.audioBookId.toString(),
                  itemTitle: chapterDe?.title.toString(),
                  price: chapterDe?.price.toString(),
                  autherid: widget.authorId ?? "",
                  contentType: "1",
                  subContentId: chapterDe?.id.toString(),
                  subaccount: audioDetailsProvider.audioDetailModel.result?.authorSubaccount,
                );
              },
              transitionDuration: Duration(milliseconds: 150),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
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
            ))
                .then((_) {
              // ✅ After payment, mark as unlocked
              audioDetailsProvider.markEpisodeUnlocked(episodeId);
            });
          }
        },
        child: episodeRowUI(
          context,
          displayIndex,
          chapterDe,
          icon: Icons.lock,
        ),
      );
    } else if (!audioDetailsProvider.isEpisodeFirstClickDone && isUnlocked) {
      // ▶️ First-time play
      return InkWell(
        onTap: () async {
          final audioPlayProvider =
              Provider.of<AudioPlayProvider>(context, listen: false);

          audioDetailsProvider.setEpisodeFirstMusicPlay(
            isFirst: true,
            isPla: true,
          );
          playAudioEpisode(
              context: context,
              title: chapterDe?.title ?? "",
              episodeId: chapterDe?.id.toString() ?? "",
              podcastId: chapterDe?.audioBookId.toString() ?? "",
              artistName:
                  audioDetailsProvider.audioDetailModel.result?.authorName ??
                      "",
              podcastEpisodeList: audioDetailsProvider.chaptersList,
              cPosition: index);

          await audioPlayProvider.clearProvider();
          await audioPlayProvider.setLoding(false);
          await audioPlayProvider.getChapterbyBook(
              chapterDe?.audioBookId.toString() ?? "", 0);
        },
        child: episodeRowUI(
          context,
          displayIndex,
          chapterDe,
          icon: Icons.play_arrow,
        ),
      );
    } else {
      // ⏯️ Already playing or paused
      return StreamBuilder(
        stream: audioPlayer.playerStateStream,
        builder: (context, snapshot) {
          final playerState = snapshot.data;
          final playing = playerState?.playing ?? false;

          return InkWell(
            onTap: () async {
              if (audioDetailsProvider.isEpisodeCompleted) {
                audioPlayer.seek(Duration.zero);
                audioPlayer.play();
                audioDetailsProvider.setEpisodeCompleteMusic(
                    isCom: false, isPla: true);
              } else {
                if (playing) {
                  audioPlayer.pause();
                  audioDetailsProvider.setEpisodePlayMusic(isPla: false);
                } else {
                  audioPlayer.play();
                  audioDetailsProvider.setEpisodePlayMusic(isPla: true);
                }
              }
            },
            child: episodeRowUI(
              context,
              displayIndex,
              chapterDe,
              icon: playing ? Icons.pause : Icons.play_arrow,
            ),
          );
        },
      );
    }
  }

  Widget episodeRowUI(
    BuildContext context,
    int displayIndex,
    dynamic chapterDe, {
    required IconData icon,
  }) {
    return Row(
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
                fontsize: Dimens.medium16TextSize,
                fontwaight: FontWeight.w400,
              ),
              const SizedBox(height: 6),
              MyText(
                text: chapterDe?.title ?? "",
                fontsize: Dimens.medium12TextSize,
                fontwaight: FontWeight.w400,
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 25, color: Theme.of(context).cardColor),
        )
      ],
    );
  }
}
