import 'package:yourappname/model/profilemodel.dart';
import 'package:yourappname/model/sectionmodel.dart' as sectiondata;
import 'package:yourappname/model/sectionmodel.dart';
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/webservice/apiservice.dart';

class BookProvider extends ChangeNotifier {
  ProfileModel profileModel = ProfileModel();
  SuccessModel successModel = SuccessModel();
  SectionModel sectionListModel = SectionModel();
  List<sectiondata.Result>? sectionListData = [];
  bool profileLoading = false, loadingSection = false;

  bool loading = false;

  int pageIndex = 0;

  setPageIndex(value) {
    pageIndex = value;
    notifyListeners();
  }

  SharedPref sharedPre = SharedPref();
    getProfile(userId) async {
    if (userId == null || userId.toString().trim().isEmpty || userId.toString() == "0") {
      loading = false;
      notifyListeners();
      return;
    }
    loading = true;
    profileModel = await ApiService().profileResponse(userId);

    if (profileModel.status == 200 &&
        profileModel.result != null &&
        profileModel.result!.isNotEmpty) {
      final result = profileModel.result!.first;

      await sharedPre.save(
        "is_subscription",
        (result.isSubscription ?? 0).toString(),
      );

      Constant.isSubscription = result.isSubscription ?? 0;
    }

    loading = false;
    notifyListeners();
  }

  int pageMagazieIndex = 0;

  setMagazinePageIndex(value) {
    pageMagazieIndex = value;
    notifyListeners();
  }

  bool loadMore = false;
  int currentIndex = 0;
  String? audioBookId,
      categoryId,
      authorId,
      bookImage,
      authorName,
      contentName,
      audioUrl,
      isPaid,
      isBuy,
      price;

  setIndexChange({
    sectionIndex,
    index,
    ids,
    catIds,
    authorIds,
    image,
    auName,
    conName,
    url,
    paid,
    buy,
    priceBook,
  }) {
    currentIndex = index;
    authorId = authorIds;
    audioBookId = ids;
    categoryId = catIds;
    bookImage = image;
    authorName = auName;
    contentName = conName;
    audioUrl = url;
    isPaid = paid;
    isBuy = buy;
    price = priceBook;

    notifyListeners();
  }

  Future<void> setView(contentType, contentId, subContentId) async {
    debugPrint("addPostView postId :==> $contentId");
    // loaded = true;
    successModel = await ApiService()
        .contentViewResponse(contentType, contentId, subContentId);
    debugPrint("addPostView status :==> ${successModel.status}");
    debugPrint("addPostView message :==> ${successModel.message}");
    // loaded = false;
  }

  setLoading(bool isLoading) {
    loading = isLoading;
    notifyListeners();
  }

/* End */
  setLoadMore(loadMore) {
    this.loadMore = loadMore;
    notifyListeners();
  }

  /*  Pagination start */
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;
  setPagination(
      int? totalRows, int? totalPage, int? currentPage, bool? morePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    isMorePage = morePage;
    notifyListeners();
  }
  /*  Pagination end */

/*  homedata api start  */

  Future<void> getSectionList(sectionType, userCategoryId, pageno) async {
    loading = true;
    sectionListModel =
        await ApiService().sectionList(sectionType, userCategoryId, pageno);
    if (sectionListModel.status == 200) {
      setPagination(sectionListModel.totalRows, sectionListModel.totalPage,
          sectionListModel.currentPage, sectionListModel.morePage);
      if (sectionListModel.result != null &&
          (sectionListModel.result?.length ?? 0) > 0) {
        if (sectionListModel.result != null &&
            (sectionListModel.result?.length ?? 0) > 0) {
          for (var i = 0; i < (sectionListModel.result?.length ?? 0); i++) {
            sectionListData
                ?.add(sectionListModel.result?[i] ?? sectiondata.Result());
          }
          final Map<int, sectiondata.Result> postMap = {};
          sectionListData?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          sectionListData = postMap.values.toList();
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }

  /*  Pagination start */
  int? sectiontotalRows, sectiontotalPage, sectioncurrentPage;
  bool? sectionisMorePage;
  setPodcastPaginationData(int? sectiontotalRows, int? sectiontotalPage,
      int? sectioncurrentPage, bool? sectionisMorePage) {
    this.sectioncurrentPage = sectioncurrentPage;
    this.sectiontotalRows = sectiontotalRows;
    this.sectiontotalPage = sectiontotalPage;
    this.sectionisMorePage = sectionisMorePage;
    printLog("isMorePage ++ $sectionisMorePage");
    printLog("totalrows ++ $sectiontotalRows");
    printLog("totalPage ++ $sectiontotalPage");
    printLog("currentPage ++ $sectioncurrentPage");

    notifyListeners();
  }

/* Web Data Started */

  String? name;
  DateTime? id;
  setBanner(ids, names) {
    id = ids;
    name = names;
    notifyListeners();
  }

  clearProvider() {
    printLog("================== ClearProvider ==================");
    sectionListModel = SectionModel();
    profileModel = ProfileModel();
    sectionListData = [];
    sectionListData?.clear();
    profileLoading = false;
    loadingSection = false;

    loading = false;
    loadMore = false;

    profileLoading = false;
    loading = false;

    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
    pageIndex = 0;
    pageMagazieIndex = 0;
    currentIndex = 0;
    audioBookId = "";
    categoryId = "";
    authorId = "";
    bookImage = "";
    authorName = "";
    contentName = "";
    audioUrl = "";
    isPaid = "";
    isBuy = "";
    price = "";
/* WEB */
    id = DateTime.now();
    name = "";
  }
}

