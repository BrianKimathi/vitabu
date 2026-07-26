import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webpages/webaudiobookdetails.dart';
import 'package:yourappname/webpages/webdetails.dart';
import 'package:yourappname/webpages/webmagazinedetails.dart' hide SizedBox, Container, Row;
import 'package:yourappname/webwidget/footerweb.dart';
import 'package:yourappname/webwidget/webappbar.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:readmore/readmore.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

const _indigo = Color(0xFF4E45B8);

class WebAuthor extends StatefulWidget {
  final String? autherUserID, name;
  const WebAuthor({super.key, this.autherUserID, required this.name});

  @override
  State<WebAuthor> createState() => _WebAuthorState();
}

class _WebAuthorState extends State<WebAuthor> {
  late ProfileProvider profileProvider;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    _scrollController.addListener(_scrollListener);
    getAPI();
    super.initState();
  }

  getAPI() {
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
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxContentWidth = 1400;
    final contentWidth =
        screenWidth > maxContentWidth ? maxContentWidth : screenWidth - 32;

    return WebAppBar(
      widget: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top breadcrumb header
                Center(
                  child: Container(
                    width: contentWidth,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth <= 1000 ? 16 : 0,
                      vertical: 12,
                    ),
                    child: Utils.buildWebDetailsAppBar(
                      context: context,
                      title2: widget.name ?? "Author Profile",
                      isHome: false,
                      multilanguage: false,
                    ),
                  ),
                ),

                // Sleek Author Hero Card Banner
                Center(
                  child: Container(
                    width: contentWidth,
                    margin: const EdgeInsets.symmetric(vertical: 16),
                    padding: EdgeInsets.all(screenWidth <= 800 ? 20 : 36),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1E1B4B), Color(0xFF4E45B8), Color(0xFF312E81)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4E45B8).withValues(alpha: 0.25),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: _buildAuthorHeroCard(profileProvider, screenWidth),
                  ),
                ),

                const SizedBox(height: 24),

                // Content Filter Tabs
                Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: _buildWishlistTab(),
                  ),
                ),

                const SizedBox(height: 24),

                // Publication Grid Content
                Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: _buildTabbarData(),
                  ),
                ),

                const SizedBox(height: 48),
                FooterWeb(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAuthorHeroCard(ProfileProvider provider, double screenWidth) {
    if (provider.loading) {
      return leftSideShimmer();
    }
    final result = (provider.profileModel.status == 200 &&
            (provider.profileModel.result?.length ?? 0) > 0)
        ? provider.profileModel.result![0]
        : null;

    final isMobile = screenWidth < 800;
    final fullName = result != null
        ? "${result.firstName ?? ''} ${result.lastName ?? ''}".trim()
        : (widget.name ?? "Author");

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Author Avatar Box
        Container(
          width: isMobile ? 80 : 120,
          height: isMobile ? 80 : 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(
            child: MyNetworkImage(
              imagePath: result?.image ?? "",
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        const SizedBox(width: 24),

        // Author Details & Stats
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      fullName.isEmpty ? "Author" : fullName,
                      style: TextStyle(
                        fontSize: isMobile ? 22 : 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF60A5FA),
                    size: 22,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (result?.description != null && result!.description!.isNotEmpty)
                Text(
                  result.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                ),
              const SizedBox(height: 16),

              // Stat pills
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _statBadge(
                    icon: FontAwesomeIcons.bookOpen,
                    count: "${result?.totalNovels ?? 0}",
                    label: "Books",
                  ),
                  _statBadge(
                    icon: FontAwesomeIcons.headphones,
                    count: "${result?.totalAudioBooks ?? 0}",
                    label: "Audiobooks",
                  ),
                  _statBadge(
                    icon: FontAwesomeIcons.newspaper,
                    count: "${result?.totalMagazines ?? 0}",
                    label: "Magazines",
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statBadge({required IconData icon, required String count, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            "$count $label",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget leftSideShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Author name shimmer
        CustomWidget.roundrectborder(height: 24, width: 200),
        SizedBox(height: 12),

        // Description shimmer (3 lines)
        CustomWidget.roundrectborder(height: 16, width: double.infinity),
        SizedBox(height: 6),
        CustomWidget.roundrectborder(height: 16, width: double.infinity),
        SizedBox(height: 6),
        CustomWidget.roundrectborder(height: 16, width: double.infinity * 0.8),
        SizedBox(height: 20),

        // Stats row shimmer
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                CustomWidget.circular(height: 60, width: 60),
                SizedBox(height: 8),
                CustomWidget.roundrectborder(height: 20, width: 40),
                SizedBox(height: 4),
                CustomWidget.roundrectborder(height: 16, width: 60),
              ],
            ),
            Column(
              children: [
                CustomWidget.circular(height: 60, width: 60),
                SizedBox(height: 8),
                CustomWidget.roundrectborder(height: 20, width: 40),
                SizedBox(height: 4),
                CustomWidget.roundrectborder(height: 16, width: 60),
              ],
            ),
            Column(
              children: [
                CustomWidget.circular(height: 60, width: 60),
                SizedBox(height: 8),
                CustomWidget.roundrectborder(height: 20, width: 40),
                SizedBox(height: 4),
                CustomWidget.roundrectborder(height: 16, width: 60),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget rightSideShimmer() {
    const double stackWidth = 400;
    const double stackHeight = 500;

    return SizedBox(
      width: stackWidth,
      height: stackHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomWidget.roundcorner(
            height: 450,
            width: stackWidth,
          ),
          Positioned(
            left: 0,
            right: 0,
            top: -30,
            child: Center(
              child: CustomWidget.roundcorner(
                height: 550,
                width: 350,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWishlistTab() {
    double screenWidth = MediaQuery.of(context).size.width;
    double horizontalPadding = (screenWidth > 1000) ? 0 : 16;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      scrollDirection: Axis.horizontal,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _titleBuild("1", FontAwesomeIcons.headphones, "audio_book", () {
              profileProvider.setType("1");
              profileProvider.audioList?.clear();
              _fetchData(profileProvider.selectedType, 0);
            }),
            _titleBuild("2", FontAwesomeIcons.bookOpen, "books", () {
              profileProvider.setType("2");
              profileProvider.bookList?.clear();
              _fetchData(profileProvider.selectedType, 0);
            }),
            _titleBuild("3", FontAwesomeIcons.newspaper, "magazines", () {
              profileProvider.setType("3");
              profileProvider.magazineList?.clear();
              _fetchData(profileProvider.selectedType, 0);
            }),
          ],
        ),
      ),
    );
  }

  Widget _titleBuild(index, iconData, title, onTap) {
    final bool isSelected = profileProvider.selectedType == index;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4E45B8) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF4E45B8).withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              size: 15,
              color: isSelected ? Colors.white : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            MyText(
              color: isSelected ? Colors.white : const Color(0xFF64748B),
              text: title,
              multilanguage: true,
              fontwaight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontsize: Dimens.medium14TextSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabbarData() {
    if (profileProvider.contentLoading && !profileProvider.loadMore) {
      return commanListShimmer();
    } else {
      if (profileProvider.selectedType == "1") {
        if (profileProvider.audioList != null &&
            (profileProvider.audioList?.length ?? 0) > 0) {
          return Column(
            children: [
              _buildCommanWhishList(profileProvider.audioList ?? []),
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
              _buildCommanWhishList(profileProvider.bookList ?? []),
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
              _buildCommanWhishList(profileProvider.magazineList ?? []),
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

  Widget _buildCommanWhishList(commanList) {
    return ResponsiveGridList(
      minItemWidth: 185,
      minItemsPerRow: Utils.customCrossAxisCount(
        context: context,
        height1600: 8,
        height1200: 6,
        height800: 4,
        height400: 3,
      ),
      horizontalGridMargin: 0,
      verticalGridMargin: 0,
      verticalGridSpacing: 20,
      horizontalGridSpacing: 10,
      listViewBuilderOptions: ListViewBuilderOptions(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width > 1000 ? 0 : 20,
        ),
        physics: const NeverScrollableScrollPhysics(),
      ),
      children: List.generate(commanList.length, (index) {
        final item = commanList[index];
        final accessInfo = getAccessInfo(
          accessType: item.accessType.toString(),
          isBuy: item.isBuy.toString(),
          isSubscription: Constant.isSubscription ?? 0,
          price: item.price?.toString(),
        );
        return InkWell(
          onTap: () {
            printLog("SelectType => ${profileProvider.selectedType}");

            if (profileProvider.selectedType == "1") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WebAudioBookDetails(
                    contentId: item.id.toString(),
                    authorId: item.authorId.toString(),
                    categoryId: item.categoryId.toString(),
                    name: item.title.toString(),
                  ),
                ),
              );
            } else if (profileProvider.selectedType == "2") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WebDetails(
                    contentId: item.id.toString(),
                    authorId: item.authorId.toString(),
                    categoryId: item.categoryId.toString(),
                    name: item.title.toString(),
                  ),
                ),
              );
            } else if (profileProvider.selectedType == "3") {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => WebMagazineDetails(
                    contentId: item.id.toString(),
                    categoryId: item.categoryId.toString(),
                    name: item.title.toString(),
                  ),
                ),
              );
            }
          },
          child: Container(
            width: 200,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: white,
                border: Border.all(width: 1, color: gray),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 📘 Image Section
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: MyNetworkImage(
                    imagePath: item.portraitImg ?? "",
                    fit: BoxFit.cover,
                    height: 260,
                    width: double.infinity,
                    radius: 6,
                  ),
                ),

                // 📗 Text Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      MyText(
                        text: item.title ?? "",
                        fontsize: Dimens.medium16TextSize,
                        fontsizeWeb: Dimens.medium16TextSize,
                        maxline: 2,
                        fontwaight: FontWeight.w500,
                      ),
                      const SizedBox(height: 2),
                      MyText(
                        text: item.categoryName ?? "",
                        fontsize: Dimens.medium16TextSize,
                        fontsizeWeb: Dimens.medium16TextSize,
                        maxline: 2,
                        color: yello,
                        fontwaight: FontWeight.w500,
                      ),
                      const SizedBox(height: 2),
                      MyText(
                        text: item.languageName ?? "",
                        fontsize: Dimens.medium16TextSize,
                        fontsizeWeb: Dimens.medium16TextSize,
                        maxline: 2,
                        color: _indigo,
                        fontwaight: FontWeight.w500,
                      ),
                      const SizedBox(height: 2),
                      MyText(
                        color: gray,
                        text: item.authorName ?? "",
                        fontsize: Dimens.medium14TextSize,
                        fontsizeWeb: Dimens.medium14TextSize,
                        maxline: 1,
                        fontwaight: FontWeight.w400,
                      ),
                      const SizedBox(height: 4),
                      MyText(
                        text: accessInfo.priceText,
                        fontsize: Dimens.medium18TextSize,
                        fontsizeWeb: Dimens.medium18TextSize,
                        maxline: 1,
                        fontwaight: FontWeight.w500,
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget commanListShimmer() {
    return ResponsiveGridList(
      minItemWidth: 185,
      minItemsPerRow: Utils.customCrossAxisCount(
          context: context,
          height1600: 8,
          height1200: 6,
          height800: 4,
          height400: 3),
      horizontalGridMargin: 0,
      verticalGridMargin: 0,
      verticalGridSpacing: 20,
      horizontalGridSpacing: 20,
      listViewBuilderOptions: ListViewBuilderOptions(
          shrinkWrap: true,
          padding: EdgeInsets.symmetric(
            horizontal: MediaQuery.of(context).size.width > 1000 ? 0 : 20,
          ),
          physics: AlwaysScrollableScrollPhysics()),
      children: List.generate(3, (index) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomWidget.roundcorner(width: 179, height: 243),
            const SizedBox(height: 8),
            CustomWidget.roundrectborder(width: 140, height: 18),
            const SizedBox(height: 4),
            CustomWidget.roundrectborder(width: 100, height: 16),
            const SizedBox(height: 4),
            CustomWidget.roundrectborder(width: 60, height: 20),
          ],
        );
      }),
    );
  }
}
