import 'package:yourappname/model/bookmodel.dart' as book;
import 'package:yourappname/model/magazinemodel.dart' as magazine;
import 'package:yourappname/model/audiobookmodel.dart' as audio;
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class ReletedItemProvider extends ChangeNotifier {
  book.BookModel bookModel = book.BookModel();
  magazine.MagazineModel magazineModel = magazine.MagazineModel();
  audio.AudioBookModel audioBookModel = audio.AudioBookModel();

  List<book.Result>? bookList = [];
  List<magazine.Result>? magazineList = [];
  List<audio.Result>? audioList = [];

  bool loadmore = false;
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;

  bool loading = false;

  setLoading(isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  // Book List API
  Future<void> getSectionBook(type, categoryId, contentId, pageno) async {
    loading = true;
    bookModel =
        await ApiService().reletedResponse(type, categoryId, contentId, pageno);
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
  Future<void> getSectionMagazine(type, categoryId, contentId, pageno) async {
    loading = true;
    magazineModel =
        await ApiService().reletedResponse(type, categoryId, contentId, pageno);
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
  Future<void> getSectionAudio(type, categoryId, contentId, pageno) async {
    loading = true;
    audioBookModel =
        await ApiService().reletedResponse(type, categoryId, contentId, pageno);
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

  setLoadMore(loadmore) {
    this.loadmore = loadmore;
    notifyListeners();
  }

  setPagination(
      int? totalRows, int? totalPage, int? currentPage, bool? morePage) {
    printLog("setPagination currentPage :==> $currentPage");
    printLog("setPagination totalRows :====> $totalRows");
    printLog("setPagination totalPage :====> $totalPage");
    printLog("setPagination morePage :=====> $morePage");
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

    bookList = [];
    bookList?.clear();
    magazineList = [];
    magazineList?.clear();
    audioList = [];
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
