import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:yourappname/pages/account.dart';
import 'package:yourappname/pages/auther.dart';
import 'package:yourappname/pages/categorywisedata.dart';
import 'package:yourappname/pages/languagewisedata.dart';
import 'package:yourappname/pages/login.dart';
import 'package:yourappname/provider/categoryprovider.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/nodata.dart';

class CategoryData extends StatefulWidget {
  const CategoryData({super.key});

  @override
  State<CategoryData> createState() => _CategoryDataState();
}

class _CategoryDataState extends State<CategoryData> {
  ScrollController scrollController = ScrollController();
  late CategoryProvider categoryProvider;
  late ProfileProvider profileProvider;

  @override
  void initState() {
    super.initState();
    categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    getUser();
    _fetchbookByAuthorData(0);
  }

  getUser() async {
    await profileProvider.getProfile(Constant.userID);
  }

  _fetchbookByAuthorData(int? nextPage) {
    categoryProvider.getAutherList((nextPage ?? 0) + 1);
  }

  _fetchbookByCategoryData(int? nextPage) {
    categoryProvider.getBookCatagory((nextPage ?? 0) + 1);
  }

  _fetchbookByBookData(int? nextPage) {
    categoryProvider.getPoularBooks((nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    categoryProvider.clearProvider();
    profileProvider.clearProvider();
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
              "Explore",
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
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                _buildTab(),
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 85),
                    child: _buildTabData(),
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

  Widget _buildTab() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _titleBuild("1", FontAwesomeIcons.userPen, "Authors", () {
            categoryProvider.setTab("1");
            categoryProvider.clearAuthor();
            _fetchbookByAuthorData(0);
          }),
          _titleBuild("2", FontAwesomeIcons.language, "Languages", () {
            categoryProvider.setTab("2");
            categoryProvider.clearCategoryData();
            _fetchbookByBookData(0);
          }),
          _titleBuild("3", FontAwesomeIcons.layerGroup, "Genres", () {
            categoryProvider.setTab("3");
            categoryProvider.clearCategoryData();
            _fetchbookByCategoryData(0);
          }),
        ],
      ),
    );
  }

  Widget _titleBuild(String index, IconData iconData, String title, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = categoryProvider.currentIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: isSelected
              ? const LinearGradient(colors: [colorPrimary, colorPrimaryDark])
              : null,
          color: isSelected
              ? null
              : isDark
                  ? const Color(0xFF1E1E2E)
                  : Colors.white,
          border: isSelected
              ? null
              : Border.all(
                  color: isDark ? Colors.grey[800]! : const Color(0xFFE5E7EB),
                ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: colorPrimary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              iconData,
              size: 14,
              color: isSelected
                  ? Colors.white
                  : isDark
                      ? Colors.grey[400]
                      : const Color(0xFF6B7280),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : isDark
                        ? Colors.grey[300]
                        : const Color(0xFF374151),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabData() {
    if (categoryProvider.currentIndex == "1") {
      return _buildAuthorData();
    } else if (categoryProvider.currentIndex == "2") {
      return _buildlanguage();
    } else {
      return _buildCategory();
    }
  }

  Widget _buildCategory() {
    if (categoryProvider.bookCatagoryloading && !categoryProvider.loadMore) {
      return _catagoryShimmer();
    } else {
      if (categoryProvider.categoryList != null &&
          (categoryProvider.categoryList?.length ?? 0) > 0) {
        return SingleChildScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              categoryData(),
              if (categoryProvider.loadMore) Utils.pageLoader(context),
            ],
          ),
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget categoryData() {
    return ResponsiveGridList(
      minItemWidth: 150,
      minItemsPerRow: 2,
      maxItemsPerRow: 4,
      listViewBuilderOptions: ListViewBuilderOptions(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
      children: List.generate(
        categoryProvider.categoryList?.length ?? 0,
        (position) {
          final item = categoryProvider.categoryList?[position];

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Widget page = (categoryProvider.currentIndex == "2")
                  ? LanguageWiseData(
                      catagoryid: item?.id.toString(),
                      catagoryname: item?.name.toString(),
                    )
                  : CategoryWiseData(
                      catagoryid: item?.id.toString() ?? "",
                      catagoryname: item?.name ?? "",
                    );

              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (context, a1, a2) => page,
                transitionDuration: const Duration(milliseconds: 200),
                transitionsBuilder: (context, a1, a2, child) =>
                    ClipPath(clipper: CircularRevealClipper(progress: a1.value), child: child),
              ));
            },
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: MyNetworkImage(
                      imagePath: item?.image ?? "",
                      radius: 16,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.2),
                            Colors.black.withOpacity(0.65),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        item?.name ?? "",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
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

  Widget _buildlanguage() {
    if (categoryProvider.languageloading && !categoryProvider.loadMore) {
      return _catagoryShimmer();
    } else {
      if (categoryProvider.langugeList != null &&
          (categoryProvider.langugeList?.length ?? 0) > 0) {
        return SingleChildScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              languageData(),
              if (categoryProvider.loadMore) Utils.pageLoader(context),
            ],
          ),
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget languageData() {
    return ResponsiveGridList(
      minItemWidth: 150,
      minItemsPerRow: 2,
      maxItemsPerRow: 4,
      listViewBuilderOptions: ListViewBuilderOptions(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
      children: List.generate(
        categoryProvider.langugeList?.length ?? 0,
        (position) {
          final item = categoryProvider.langugeList?[position];

          return InkWell(
            borderRadius: BorderRadius.circular(16),
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
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: MyNetworkImage(
                      imagePath: item?.image ?? "",
                      radius: 16,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.2),
                            Colors.black.withOpacity(0.65),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        item?.name ?? "",
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.3,
                        ),
                      ),
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

  Widget _catagoryShimmer() {
    return ResponsiveGridList(
      minItemWidth: 150,
      minItemsPerRow: 2,
      maxItemsPerRow: 4,
      listViewBuilderOptions: ListViewBuilderOptions(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
      children: List.generate(
        8,
        (index) => const CustomWidget.roundcorner(height: 90),
      ),
    );
  }

  Widget _buildAuthorData() {
    if (categoryProvider.autherloading && !categoryProvider.loadMore) {
      return authorShimmer();
    } else {
      if (categoryProvider.authorList != null &&
          (categoryProvider.authorList?.length ?? 0) > 0) {
        return SingleChildScrollView(
          controller: scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              authorDetails(),
              if (categoryProvider.loadMore) Utils.pageLoader(context),
            ],
          ),
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget authorDetails() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ResponsiveGridList(
      minItemWidth: 100,
      minItemsPerRow: 3,
      maxItemsPerRow: 6,
      listViewBuilderOptions: ListViewBuilderOptions(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
      children: List.generate(categoryProvider.authorList?.length ?? 0, (index) {
        final item = categoryProvider.authorList?[index];

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
      }),
    );
  }

  Widget authorShimmer() {
    return ResponsiveGridList(
      minItemWidth: 100,
      minItemsPerRow: 3,
      maxItemsPerRow: 6,
      listViewBuilderOptions: ListViewBuilderOptions(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
      children: List.generate(
        9,
        (index) => const Column(
          children: [
            CustomWidget.circular(height: 64, width: 64),
            SizedBox(height: 8),
            CustomWidget.roundcorner(height: 14, width: 60),
          ],
        ),
      ),
    );
  }
}
