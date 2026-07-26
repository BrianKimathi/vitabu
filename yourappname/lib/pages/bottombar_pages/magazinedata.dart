import 'package:carousel_indicator/carousel_indicator.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';
import 'package:yourappname/model/sectionmodel.dart';
import 'package:yourappname/model/sectionmodel.dart' as list;
import 'package:yourappname/pages/account.dart';
import 'package:yourappname/pages/auther.dart';
import 'package:yourappname/pages/categorywisedata.dart';
import 'package:yourappname/pages/languagewisedata.dart';
import 'package:yourappname/pages/login.dart';
import 'package:yourappname/pages/magazinedetails.dart';
import 'package:yourappname/pages/search.dart';
import 'package:yourappname/pages/viewall.dart';
import 'package:yourappname/provider/magazineprovider.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/nodata.dart';

class MagazineData extends StatefulWidget {
  const MagazineData({super.key});

  @override
  State<MagazineData> createState() => _MagazineDataState();
}

class _MagazineDataState extends State<MagazineData> {
  ScrollController scrollController = ScrollController();
  final searchController = TextEditingController();
  late MagazineProvider magazineProvider;

  @override
  void initState() {
    super.initState();
    magazineProvider = Provider.of<MagazineProvider>(context, listen: false);

    scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getApiData(0);
    });
  }

  _scrollListener() {
    if (!scrollController.hasClients) return;
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange &&
        (magazineProvider.currentPage ?? 0) < (magazineProvider.totalPage ?? 0)) {
      magazineProvider.setLoadMore(true);
      getApiData(magazineProvider.currentPage ?? 0);
    }
  }

  getApiData(pageno) async {
    magazineProvider.setLoading(true);
    await magazineProvider.getSectionList("3", Constant.userCategoryId, (pageno ?? 0) + 1);
    await magazineProvider.getProfile(Constant.userID);
  }

  @override
  void dispose() {
    scrollController.dispose();
    magazineProvider.clearProvider();
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
        titleSpacing: 20,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Magazines",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Container(
                  width: 28,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [colorPrimary, colorPrimaryDark],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorPrimary.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          profileData(),
          const SizedBox(width: 20),
        ],
      ),
      body: Consumer<MagazineProvider>(
        builder: (context, magazineProvider, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                searchData(),
                const SizedBox(height: 16),
                Expanded(
                  child: RefreshIndicator(
                    backgroundColor: colorPrimaryDark,
                    color: Colors.white,
                    onRefresh: () async {
                      await magazineProvider.getSectionList("3", Constant.userCategoryId, 0);
                    },
                    child: _buildSectionData(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget profileData() {
    final isLogged = Constant.userID != null && Constant.userID != "";
    final imgUrl = Constant.userimage ?? "";

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: colorPrimary.withOpacity(0.25),
            blurRadius: 10,
            spreadRadius: 1,
          )
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Widget page = isLogged ? Account() : Login();
          if (isLogged && !Utils.checkLoginUser(context)) return;
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => page,
            transitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return ClipPath(
                clipper: CircularRevealClipper(progress: animation.value),
                child: child,
              );
            },
          ));
        },
        child: isLogged
            ? MyNetworkImage(
                imagePath: imgUrl,
                fit: BoxFit.cover,
                radius: 22,
                height: 44,
                width: 44,
              )
            : Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [colorPrimary, colorPrimaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
      ),
    );
  }

  Widget searchData() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: searchController,
        readOnly: true,
        onTap: () {
          Navigator.of(context).push(PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const Search(showType: "magazine"),
            transitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return ClipPath(
                clipper: CircularRevealClipper(progress: animation.value),
                child: child,
              );
            },
          ));
        },
        decoration: InputDecoration(
          hintText: "Search for Magazines...",
          hintStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: isDark ? Colors.grey[400] : const Color(0xFF9CA3AF),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 12, right: 8),
            child: Icon(Icons.search_rounded, color: colorPrimary, size: 22),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionData() {
    if (magazineProvider.loading && !magazineProvider.loadMore) {
      return sectionShimmer();
    } else {
      if (magazineProvider.sectionListModel.status == 200 &&
          (magazineProvider.sectionListData?.length ?? 0) > 0) {
        return SingleChildScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 85),
            child: setSectionByType(magazineProvider.sectionListData),
          ),
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget setSectionByType(List<list.Result>? sectionList) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.builder(
      itemCount: sectionList?.length ?? 0,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        final section = sectionList?[index];
        if (section?.data != null && (section?.data?.length ?? 0) > 0) {
          final isBanner = (section?.screenLayout ?? "") == "banner";

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isBanner) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        section?.title.toString() ?? "",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    if (section?.viewAll == 1)
                      InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.of(context).push(PageRouteBuilder(
                            pageBuilder: (context, a1, a2) => ViewAll(
                              screenLayOut: section?.screenLayout ?? "",
                              type: section?.contentType.toString() ?? "",
                              sectionID: section?.id.toString() ?? "",
                              title: section?.title.toString() ?? "",
                            ),
                            transitionDuration: const Duration(milliseconds: 200),
                            transitionsBuilder: (context, a1, a2, child) =>
                                ClipPath(clipper: CircularRevealClipper(progress: a1.value), child: child),
                          ));
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: colorPrimary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "See all",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colorPrimary,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios_rounded, size: 10, color: colorPrimary),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
              setSectionData(sectionList: sectionList, index: index),
              const SizedBox(height: 8),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget setSectionData({required List<list.Result>? sectionList, required int index}) {
    final section = sectionList?[index];
    final layout = section?.screenLayout ?? "";
    final contentType = section?.contentType ?? 0;
    final data = section?.data;

    if (layout == "banner") {
      return _buildBanner(data, index, contentType);
    } else if (layout == "author") {
      return _buildAuthorData(data, index);
    } else if (layout == "category") {
      return _buildCategoryData(data, index);
    } else if (layout == "language") {
      return _buildLanguageData(data, index);
    } else if (layout == "square") {
      return _buildSquare(data, index, contentType);
    } else if (layout == "portrait") {
      return _buildPortraitData(data, index, contentType);
    } else if (layout == "horizontal_view") {
      return _buildHorizontalView(data, index, contentType);
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget _buildBanner(List<Datum>? sectionDataList, int sectionIndex, int? contentType) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: CarouselSlider.builder(
        itemCount: sectionDataList?.length ?? 0,
        options: CarouselOptions(
          autoPlay: true,
          height: 180,
          viewportFraction: 0.95,
          enlargeCenterPage: true,
        ),
        itemBuilder: (BuildContext context, int index, int realIndex) {
          final item = sectionDataList?[index];
          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () async {
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (context, a1, a2) => MagazineDetails(
                  contentId: item?.id.toString(),
                  categoryId: item?.categoryId.toString(),
                ),
                transitionDuration: const Duration(milliseconds: 200),
                transitionsBuilder: (context, a1, a2, child) =>
                    ClipPath(clipper: CircularRevealClipper(progress: a1.value), child: child),
              ));
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: MyNetworkImage(
                  imagePath: item?.landscapeImg.toString() ?? "",
                  fit: BoxFit.cover,
                  width: MediaQuery.sizeOf(context).width,
                  height: 180,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPortraitData(List<Datum>? sectionDataList, int sectionIndex, int? contentType) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlignedGridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: sectionDataList?.length ?? 0,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 14,
      padding: EdgeInsets.zero,
      itemBuilder: (BuildContext context, int position) {
        final item = sectionDataList?[position];
        final accessInfo = getAccessInfo(
          accessType: item?.accessType.toString(),
          isBuy: item?.isBuy.toString(),
          isSubscription: Constant.isSubscription ?? 0,
          price: item?.price?.toString(),
        );

        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            Navigator.of(context).push(PageRouteBuilder(
              pageBuilder: (context, a1, a2) => MagazineDetails(
                contentId: item?.id.toString(),
                categoryId: item?.categoryId.toString(),
              ),
              transitionDuration: const Duration(milliseconds: 200),
              transitionsBuilder: (context, a1, a2, child) =>
                  ClipPath(clipper: CircularRevealClipper(progress: a1.value), child: child),
            ));
          },
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
                        imagePath: item?.portraitImg.toString() ?? "",
                        height: 210,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
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
                        item?.title.toString() ?? "",
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
                        "By ${item?.authorName.toString() ?? ''}",
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
                            item?.avgReviews.toString() ?? "0.0",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.grey[300] : const Color(0xFF374151),
                            ),
                          ),
                          const Spacer(),
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
      },
    );
  }

  Widget _buildSquare(List<Datum>? sectionDataList, int sectionIndex, int? contentType) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          sectionDataList?.length ?? 0,
          (position) {
            final item = sectionDataList?[position];
            final accessInfo = getAccessInfo(
              accessType: item?.accessType.toString(),
              isBuy: item?.isBuy.toString(),
              isSubscription: Constant.isSubscription ?? 0,
              price: item?.price?.toString(),
            );

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, a1, a2) => MagazineDetails(
                    contentId: item?.id.toString(),
                    categoryId: item?.categoryId.toString(),
                  ),
                  transitionDuration: const Duration(milliseconds: 200),
                  transitionsBuilder: (context, a1, a2, child) =>
                      ClipPath(clipper: CircularRevealClipper(progress: a1.value), child: child),
                ));
              },
              child: Container(
                width: 145,
                margin: const EdgeInsets.only(right: 14, top: 4, bottom: 8),
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
                            imagePath: item?.portraitImg.toString() ?? "",
                            height: 180,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
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
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item?.title.toString() ?? "",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "By ${item?.authorName.toString() ?? ''}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, size: 13, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 2),
                              Text(
                                item?.avgReviews.toString() ?? "0.0",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.grey[300] : const Color(0xFF374151),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                accessInfo.priceText,
                                style: TextStyle(
                                  fontSize: 11,
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
          },
        ),
      ),
    );
  }

  Widget _buildHorizontalView(List<Datum>? sectionDataList, int sectionIndex, int? contentType) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(
          sectionDataList?.length ?? 0,
          (position) {
            final item = sectionDataList?[position];
            final accessInfo = getAccessInfo(
              accessType: item?.accessType.toString(),
              isBuy: item?.isBuy.toString(),
              isSubscription: Constant.isSubscription ?? 0,
              price: item?.price?.toString(),
            );

            return InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () async {
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, a1, a2) => MagazineDetails(
                    contentId: item?.id.toString(),
                    categoryId: item?.categoryId.toString(),
                  ),
                  transitionDuration: const Duration(milliseconds: 200),
                  transitionsBuilder: (context, a1, a2, child) =>
                      ClipPath(clipper: CircularRevealClipper(progress: a1.value), child: child),
                ));
              },
              child: Container(
                width: 320,
                margin: const EdgeInsets.only(right: 14, top: 4, bottom: 8),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: MyNetworkImage(
                        imagePath: item?.portraitImg?.toString() ?? "",
                        height: 140,
                        width: 95,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(
                            item?.title?.toString() ?? "",
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
                            "By ${item?.authorName?.toString() ?? ''}",
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
                                item?.avgReviews?.toString() ?? "0.0",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.grey[300] : const Color(0xFF374151),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
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
          },
        ),
      ),
    );
  }

  Widget _buildCategoryData(List<Datum>? sectionDataList, int sectionIndex) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(
          sectionDataList?.length ?? 0,
          (position) {
            final item = sectionDataList?[position];
            return InkWell(
              onTap: () {
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, a1, a2) => CategoryWiseData(
                    catagoryid: item?.id.toString(),
                    catagoryname: item?.name.toString(),
                  ),
                  transitionDuration: const Duration(milliseconds: 200),
                  transitionsBuilder: (context, a1, a2, child) =>
                      ClipPath(clipper: CircularRevealClipper(progress: a1.value), child: child),
                ));
              },
              child: Container(
                margin: const EdgeInsets.only(right: 14),
                width: 80,
                child: Column(
                  children: [
                    MyNetworkImage(
                      imagePath: item?.image ?? "",
                      fit: BoxFit.cover,
                      height: 64,
                      width: 64,
                      radius: 32,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item?.name ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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

  Widget _buildLanguageData(List<Datum>? sectionDataList, int sectionIndex) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(
          sectionDataList?.length ?? 0,
          (position) {
            final item = sectionDataList?[position];
            return InkWell(
              onTap: () {
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, a1, a2) => LanguageWiseData(
                    catagoryid: item?.id.toString(),
                    catagoryname: item?.name.toString(),
                  ),
                  transitionDuration: const Duration(milliseconds: 200),
                  transitionsBuilder: (context, a1, a2, child) =>
                      ClipPath(clipper: CircularRevealClipper(progress: a1.value), child: child),
                ));
              },
              child: Container(
                margin: const EdgeInsets.only(right: 14),
                width: 80,
                child: Column(
                  children: [
                    MyNetworkImage(
                      imagePath: item?.image ?? "",
                      fit: BoxFit.cover,
                      height: 64,
                      width: 64,
                      radius: 32,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item?.name ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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

  Widget _buildAuthorData(List<Datum>? sectionDataList, int sectionIndex) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(
          sectionDataList?.length ?? 0,
          (position) {
            final item = sectionDataList?[position];
            return InkWell(
              onTap: () {
                Navigator.of(context).push(PageRouteBuilder(
                  pageBuilder: (context, a1, a2) => Auther(
                    autherUserID: item?.id.toString(),
                  ),
                  transitionDuration: const Duration(milliseconds: 200),
                  transitionsBuilder: (context, a1, a2, child) =>
                      ClipPath(clipper: CircularRevealClipper(progress: a1.value), child: child),
                ));
              },
              child: Container(
                margin: const EdgeInsets.only(right: 14),
                width: 80,
                child: Column(
                  children: [
                    MyNetworkImage(
                      imagePath: item?.image ?? "",
                      fit: BoxFit.cover,
                      height: 64,
                      width: 64,
                      radius: 32,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item?.firstName ?? "",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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

  Widget sectionShimmer() {
    return ListView.builder(
      itemCount: 6,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: CustomWidget.roundcorner(height: 180),
      ),
    );
  }
}
