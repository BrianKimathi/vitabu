import 'dart:developer';

import 'package:yourappname/model/authormodel.dart' as author;
import 'package:yourappname/model/audiobookmodel.dart' as audio;
import 'package:yourappname/model/bookmodel.dart' as book;
import 'package:yourappname/model/magazinemodel.dart' as magazine;
import 'package:yourappname/model/categorymodel.dart' as category;
import 'package:flutter/material.dart';
import 'package:yourappname/webservice/apiservice.dart';
import '../utils/utils.dart';

class ViewAllProvider extends ChangeNotifier {
  book.BookModel bookModel = book.BookModel();
  magazine.MagazineModel magazineModel = magazine.MagazineModel();
  audio.AudioBookModel audioBookModel = audio.AudioBookModel();
  category.CategoryModel categoryModel = category.CategoryModel();
  author.AuthorModel autherModel = author.AuthorModel();

  List<book.Result>? bookList = [];
  List<magazine.Result>? magazineList = [];
  List<audio.Result>? audioList = [];
  List<category.Result>? categoryList = [];
  List<author.Result>? authorList = [];

  bool loadmore = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  bool loading = false;

  setLoading(isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  // Book List API
  Future<void> getSectionBook(sectionID, contentType, pageno) async {
    loading = true;
    bookModel = await ApiService()
        .sectionDetailsResponse(sectionID, contentType, pageno);
    if (bookModel.status == 200) {
      setPagination(bookModel.totalRows, bookModel.totalPage,
          bookModel.currentPage, bookModel.morePage);
      if (bookModel.result != null && (bookModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (bookModel.result?.length ?? 0); i++) {
          bookList?.add(bookModel.result?[i] ?? book.Result());
        }
        final Map<int, book.Result> postMap = {};
        bookList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        bookList = postMap.values.toList();
        setLoadMore(false);
        printLog("bookModel length :=2=> ${(bookModel.result?.length ?? 0)}");
      }
      printLog("getSectionDetails status :===> ${bookModel.status}");
      printLog("getSectionDetails message :==> ${bookModel.message}");
    }
    loading = false;
    notifyListeners();
  }

  // Magazibe List API
  Future<void> getSectionMagazine(sectionID, contentType, pageno) async {
    loading = true;
    magazineModel = await ApiService()
        .sectionDetailsResponse(sectionID, contentType, pageno);
    if (magazineModel.status == 200) {
      setPagination(magazineModel.totalRows, magazineModel.totalPage,
          magazineModel.currentPage, magazineModel.morePage);
      if (magazineModel.result != null &&
          (magazineModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (magazineModel.result?.length ?? 0); i++) {
          magazineList?.add(magazineModel.result?[i] ?? magazine.Result());
        }
        final Map<int, magazine.Result> postMap = {};
        magazineList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        magazineList = postMap.values.toList();
        setLoadMore(false);
        printLog(
            "bookModel length :=2=> ${(magazineModel.result?.length ?? 0)}");
      }
      printLog("getSectionDetails status :===> ${magazineModel.status}");
      printLog("getSectionDetails message :==> ${magazineModel.message}");
    }
    loading = false;
    notifyListeners();
  }

  // Audio List API
  Future<void> getSectionAudio(sectionID, contentType, pageno) async {
    loading = true;
    audioBookModel = await ApiService()
        .sectionDetailsResponse(sectionID, contentType, pageno);
    if (audioBookModel.status == 200) {
      setPagination(audioBookModel.totalRows, audioBookModel.totalPage,
          audioBookModel.currentPage, audioBookModel.morePage);
      if (audioBookModel.result != null &&
          (audioBookModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (audioBookModel.result?.length ?? 0); i++) {
          audioList?.add(audioBookModel.result?[i] ?? audio.Result());
        }
        final Map<int, audio.Result> postMap = {};
        audioList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        audioList = postMap.values.toList();
        setLoadMore(false);
        printLog(
            "audioBookModel length :=2=> ${(audioBookModel.result?.length ?? 0)}");
      }
      printLog("getSectionDetails status :===> ${audioBookModel.status}");
      printLog("getSectionDetails message :==> ${audioBookModel.message}");
    }
    loading = false;
    notifyListeners();
  }

  // AUthor List API
  Future<void> getSectionAuthor(sectionID, contentType, pageno) async {
    loading = true;
    autherModel = await ApiService()
        .sectionDetailsResponse(sectionID, contentType, pageno);
    if (autherModel.status == 200) {
      setPagination(autherModel.totalRows, autherModel.totalPage,
          autherModel.currentPage, autherModel.morePage);
      if (autherModel.result != null && (autherModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (autherModel.result?.length ?? 0); i++) {
          authorList?.add(autherModel.result?[i] ?? author.Result());
        }
        final Map<int, author.Result> postMap = {};
        authorList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        authorList = postMap.values.toList();
        setLoadMore(false);
        printLog(
            "autherModel length :=2=> ${(autherModel.result?.length ?? 0)}");
      }
      printLog("getSectionDetails status :===> ${autherModel.status}");
      printLog("getSectionDetails message :==> ${autherModel.message}");
    }
    loading = false;
    notifyListeners();
  }

  // Category List API
  Future<void> getSectionCategory(sectionID, contentType, pageno) async {
    loading = true;
    categoryModel = await ApiService()
        .sectionDetailsResponse(sectionID, contentType, pageno);
    if (categoryModel.status == 200) {
      setPagination(categoryModel.totalRows, categoryModel.totalPage,
          categoryModel.currentPage, categoryModel.morePage);
      if (categoryModel.result != null &&
          (categoryModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (categoryModel.result?.length ?? 0); i++) {
          categoryList?.add(categoryModel.result?[i] ?? category.Result());
        }
        final Map<int, category.Result> postMap = {};
        categoryList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        categoryList = postMap.values.toList();
        setLoadMore(false);
        printLog(
            "categoryModel length :=2=> ${(categoryModel.result?.length ?? 0)}");
      }
      printLog("getSectionDetails status :===> ${categoryModel.status}");
      printLog("getSectionDetails message :==> ${categoryModel.message}");
    }
    loading = false;
    notifyListeners();
  }

  // Category List API
  Future<void> getSectionLanguage(sectionID, contentType, pageno) async {
    loading = true;
    categoryModel = await ApiService()
        .sectionDetailsResponse(sectionID, contentType, pageno);
    if (categoryModel.status == 200) {
      setPagination(categoryModel.totalRows, categoryModel.totalPage,
          categoryModel.currentPage, categoryModel.morePage);
      if (categoryModel.result != null &&
          (categoryModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (categoryModel.result?.length ?? 0); i++) {
          categoryList?.add(categoryModel.result?[i] ?? category.Result());
        }
        final Map<int, category.Result> postMap = {};
        categoryList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        categoryList = postMap.values.toList();
        setLoadMore(false);
        printLog(
            "categoryModel length :=2=> ${(categoryModel.result?.length ?? 0)}");
      }
      printLog("getSectionDetails status :===> ${categoryModel.status}");
      printLog("getSectionDetails message :==> ${categoryModel.message}");
    }
    loading = false;
    notifyListeners();
  }

  setLoadMore(loadmore) {
    this.loadmore = loadmore;
    notifyListeners();
  }

  setPagination(
      int? totalRows, int? totalPage, int? currentPage, bool? morePage) {
    log("setPagination currentPage :==> $currentPage");
    log("setPagination totalRows :====> $totalRows");
    log("setPagination totalPage :====> $totalPage");
    log("setPagination morePage :=====> $morePage");
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    isMorePage = morePage;
    notifyListeners();
  }

  clearProvider() {
    bookModel = book.BookModel();
    magazineModel = magazine.MagazineModel();
    audioBookModel = audio.AudioBookModel();
    categoryModel = category.CategoryModel();
    autherModel = author.AuthorModel();

    bookList = [];
    bookList?.clear();
    magazineList = [];
    magazineList?.clear();
    audioList = [];
    audioList?.clear();
    categoryList = [];
    categoryList?.clear();
    authorList = [];
    audioList?.clear();

    loading = false;
    /* Pagination */
    loadmore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }
}
