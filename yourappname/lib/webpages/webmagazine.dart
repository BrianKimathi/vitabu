import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:yourappname/provider/categoryprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webpages/webmagazinedetails.dart' hide SizedBox, Container, Row;
import 'package:yourappname/webwidget/interactivecontainer.dart' hide SizedBox, Container, Row;
import 'package:yourappname/webwidget/webappbar.dart' hide SizedBox, Container, Row;
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:yourappname/webwidget/footerweb.dart' hide SizedBox, Container, Row;

const _mgIndigo = Color(0xFF4E45B8);
const _mgIndigoLight = Color(0xFFEEF0FF);
const _mgTextDark = Color(0xFF0F172A);
const _mgTextMedium = Color(0xFF6B7280);
const _mgTextLight = Color(0xFF94A3B8);
const _mgBorderLight = Color(0xFFF1F4F9);
const _mgBorderHover = Color(0xFFD4D0F5);

class WebMagazine extends StatefulWidget {
  const WebMagazine({super.key});

  @override
  State<WebMagazine> createState() => _WebMagazineState();
}

class _WebMagazineState extends State<WebMagazine> {
  ScrollController scrollController = ScrollController();
  late CategoryProvider categoryProvider;

  @override
  void initState() {
    categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    scrollController.addListener(_scrollListener);
    _fetchbookByAuthorData(0);
    _fetchbookByCategoryData(0);
    _fetchbookByBookData(0);
    _fetchbycommanapidata(0, "3");
    super.initState();
  }

  _scrollListener() {
    if (!scrollController.hasClients) return;
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      if (categoryProvider.currentIndex == "1" &&
          (categoryProvider.authorCurrentPage ?? 0) <
              (categoryProvider.authorTotalPage ?? 0)) {
        categoryProvider.setLoadMore(true);
        _fetchbookByAuthorData(categoryProvider.authorCurrentPage ?? 0);
      } else if (categoryProvider.currentIndex == "2" &&
          (categoryProvider.languageCurrentPage ?? 0) <
              (categoryProvider.languageTotalPage ?? 0)) {
        categoryProvider.setLoadMore(true);
        _fetchbookByBookData(categoryProvider.languageCurrentPage ?? 0);
      } else if (categoryProvider.currentIndex == "3" &&
          (categoryProvider.categoryCurrentPage ?? 0) <
              (categoryProvider.categoryTotalPage ?? 0)) {
        categoryProvider.setLoadMore(true);
        _fetchbookByCategoryData(categoryProvider.categoryCurrentPage ?? 0);
      }
      if ((categoryProvider.commanCurrentPage ?? 0) <
          (categoryProvider.commanTotalPage ?? 0)) {
        _fetchbycommanapidata(categoryProvider.commanCurrentPage ?? 0, "3");
      }
    }
  }

  _fetchbookByAuthorData(int? nextPage) =>
      categoryProvider.getAutherList((nextPage ?? 0) + 1);
  _fetchbookByCategoryData(int? nextPage) =>
      categoryProvider.getBookCatagory((nextPage ?? 0) + 1);
  _fetchbookByBookData(int? nextPage) =>
      categoryProvider.getPoularBooks((nextPage ?? 0) + 1);
  _fetchbycommanapidata(int? nextPage, contentType) =>
      categoryProvider.getcommanlist(
          "3",
          getSelectedIds(categoryProvider.categoryId),
          getSelectedIds(categoryProvider.authorId),
          getSelectedIds(categoryProvider.langaugeId),
          (nextPage ?? 0) + 1);

  String? getSelectedIds(List<String> ids) =>
      ids.isEmpty ? null : ids.join(',');

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebAppBar(
      widget: Consumer<CategoryProvider>(
        builder: (context, cp, _) {
          categoryProvider = cp;
          return _buildLayout();
        },
      ),
    );
  }

  Widget _buildLayout() =>
      MediaQuery.sizeOf(context).width > 1000 ? _buildWeb() : _buildMobileViewData();

  // ============================================================
  //  DESKTOP
  // ============================================================
  Widget _buildWeb() {
    final sw = MediaQuery.of(context).size.width;
    const maxW = 1400.0;

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          SizedBox(
            width: sw > 1000 ? maxW : sw,
            child: Utils.buildWebDetailsAppBar(
              context: context,
              isHome: true,
              title1: "magazines",
              multilanguage: true,
            ),
          ),
          const SizedBox(height: 20),
          _buildMain(),
          FooterWeb(),
        ],
      ),
    );
  }

  Widget _buildMain() {
    final sw = MediaQuery.of(context).size.width;
    const maxW = 1400.0;
    final wide = sw > maxW;

    return Center(
      child: Container(
        width: wide ? maxW : sw - 20,
        padding: EdgeInsets.symmetric(horizontal: sw <= 1000 ? 10 : 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: _buildLeftSideData()),
            const SizedBox(width: 20),
            Expanded(
              flex: 8,
              child: Column(
                children: [
                  _buildrightside(),
                  if (categoryProvider.loadMore) Utils.pageLoader(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //  LEFT SIDEBAR — Filters
  // ============================================================
  Widget _buildLeftSideData() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCategory(),
          const SizedBox(height: 12),
          _buildAuthorData(),
          const SizedBox(height: 12),
          _buildLanguage(),
          const SizedBox(height: 60),
        ],
      );

  Widget _buildFilterCard({
    required String title,
    required int itemCount,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.22,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700, color: _mgTextDark)),
              if (itemCount > 5)
                GestureDetector(
                  onTap: onToggle,
                  child: Icon(
                    isExpanded ? FontAwesomeIcons.angleUp : FontAwesomeIcons.angleDown,
                    size: 14, color: _mgIndigo,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildCheckboxItem({
    required bool isSelected,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 20, height: 20,
            child: Checkbox(
              value: isSelected,
              onChanged: (_) => onTap(),
              activeColor: _mgIndigo,
              checkColor: Colors.white,
              side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500,
                  color: isSelected ? _mgIndigo : _mgTextDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterList({
    required int itemCount,
    required bool isExpanded,
    required Widget Function(BuildContext, int) itemBuilder,
  }) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: isExpanded ? itemCount : (itemCount > 5 ? 5 : itemCount),
      itemBuilder: itemBuilder,
    );
  }

  void _onFilterTap() {
    categoryProvider.clearcommanlist();
    _fetchbycommanapidata(0, "3");
  }

  Widget _buildCategory() {
    if (categoryProvider.bookCatagoryloading && !categoryProvider.loadMore) return _shimmerCard();
    final list = categoryProvider.categoryList ?? [];
    if (list.isEmpty) return const NoData();
    return _buildFilterCard(
      title: "Category",
      itemCount: list.length,
      isExpanded: categoryProvider.isCategory,
      onToggle: () => categoryProvider.setShowData(!categoryProvider.isCategory, false, false),
      child: _buildFilterList(
        itemCount: list.length,
        isExpanded: categoryProvider.isCategory,
        itemBuilder: (_, i) {
          final c = list[i];
          final id = c.id.toString();
          return _buildCheckboxItem(
            isSelected: categoryProvider.categoryId.contains(id),
            label: c.name ?? "",
            onTap: () { categoryProvider.setCategoryIds(id); _onFilterTap(); },
          );
        },
      ),
    );
  }

  Widget _buildLanguage() {
    if (categoryProvider.languageloading && !categoryProvider.loadMore) return _shimmerCard();
    final list = categoryProvider.langugeList ?? [];
    if (list.isEmpty) return const NoData();
    return _buildFilterCard(
      title: "Language",
      itemCount: list.length,
      isExpanded: categoryProvider.isLangugae,
      onToggle: () => categoryProvider.setShowData(false, !categoryProvider.isLangugae, false),
      child: _buildFilterList(
        itemCount: list.length,
        isExpanded: categoryProvider.isLangugae,
        itemBuilder: (_, i) {
          final l = list[i]!;
          final id = l.id.toString();
          return _buildCheckboxItem(
            isSelected: categoryProvider.langaugeId.contains(id),
            label: l.name ?? "",
            onTap: () { categoryProvider.setLanguageIds(id); _onFilterTap(); },
          );
        },
      ),
    );
  }

  Widget _buildAuthorData() {
    if (categoryProvider.autherloading && !categoryProvider.loadMore) return _shimmerCard();
    final list = categoryProvider.authorList ?? [];
    if (list.isEmpty) return const NoData();
    return _buildFilterCard(
      title: "Author",
      itemCount: list.length,
      isExpanded: categoryProvider.isAuthor,
      onToggle: () => categoryProvider.setShowData(false, false, !categoryProvider.isAuthor),
      child: _buildFilterList(
        itemCount: list.length,
        isExpanded: categoryProvider.isAuthor,
        itemBuilder: (_, i) {
          final a = list[i]!;
          final id = a.id.toString();
          final name = "${a.firstName ?? ""} ${a.lastName ?? ""}".trim();
          return _buildCheckboxItem(
            isSelected: categoryProvider.authorId.contains(id),
            label: name,
            onTap: () { categoryProvider.setAuthorIds(id); _onFilterTap(); },
          );
        },
      ),
    );
  }

  // ============================================================
  //  RIGHT — Magazine Grid
  // ============================================================
  Widget _buildrightside() {
    if (categoryProvider.commanloading && !categoryProvider.loadMore)
      return _buildRightSideShimmer();
    if ((categoryProvider.commanlist?.length ?? 0) == 0) return const NoData();
    return _buildRightSideData();
  }

  Widget _buildRightSideData() {
    final list = categoryProvider.commanlist ?? [];
    return ResponsiveGridList(
      minItemWidth: 185,
      minItemsPerRow: 2,
      maxItemsPerRow: Utils.customCrossAxisCount(
        context: context, height1600: 7, height1200: 5, height800: 4, height400: 2,
      ),
      horizontalGridSpacing: 16,
      verticalGridSpacing: 16,
      listViewBuilderOptions: ListViewBuilderOptions(
        shrinkWrap: true, padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
      ),
      children: list.map((item) => _buildMagazineCard(item)).toList(),
    );
  }

  // ── THE CARD — matches home page _ContentCard exactly ──
  Widget _buildMagazineCard(item) {
    final acc = getAccessInfo(
      accessType: item.accessType.toString(),
      isBuy: item.isBuy.toString(),
      isSubscription: Constant.isSubscription ?? 0,
      price: item.price?.toString(),
    );
    return StatefulBuilder(
      builder: (context, setLocalState) {
        bool hovered = false;
        return MouseRegion(
          onEnter: (_) => setLocalState(() => hovered = true),
          onExit: (_) => setLocalState(() => hovered = false),
          child: GestureDetector(
            onTap: () {
              Navigator.of(context).push(PageRouteBuilder(
                pageBuilder: (_, __, ___) => WebMagazineDetails(
                  categoryId: item.categoryId.toString(),
                  contentId: item.id.toString(),
                  name: item.title.toString(),
                ),
                transitionDuration: const Duration(milliseconds: 150),
                transitionsBuilder: (_, animation, __, child) => AnimatedBuilder(
                  animation: animation,
                  builder: (_, child) => ClipPath(
                    clipper: CircularRevealClipper(progress: animation.value),
                    child: child,
                  ),
                  child: child,
                ),
              ));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              transform: hovered
                  ? Matrix4.translationValues(0, -6, 0)
                  : Matrix4.identity(),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: hovered ? _mgBorderHover : _mgBorderLight,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: hovered
                        ? Colors.black.withOpacity(0.1)
                        : Colors.black.withOpacity(0.04),
                    blurRadius: hovered ? 20 : 8,
                    offset: Offset(0, hovered ? 8 : 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Cover Image ──
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        child: AspectRatio(
                          aspectRatio: 3 / 4,
                          child: Container(
                            color: const Color(0xFFF1F5F9),
                            child: MyNetworkImage(
                              imagePath: item.portraitImg ?? "",
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8, left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: acc.badgeBg.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(acc.badgeLabel,
                              style: TextStyle(color: acc.badgeTextColor, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                      ),
                      if (hovered)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                              color: Colors.black.withOpacity(0.06),
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.remove_red_eye_outlined, size: 16, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text("View", style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  // ── Content ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title ?? "",
                          style: const TextStyle(
                            color: _mgTextDark, fontSize: 14,
                            fontWeight: FontWeight.w600, height: 1.3,
                          ),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        if ((item.authorName ?? "").isNotEmpty)
                          Text(
                            item.authorName ?? "",
                            style: const TextStyle(color: _mgTextLight, fontSize: 12, fontWeight: FontWeight.w400),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 15, color: Color(0xFFF59E0B)),
                            const SizedBox(width: 4),
                            Text(
                              (item.avgReviews ?? 0) > 0 ? item.avgReviews.toString() : "0",
                              style: const TextStyle(color: _mgTextDark, fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "(${Utils.kmbGenerator(item.totalReviews ?? 0)})",
                              style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
                            ),
                            const Spacer(),
                            if ((item.categoryName ?? "").isNotEmpty)
                              Flexible(
                                child: Text(
                                  item.categoryName ?? "",
                                  style: const TextStyle(color: _mgTextLight, fontSize: 11),
                                  maxLines: 1, overflow: TextOverflow.ellipsis,
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
  }

  // ============================================================
  //  MOBILE VIEW
  // ============================================================
  Widget _buildMobileViewData() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Utils.buildWebDetailsAppBar(context: context, isHome: true, title1: "magazines", multilanguage: true),
          const SizedBox(height: 8),
          _buildFilterTabs(),
          const SizedBox(height: 12),
          _buildrightside(),
          if (categoryProvider.loadMore) Utils.pageLoader(context),
          const SizedBox(height: 20),
          FooterWeb(),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final tabs = [
      {"index": 0, "count": "1", "title": "Category", "icon": Icons.category, "list": categoryProvider.categoryList, "fetch": () => categoryProvider.getBookCatagory(1)},
      {"index": 1, "count": "2", "title": "Language", "icon": Icons.language, "list": categoryProvider.langugeList, "fetch": () => categoryProvider.getPoularBooks(1)},
      {"index": 2, "count": "3", "title": "Author", "icon": Icons.person, "list": categoryProvider.authorList, "fetch": () => categoryProvider.getAutherList(1)},
    ];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: tabs.map((t) {
        final idx = t["index"] as int;
        final icon = t["icon"] as IconData;
        final title = t["title"] as String;
        final count = t["count"] as String;
        final list = t["list"] as List?;
        final fetch = t["fetch"] as Future Function();
        return _titleBuild(idx, icon, title, () async {
          categoryProvider.setFilterTab(count);
          if (list?.isEmpty ?? true) await fetch();
          final clist = (list ?? []).map((e) {
            if (count == "3") return {"id": e.id, "name": "${e.firstName ?? ""} ${e.lastName ?? ""}".trim()};
            return {"id": e.id, "name": e.name ?? ""};
          }).toList();
          _filterBottomSheetOpen(commanList: clist, title: title);
        });
      }).toList()),
    );
  }

  Widget _titleBuild(int index, IconData icon, String title, VoidCallback onTap) {
    final selected = categoryProvider.currentIndex == index.toString();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? _mgIndigo : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? _mgIndigo : const Color(0xFFE5E7EB), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : _mgTextMedium),
            const SizedBox(width: 6),
            Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : _mgTextMedium)),
          ],
        ),
      ),
    );
  }

  void _filterBottomSheetOpen({required List commanList, required String title}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.6,
        child: Column(
          children: [
            Expanded(
              child: Consumer<CategoryProvider>(
                builder: (_, cp, __) => _buildFilterCategory(commanList: commanList, title: title),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -1), blurRadius: 4)]),
              child: Row(
                children: [
                  Expanded(child: _bottomSheetBtn(label: "cancel", isPrimary: false, onTap: () => Navigator.pop(ctx))),
                  const SizedBox(width: 10),
                  Expanded(child: _bottomSheetBtn(label: "clear", isPrimary: false, onTap: () {
                    categoryProvider.categoryId.clear();
                    categoryProvider.authorId.clear();
                    categoryProvider.langaugeId.clear();
                    categoryProvider.clearcommanlist();
                    _fetchbycommanapidata(0, "3");
                    Navigator.pop(ctx);
                  })),
                  const SizedBox(width: 10),
                  Expanded(child: _bottomSheetBtn(label: "apply", isPrimary: true, onTap: () {
                    categoryProvider.clearcommanlist();
                    _fetchbycommanapidata(0, "3");
                    Navigator.pop(ctx);
                  })),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bottomSheetBtn({required String label, required bool isPrimary, required VoidCallback onTap}) {
    return InteractiveContainer(
      child: (hovered) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isPrimary ? _mgIndigo : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isPrimary ? null : Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isPrimary ? Colors.white : _mgTextMedium)),
        ),
      ),
    );
  }

  Widget _buildFilterCategory({required List commanList, required String title}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _mgTextDark)),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: commanList.length,
            itemBuilder: (_, i) {
              final it = commanList[i];
              final id = it["id"].toString();
              final name = it["name"] ?? "";
              final isSelected = title == "Author"
                  ? categoryProvider.authorId.contains(id)
                  : title == "Language"
                      ? categoryProvider.langaugeId.contains(id)
                      : categoryProvider.categoryId.contains(id);
              void toggle() {
                if (title == "Author") categoryProvider.setAuthorIds(id);
                else if (title == "Language") categoryProvider.setLanguageIds(id);
                else categoryProvider.setCategoryIds(id);
                categoryProvider.clearcommanlist();
                _fetchbycommanapidata(0, "3");
              }
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Checkbox(
                  activeColor: _mgIndigo,
                  checkColor: Colors.white,
                  value: isSelected,
                  onChanged: (_) => toggle(),
                  side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                title: GestureDetector(
                  onTap: toggle,
                  child: Text(name, maxLines: 2, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isSelected ? _mgIndigo : _mgTextDark)),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  SHIMMER
  // ============================================================
  Widget _shimmerCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      width: MediaQuery.sizeOf(context).width * 0.22,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Column(
        children: [
          CustomWidget.roundrectborder(height: 18, width: double.infinity),
          const SizedBox(height: 16),
          ...List.generate(5, (_) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(children: [
              CustomWidget.roundrectborder(width: 20, height: 20),
              const SizedBox(width: 10),
              Expanded(child: CustomWidget.roundrectborder(height: 14, width: double.infinity)),
            ]),
          )),
        ],
      ),
    );
  }

  Widget _buildRightSideShimmer() {
    return ResponsiveGridList(
      minItemWidth: 185, minItemsPerRow: 2,
      maxItemsPerRow: Utils.customCrossAxisCount(context: context, height1600: 7, height1200: 5, height800: 4, height400: 2),
      horizontalGridSpacing: 16, verticalGridSpacing: 16,
      listViewBuilderOptions: ListViewBuilderOptions(shrinkWrap: true, padding: EdgeInsets.zero, physics: const NeverScrollableScrollPhysics()),
      children: List.generate(6, (_) => Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: _mgBorderLight, width: 1)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(aspectRatio: 3 / 4, child: const CustomWidget.rectangular(height: double.infinity, width: double.infinity)),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                CustomWidget.roundrectborder(height: 14, width: double.infinity),
                SizedBox(height: 6),
                CustomWidget.roundrectborder(height: 12, width: 100),
                SizedBox(height: 8),
                CustomWidget.roundrectborder(height: 12, width: 140),
              ]),
            ),
          ],
        ),
      )),
    );
  }
}
