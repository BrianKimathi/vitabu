import 'package:yourappname/model/audiobookmodel.dart' as audio;
import 'package:yourappname/model/bookmodel.dart' as book;
import 'package:yourappname/model/magazinemodel.dart' as magazine;
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class CategoryWiseDataProvider extends ChangeNotifier {
  bool loading = false;
  bool loadMore = false;
  book.BookModel bookModel = book.BookModel();
  magazine.MagazineModel magazineModel = magazine.MagazineModel();
  audio.AudioBookModel audioBookModel = audio.AudioBookModel();
  SuccessModel successModel = SuccessModel();

  List<book.Result>? bookList = [];
  List<magazine.Result>? magazineList = [];
  List<audio.Result>? audioList = [];

  String currentIndex = "2";

  setTab(index) {
    currentIndex = index;

    notifyListeners();
  }

  setLoading(bool isLoading) {
    loading = isLoading;

    notifyListeners();
  }

  // Book List API
  Future<void> getSectionBook(type, categoryId, pageno) async {
    loading = true;
    bookModel =
        await ApiService().categoryByContentResponse(type, categoryId, pageno);
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
  Future<void> getSectionMagazine(type, categoryId, pageno) async {
    loading = true;
    magazineModel =
        await ApiService().categoryByContentResponse(type, categoryId, pageno);
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
  Future<void> getSectionAudio(type, categoryId, pageno) async {
    loading = true;
    audioBookModel =
        await ApiService().categoryByContentResponse(type, categoryId, pageno);
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
      int? totalRows, int? totalPage, int? currentPage, bool? isMorePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    this.isMorePage = isMorePage;
    notifyListeners();
  }
  /*  Pagination end */

/* Bookmark api Stared */
  Future<void> categoryByContentResponse(index, contentType, contentId) async {
    if (contentType == "1") {
      if ((audioList?[index].isBookmark ?? 0) == 1) {
        audioList?[index].isBookmark = 0;
      } else {
        audioList?[index].isBookmark = 1;
      }
      audioList?.removeAt(index);
    } else if (contentType == "2") {
      if ((bookList?[index].isBookmark ?? 0) == 1) {
        bookList?[index].isBookmark = 0;
      } else {
        bookList?[index].isBookmark = 1;
      }
      bookList?.removeAt(index);
    } else {
      if ((magazineList?[index].isBookmark ?? 0) == 1) {
        magazineList?[index].isBookmark = 0;
      } else {
        magazineList?[index].isBookmark = 1;
      }
      magazineList?.removeAt(index);
    }
    notifyListeners();
    successModel = await ApiService().bookmarkResponse(contentType, contentId);
  }

  /* Bookmark api END */

  clearData() {
    loading = false;
    bookModel = book.BookModel();
    magazineModel = magazine.MagazineModel();
    audioBookModel = audio.AudioBookModel();
    bookList = [];
    bookList?.clear();
    magazineList = [];
    magazineList?.clear();
    audioList = [];
    audioList?.clear();
    loadMore = false; /*  Pagination start */
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }

  clearProvider() {
    printLog("================== ClearProvider ==================");
    bookModel = book.BookModel();
    magazineModel = magazine.MagazineModel();
    audioBookModel = audio.AudioBookModel();
    currentIndex = "2";
    loading = false;
    bookList = [];
    bookList?.clear();
    magazineList = [];
    magazineList?.clear();
    audioList = [];
    audioList?.clear();
    /*  Pagination start */
    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }
}
