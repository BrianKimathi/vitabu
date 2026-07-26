import 'dart:io';

import 'package:yourappname/pages/bottombar.dart';
import 'package:yourappname/provider/categoryprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/webpages/webhome.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';

class GenresPrefrences extends StatefulWidget {
  final bool? isCategoryType;
  final String? isEditType, categoryIds, categoryName;
  const GenresPrefrences(
      {super.key,
      required this.isCategoryType,
      this.isEditType,
      this.categoryIds,
      this.categoryName});

  @override
  State<GenresPrefrences> createState() => _GenrePprefrencesState();
}

class _GenrePprefrencesState extends State<GenresPrefrences> {
  late CategoryProvider categoryProvider;
  String? strDeviceType, strDeviceToken;
  @override
  void initState() {
    categoryProvider = Provider.of<CategoryProvider>(context, listen: false);
    getData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getApi(0);
    });
    _getDeviceToken();
    super.initState();
  }

  _getDeviceToken() async {
    if (kIsWeb) {
      strDeviceType = "3";
      strDeviceToken = "123";
    } else if (Platform.isAndroid) {
      strDeviceType = "1";
      strDeviceToken = await FirebaseMessaging.instance.getToken();
    } else if (Platform.isIOS) {
      strDeviceType = "2";
      strDeviceToken = OneSignal.User.pushSubscription.id.toString();
    }
  }

  // _getDeviceToken() async {
  //   if (Platform.isAndroid) {
  //     strDeviceType = "1";
  //     strDeviceToken = await FirebaseMessaging.instance.getToken();
  //   } else {
  //     strDeviceType = "2";
  //     strDeviceToken = OneSignal.User.pushSubscription.id.toString();
  //   }
  // }

  getApi(nextPage) {
    categoryProvider.setLoding(true);
    categoryProvider.getBookCatagory((nextPage ?? 0) + 1);
  }

  getData() {
    List<String> idStrings = (widget.categoryIds ?? "")
        .split(',')
        .where((e) => e.trim().isNotEmpty)
        .toList();

    List<String> nameList = (widget.categoryName ?? "")
        .split(',')
        .where((e) => e.trim().isNotEmpty)
        .toList();

    List<int> ids = idStrings.map((e) => int.tryParse(e) ?? 0).toList();

    if (ids.length == nameList.length) {
      for (int i = 0; i < ids.length; i++) {
        categoryProvider.selectedItems[ids[i]] = nameList[i];
      }

      categoryProvider.categoryIds =
          categoryProvider.selectedItems.keys.join(",");
      categoryProvider.categoryNames =
          categoryProvider.selectedItems.values.join(",");
    }

    printLog("Pre-selected IDs: ${categoryProvider.categoryIds}");
    printLog("Pre-selected Names: ${categoryProvider.categoryNames}");
  }

  @override
  void dispose() {
    categoryProvider.clearProvider();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorPrimary,
      appBar: AppBar(
        backgroundColor: colorPrimary,
        leading: (widget.isCategoryType == true)
            ? SizedBox.shrink()
            : IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 20,
                ),
              ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth >= 800;

          double horizontalPadding = isWideScreen ? 100 : 15;

          return Consumer<CategoryProvider>(
              builder: (context, categoryProvider, child) {
            final isLastPage = (categoryProvider.categoryCurrentPage ?? 0) >=
                (categoryProvider.categoryTotalPage ?? 0);
            final isListNotEmpty =
                (categoryProvider.categoryList?.isNotEmpty ?? false);

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                  horizontalPadding, 20, horizontalPadding, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    text: "select_genres",
                    multilanguage: true,
                    fontsize: isWideScreen ? 36 : Dimens.text32Size,
                    fontwaight: FontWeight.w700,
                    color: white,
                  ),
                  const SizedBox(height: 20),
                  MyText(
                    text: "select_type_reading",
                    multilanguage: true,
                    fontsize: isWideScreen ? 18 : Dimens.medium14TextSize,
                    fontwaight: FontWeight.w400,
                    color: white,
                  ),
                  const SizedBox(height: 20),
                  categoryList(isWideScreen: isWideScreen),
                  (categoryProvider.loadMore)
                      ? Utils.pageLoader(context)
                      : SizedBox.fromSize(),
                  SizedBox(height: 10),
                  if (!isLastPage && isListNotEmpty)
                    Align(
                      alignment: Alignment.center,
                      child: InkWell(
                        splashColor: transparent,
                        focusColor: transparent,
                        hoverColor: transparent,
                        onTap: () async {
                          categoryProvider.setLoadMore(true);
                          await getApi(
                              categoryProvider.categoryCurrentPage ?? 0);
                        },
                        child: MyText(
                          text: "show_more",
                          multilanguage: true,
                          fontsize: isWideScreen ? 18 : Dimens.medium14TextSize,
                          fontwaight: FontWeight.w700,
                          color: white,
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                  Center(
                    child: InkWell(
                      onTap: () {
                        if (categoryProvider.categoryIds == "") {
                          Utils.showSnackbar(
                              context, "please_select_category", true);
                        } else {
                          if (widget.isEditType == "1") {
                            Navigator.of(context).pop({
                              'type': '1',
                              'ids': categoryProvider.categoryIds,
                              'name': categoryProvider.selectedItems.values
                                  .join(","),
                            });
                          } else {
                            updateCategoryApi(
                              categoryProvider.categoryIds,
                              strDeviceType,
                              strDeviceToken,
                            );
                          }
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 80),
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        curve: Curves.bounceInOut,
                        width: isWideScreen
                            ? 400
                            : MediaQuery.of(context).size.width,
                        height: 45,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: colorPrimary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: categoryProvider.updateCategory
                            ? SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(
                                  color: white,
                                  strokeWidth: 2,
                                ),
                              )
                            : MyText(
                                color: white,
                                text: "continue",
                                fontsize:
                                    isWideScreen ? 18 : Dimens.medium14TextSize,
                                fontwaight: FontWeight.w600,
                                maxline: 1,
                                multilanguage: true,
                                overflow: TextOverflow.ellipsis,
                                textalign: TextAlign.center,
                                fontstyle: FontStyle.normal,
                              ),
                      ),
                    ),
                  )
                ],
              ),
            );
          });
        },
      ),
    );
  }

  Widget categoryList({required bool isWideScreen}) {
    if (categoryProvider.bookCatagoryloading && !categoryProvider.loadMore) {
      return shimmerCategory(isWideScreen: isWideScreen);
    } else {
      if (categoryProvider.bookCatagoryModel.status == 200 &&
          categoryProvider.categoryList != null) {
        return Wrap(
          runSpacing: 15,
          spacing: 15,
          direction: Axis.horizontal,
          children: List.generate(
            categoryProvider.categoryList?.length ?? 0,
            (index) {
              return InkWell(
                splashColor: transparent,
                hoverColor: transparent,
                focusColor: transparent,
                onTap: () {
                  categoryProvider.selectIds(
                      categoryProvider.categoryList?[index].id ?? 0,
                      categoryProvider.categoryList?[index].name ?? "");
                },
                child: Container(
                  padding: EdgeInsets.all(isWideScreen ? 20 : 12),
                  decoration: BoxDecoration(
                    color: categoryProvider.selectedItems.containsKey(
                            categoryProvider.categoryList?[index].id ?? 0)
                        ? colorPrimaryDark
                        : transparent,
                    border: Border.all(
                        width: 1,
                        color: categoryProvider.selectedItems.containsKey(
                                categoryProvider.categoryList?[index].id ?? 0)
                            ? transparent
                            : white,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyText(
                        text: categoryProvider.categoryList?[index].name ?? "",
                        fontsize: isWideScreen ? 18 : Dimens.medium14TextSize,
                        fontwaight: FontWeight.w800,
                        color: categoryProvider.selectedItems.containsKey(
                                categoryProvider.categoryList?[index].id ?? 0)
                            ? black
                            : white,
                      ),
                      SizedBox(width: 10),
                      Icon(
                        categoryProvider.selectedItems.containsKey(
                                categoryProvider.categoryList?[index].id ?? 0)
                            ? Icons.check_circle_outline_rounded
                            : Icons.add_circle_outline_sharp,
                        size: isWideScreen ? 24 : 20,
                        color: categoryProvider.selectedItems.containsKey(
                                categoryProvider.categoryList?[index].id ?? 0)
                            ? black
                            : white,
                      )
                    ],
                  ),
                ),
              );
            },
          ).toList(),
        );
      } else {
        return SizedBox.shrink();
      }
    }
  }

  Widget shimmerCategory({required bool isWideScreen}) {
    return Wrap(
      runSpacing: isWideScreen ? 15 : 5,
      spacing: isWideScreen ? 15 : 10,
      direction: Axis.horizontal,
      children: List.generate(
        15,
        (index) {
          return Container(
            padding: EdgeInsets.all(isWideScreen ? 20 : 12),
            decoration: BoxDecoration(
              color: colorPrimary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomWidget.roundcorner(
                  height: isWideScreen ? 20 : 12,
                  width: isWideScreen ? 150 : 100,
                ),
                SizedBox(width: isWideScreen ? 15 : 10),
                CustomWidget.circular(
                  height: isWideScreen ? 20 : 15,
                  width: isWideScreen ? 20 : 15,
                )
              ],
            ),
          );
        },
      ).toList(),
    );
  }

  /* Update Category */
  updateCategoryApi(categoryIds, deviceType, deviceToken) async {
    categoryProvider.setCategoryLoding(true);
    try {
      await categoryProvider.getUserUpdateCategory(
          categoryIds, deviceType, deviceToken);

      if (categoryProvider.userModel.status == 200) {
        Utils.saveUserCreds(
          userID: categoryProvider.userModel.result?[0].id.toString() ?? "",
          categoryId:
              categoryProvider.userModel.result?[0].categoryIds.toString() ??
                  "",
          firstName:
              categoryProvider.userModel.result?[0].firstName.toString() ?? "",
          lastName:
              categoryProvider.userModel.result?[0].lastName.toString() ?? "",
          userName:
              categoryProvider.userModel.result?[0].userName.toString() ?? "",
          userImage:
              categoryProvider.userModel.result?[0].image.toString() ?? "",
          userEmail:
              categoryProvider.userModel.result?[0].email.toString() ?? "",
          mobileNumber:
              categoryProvider.userModel.result?[0].mobileNumber.toString() ??
                  "",
          walletCoin:
              categoryProvider.userModel.result?[0].walletAmount.toString() ??
                  "",
          address:
              categoryProvider.userModel.result?[0].address.toString() ?? "",
          isAuthor:
              categoryProvider.userModel.result?[0].isAuthor.toString() ?? "",
          deviceType:
              categoryProvider.userModel.result?[0].deviceType.toString() ?? "",
          deviceToken:
              categoryProvider.userModel.result?[0].deviceToken.toString() ??
                  "",
          description:
              categoryProvider.userModel.result?[0].description.toString() ??
                  "",
        );

        categoryProvider.setCategoryLoding(false);
        await SharedPref().save("isEdit", "1");

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushAndRemoveUntil(
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) {
                return kIsWeb ? WebHome() : Bottombar();
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
            ),
            (Route route) => false,
          );
        });
      } else {
        categoryProvider.setCategoryLoding(false);
        if (!mounted) return;
        Utils.showSnackbar(
            context, categoryProvider.userModel.message ?? "", false);
      }
    } catch (e) {
      categoryProvider.setCategoryLoding(false);
      if (!mounted) return;

      Utils.showSnackbar(
          context, categoryProvider.userModel.message ?? "", false);
    }
  }
}
