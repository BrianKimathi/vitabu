import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:yourappname/pages/account.dart';
import 'package:yourappname/pages/audiobookdetails.dart';
import 'package:yourappname/pages/bookdetails.dart';
import 'package:yourappname/pages/login.dart';
import 'package:yourappname/pages/magazinedetails.dart';
import 'package:yourappname/provider/mylibraryprovider.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/nodata.dart';

class MyLibrary extends StatefulWidget {
  const MyLibrary({super.key});

  @override
  State<MyLibrary> createState() => _MyLibraryState();
}

class _MyLibraryState extends State<MyLibrary> {
  late MylibraryProvider mylibraryProvider;
  final ScrollController _bookController = ScrollController();
  late ProfileProvider profileProvider;

  @override
  void initState() {
    super.initState();
    mylibraryProvider = Provider.of<MylibraryProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    _bookController.addListener(_bookScrollListener);
    getUser();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchData(mylibraryProvider.currentIndex, 0);
    });
  }

  getUser() {
    profileProvider.getProfile(Constant.userID);
  }

  _bookScrollListener() {
    if (!_bookController.hasClients) return;
    if (_bookController.offset >= _bookController.position.maxScrollExtent &&
        !_bookController.position.outOfRange &&
        (mylibraryProvider.currentPage ?? 0) < (mylibraryProvider.totalPage ?? 0)) {
      mylibraryProvider.setLoadMore(true);
      _fetchData(mylibraryProvider.currentIndex, mylibraryProvider.currentPage ?? 0);
    }
  }

  _fetchData(type, int? nextPage) {
    mylibraryProvider.setLoading(true);
    if (type == "1") {
      mylibraryProvider.getSectionAudio(type, (nextPage ?? 0) + 1);
    } else if (type == "2") {
      mylibraryProvider.getSectionBook(type, (nextPage ?? 0) + 1);
    } else {
      mylibraryProvider.getSectionMagazine(type, (nextPage ?? 0) + 1);
    }
  }

  @override
  void dispose() {
    _bookController.dispose();
    mylibraryProvider.clearProvider();
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
              "My Library",
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
      body: Consumer<MylibraryProvider>(
        builder: (context, mylibraryProvider, child) {
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
          _titleBuild("2", FontAwesomeIcons.bookOpen, "Books", () {
            mylibraryProvider.setTab("2");
            mylibraryProvider.clearData();
            _fetchData("2", 0);
          }),
          _titleBuild("1", FontAwesomeIcons.headphones, "Audiobooks", () {
            mylibraryProvider.setTab("1");
            mylibraryProvider.clearData();
            _fetchData("1", 0);
          }),
          _titleBuild("3", FontAwesomeIcons.newspaper, "Magazines", () {
            mylibraryProvider.setTab("3");
            mylibraryProvider.clearData();
            _fetchData("3", 0);
          }),
        ],
      ),
    );
  }

  Widget _titleBuild(String index, IconData iconData, String title, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = mylibraryProvider.currentIndex == index;

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
    if (mylibraryProvider.currentIndex == "1") {
      return _buildAudiobook();
    } else if (mylibraryProvider.currentIndex == "2") {
      return _buildBook();
    } else {
      return _buildMagazine();
    }
  }

  Widget _buildBook() {
    if (mylibraryProvider.loading && !mylibraryProvider.loadMore) {
      return _shimmer();
    } else {
      if (mylibraryProvider.bookList != null &&
          (mylibraryProvider.bookList?.length ?? 0) > 0) {
        return SingleChildScrollView(
          controller: _bookController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _bookDataList(mylibraryProvider.bookList),
              if (mylibraryProvider.loadMore) Utils.pageLoader(context),
            ],
          ),
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget _buildAudiobook() {
    if (mylibraryProvider.loading && !mylibraryProvider.loadMore) {
      return _shimmer();
    } else {
      if (mylibraryProvider.audioList != null &&
          (mylibraryProvider.audioList?.length ?? 0) > 0) {
        return SingleChildScrollView(
          controller: _bookController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _bookDataList(mylibraryProvider.audioList),
              if (mylibraryProvider.loadMore) Utils.pageLoader(context),
            ],
          ),
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget _buildMagazine() {
    if (mylibraryProvider.loading && !mylibraryProvider.loadMore) {
      return _shimmer();
    } else {
      if (mylibraryProvider.magazineList != null &&
          (mylibraryProvider.magazineList?.length ?? 0) > 0) {
        return SingleChildScrollView(
          controller: _bookController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              _bookDataList(mylibraryProvider.magazineList),
              if (mylibraryProvider.loadMore) Utils.pageLoader(context),
            ],
          ),
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget _bookDataList(List<dynamic>? listData) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ResponsiveGridList(
      minItemWidth: 150,
      minItemsPerRow: 2,
      maxItemsPerRow: 4,
      listViewBuilderOptions: ListViewBuilderOptions(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
      children: List.generate(
        listData?.length ?? 0,
        (index) {
          final item = listData?[index];

          return InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {
              Widget page;
              if (mylibraryProvider.currentIndex == "1") {
                page = AudioBookDetails(
                  categoryId: item?.categoryId.toString(),
                  authorId: item?.authorId.toString(),
                  contentId: item?.id.toString(),
                );
              } else if (mylibraryProvider.currentIndex == "2") {
                page = BookDetails(
                  categoryId: item?.categoryId.toString(),
                  authorId: item?.authorId.toString(),
                  contentId: item?.id.toString(),
                );
              } else {
                page = MagazineDetails(
                  contentId: item?.id.toString(),
                  categoryId: item?.categoryId.toString(),
                );
              }

              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (context, a1, a2) => page,
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
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    child: MyNetworkImage(
                      imagePath: item?.portraitImg?.toString() ?? "",
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item?.title?.toString() ?? "",
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
                          "By ${item?.authorName?.toString() ?? ''}",
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
                              item?.avgReviews?.toString() ?? "0.0",
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.grey[300] : const Color(0xFF374151),
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
    );
  }

  Widget _shimmer() {
    return ResponsiveGridList(
      minItemWidth: 150,
      minItemsPerRow: 2,
      maxItemsPerRow: 4,
      listViewBuilderOptions: ListViewBuilderOptions(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
      ),
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
}
