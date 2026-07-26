import 'dart:developer';

import 'package:yourappname/model/commanmodel.dart' as comman;
import 'package:yourappname/model/usermodel.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/model/categorymodel.dart' as category;
import 'package:yourappname/model/authormodel.dart' as author;
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webservice/apiservice.dart';

class CategoryProvider extends ChangeNotifier {
  String currentIndex = "1";
  comman.CommonModel commanmodel = comman.CommonModel();
  author.AuthorModel autherModel = author.AuthorModel();
  category.CategoryModel bookCatagoryModel = category.CategoryModel();
  category.CategoryModel languagemodel = category.CategoryModel();

  UserModel userModel = UserModel();
  bool autherloading = false;
  bool bookloading = false;
  bool bookCatagoryloading = false;
  bool languageloading = false;
  bool commanloading = false;

  List<author.Result>? authorList = [];
  List<category.Result>? categoryList = [];
  List<category.Result>? langugeList = [];
  List<comman.Result>? commanlist = [];

  setLoding(isLoding) {
    bookCatagoryloading = isLoding;
    autherloading = isLoding;
    languageloading = isLoding;
    notifyListeners();
  }

  bool loadMore = false;
  setLoadMore(loadMore) {
    printLog("setLoadMore loadMore :=> $loadMore");
    this.loadMore = loadMore;
    notifyListeners();
  }

/* Category Ids Data Started */
  List ids = [];
  String? categoryIds = "";
  List names = [];
  String? categoryNames = "";

  Map<int, String> selectedItems = {};

  void selectIds(int id, String name) {
    if (selectedItems.containsKey(id)) {
      selectedItems.remove(id);
    } else {
      selectedItems[id] = name;
    }

    printLog("My Category Ids List is ${selectedItems.keys.toList()}");

    categoryIds = selectedItems.keys.join(",");
    categoryNames = selectedItems.values.join(",");

    printLog("My String Data Ids is $categoryIds");
    printLog("My String Data Names is $categoryNames");

    notifyListeners();
  }

  /* End */

  /*  Pagination start */
// Pagination for Author
  int? authorTotalRows, authorTotalPage, authorCurrentPage;
  bool? authorMorePage;

// Pagination for Category
  int? categoryTotalRows, categoryTotalPage, categoryCurrentPage;
  bool? categoryMorePage;

// Pagination for Language
  int? languageTotalRows, languageTotalPage, languageCurrentPage;
  bool? languageMorePage;

// Pagination for Common list
  int? commanTotalRows, commanTotalPage, commanCurrentPage;
  bool? commanMorePage;

  ssetAuthorPagination(
      int? totalRows, int? totalPage, int? currentPage, bool? morePage) {
    authorTotalRows = totalRows;
    authorTotalPage = totalPage;
    authorCurrentPage = currentPage;
    authorMorePage = morePage;
    notifyListeners();
  }

  setCategoryPagination(
      int? totalRows, int? totalPage, int? currentPage, bool? morePage) {
    categoryTotalRows = totalRows;
    categoryTotalPage = totalPage;
    categoryCurrentPage = currentPage;
    categoryMorePage = morePage;
    notifyListeners();
  }

  setLanguagePagination(
      int? totalRows, int? totalPage, int? currentPage, bool? morePage) {
    languageTotalRows = totalRows;
    languageTotalPage = totalPage;
    languageCurrentPage = currentPage;
    languageMorePage = morePage;
    notifyListeners();
  }

  setCommanPagination(
      int? totalRows, int? totalPage, int? currentPage, bool? morePage) {
    commanTotalRows = totalRows;
    commanTotalPage = totalPage;
    commanCurrentPage = currentPage;
    commanMorePage = morePage;
    notifyListeners();
  }

  /*  Pagination end */

  Future<void> getBookCatagory(pageno) async {
    bookCatagoryloading = true;

    bookCatagoryModel = await ApiService().categoryResponse(pageno);
    if (bookCatagoryModel.status == 200) {
      setCategoryPagination(
          bookCatagoryModel.totalRows,
          bookCatagoryModel.totalPage,
          bookCatagoryModel.currentPage,
          bookCatagoryModel.morePage);
      if (bookCatagoryModel.result != null &&
          (bookCatagoryModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (bookCatagoryModel.result?.length ?? 0); i++) {
          categoryList?.add(bookCatagoryModel.result?[i] ?? category.Result());
        }
        final Map<int, category.Result> bookbycategoryMap = {};
        categoryList?.forEach((item) {
          bookbycategoryMap[item.id ?? 0] = item;
        });
        categoryList = bookbycategoryMap.values.toList();
        setLoadMore(false);
        log("getRentContentList length :=2=> ${(bookCatagoryModel.result?.length ?? 0)}");
      }
    }

    bookCatagoryloading = false;
    notifyListeners();
  }

// Book Api started
  Future<void> getPoularBooks(pageno) async {
    languageloading = true;
    languagemodel = await ApiService().languageResponse(pageno);
    if (languagemodel.status == 200) {
      setLanguagePagination(languagemodel.totalRows, languagemodel.totalPage,
          languagemodel.currentPage, languagemodel.morePage);
      if (languagemodel.result != null &&
          (languagemodel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (languagemodel.result?.length ?? 0); i++) {
          langugeList?.add(languagemodel.result?[i] ?? category.Result());
        }
        final Map<int, category.Result> bookbycategoryMap = {};
        langugeList?.forEach((item) {
          bookbycategoryMap[item.id ?? 0] = item;
        });
        langugeList = bookbycategoryMap.values.toList();
        setLoadMore(false);
        log("getRentContentList length :=2=> ${(languagemodel.result?.length ?? 0)}");
      }
    }

    languageloading = false;
    notifyListeners();
  }

// Book Api END
// Author Api Started
  Future<void> getAutherList(pageno) async {
    autherloading = true;
    autherModel = await ApiService().authorResponse(pageno);

    if (autherModel.status == 200) {
      ssetAuthorPagination(autherModel.totalRows, autherModel.totalPage,
          autherModel.currentPage, autherModel.morePage);
      if (autherModel.result != null && (autherModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (autherModel.result?.length ?? 0); i++) {
          authorList?.add(autherModel.result?[i] ?? author.Result());
        }
        final Map<int, author.Result> bookbycategoryMap = {};
        authorList?.forEach((item) {
          bookbycategoryMap[item.id ?? 0] = item;
        });
        authorList = bookbycategoryMap.values.toList();
        setLoadMore(false);
        log("getRentContentList length :=2=> ${(autherModel.result?.length ?? 0)}");
      }
    }

    autherloading = false;
    notifyListeners();
  }

// Author Api END
/* Update Category For User */
  bool updateCategory = false;
  setCategoryLoding(isLoding) {
    updateCategory = isLoding;
    notifyListeners();
  }

  Future<void> getUserUpdateCategory(
    categoryId,
    deviceType,
    deviceToken,
  ) async {
    userModel = await ApiService()
        .profileCategoryUpdate(categoryId, deviceType, deviceToken);
  }

  setTab(index) {
    currentIndex = index;
    notifyListeners();
  }
  /* =========== Web data started =========== */

  List<String> categoryId = [];
  List<String> langaugeId = [];
  List<String> authorId = [];

  bool isCategory = false, isLangugae = false, isAuthor = false;

  String filterTab = "0";

  setFilterTab(vale) {
    filterTab = vale;
    notifyListeners();
  }

  setShowData(isCat, isLan, isAut) {
    isCategory = isCat;
    isLangugae = isLan;
    isAuthor = isAut;
    notifyListeners();
  }

  setCategoryIds(ids) {
    if (categoryId.contains(ids)) {
      categoryId.remove(ids);
    } else {
      categoryId.add(ids);
    }
    printLog("My Selected Value $categoryId");
    notifyListeners();
  }

  setLanguageIds(ids) {
    if (langaugeId.contains(ids)) {
      langaugeId.remove(ids);
    } else {
      langaugeId.add(ids);
    }
    printLog("My Selected Value $langaugeId");
    notifyListeners();
  }

  setAuthorIds(ids) {
    if (authorId.contains(ids)) {
      authorId.remove(ids);
    } else {
      authorId.add(ids);
    }
    printLog("My Selected Value $authorId");
    notifyListeners();
  }

  Future<void> getcommanlist(
    contenttype,
    categoryid,
    authorid,
    languageid,
    pageno,
  ) async {
    // 🔹 If it's the first page, show shimmer
    if (pageno == 0 || pageno == 1) {
      commanloading = true;
    } else {
      // 🔹 Otherwise show bottom loader
      setLoadMore(true);
    }

    try {
      // 🔹 API call
      commanmodel = await ApiService().getCategoryContent(
        contentType: contenttype,
        categoryId: categoryid,
        authorId: authorid,
        languageId: languageid,
        pageno: pageno,
      );

      // 🔹 When data successfully received
      if (commanmodel.status == 200) {
        // Set pagination info
        setCommanPagination(
          commanmodel.totalRows,
          commanmodel.totalPage,
          commanmodel.currentPage,
          commanmodel.morePage,
        );

        // 🔹 Add result to list
        if (commanmodel.result != null &&
            (commanmodel.result?.length ?? 0) > 0) {
          // If it's the first page, clear previous list
          if (pageno == 0 || pageno == 1) {
            commanlist = [];
          }

          // Append unique items
          for (var item in commanmodel.result!) {
            commanlist?.add(item);
          }

          // 🔹 Remove duplicates using map
          final Map<int, comman.Result> uniqueMap = {};
          for (var item in commanlist!) {
            uniqueMap[item.id ?? 0] = item;
          }
          commanlist = uniqueMap.values.toList();

          log("✅ CommanList updated: ${commanlist?.length}");
        }
      } else {
        log("⚠️ API returned status: ${commanmodel.status}");
      }
    } catch (e, s) {
      log("❌ getcommanlist error: $e");
      log("Stack: $s");
    } finally {
      // 🔹 Always turn off loaders
      commanloading = false;
      setLoadMore(false);
      notifyListeners();
    }
  }

  clearcommanlist() {
    commanlist = [];
    commanlist?.clear();
    commanmodel = comman.CommonModel();
    setCommanPagination(0, 0, 0, false);
    commanloading = false;
    notifyListeners();
    log("===>> Comman List Cleared");
  }

  clearWebData() {
    categoryId = [];
    categoryId.clear();
    langaugeId = [];
    langaugeId.clear();
    authorId = [];
    authorId.clear();
    isCategory = false;
    isLangugae = false;
    isAuthor = false;
    filterTab = "0";
  }

/* =========== Web data End =========== */

  clearCategoryData() {
    bookCatagoryloading = false;
    categoryList?.clear();
    categoryList = [];
    bookCatagoryModel = category.CategoryModel();
    loadMore = false;

    categoryCurrentPage = 0;
    categoryTotalPage = 0;

    commanCurrentPage = 0;
    commanTotalPage = 0;
  }

  clearAuthor() {
    autherloading = false;
    authorList?.clear();
    authorList = [];
    autherModel = author.AuthorModel();
    loadMore = false;
    authorCurrentPage = 0;
    authorTotalPage = 0;
  }

  clearProvider() {
    printLog("==== Clearing CategoryProvider ====");

    currentIndex = "1";
    bookCatagoryloading = false;
    bookloading = false;
    autherloading = false;
    commanloading = false;
    languageloading = false;
    loadMore = false;

    // Lists reset
    categoryList = [];
    authorList = [];
    commanlist = [];
    langugeList = [];

    // Models reset
    bookCatagoryModel = category.CategoryModel();
    autherModel = author.AuthorModel();
    commanmodel = comman.CommonModel();

    authorCurrentPage = 0;
    authorTotalPage = 0;
    categoryCurrentPage = 0;
    categoryTotalPage = 0;
    languageCurrentPage = 0;
    languageTotalPage = 0;
    commanCurrentPage = 0;
    commanTotalPage = 0;

    // Filters reset
    ids = [];
    categoryIds = "";
    names = [];
    categoryNames = "";
    selectedItems = {};
    categoryId = [];
    authorId = [];
    langaugeId = [];
    isCategory = false;
    isLangugae = false;
    isAuthor = false;
    filterTab = "0";
    log("After clear=======================>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>: ${categoryList?.length}, ${authorList?.length}, ${commanlist?.length}");
  }
}
