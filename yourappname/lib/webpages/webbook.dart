import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';
import 'package:yourappname/provider/categoryprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webpages/webdetails.dart';
import 'package:yourappname/webwidget/interactive_icon.dart';
import 'package:yourappname/webwidget/interactivecontainer.dart';
import 'package:yourappname/webwidget/webappbar.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:yourappname/webwidget/footerweb.dart';

const _indigo = Color(0xFF4E45B8);
const _indigoLight = Color(0xFFEEF0FF);
const _textDark = Color(0xFF1F2937);
const _textMedium = Color(0xFF6B7280);
const _textLight = Color(0xFF9CA3AF);
const _bgGray = Color(0xFFF8F9FA);
const _borderLight = Color(0xFFE5E7EB);

class WebBook extends StatefulWidget {
  const WebBook({super.key});

  @override
  State<WebBook> createState() => _WebBookState();
}

class _WebBookState extends State<WebBook> {
  ScrollController scrollController = ScrollController();
  late CategoryProvider categoryProvider;

  @override
  void initState() {
    categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    scrollController.addListener(_scrollListener);
    _fetchbookByAuthorData(0);
    _fetchbookByCategoryData(0);
    _fetchbookByBookData(0);
    _fetchbycommanapidata(0, "2");
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
        _fetchbycommanapidata(categoryProvider.commanCurrentPage ?? 0, "2");
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
      categoryProvider.getcommanlist("2",
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
              title1: "books",
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
          const SizedBox(height: 60), // Spacer so sidebar doesn't touch footer
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
        border: Border.all(color: _borderLight, width: 1),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _textDark)),
              if (itemCount > 5)
                GestureDetector(
                  onTap: onToggle,
                  child: Icon(
                    isExpanded ? FontAwesomeIcons.angleUp : FontAwesomeIcons.angleDown,
                    size: 14, color: _indigo,
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

  Widget _buildFilterCheckboxList({
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
              activeColor: _indigo,
              checkColor: Colors.white,
              side: const BorderSide(color: _borderLight, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: onTap,
            child: Text(
              label, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w500,
                color: isSelected ? _indigo : _textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onFilterTap(String idSet) {
    categoryProvider.clearcommanlist();
    _fetchbycommanapidata(0, "1");
  }

  // ---------- Category Filter ----------
  Widget _buildCategory() {
    if (categoryProvider.bookCatagoryloading && !categoryProvider.loadMore) return _shimmerCard();
    final list = categoryProvider.categoryList ?? [];
    if (list.isEmpty) return const NoData();
    return _buildFilterCard(
      title: "Category",
      itemCount: list.length,
      isExpanded: categoryProvider.isCategory,
      onToggle: () => categoryProvider.setShowData(!categoryProvider.isCategory, false, false),
      child: _buildFilterCheckboxList(
        itemCount: list.length,
        isExpanded: categoryProvider.isCategory,
        itemBuilder: (_, i) {
          final c = list[i];
          final id = c.id.toString();
          return _buildCheckboxItem(
            isSelected: categoryProvider.categoryId.contains(id),
            label: c.name ?? "",
            onTap: () {
              categoryProvider.setCategoryIds(id);
              _onFilterTap("1");
            },
          );
        },
      ),
    );
  }

  // ---------- Language Filter ----------
  Widget _buildLanguage() {
    if (categoryProvider.languageloading && !categoryProvider.loadMore) return _shimmerCard();
    final list = categoryProvider.langugeList ?? [];
    if (list.isEmpty) return const NoData();
    return _buildFilterCard(
      title: "Language",
      itemCount: list.length,
      isExpanded: categoryProvider.isLangugae,
      onToggle: () => categoryProvider.setShowData(false, !categoryProvider.isLangugae, false),
      child: _buildFilterCheckboxList(
        itemCount: list.length,
        isExpanded: categoryProvider.isLangugae,
        itemBuilder: (_, i) {
          final l = list[i];
          final id = l!.id.toString();
          return _buildCheckboxItem(
            isSelected: categoryProvider.langaugeId.contains(id),
            label: l.name ?? "",
            onTap: () {
              categoryProvider.setLanguageIds(id);
              _onFilterTap("1");
            },
          );
        },
      ),
    );
  }

  // ---------- Author Filter ----------
  Widget _buildAuthorData() {
    if (categoryProvider.autherloading && !categoryProvider.loadMore) return _shimmerCard();
    final list = categoryProvider.authorList ?? [];
    if (list.isEmpty) return const NoData();
    return _buildFilterCard(
      title: "Author",
      itemCount: list.length,
      isExpanded: categoryProvider.isAuthor,
      onToggle: () => categoryProvider.setShowData(false, false, !categoryProvider.isAuthor),
      child: _buildFilterCheckboxList(
        itemCount: list.length,
        isExpanded: categoryProvider.isAuthor,
        itemBuilder: (_, i) {
          final a = list[i];
          final id = a!.id.toString();
          final name = "${a.firstName ?? ""} ${a.lastName ?? ""}".trim();
          return _buildCheckboxItem(
            isSelected: categoryProvider.authorId.contains(id),
            label: name,
            onTap: () {
              categoryProvider.setAuthorIds(id);
              _onFilterTap("1");
            },
          );
        },
      ),
    );
  }

  // ============================================================
  //  RIGHT — Book Grid
  // ============================================================
  Widget _buildrightside() {
    if (categoryProvider.commanloading && !categoryProvider.loadMore) return _buildRightSideShimmer();
    if ((categoryProvider.commanlist?.length ?? 0) == 0) return const NoData();
    return _buildRightSideData();
  }

  Widget _buildRightSideData() {
    final list = categoryProvider.commanlist ?? [];
    return ResponsiveGridList(
      minItemWidth: 180,
      minItemsPerRow: 2,
      maxItemsPerRow: Utils.customCrossAxisCount(
        context: context,
        height1600: 8, height1200: 6, height800: 4, height400: 2,
      ),
      horizontalGridSpacing: 16,
      verticalGridSpacing: 16,
      listViewBuilderOptions: ListViewBuilderOptions(
        shrinkWrap: true, padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
      ),
      children: list.map((item) => _buildBookCard(item)).toList(),
    );
  }

  Widget _buildBookCard(item) {
    final acc = getAccessInfo(
      accessType: item.accessType.toString(),
      isBuy: item.isBuy.toString(),
      isSubscription: Constant.isSubscription ?? 0,
      price: item.price?.toString(),
    );
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (_, __, ___) => WebDetails(
            categoryId: item.categoryId.toString(),
            authorId: item.authorId.toString(),
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderLight, width: 1),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: MyNetworkImage(
                imagePath: item.portraitImg ?? "",
                fit: BoxFit.cover,
                height: 220,
                width: double.infinity,
                radius: 0,
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _indigoLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          acc.badgeLabel,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: _indigo),
                        ),
                      ),
                      if (item.price != null && item.price! > 0) ...[
                        const Spacer(),
                        Text(
                          acc.priceText,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _textDark),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title ?? "",
                    maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _textDark),
                  ),
                  const SizedBox(height: 4),
                  if ((item.categoryName ?? "").isNotEmpty)
                    Text(
                      item.categoryName ?? "",
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _textMedium),
                    ),
                  if ((item.authorName ?? "").isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      "by ${item.authorName ?? ""}",
                      style: const TextStyle(fontSize: 12, color: _textLight),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
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
          Utils.buildWebDetailsAppBar(context: context, isHome: true, title1: "books", multilanguage: true),
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
            if (count == "3") {
              return {"id": e.id, "name": "${e.firstName ?? ""} ${e.lastName ?? ""}".trim()};
            }
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
          color: selected ? _indigo : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? _indigo : _borderLight, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: selected ? Colors.white : _textMedium),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: selected ? Colors.white : _textMedium,
              ),
            ),
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
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -1), blurRadius: 4)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _bottomSheetBtn(
                      label: "cancel", isPrimary: false,
                      onTap: () => Navigator.pop(ctx),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _bottomSheetBtn(
                      label: "clear", isPrimary: false,
                      onTap: () {
                        categoryProvider.categoryId.clear();
                        categoryProvider.authorId.clear();
                        categoryProvider.langaugeId.clear();
                        categoryProvider.clearcommanlist();
                        _fetchbycommanapidata(0, "2");
                        Navigator.pop(ctx);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _bottomSheetBtn(
                      label: "apply", isPrimary: true,
                      onTap: () {
                        categoryProvider.clearcommanlist();
                        _fetchbycommanapidata(0, "2");
                        Navigator.pop(ctx);
                      },
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

  Widget _bottomSheetBtn({required String label, required bool isPrimary, required VoidCallback onTap}) {
    return InteractiveContainer(
      child: (hovered) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isPrimary ? _indigo : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isPrimary ? null : Border.all(color: _borderLight),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600,
              color: isPrimary ? Colors.white : _textMedium,
            ),
          ),
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
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _textDark)),
          const SizedBox(height: 8),
          const Divider(height: 1, color: _borderLight),
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
                _fetchbycommanapidata(0, "2");
              }
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Checkbox(
                  activeColor: _indigo,
                  checkColor: Colors.white,
                  value: isSelected,
                  onChanged: (_) => toggle(),
                  side: const BorderSide(color: _borderLight, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                title: GestureDetector(
                  onTap: toggle,
                  child: Text(
                    name,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: isSelected ? _indigo : _textDark,
                    ),
                  ),
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
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderLight, width: 1),
      ),
      child: Column(
        children: [
          CustomWidget.roundrectborder(height: 18, width: double.infinity),
          const SizedBox(height: 16),
          ...List.generate(5, (_) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                CustomWidget.roundrectborder(width: 20, height: 20),
                const SizedBox(width: 10),
                Expanded(child: CustomWidget.roundrectborder(height: 14, width: double.infinity)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildRightSideShimmer() {
    return ResponsiveGridList(
      minItemWidth: 180, minItemsPerRow: 2,
      maxItemsPerRow: Utils.customCrossAxisCount(
        context: context, height1600: 8, height1200: 6, height800: 4, height400: 2,
      ),
      horizontalGridSpacing: 16, verticalGridSpacing: 16,
      listViewBuilderOptions: ListViewBuilderOptions(shrinkWrap: true, padding: EdgeInsets.zero, physics: const NeverScrollableScrollPhysics()),
      children: List.generate(6, (_) => Container(
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderLight, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CustomWidget.rectangular(height: 180, width: double.infinity),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  CustomWidget.roundrectborder(height: 12, width: 60),
                  SizedBox(height: 8),
                  CustomWidget.roundrectborder(height: 14, width: double.infinity),
                  SizedBox(height: 6),
                  CustomWidget.roundrectborder(height: 12, width: 100),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
