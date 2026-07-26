import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:yourappname/pages/audiobookdetails.dart';
import 'package:yourappname/pages/auther.dart';
import 'package:yourappname/pages/bookdetails.dart';
import 'package:yourappname/pages/categorywisedata.dart';
import 'package:yourappname/pages/languagewisedata.dart';
import 'package:yourappname/pages/magazinedetails.dart';
import 'package:yourappname/provider/viewallprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/nodata.dart';

class ViewAll extends StatefulWidget {
  final String? type, sectionID, title, screenLayOut;
  const ViewAll({
    super.key,
    required this.screenLayOut,
    required this.title,
    required this.type,
    required this.sectionID,
  });

  @override
  State<ViewAll> createState() => _ViewAllState();
}

class _ViewAllState extends State<ViewAll> {
  final ScrollController _scrollController = ScrollController();
  late ViewAllProvider viewAllProvider;

  @override
  void initState() {
    super.initState();
    viewAllProvider = Provider.of<ViewAllProvider>(context, listen: false);
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getApi(0);
    });
  }

  _scrollListener() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (viewAllProvider.currentPage ?? 0) < (viewAllProvider.totalPage ?? 0)) {
      viewAllProvider.setLoadMore(true);
      getApi((viewAllProvider.currentPage ?? 0));
    }
  }

  getApi(nextPage) {
    viewAllProvider.setLoading(true);
    final id = widget.sectionID ?? "";
    final type = widget.type ?? "";
    final page = (nextPage ?? 0) + 1;

    if (widget.type == "1") {
      viewAllProvider.getSectionAudio(id, type, page);
    } else if (widget.type == "2") {
      viewAllProvider.getSectionBook(id, type, page);
    } else if (widget.type == "3") {
      viewAllProvider.getSectionMagazine(id, type, page);
    } else if (widget.type == "4") {
      viewAllProvider.getSectionCategory(id, type, page);
    } else if (widget.type == "5") {
      viewAllProvider.getSectionLanguage(id, type, page);
    } else {
      viewAllProvider.getSectionAuthor(id, type, page);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    viewAllProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF12121A) : const Color(0xFFF8F9FD),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : const Color(0xFF1F2937), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title ?? "",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1F2937),
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<ViewAllProvider>(
        builder: (context, viewAllProvider, child) {
          return SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 30),
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                checkUi(),
                if (viewAllProvider.loadmore) ...[
                  const SizedBox(height: 20),
                  Utils.pageLoader(context),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget checkUi() {
    final type = widget.type;
    final layout = widget.screenLayOut.toString();

    if (type == "1") {
      return (layout == "square")
          ? squareAudio()
          : (layout == "portrait")
              ? portraitviewAudio()
              : horizontalviewAudio();
    } else if (type == "2") {
      return (layout == "square")
          ? square()
          : (layout == "portrait")
              ? portrait()
              : horizontalView();
    } else if (type == "3") {
      return (layout == "square")
          ? squareMagazine()
          : (layout == "portrait")
              ? portraitMagazine()
              : horizontalViewMagazine();
    } else if (type == "4" || type == "5") {
      return catagory();
    } else {
      return author();
    }
  }

  /* Grid Item Redesign (Unified Helper) */
  Widget _buildGridCard({
    required BuildContext context,
    required String title,
    required String authorName,
    required String? image,
    required String? avgReviews,
    required dynamic accessInfo,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  child: MyNetworkImage(
                    imagePath: image ?? "",
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                if (accessInfo != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: accessInfo.badgeBg.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        accessInfo.badgeLabel,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: accessInfo.badgeTextColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    "By $authorName",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 3),
                      Text(
                        avgReviews ?? "0.0",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.grey[300] : const Color(0xFF374151),
                        ),
                      ),
                      const Spacer(),
                      if (accessInfo != null)
                        Text(
                          accessInfo.priceText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: accessInfo.priceText == "Free" ? Colors.green : colorPrimary,
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
    );
  }

  /* Horizontal Item Redesign (Unified Helper) */
  Widget _buildHorizontalCard({
    required BuildContext context,
    required String title,
    required String authorName,
    required String? image,
    required String? avgReviews,
    required dynamic accessInfo,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MyNetworkImage(
                    imagePath: image ?? "",
                    height: 140,
                    width: 95,
                    fit: BoxFit.cover,
                  ),
                ),
                if (accessInfo != null)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: accessInfo.badgeBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        accessInfo.badgeLabel,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: accessInfo.badgeTextColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "By $authorName",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: Color(0xFFF59E0B)),
                      const SizedBox(width: 3),
                      Text(
                        avgReviews ?? "0.0",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.grey[300] : const Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (accessInfo != null)
                    Text(
                      accessInfo.priceText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: accessInfo.priceText == "Free" ? Colors.green : colorPrimary,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* Audio Book Sections */
  Widget squareAudio() {
    if (viewAllProvider.loading && !viewAllProvider.loadmore) return portraitShimmer();
    if (viewAllProvider.audioList == null || viewAllProvider.audioList!.isEmpty) return const NoData();

    return ResponsiveGridList(
      minItemWidth: 150,
      minItemsPerRow: 2,
      maxItemsPerRow: 4,
      listViewBuilderOptions: ListViewBuilderOptions(shrinkWrap: true, physics: const NeverScrollableScrollPhysics()),
      children: List.generate(
        viewAllProvider.audioList?.length ?? 0,
        (index) {
          final item = viewAllProvider.audioList?[index];
          final accessInfo = getAccessInfo(
            accessType: item?.accessType.toString(),
            isBuy: item?.isBuy.toString(),
            isSubscription: Constant.isSubscription ?? 0,
            price: item?.price?.toString(),
          );

          return _buildGridCard(
            context: context,
            title: item?.title ?? "",
            authorName: item?.authorName ?? "",
            image: item?.portraitImg,
            avgReviews: item?.avgReviews?.toString(),
            accessInfo: accessInfo,
            onTap: () {
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (context, a1, a2) => AudioBookDetails(
                  categoryId: item?.categoryId.toString(),
                  authorId: item?.authorId.toString(),
                  contentId: item?.id.toString(),
                ),
                transitionDuration: const Duration(milliseconds: 200),
                transitionsBuilder: (context, a1, a2, child) =>
                    ClipPath(clipper: CircularRevealClipper(progress: a1.value), child: child),
              ));
            },
          );
        },
      ),
    );
  }

  Widget portraitviewAudio() => squareAudio();

  Widget horizontalviewAudio() {
    if (viewAllProvider.loading && !viewAllProvider.loadmore) return listShimmer();
    if (viewAllProvider.audioList == null || viewAllProvider.audioList!.isEmpty) return const NoData();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewAllProvider.audioList?.length ?? 0,
      itemBuilder: (context, index) {
        final item = viewAllProvider.audioList?[index];
        final accessInfo = getAccessInfo(
          accessType: item?.accessType.toString(),
          isBuy: item?.isBuy.toString(),
          isSubscription: Constant.isSubscription ?? 0,
          price: item?.price?.toString(),
        );

        return _buildHorizontalCard(
          context: context,
          title: item?.title ?? "",
          authorName: item?.authorName ?? "",
          image: item?.portraitImg,
          avgReviews: item?.avgReviews?.toString(),
          accessInfo: accessInfo,
          onTap: () {
            Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (context, a1, a2) => AudioBookDetails(
                categoryId: item?.categoryId.toString(),
                authorId: item?.authorId.toString(),
                contentId: item?.id.toString(),
              ),
              transitionDuration: const Duration(milliseconds: 200),
              transitionsBuilder: (context, a1, a2, child) =>
                  ClipPath(clipper: CircularRevealClipper(progress: a1.value), child: child),
            ));
          },
        );
      },
    );
  }

  /* Books Sections */
  Widget square() {
    if (viewAllProvider.loading && !viewAllProvider.loadmore) return portraitShimmer();
    if (viewAllProvider.bookList == null || viewAllProvider.bookList!.isEmpty) return const NoData();

    return ResponsiveGridList(
      minItemWidth: 150,
      minItemsPerRow: 2,
      maxItemsPerRow: 4,
      listViewBuilderOptions: ListViewBuilderOptions(shrinkWrap: true, physics: const NeverScrollableScrollPhysics()),
      children: List.generate(
        viewAllProvider.bookList?.length ?? 0,
        (index) {
          final item = viewAllProvider.bookList?[index];
          final accessInfo = getAccessInfo(
            accessType: item?.accessType.toString(),
            isBuy: item?.isBuy.toString(),
            isSubscription: Constant.isSubscription ?? 0,
            price: item?.price?.toString(),
          );

          return _buildGridCard(
            context: context,
            title: item?.title ?? "",
            authorName: item?.authorName ?? "",
            image: item?.portraitImg,
            avgReviews: item?.avgReviews?.toString(),
            accessInfo: accessInfo,
            onTap: () {
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (context, a1, a2) => BookDetails(
                  categoryId: item?.categoryId.toString(),
                  authorId: item?.authorId.toString(),
                  contentId: item?.id.toString(),
                ),
                transitionDuration: const Duration(milliseconds: 200),
                transitionsBuilder: (context, a1, a2, child) =>
                    ClipPath(clipper: CircularRevealClipper(progress: a1.value), child: child),
              ));
            },
          );
        },
      ),
    );
  }

  Widget portrait() => square();

  Widget horizontalView() {
    if (viewAllProvider.loading && !viewAllProvider.loadmore) return listShimmer();
    if (viewAllProvider.bookList == null || viewAllProvider.bookList!.isEmpty) return const NoData();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewAllProvider.bookList?.length ?? 0,
      itemBuilder: (context, index) {
        final item = viewAllProvider.bookList?[index];
        final accessInfo = getAccessInfo(
          accessType: item?.accessType.toString(),
          isBuy: item?.isBuy.toString(),
          isSubscription: Constant.isSubscription ?? 0,
          price: item?.price?.toString(),
        );

        return _buildHorizontalCard(
          context: context,
          title: item?.title ?? "",
          authorName: item?.authorName ?? "",
          image: item?.portraitImg,
          avgReviews: item?.avgReviews?.toString(),
          accessInfo: accessInfo,
          onTap: () {
            Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (context, a1, a2) => BookDetails(
                categoryId: item?.categoryId.toString(),
                authorId: item?.authorId.toString(),
                contentId: item?.id.toString(),
              ),
              transitionDuration: const Duration(milliseconds: 200),
              transitionsBuilder: (context, a1, a2, child) =>
                  ClipPath(clipper: CircularRevealClipper(progress: a1.value), child: child),
            ));
          },
        );
      },
    );
  }

  /* Magazine Sections */
  Widget squareMagazine() {
    if (viewAllProvider.loading && !viewAllProvider.loadmore) return portraitShimmer();
    if (viewAllProvider.magazineList == null || viewAllProvider.magazineList!.isEmpty) return const NoData();

    return ResponsiveGridList(
      minItemWidth: 150,
      minItemsPerRow: 2,
      maxItemsPerRow: 4,
      listViewBuilderOptions: ListViewBuilderOptions(shrinkWrap: true, physics: const NeverScrollableScrollPhysics()),
      children: List.generate(
        viewAllProvider.magazineList?.length ?? 0,
        (index) {
          final item = viewAllProvider.magazineList?[index];
          final accessInfo = getAccessInfo(
            accessType: item?.accessType.toString(),
            isBuy: item?.isBuy.toString(),
            isSubscription: Constant.isSubscription ?? 0,
            price: item?.price?.toString(),
          );

          return _buildGridCard(
            context: context,
            title: item?.title ?? "",
            authorName: item?.authorName ?? "",
            image: item?.portraitImg,
            avgReviews: item?.avgReviews?.toString(),
            accessInfo: accessInfo,
            onTap: () {
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (context, a1, a2) => MagazineDetails(
                  categoryId: item?.categoryId.toString(),
                  contentId: item?.id.toString(),
                ),
                transitionDuration: const Duration(milliseconds: 200),
                transitionsBuilder: (context, a1, a2, child) =>
                    ClipPath(clipper: CircularRevealClipper(progress: a1.value), child: child),
              ));
            },
          );
        },
      ),
    );
  }

  Widget portraitMagazine() => squareMagazine();

  Widget horizontalViewMagazine() {
    if (viewAllProvider.loading && !viewAllProvider.loadmore) return listShimmer();
    if (viewAllProvider.magazineList == null || viewAllProvider.magazineList!.isEmpty) return const NoData();

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: viewAllProvider.magazineList?.length ?? 0,
      itemBuilder: (context, index) {
        final item = viewAllProvider.magazineList?[index];
        final accessInfo = getAccessInfo(
          accessType: item?.accessType.toString(),
          isBuy: item?.isBuy.toString(),
          isSubscription: Constant.isSubscription ?? 0,
          price: item?.price?.toString(),
        );

        return _buildHorizontalCard(
          context: context,
          title: item?.title ?? "",
          authorName: item?.authorName ?? "",
          image: item?.portraitImg,
          avgReviews: item?.avgReviews?.toString(),
          accessInfo: accessInfo,
          onTap: () {
            Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (context, a1, a2) => MagazineDetails(
                categoryId: item?.categoryId.toString(),
                contentId: item?.id.toString(),
              ),
              transitionDuration: const Duration(milliseconds: 200),
              transitionsBuilder: (context, a1, a2, child) =>
                  ClipPath(clipper: CircularRevealClipper(progress: a1.value), child: child),
            ));
          },
        );
      },
    );
  }

  /* Category / Language / Author Circles */
  Widget catagory() {
    if (viewAllProvider.loading && !viewAllProvider.loadmore) return circleShimmer();
    if (viewAllProvider.categoryList == null || viewAllProvider.categoryList!.isEmpty) return const NoData();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ResponsiveGridList(
      minItemWidth: 100,
      minItemsPerRow: 3,
      maxItemsPerRow: 6,
      listViewBuilderOptions: ListViewBuilderOptions(shrinkWrap: true, physics: const NeverScrollableScrollPhysics()),
      children: List.generate(
        viewAllProvider.categoryList?.length ?? 0,
        (position) {
          final item = viewAllProvider.categoryList?[position];

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Widget page = (widget.type == "4")
                  ? CategoryWiseData(catagoryid: item?.id.toString(), catagoryname: item?.name.toString())
                  : LanguageWiseData(catagoryid: item?.id.toString(), catagoryname: item?.name.toString());

              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (context, a1, a2) => page,
                transitionDuration: const Duration(milliseconds: 200),
                transitionsBuilder: (context, a1, a2, child) =>
                    ClipPath(clipper: CircularRevealClipper(progress: a1.value), child: child),
              ));
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [colorPrimary, colorPrimaryDark],
                      ),
                    ),
                    child: MyNetworkImage(
                      imagePath: item?.image ?? "",
                      fit: BoxFit.cover,
                      height: 64,
                      width: 64,
                      radius: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item?.name ?? "",
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[200] : const Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget author() {
    if (viewAllProvider.loading && !viewAllProvider.loadmore) return circleShimmer();
    if (viewAllProvider.authorList == null || viewAllProvider.authorList!.isEmpty) return const NoData();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ResponsiveGridList(
      minItemWidth: 100,
      minItemsPerRow: 3,
      maxItemsPerRow: 6,
      listViewBuilderOptions: ListViewBuilderOptions(shrinkWrap: true, physics: const NeverScrollableScrollPhysics()),
      children: List.generate(
        viewAllProvider.authorList?.length ?? 0,
        (position) {
          final item = viewAllProvider.authorList?[position];

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (context, a1, a2) => Auther(
                  autherUserID: item?.id.toString() ?? "",
                ),
                transitionDuration: const Duration(milliseconds: 200),
                transitionsBuilder: (context, a1, a2, child) =>
                    ClipPath(clipper: CircularRevealClipper(progress: a1.value), child: child),
              ));
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
                      ),
                    ),
                    child: MyNetworkImage(
                      imagePath: item?.image ?? "",
                      fit: BoxFit.cover,
                      height: 64,
                      width: 64,
                      radius: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item?.firstName ?? "",
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.grey[200] : const Color(0xFF1F2937),
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /* Shimmers */
  Widget portraitShimmer() {
    return ResponsiveGridList(
      minItemWidth: 150,
      minItemsPerRow: 2,
      maxItemsPerRow: 4,
      listViewBuilderOptions: ListViewBuilderOptions(shrinkWrap: true, physics: const NeverScrollableScrollPhysics()),
      children: List.generate(
        6,
        (index) => const Column(
          children: [
            CustomWidget.roundcorner(height: 200),
            SizedBox(height: 8),
            CustomWidget.roundcorner(height: 14, width: 100),
            SizedBox(height: 6),
            CustomWidget.roundcorner(height: 12, width: 60),
          ],
        ),
      ),
    );
  }

  Widget listShimmer() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: CustomWidget.roundcorner(height: 120),
      ),
    );
  }

  Widget circleShimmer() {
    return ResponsiveGridList(
      minItemWidth: 100,
      minItemsPerRow: 3,
      maxItemsPerRow: 6,
      listViewBuilderOptions: ListViewBuilderOptions(shrinkWrap: true, physics: const NeverScrollableScrollPhysics()),
      children: List.generate(
        9,
        (index) => const Column(
          children: [
            CustomWidget.circular(height: 64, width: 64),
            SizedBox(height: 8),
            CustomWidget.roundcorner(height: 12, width: 50),
          ],
        ),
      ),
    );
  }
}
