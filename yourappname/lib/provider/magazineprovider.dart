import 'package:yourappname/model/bookmodel.dart';
import 'package:yourappname/model/profilemodel.dart';
import 'package:yourappname/model/sectionmodel.dart' as sectiondata;
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webservice/apiservice.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/model/bookmodel.dart' as magazinebycategory;

class MagazineProvider extends ChangeNotifier {
  ProfileModel profileModel = ProfileModel();
  BookModel topDownloadMagazineModel = BookModel();
  magazinebycategory.BookModel magazineByCatagoryModel =
      magazinebycategory.BookModel();

  sectiondata.SectionModel sectionListModel = sectiondata.SectionModel();
  List<sectiondata.Result>? sectionListData = [];

  List<magazinebycategory.Result>? magazinebycategoryList = [];

  bool loadMore = false;

  bool loading = false;
  bool profileLoading = false;
  int pageIndex = 0;

  setPageIndex(value) {
    pageIndex = value;
    notifyListeners();
  }

  setLoading(bool isLoading) {
    loading = isLoading;
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

/* Magazine Section Data Started */
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

  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  setLoadMore(loadMore) {
    printLog("setLoadMore loadMore :=> $loadMore");
    this.loadMore = loadMore;
    notifyListeners();
  }

  setPagination(
      int? totalRows, int? totalPage, int? currentPage, bool? morePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    isMorePage = morePage;
    notifyListeners();
  }
  // Future<void> getPoularMagazine(pageno) async {
  //   popularmagazineloading = true;
  //   popularMagazineModel = await ApiService().popularmagazines(pageno);
  //   popularmagazineloading = false;
  //   notifyListeners();
  // }

  // Future<void> getMagazineCatagory(pageno) async {
  //   magazineCatagoryloading = true;
  //   magazineCatagoryModel = await ApiService().category(pageno);
  //   magazineCatagoryloading = false;
  //   notifyListeners();
  // }

  Future<void> getMagazineByCatagory(pageno, catagoryid) async {
    loading = true;
    magazineByCatagoryModel = magazinebycategory.BookModel();
    magazineByCatagoryModel =
        await ApiService().magazinebyCatagory(pageno, catagoryid);
    if (magazineByCatagoryModel.status == 200) {
      setPagination(
          magazineByCatagoryModel.totalRows,
          magazineByCatagoryModel.totalPage,
          magazineByCatagoryModel.currentPage,
          magazineByCatagoryModel.morePage);
      if (magazineByCatagoryModel.result != null &&
          (magazineByCatagoryModel.result?.length ?? 0) > 0) {
        for (var i = 0;
            i < (magazineByCatagoryModel.result?.length ?? 0);
            i++) {
          magazinebycategoryList?.add(magazineByCatagoryModel.result?[i] ??
              magazinebycategory.Result());
        }
        final Map<int, magazinebycategory.Result> magazinebycategoryMap = {};
        magazinebycategoryList?.forEach((item) {
          magazinebycategoryMap[item.id ?? 0] = item;
        });
        magazinebycategoryList = magazinebycategoryMap.values.toList();
        setLoadMore(false);
      }
    }
    loading = false;
    notifyListeners();
  }

  // Future<void> getTopDownloadMagazine(pageno) async {
  //   topdownloadmagazineloading = true;
  //   topDownloadMagazineModel = await ApiService().topDownloadMagazine(pageno);
  //   topdownloadmagazineloading = false;
  //   notifyListeners();
  // }
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
    pageIndex = 0;
    id = DateTime.now();
    name = "";
    sectionListModel = sectiondata.SectionModel();
    profileModel = ProfileModel();
    sectionListData = [];
    sectionListData?.clear();
    loading = false;
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }
}

