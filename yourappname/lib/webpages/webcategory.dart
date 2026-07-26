// import 'package:yourappname/provider/categoryprovider.dart';
// import 'package:yourappname/utils/color.dart';
// import 'package:yourappname/utils/constant.dart';
// import 'package:yourappname/utils/dimens.dart';
// import 'package:yourappname/utils/utils.dart';
// import 'package:yourappname/webpages/webaudiobookdetails.dart';
// import 'package:yourappname/webpages/webdetails.dart';
// import 'package:yourappname/webpages/webmagazinedetails.dart';
// import 'package:yourappname/webwidget/footerweb.dart';
// import 'package:yourappname/webwidget/interactive_icon.dart';
// import 'package:yourappname/webwidget/interactivecontainer.dart';
// import 'package:yourappname/webwidget/webappbar.dart';
// import 'package:yourappname/widget/circularrevealclipper.dart';
// import 'package:yourappname/widget/customwidget.dart';
// import 'package:yourappname/widget/mynetworkimg.dart';
// import 'package:yourappname/widget/mytext.dart';
// import 'package:yourappname/widget/nodata.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_locales/flutter_locales.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:provider/provider.dart';
// import 'package:responsive_grid_list/responsive_grid_list.dart';

// class WebCategory extends StatefulWidget {
//   const WebCategory({super.key});

//   @override
//   State<WebCategory> createState() => _WebCategoryState();
// }

// class _WebCategoryState extends State<WebCategory> {
//   ScrollController scrollController = ScrollController();
//   late CategoryProvider categoryProvider;
//   @override
//   void initState() {
//     categoryProvider = Provider.of<CategoryProvider>(context, listen: false);

//     scrollController.addListener(_scrollListener);
//     _fetchbookByAuthorData(0);
//     _fetchbookByCategoryData(0);
//     _fetchbookByBookData(0);
//     _fetchbycommanapidata(0, "1");
//     super.initState();
//   }

//   _scrollListener() {
//     if (!scrollController.hasClients) return;
//     if (scrollController.offset >= scrollController.position.maxScrollExtent &&
//         !scrollController.position.outOfRange &&
//         (categoryProvider.currentPage ?? 0) <
//             (categoryProvider.totalPage ?? 0)) {
//       categoryProvider.setLoadMore(true);
//       if (categoryProvider.currentIndex == "1") {
//         _fetchbookByAuthorData(categoryProvider.currentPage ?? 0);
//       } else if (categoryProvider.currentIndex == "2") {
//         _fetchbookByBookData(categoryProvider.currentPage ?? 0);
//       } else {
//         _fetchbookByCategoryData(categoryProvider.currentPage ?? 0);
//       }
//       _fetchbycommanapidata(0, categoryProvider.currentIndex == "1");
//     }
//   }

// // Author Api
//   _fetchbookByAuthorData(int? nextPage) {
//     categoryProvider.getAutherList((nextPage ?? 0) + 1);
//   }

// // Category(Genres) Api
//   _fetchbookByCategoryData(int? nextPage) {
//     categoryProvider.getBookCatagory((nextPage ?? 0) + 1);
//   }

// // Book Data Api
//   _fetchbookByBookData(int? nextPage) {
//     categoryProvider.getPoularBooks((nextPage ?? 0) + 1);
//   }

//   _fetchbycommanapidata(int? nextPage, contentType) {
//     categoryProvider.getcommanlist(
//       contentType,
//       getSelectedIds(categoryProvider.categoryId),
//       getSelectedIds(categoryProvider.authorId),
//       getSelectedIds(categoryProvider.langaugeId),
//       (nextPage ?? 0) + 1,
//     );
//   }

//   void fetchDataFromProvider(int contentType) {
//     _fetchbycommanapidata(0, contentType);
//   }

//   String? getSelectedIds(List<String> ids) {
//     return ids.isEmpty ? null : ids.join(',');
//   }

//   @override
//   void dispose() {
//     scrollController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return WebAppBar(widget:
//         Consumer<CategoryProvider>(builder: (context, categoryProvider, child) {
//       return _buildLayout();
//     }));
//   }

//   Widget _buildLayout() {
//     if (MediaQuery.sizeOf(context).width > 1000) {
//       return _buildWeb();
//     } else {
//       return _buildMobileViewData();
//     }
//   }

//   Widget _buildWeb() {
//     final screenWidth = MediaQuery.of(context).size.width;
//     const double maxContentWidth = 1400;
//     final bool isWide = screenWidth > 1000;

//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           Center(
//             child: SizedBox(
//               width: isWide ? maxContentWidth : screenWidth,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // AppBar left side
//                   Expanded(
//                     child: Utils.buildWebDetailsAppBar(
//                       context: context,
//                       isHome: true,
//                       title1: "category",
//                       multilanguage: true,
//                     ),
//                   ),

//                   _buildTab(),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           _buildMain(),
//           FooterWeb(),
//         ],
//       ),
//     );
//   }

//   Widget _buildMain() {
//     final screenWidth = MediaQuery.of(context).size.width;
//     const double maxContentWidth = 1400;
//     final bool isWide = screenWidth > maxContentWidth;

//     return Center(
//       child: Container(
//         width: isWide ? maxContentWidth : screenWidth - 20,
//         padding: EdgeInsets.symmetric(horizontal: screenWidth <= 1000 ? 10 : 0),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Expanded(flex: 3, child: _buildLeftSideData()),
//             const SizedBox(width: 20),
//             Expanded(
//               flex: 8,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   _buildrightside(),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// /* Left Side data  */

//   Widget _buildLeftSideData() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _buildCategory(),
//         _buildAuthorData(),
//         _buildLanguage(),
//       ],
//     );
//   }

// /* Category Data Starts */

//   Widget _buildCategory() {
//     if (categoryProvider.bookCatagoryloading &&
//         categoryProvider.loadMore == false) {
//       return categoryShimmer();
//     } else {
//       if (categoryProvider.categoryList != null &&
//           (categoryProvider.categoryList?.length ?? 0) > 0) {
//         return SingleChildScrollView(
//           controller: scrollController,
//           physics: AlwaysScrollableScrollPhysics(),
//           child: Column(
//             children: [
//               categorydata(),
//               SizedBox(height: 10),
//               if (categoryProvider.loadMore)
//                 Utils.pageLoader(context)
//               else
//                 SizedBox.shrink(),
//               SizedBox(height: 10),
//             ],
//           ),
//         );
//       } else {
//         return const NoData();
//       }
//     }
//   }

//   Widget categorydata() {
//     final categories = categoryProvider.categoryList;

//     return Container(
//       width: MediaQuery.sizeOf(context).width * 0.22,
//       decoration: BoxDecoration(
//         color: white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: gray, width: 1),
//       ),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Expanded(
//                 child: MyText(
//                   text: "Category",
//                   fontsize: Dimens.medium16TextSize,
//                   fontwaight: FontWeight.w700,
//                   maxline: 1,
//                   multilanguage: true,
//                 ),
//               ),
//               if (categories!.length > 5)
//                 InteractiveIcon(
//                   iconData: categoryProvider.isCategory
//                       ? FontAwesomeIcons.angleUp
//                       : FontAwesomeIcons.angleDown,
//                   onTap: () {
//                     categoryProvider.setShowData(
//                         !categoryProvider.isCategory, false, false);
//                   },
//                   size: 18,
//                   color: colorAccent,
//                 ),
//             ],
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           ListView.builder(
//             shrinkWrap: true,
//             physics: const NeverScrollableScrollPhysics(),
//             padding: EdgeInsets.zero,
//             itemCount: categoryProvider.isCategory
//                 ? categories.length
//                 : (categories.length > 5 ? 5 : categories.length),
//             itemBuilder: (context, index) {
//               final category = categories[index];
//               final id = category.id;
//               final name = category.name ?? "";

//               return Padding(
//                 padding: const EdgeInsets.only(top: 5, bottom: 5),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Checkbox(
//                       value:
//                           categoryProvider.categoryId.contains(id.toString()),
//                       onChanged: (_) {
//                         categoryProvider.setCategoryIds(id.toString());
//                         categoryProvider.clearcommanlist();
//                         printLog(
//                             "===>> Clear List ===>> : ${categoryProvider.clearcommanlist()}");
//                         _fetchbycommanapidata(0, categoryProvider.currentIndex);
//                       },
//                       side: BorderSide(color: gray, width: 1.5),
//                       activeColor: colorAccent,
//                       checkColor: white,
//                       hoverColor: colorAccent.withOpacity( 0.2),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                       visualDensity:
//                           const VisualDensity(horizontal: -4, vertical: -4),
//                     ),
//                     SizedBox(
//                       width: 5,
//                     ),
//                     Expanded(
//                       child: InkWell(
//                         onTap: () {
//                           categoryProvider.setCategoryIds(id.toString());
//                           categoryProvider.clearcommanlist();
//                           printLog(
//                               "===>> Clear List ===>> : ${categoryProvider.clearcommanlist()}");
//                           _fetchbycommanapidata(
//                               0, categoryProvider.currentIndex);
//                         },
//                         hoverColor: transparent,
//                         child: MyText(
//                           text: name,
//                           maxline: 1,
//                           fontsize: Dimens.medium14TextSize,
//                           fontwaight: FontWeight.bold,
//                           overflow: TextOverflow.ellipsis,
//                           color: categoryProvider.categoryId
//                                   .contains(id.toString())
//                               ? colorAccent
//                               : black,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget categoryShimmer() {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10),
//       child: Container(
//         padding: EdgeInsets.all(16),
//         width: MediaQuery.sizeOf(context).width * 0.3,
//         decoration: BoxDecoration(
//           color: white,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: gray, width: 1),
//         ),
//         child: Column(
//           children: [
//             CustomWidget.roundrectborder(
//               height: 20,
//               width: MediaQuery.sizeOf(context).width * 0.2,
//             ),
//             SizedBox(height: 16),
//             Column(
//               children: List.generate(5, (index) {
//                 return Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 8.0),
//                   child: Row(
//                     children: [
//                       CustomWidget.roundrectborder(
//                         width: 24,
//                         height: 24,
//                       ),
//                       SizedBox(width: 12),
//                       Expanded(
//                         child: CustomWidget.roundrectborder(
//                           height: 16,
//                           width: double.infinity,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

// /* Category Data end */

// /* Languge data started  */

//   Widget _buildLanguage() {
//     if (categoryProvider.bookCatagoryloading &&
//         categoryProvider.loadMore == false) {
//       return categoryShimmer();
//     } else {
//       if (categoryProvider.langugeList != null &&
//           (categoryProvider.langugeList?.length ?? 0) > 0) {
//         return SingleChildScrollView(
//           controller: scrollController,
//           physics: AlwaysScrollableScrollPhysics(),
//           child: Column(
//             children: [
//               langaugedata(),
//               SizedBox(height: 10),
//               if (categoryProvider.loadMore)
//                 Utils.pageLoader(context)
//               else
//                 SizedBox.shrink(),
//               SizedBox(height: 10),
//             ],
//           ),
//         );
//       } else {
//         return const NoData();
//       }
//     }
//   }

//   Widget langaugedata() {
//     final languages = categoryProvider.langugeList;
//     final languageCount = languages?.length ?? 0;

//     return Container(
//       padding: EdgeInsets.fromLTRB(16, 20, 16, 20),
//       width: MediaQuery.sizeOf(context).width * 0.22,
//       decoration: BoxDecoration(
//         color: white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(width: 1, color: gray, style: BorderStyle.solid),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Expanded(
//                 child: MyText(
//                   text: "Language",
//                   fontsize: Dimens.medium16TextSize,
//                   fontwaight: FontWeight.w700,
//                   maxline: 1,
//                   multilanguage: true,
//                 ),
//               ),
//               if (languageCount > 5)
//                 InteractiveIcon(
//                   iconData: categoryProvider.isLangugae
//                       ? FontAwesomeIcons.angleUp
//                       : FontAwesomeIcons.angleDown,
//                   onTap: () {
//                     categoryProvider.setShowData(
//                         false, !categoryProvider.isLangugae, false);
//                   },
//                   size: 18,
//                   color: colorAccent,
//                 ),
//             ],
//           ),
//           const SizedBox(
//             height: 10,
//           ),
//           ListView.builder(
//             shrinkWrap: true,
//             scrollDirection: Axis.vertical,
//             physics: NeverScrollableScrollPhysics(),
//             padding: EdgeInsets.zero,
//             itemCount: categoryProvider.isLangugae
//                 ? languageCount
//                 : (languageCount > 5 ? 5 : languageCount),
//             itemBuilder: (context, index) {
//               final lang = languages?[index];
//               final id = lang?.id ?? 0;
//               final name = lang?.name ?? "";
//               final idString = id.toString();
//               final isSelected = categoryProvider.langaugeId.contains(idString);

//               return Padding(
//                 padding: const EdgeInsets.only(top: 5, bottom: 5),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Checkbox(
//                       value: isSelected,
//                       onChanged: (value) {
//                         categoryProvider.setLanguageIds(idString);
//                         categoryProvider.clearcommanlist();
//                         printLog(
//                             "===>> Clear List ===>> : ${categoryProvider.clearcommanlist()}");
//                         _fetchbycommanapidata(0, categoryProvider.currentIndex);
//                       },
//                       side: BorderSide(color: gray, width: 1.5),
//                       activeColor: colorAccent,
//                       checkColor: white,
//                       hoverColor: colorAccent.withOpacity( 0.2),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(4),
//                       ),
//                       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                       visualDensity:
//                           const VisualDensity(horizontal: -4, vertical: -4),
//                     ),
//                     SizedBox(
//                       width: 5,
//                     ),
//                     Expanded(
//                       child: InkWell(
//                         onTap: () {
//                           categoryProvider.setLanguageIds(idString);
//                           categoryProvider.clearcommanlist();
//                           printLog(
//                               "===>> Clear List ===>> : ${categoryProvider.clearcommanlist()}");
//                           _fetchbycommanapidata(
//                               0, categoryProvider.currentIndex);
//                         },
//                         hoverColor: transparent,
//                         child: MyText(
//                           text: name,
//                           maxline: 1,
//                           fontsize: Dimens.medium14TextSize,
//                           fontwaight: FontWeight.bold,
//                           overflow: TextOverflow.ellipsis,
//                           color: isSelected ? colorAccent : black,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//     );
//   }

// // Author Data Started//
//   Widget _buildAuthorData() {
//     if (categoryProvider.autherloading && categoryProvider.loadMore == false) {
//       return categoryShimmer();
//     } else {
//       if (categoryProvider.authorList != null &&
//           (categoryProvider.authorList?.length ?? 0) > 0) {
//         return SingleChildScrollView(
//           controller: scrollController,
//           physics: AlwaysScrollableScrollPhysics(),
//           child: Column(
//             children: [
//               authordetails(),
//               SizedBox(height: 10),
//               if (categoryProvider.loadMore)
//                 Utils.pageLoader(context)
//               else
//                 SizedBox.shrink(),
//               SizedBox(height: 10),
//             ],
//           ),
//         );
//       } else {
//         return const NoData();
//       }
//     }
//   }

//   Widget authordetails() {
//     return Consumer<CategoryProvider>(
//       builder: (context, categoryProvider, child) {
//         final authors = categoryProvider.authorList;
//         final authorCount = authors?.length ?? 0;
//         return Container(
//           padding: EdgeInsets.all(16),
//           width: MediaQuery.sizeOf(context).width * 0.22,
//           decoration: BoxDecoration(
//             color: white,
//             borderRadius: BorderRadius.circular(10),
//             border: Border.all(color: gray, width: 1),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Expanded(
//                     child: MyText(
//                       text: "Author",
//                       fontsize: Dimens.medium16TextSize,
//                       fontwaight: FontWeight.w700,
//                       maxline: 1,
//                       multilanguage: true,
//                     ),
//                   ),
//                   if (authorCount > 5)
//                     InteractiveIcon(
//                       iconData: categoryProvider.isAuthor
//                           ? FontAwesomeIcons.angleUp
//                           : FontAwesomeIcons.angleDown,
//                       onTap: () {
//                         categoryProvider.setShowData(
//                             false, false, !categoryProvider.isAuthor);
//                       },
//                       size: 18,
//                       color: colorAccent,
//                     ),
//                 ],
//               ),
//               const SizedBox(
//                 height: 10,
//               ),
//               ListView.builder(
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 padding: EdgeInsets.zero,
//                 itemCount: categoryProvider.isAuthor
//                     ? authorCount
//                     : (authorCount > 5 ? 5 : authorCount),
//                 itemBuilder: (context, index) {
//                   final authorItem = authors?[index];
//                   final id = authorItem?.id ?? 0;
//                   final idString = id.toString();
//                   final fullName =
//                       "${authorItem?.firstName ?? ""} ${authorItem?.lastName ?? ""}";
//                   final isSelected =
//                       categoryProvider.authorId.contains(idString);

//                   return Padding(
//                     padding: const EdgeInsets.only(top: 5, bottom: 5),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         Checkbox(
//                           value: isSelected,
//                           onChanged: (_) {
//                             categoryProvider.setAuthorIds(idString);
//                             categoryProvider.clearcommanlist();
//                             printLog(
//                                 "===>> Clear List ===>> : ${categoryProvider.clearcommanlist()}");
//                             _fetchbycommanapidata(
//                                 0, categoryProvider.currentIndex);
//                           },
//                           side: BorderSide(color: gray, width: 1.5),
//                           activeColor: colorAccent,
//                           checkColor: white,
//                           hoverColor: colorAccent.withOpacity( 0.2),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           materialTapTargetSize:
//                               MaterialTapTargetSize.shrinkWrap,
//                           visualDensity:
//                               const VisualDensity(horizontal: -4, vertical: -4),
//                         ),
//                         SizedBox(
//                           width: 5,
//                         ),
//                         Expanded(
//                           child: InkWell(
//                             onTap: () {
//                               categoryProvider.setAuthorIds(idString);
//                               categoryProvider.clearcommanlist();
//                               printLog(
//                                   "===>> Clear List ===>> : ${categoryProvider.clearcommanlist()}");
//                               _fetchbycommanapidata(
//                                   0, categoryProvider.currentIndex);
//                             },
//                             hoverColor: transparent,
//                             child: MyText(
//                               text: fullName,
//                               maxline: 1,
//                               fontsize: Dimens.medium14TextSize,
//                               fontwaight: FontWeight.bold,
//                               overflow: TextOverflow.ellipsis,
//                               color: isSelected ? colorAccent : black,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// // authordata  end //

// /* Rigth side data */

//   Widget _buildrightside() {
//     if (categoryProvider.commanloading && categoryProvider.loadMore == false) {
//       return buildRightSideShimmer();
//     } else {
//       if (categoryProvider.commanlist != null &&
//           (categoryProvider.commanlist?.length ?? 0) > 0) {
//         return SingleChildScrollView(
//           controller: scrollController,
//           physics: AlwaysScrollableScrollPhysics(),
//           child: Column(
//             children: [
//               _buildRightSideData(),
//               SizedBox(height: 20),
//               if (categoryProvider.loadMore)
//                 Utils.pageLoader(context)
//               else
//                 SizedBox.shrink(),
//               SizedBox(height: 20),
//             ],
//           ),
//         );
//       } else {
//         return const NoData();
//       }
//     }
//   }

//   Widget _buildRightSideData() {
//     final commanList = categoryProvider.commanlist ?? [];

//     return ResponsiveGridList(
//       minItemWidth: 185,
//       minItemsPerRow: 2,
//       maxItemsPerRow: Utils.customCrossAxisCount(
//         context: context,
//         height1600: 8,
//         height1200: 6,
//         height800: 4,
//         height400: 2,
//       ),
//       horizontalGridMargin: 0,
//       verticalGridMargin: 0,
//       verticalGridSpacing: 20,
//       horizontalGridSpacing: 20,
//       listViewBuilderOptions: ListViewBuilderOptions(
//         shrinkWrap: true,
//         padding: EdgeInsets.zero,
//         physics: AlwaysScrollableScrollPhysics(),
//       ),
//       children: List.generate(commanList.length, (index) {
//         final item = commanList[index];

//         final contentType = categoryProvider.currentIndex;

//         return InkWell(
//           onTap: () {
//             if (contentType == "1") {
//               Navigator.of(context).push(PageRouteBuilder(
//                 pageBuilder: (context, animation, secondaryAnimation) {
//                   return WebAudioBookDetails(
//                     categoryId: item.categoryId.toString(),
//                     authorId: item.authorId.toString(),
//                     contentId: item.id.toString(),
//                     name: item.title.toString(),
//                   );
//                 },
//                 transitionDuration: Duration(milliseconds: 150),
//                 transitionsBuilder:
//                     (context, animation, secondaryAnimation, child) {
//                   return AnimatedBuilder(
//                     animation: animation,
//                     builder: (context, child) {
//                       return ClipPath(
//                         clipper:
//                             CircularRevealClipper(progress: animation.value),
//                         child: child,
//                       );
//                     },
//                     child: child,
//                   );
//                 },
//               ));
//             } else if (contentType == "2") {
//               Navigator.of(context).push(PageRouteBuilder(
//                 pageBuilder: (context, animation, secondaryAnimation) {
//                   return WebDetails(
//                     categoryId: item.categoryId.toString(),
//                     authorId: item.authorId.toString(),
//                     contentId: item.id.toString(),
//                     name: item.title.toString(),
//                   );
//                 },
//                 transitionDuration: Duration(milliseconds: 150),
//                 transitionsBuilder:
//                     (context, animation, secondaryAnimation, child) {
//                   return AnimatedBuilder(
//                     animation: animation,
//                     builder: (context, child) {
//                       return ClipPath(
//                         clipper:
//                             CircularRevealClipper(progress: animation.value),
//                         child: child,
//                       );
//                     },
//                     child: child,
//                   );
//                 },
//               ));
//             } else {
//               Navigator.of(context).push(PageRouteBuilder(
//                 pageBuilder: (context, animation, secondaryAnimation) {
//                   return WebMagazineDetails(
//                     contentId: item.id.toString(),
//                     categoryId: item.categoryId.toString(),
//                     name: item.title.toString(),
//                   );
//                 },
//                 transitionDuration: Duration(milliseconds: 150),
//                 transitionsBuilder:
//                     (context, animation, secondaryAnimation, child) {
//                   return AnimatedBuilder(
//                     animation: animation,
//                     builder: (context, child) {
//                       return ClipPath(
//                         clipper:
//                             CircularRevealClipper(progress: animation.value),
//                         child: child,
//                       );
//                     },
//                     child: child,
//                   );
//                 },
//               ));
//             }
//           },
//           child: Container(
//             width: 200,
//             alignment: Alignment.center,
//             decoration: BoxDecoration(
//                 color: white,
//                 border: Border.all(width: 1, color: gray),
//                 borderRadius: BorderRadius.circular(10)),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // 📘 Image Section
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                   child: MyNetworkImage(
//                     imagePath: item.portraitImg ?? "",
//                     fit: BoxFit.cover,
//                     height: 260,
//                     width: double.infinity,
//                     radius: 6,
//                   ),
//                 ),

//                 Padding(
//                   padding: const EdgeInsets.symmetric(horizontal: 10),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       const SizedBox(height: 6),
//                       MyText(
//                         color: colorAccent,
//                         text: item.isPaid == 1 ? "Paid" : "Free",
//                         fontsize: Dimens.medium14TextSize,
//                         fontsizeWeb: Dimens.medium14TextSize,
//                         maxline: 1,
//                         fontwaight: FontWeight.w600,
//                       ),
//                       const SizedBox(height: 3),
//                       MyText(
//                         text: item.title ?? "",
//                         fontsize: Dimens.medium16TextSize,
//                         fontsizeWeb: Dimens.medium16TextSize,
//                         maxline: 2,
//                         fontwaight: FontWeight.w500,
//                       ),
//                       const SizedBox(height: 2),
//                       MyText(
//                         text: item.categoryName ?? "",
//                         fontsize: Dimens.medium16TextSize,
//                         fontsizeWeb: Dimens.medium16TextSize,
//                         maxline: 2,
//                         color: yello,
//                         fontwaight: FontWeight.w500,
//                       ),
//                       const SizedBox(height: 2),
//                       MyText(
//                         text: item.languageName ?? "",
//                         fontsize: Dimens.medium16TextSize,
//                         fontsizeWeb: Dimens.medium16TextSize,
//                         maxline: 2,
//                         color: colorPrimaryDark,
//                         fontwaight: FontWeight.w500,
//                       ),
//                       const SizedBox(height: 2),
//                       MyText(
//                         color: gray,
//                         text: item.authorName ?? "",
//                         fontsize: Dimens.medium14TextSize,
//                         fontsizeWeb: Dimens.medium14TextSize,
//                         maxline: 1,
//                         fontwaight: FontWeight.w400,
//                       ),
//                       const SizedBox(height: 4),
//                       MyText(
//                         text: (item.isPaid == 1 && item.isBuy == 0)
//                             ? "${Constant.currencyCode} ${item.price}"
//                             : Locales.string(context, "free"),
//                         fontsize: Dimens.medium18TextSize,
//                         fontsizeWeb: Dimens.medium18TextSize,
//                         maxline: 1,
//                         fontwaight: FontWeight.w500,
//                       ),
//                       const SizedBox(height: 8),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       }),
//     );
//   }

// /* TAB Category */

//   Widget _buildTab() {
//     double screenWidth = MediaQuery.of(context).size.width;
//     double horizontalPadding = (screenWidth > 1000) ? 0 : 6;
//     return SingleChildScrollView(
//         padding:
//             EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _titleBuild("1", Icons.audio_file_rounded, "audio_book", () {
//               categoryProvider.setTab("1");
//               categoryProvider.clearcommanlist();
//               printLog(
//                   "===>> Clear List ===>> : ${categoryProvider.clearcommanlist()}");
//               _fetchbycommanapidata(0, "1");
//             }),
//             _titleBuild("2", FontAwesomeIcons.book, "books", () {
//               categoryProvider.setTab("2");
//               categoryProvider.clearcommanlist();
//               printLog(
//                   "===>> Clear List ===>> : ${categoryProvider.clearcommanlist()}");
//               _fetchbycommanapidata(0, "2");
//             }),
//             _titleBuild("3", FontAwesomeIcons.newspaper, "magazines", () {
//               categoryProvider.setTab("3");
//               categoryProvider.clearcommanlist();
//               printLog(
//                   "===>> Clear List ===>> : ${categoryProvider.clearcommanlist()}");
//               _fetchbycommanapidata(0, "3");
//             }),
//           ],
//         ));
//   }

//   Widget _titleBuild(index, iconData, title, onTap) {
//     return InkWell(
//       splashColor: transparent,
//       hoverColor: transparent,
//       focusColor: transparent,
//       onTap: onTap,
//       child: Container(
//         margin: EdgeInsets.only(right: 10),
//         padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         decoration: BoxDecoration(
//             color: Constant.isDarkMode
//                 ? categoryProvider.currentIndex == index
//                     ? colorPrimaryDark
//                     : transparent
//                 : categoryProvider.currentIndex == index
//                     ? colorPrimary
//                     : transparent,
//             borderRadius: BorderRadius.circular(6),
//             border: Border.all(
//               width: 1,
//               style: BorderStyle.solid,
//               color: Constant.isDarkMode
//                   ? categoryProvider.currentIndex == index
//                       ? colorPrimary
//                       : gray
//                   : colorPrimary,
//             )),
//         child: Row(
//           children: [
//             Icon(
//               color: Constant.isDarkMode
//                   ? categoryProvider.currentIndex == index
//                       ? colorPrimary
//                       : white
//                   : categoryProvider.currentIndex == index
//                       ? white
//                       : black,
//               iconData,
//               size: 16,
//             ),
//             SizedBox(width: 6),
//             MyText(
//               color: Constant.isDarkMode
//                   ? categoryProvider.currentIndex == index
//                       ? colorPrimary
//                       : white
//                   : categoryProvider.currentIndex == index
//                       ? white
//                       : black,
//               text: title,
//               multilanguage: true,
//               fontwaight: FontWeight.w500,
//               fontsize: Dimens.medium14TextSize,
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMobileViewData() {
//     return SingleChildScrollView(
//       padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         spacing: 20,
//         children: [
//           Utils.buildWebDetailsAppBar(
//               context: context,
//               isHome: true,
//               title1: "category",
//               multilanguage: true),
//           Row(
//             children: [
//               Expanded(flex: 3, child: _buildTab()),
//               Expanded(flex: 1, child: _buildFilterIcon()),
//             ],
//           ),
//           _buildrightside(),
//           FooterWeb(),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterIcon() {
//     final tabs = [
//       {
//         "count": "1",
//         "name": "category",
//         "list": categoryProvider.categoryList,
//         "fetch": () => categoryProvider.getBookCatagory(1),
//         "title": "Category",
//       },
//       {
//         "count": "2",
//         "name": "language",
//         "list": categoryProvider.langugeList,
//         "fetch": () => categoryProvider.getPoularBooks(1),
//         "title": "Language",
//       },
//       {
//         "count": "3",
//         "name": "author",
//         "list": categoryProvider.authorList,
//         "fetch": () => categoryProvider.getAutherList(1),
//         "title": "Author",
//       },
//     ];

//     return PopupMenuButton<int>(
//       icon: Icon(Icons.filter_list, color: black),
//       onSelected: (index) async {
//         final tab = tabs[index];
//         categoryProvider.setFilterTab(tab["count"]!);

//         // Fetch data if list is empty
//         if ((tab["list"] as List?)?.isEmpty ?? true) {
//           await (tab["fetch"] as Future Function())();
//         }

//         // Prepare list for bottom sheet
//         final commanList = (tab["list"] as List?)?.map((e) {
//               if (tab["count"] == "3") {
//                 return {
//                   "id": e.id,
//                   "name": "${e.firstName ?? ""} ${e.lastName ?? ""}"
//                 };
//               } else {
//                 return {"id": e.id, "name": e.name};
//               }
//             }).toList() ??
//             [];

//         // Open bottom sheet
//         filterBottomSheetOpen(
//           commanList: commanList,
//           title: tab["title"],
//         );
//       },
//       itemBuilder: (context) {
//         return List<PopupMenuEntry<int>>.generate(
//           tabs.length,
//           (index) {
//             final title = tabs[index]["title"] as String? ?? "";
//             return PopupMenuItem<int>(
//               value: index,
//               child: Text(title),
//             );
//           },
//         );
//       },
//     );
//   }

//   void filterBottomSheetOpen({commanList, title}) {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: white,
//       showDragHandle: true,
//       isDismissible: true,
//       isScrollControlled: true,
//       builder: (context) {
//         return SizedBox(
//           height: MediaQuery.sizeOf(context).height * 0.6,
//           width: MediaQuery.sizeOf(context).width,
//           child: SingleChildScrollView(
//             padding: EdgeInsets.fromLTRB(20, 20, 20, 30),
//             child: Column(
//               children: [
//                 Consumer<CategoryProvider>(builder: (context, provider, child) {
//                   return _buildFilterCategory(
//                       commanList: commanList, title: title);
//                 }),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   spacing: 20,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: InteractiveContainer(
//                         child: (isHovered) {
//                           return InkWell(
//                             hoverColor: transparent,
//                             splashColor: transparent,
//                             focusColor: transparent,
//                             highlightColor: transparent,
//                             onTap: () {
//                               Navigator.pop(context);
//                             },
//                             borderRadius: BorderRadius.circular(5),
//                             child: AnimatedScale(
//                               scale: isHovered ? 1.05 : 1,
//                               duration: const Duration(milliseconds: 150),
//                               curve: Curves.easeInOut,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                     horizontal: 16, vertical: 10),
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                     width: 1,
//                                     color:
//                                         isHovered ? colorAccent : colorPrimary,
//                                   ),
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                                 child: MyText(
//                                   color: isHovered ? colorAccent : colorPrimary,
//                                   multilanguage: true,
//                                   text: "cancel",
//                                   textalign: TextAlign.center,
//                                   fontsize: Dimens.medium14TextSize,
//                                   fontsizeWeb: Dimens.medium14TextSize,
//                                   maxline: 1,
//                                   fontwaight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 10),
//                     Expanded(
//                       child: InteractiveContainer(child: (isHovered) {
//                         return InkWell(
//                             hoverColor: transparent,
//                             splashColor: transparent,
//                             focusColor: transparent,
//                             highlightColor: transparent,
//                             onTap: () {
//                               categoryProvider.categoryId.clear();
//                               categoryProvider.authorId.clear();
//                               categoryProvider.langaugeId.clear();
//                               categoryProvider.clearcommanlist();
//                               _fetchbycommanapidata(
//                                   0, categoryProvider.currentIndex);
//                               Navigator.pop(context);
//                             },
//                             borderRadius: BorderRadius.circular(5),
//                             child: AnimatedScale(
//                               scale: isHovered ? 1.05 : 1,
//                               duration: const Duration(milliseconds: 150),
//                               curve: Curves.easeInOut,
//                               child: Container(
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal: 16, vertical: 6),
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                   border: Border.all(
//                                       width: 1,
//                                       color: isHovered
//                                           ? colorAccent
//                                           : colorPrimary,
//                                       style: BorderStyle.solid),
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                                 child: MyText(
//                                     color:
//                                         isHovered ? colorAccent : colorPrimary,
//                                     multilanguage: true,
//                                     text: "clear",
//                                     textalign: TextAlign.left,
//                                     fontsize: Dimens.medium14TextSize,
//                                     fontsizeWeb: Dimens.medium14TextSize,
//                                     maxline: 1,
//                                     fontwaight: FontWeight.w500,
//                                     overflow: TextOverflow.ellipsis,
//                                     fontstyle: FontStyle.normal),
//                               ),
//                             ));
//                       }),
//                     ),
//                     Expanded(
//                       child: InteractiveContainer(child: (isHovered) {
//                         return InkWell(
//                             hoverColor: transparent,
//                             splashColor: transparent,
//                             focusColor: transparent,
//                             highlightColor: transparent,
//                             onTap: () {
//                               categoryProvider.clearcommanlist();
//                               _fetchbycommanapidata(
//                                   0, categoryProvider.currentIndex);
//                               Navigator.pop(context);
//                             },
//                             borderRadius: BorderRadius.circular(5),
//                             child: AnimatedScale(
//                               scale: isHovered ? 1.05 : 1,
//                               duration: const Duration(milliseconds: 150),
//                               curve: Curves.easeInOut,
//                               child: Container(
//                                 alignment: Alignment.center,
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal: 16, vertical: 6),
//                                 decoration: BoxDecoration(
//                                   color: isHovered ? colorAccent : colorPrimary,
//                                   borderRadius: BorderRadius.circular(4),
//                                 ),
//                                 child: MyText(
//                                     color: white,
//                                     multilanguage: true,
//                                     text: "apply",
//                                     textalign: TextAlign.left,
//                                     fontsize: Dimens.medium14TextSize,
//                                     fontsizeWeb: Dimens.medium14TextSize,
//                                     maxline: 1,
//                                     fontwaight: FontWeight.w500,
//                                     overflow: TextOverflow.ellipsis,
//                                     fontstyle: FontStyle.normal),
//                               ),
//                             ));
//                       }),
//                     )
//                   ],
//                 )
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildFilterCategory({commanList, title}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       spacing: 20,
//       children: [
//         MyText(
//           text: title,
//           fontsize: Dimens.medium16TextSize,
//           fontsizeWeb: Dimens.medium16TextSize,
//           fontwaight: FontWeight.w700,
//           maxline: 1,
//           multilanguage: true,
//         ),
//         Divider(thickness: 2, color: gray, height: 0),
//         ListView.builder(
//             shrinkWrap: true,
//             scrollDirection: Axis.vertical,
//             physics: NeverScrollableScrollPhysics(),
//             padding: EdgeInsets.zero,
//             itemBuilder: (context, index) {
//               final id = commanList?[index]["id"];
//               final name = commanList?[index]["name"];

//               final idString = id.toString();
//               final bool isSelected = title == "Author"
//                   ? categoryProvider.authorId.contains(idString)
//                   : title == "Language"
//                       ? categoryProvider.langaugeId.contains(idString)
//                       : categoryProvider.categoryId.contains(idString);

//               void toggleSelection() {
//                 if (title == "Author") {
//                   categoryProvider.setAuthorIds(idString);
//                 } else if (title == "Language") {
//                   categoryProvider.setLanguageIds(idString);
//                 } else {
//                   categoryProvider.setCategoryIds(idString);
//                 }

//                 categoryProvider.clearcommanlist();
//                 _fetchbycommanapidata(0, categoryProvider.currentIndex);
//               }

//               return ListTile(
//                 contentPadding: EdgeInsets.zero,
//                 leading: Checkbox(
//                   activeColor: colorAccent,
//                   checkColor: white,
//                   mouseCursor: MouseCursor.uncontrolled,
//                   value: isSelected,
//                   onChanged: (value) {
//                     toggleSelection();
//                   },
//                 ),
//                 title: InkWell(
//                   splashColor: transparent,
//                   focusColor: transparent,
//                   hoverColor: transparent,
//                   highlightColor: transparent,
//                   onTap: () {
//                     toggleSelection();
//                   },
//                   child: MyText(
//                     text: name,
//                     multilanguage: false,
//                     maxline: 2,
//                     textalign: TextAlign.justify,
//                     fontstyle: FontStyle.normal,
//                     fontsizeWeb: Dimens.medium14TextSize,
//                     fontwaight: FontWeight.w600,
//                     color: isSelected ? colorAccent : black,
//                   ),
//                 ),
//               );
//             },
//             itemCount: commanList?.length ?? 0)
//       ],
//     );
//   }

//   Widget buildRightSideShimmer() {
//     return ResponsiveGridList(
//       minItemWidth: 185,
//       minItemsPerRow: 2,
//       maxItemsPerRow: Utils.customCrossAxisCount(
//         context: context,
//         height1600: 8,
//         height1200: 6,
//         height800: 4,
//         height400: 2,
//       ),
//       horizontalGridMargin: 0,
//       verticalGridMargin: 0,
//       verticalGridSpacing: 20,
//       horizontalGridSpacing: 20,
//       listViewBuilderOptions: ListViewBuilderOptions(
//         shrinkWrap: true,
//         padding: EdgeInsets.zero,
//         physics: NeverScrollableScrollPhysics(),
//       ),
//       children: List.generate(8, (index) {
//         return Container(
//           width: 200,
//           alignment: Alignment.center,
//           decoration: BoxDecoration(
//             color: white,
//             border: Border.all(width: 1, color: gray),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Padding(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
//                 child: const CustomWidget.rectangular(
//                   height: 260,
//                   width: double.infinity,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: const [
//                     SizedBox(height: 6),
//                     CustomWidget.roundrectborder(height: 14, width: 60),
//                     SizedBox(height: 6),
//                     CustomWidget.roundrectborder(height: 16, width: 140),
//                     SizedBox(height: 6),
//                     CustomWidget.roundrectborder(height: 14, width: 100),
//                     SizedBox(height: 6),
//                     CustomWidget.roundrectborder(height: 18, width: 80),
//                     SizedBox(height: 8),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         );
//       }),
//     );
//   }
// }
