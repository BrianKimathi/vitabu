import 'package:yourappname/model/bookmodel.dart' as bestebook;
import 'package:yourappname/model/bookmodel.dart' as continueread;
import 'package:yourappname/model/bookmodel.dart' as freereleasebook;
import 'package:yourappname/model/bookmodel.dart' as paidreleasebook;
import 'package:yourappname/model/bookmodel.dart' as newarrivalbook;
import 'package:yourappname/model/bookmodel.dart' as alsolikebook;
import 'package:yourappname/model/categorymodel.dart' as bookcatagory;
import 'package:yourappname/model/categorymodel.dart' as magazinecatagory;
import 'package:yourappname/model/bookmodel.dart' as popularmagazine;
import 'package:yourappname/model/bookmodel.dart' as topdownloadmagazine;
import 'package:yourappname/model/bookmodel.dart' as relateditems;
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webservice/apiservice.dart';
import 'package:flutter/material.dart';
import '../model/authormodel.dart' as auther;

class AllViewProvider extends ChangeNotifier {
  bestebook.BookModel bestEbookModel = bestebook.BookModel();
  continueread.BookModel continueReadModel = continueread.BookModel();
  auther.AuthorModel autherModel = auther.AuthorModel();
  freereleasebook.BookModel freeBooksModel = freereleasebook.BookModel();
  paidreleasebook.BookModel paidBooksModel = paidreleasebook.BookModel();
  newarrivalbook.BookModel newArrivalBooksModel = newarrivalbook.BookModel();
  alsolikebook.BookModel alsoLikeBooksModel = alsolikebook.BookModel();
  popularmagazine.BookModel popularMagazineModel = popularmagazine.BookModel();
  magazinecatagory.CategoryModel magazineCatagoryModel =
      magazinecatagory.CategoryModel();
  bookcatagory.CategoryModel bookCatagoryModel = bookcatagory.CategoryModel();
  topdownloadmagazine.BookModel topDownloadMagazineModel =
      topdownloadmagazine.BookModel();
  relateditems.BookModel reletedBookModel = relateditems.BookModel();

  List<bestebook.Result>? bestEbookList = [];
  List<continueread.Result>? continueReadList = [];
  List<bookcatagory.Result>? bookCategoryList = [];
  List<auther.Result>? autherList = [];
  List<freereleasebook.Result>? freeReleaseBookList = [];
  List<paidreleasebook.Result>? paidReleaseBookList = [];
  List<newarrivalbook.Result>? newArrivalBookList = [];
  List<alsolikebook.Result>? alsoLikeBookList = [];
  List<popularmagazine.Result>? popularMagazineList = [];
  List<magazinecatagory.Result>? magazineCatagoryList = [];
  List<topdownloadmagazine.Result>? topDownloadMagazineList = [];
  List<relateditems.Result>? reletedItemsList = [];

  bool loadMore = false;
  bool popularbooksloading = false;
  bool continuereadloading = false;
  bool bookCatagoryloading = false;
  bool autherloading = false;
  bool freebookloading = false;
  bool paidbooksloading = false;
  bool newarrivalloading = false;
  bool alsolikeloading = false;
  bool popularmagazineloading = false;
  bool magazineCatagoryloading = false;
  bool topdownloadmagazineloading = false;
  bool releteditemsloading = false;

  setLoadMore(loadMore) {
    printLog("setLoadMore loadMore :=> $loadMore");
    this.loadMore = loadMore;
    notifyListeners();
  }

  Future<void> getPoularBooks(pageno) async {
    popularbooksloading = true;
    bestEbookModel = bestebook.BookModel();
    bestEbookModel = await ApiService().popularbooks(pageno);
    if (bestEbookModel.status == 200) {
      setPagination(bestEbookModel.totalRows, bestEbookModel.totalPage,
          bestEbookModel.currentPage, bestEbookModel.morePage);
      if (bestEbookModel.result != null &&
          (bestEbookModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (bestEbookModel.result?.length ?? 0); i++) {
          bestEbookList?.add(bestEbookModel.result?[i] ?? bestebook.Result());
        }
        final Map<int, bestebook.Result> postMap = {};
        bestEbookList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        bestEbookList = postMap.values.toList();
        setLoadMore(false);
        printLog("postList length :==> ${(bestEbookList?.length ?? 0)}");
      }
    }
    popularbooksloading = false;
    notifyListeners();
  }

  Future<void> getContinueRead(pageno) async {
    continuereadloading = true;
    continueReadModel = continueread.BookModel();
    continueReadModel = await ApiService().getContinueRead(pageno);
    if (continueReadModel.status == 200) {
      setPagination(continueReadModel.totalRows, continueReadModel.totalPage,
          continueReadModel.currentPage, continueReadModel.morePage);
      if (continueReadModel.result != null &&
          (continueReadModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (continueReadModel.result?.length ?? 0); i++) {
          continueReadList
              ?.add(continueReadModel.result?[i] ?? continueread.Result());
        }
        final Map<int, continueread.Result> continuereadMap = {};
        continueReadList?.forEach((item) {
          continuereadMap[item.id ?? 0] = item;
        });
        continueReadList = continuereadMap.values.toList();
        setLoadMore(false);
        printLog("postList length :==> ${(bestEbookList?.length ?? 0)}");
      }
    }
    continuereadloading = false;
    notifyListeners();
  }

  Future<void> getBookCatagory(pageno) async {
    bookCatagoryloading = true;
    bookCatagoryModel = bookcatagory.CategoryModel();
    bookCatagoryModel = await ApiService().categoryResponse(pageno);
    if (bookCatagoryModel.status == 200) {
      setPagination(bookCatagoryModel.totalRows, bookCatagoryModel.totalPage,
          bookCatagoryModel.currentPage, bookCatagoryModel.morePage);
      if (bookCatagoryModel.result != null &&
          (bookCatagoryModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (bookCatagoryModel.result?.length ?? 0); i++) {
          bookCategoryList
              ?.add(bookCatagoryModel.result?[i] ?? bookcatagory.Result());
        }
        final Map<int, bookcatagory.Result> bookcatagoryMap = {};
        bookCategoryList?.forEach((item) {
          bookcatagoryMap[item.id ?? 0] = item;
        });
        bookCategoryList = bookcatagoryMap.values.toList();
        setLoadMore(false);
        printLog("postList length :==> ${(bestEbookList?.length ?? 0)}");
      }
    }
    bookCatagoryloading = false;
    notifyListeners();
  }

  Future<void> getAutherList(pageno) async {
    autherloading = true;
    autherModel = auther.AuthorModel();
    autherModel = await ApiService().autherList(pageno);
    if (autherModel.status == 200) {
      setPagination(autherModel.totalRows, autherModel.totalPage,
          autherModel.currentPage, autherModel.morePage);
      if (autherModel.result != null && (autherModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (autherModel.result?.length ?? 0); i++) {
          autherList?.add(autherModel.result?[i] ?? auther.Result());
        }
        final Map<int, auther.Result> autherMap = {};
        autherList?.forEach((item) {
          autherMap[item.id ?? 0] = item;
        });
        autherList = autherMap.values.toList();
        setLoadMore(false);
      }
    }
    autherloading = false;
    notifyListeners();
  }

  Future<void> getFreeBooks(pageno) async {
    freebookloading = true;
    freeBooksModel = freereleasebook.BookModel();
    freeBooksModel = await ApiService().freeBooks(pageno);
    if (freeBooksModel.status == 200) {
      setPagination(freeBooksModel.totalRows, freeBooksModel.totalPage,
          freeBooksModel.currentPage, freeBooksModel.morePage);
      if (freeBooksModel.result != null &&
          (freeBooksModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (freeBooksModel.result?.length ?? 0); i++) {
          freeReleaseBookList
              ?.add(freeBooksModel.result?[i] ?? freereleasebook.Result());
        }
        final Map<int, freereleasebook.Result> freereleasebookMap = {};
        freeReleaseBookList?.forEach((item) {
          freereleasebookMap[item.id ?? 0] = item;
        });
        freeReleaseBookList = freereleasebookMap.values.toList();
        setLoadMore(false);
      }
    }
    freebookloading = false;
    notifyListeners();
  }

  Future<void> getPaidBooks(pageno) async {
    paidbooksloading = true;
    paidBooksModel = paidreleasebook.BookModel();
    paidBooksModel = await ApiService().paidBooks(pageno);
    if (paidBooksModel.status == 200) {
      setPagination(paidBooksModel.totalRows, paidBooksModel.totalPage,
          paidBooksModel.currentPage, paidBooksModel.morePage);
      if (paidBooksModel.result != null &&
          (paidBooksModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (paidBooksModel.result?.length ?? 0); i++) {
          paidReleaseBookList
              ?.add(paidBooksModel.result?[i] ?? paidreleasebook.Result());
        }
        final Map<int, paidreleasebook.Result> paidreleasebookMap = {};
        paidReleaseBookList?.forEach((item) {
          paidreleasebookMap[item.id ?? 0] = item;
        });
        paidReleaseBookList = paidreleasebookMap.values.toList();
        setLoadMore(false);
      }
    }
    paidbooksloading = false;
    notifyListeners();
  }

  Future<void> getNewArrivalBooks(pageno) async {
    newarrivalloading = true;
    newArrivalBooksModel = newarrivalbook.BookModel();
    newArrivalBooksModel = await ApiService().newArrivalbooks(pageno);
    if (newArrivalBooksModel.status == 200) {
      setPagination(
          newArrivalBooksModel.totalRows,
          newArrivalBooksModel.totalPage,
          newArrivalBooksModel.currentPage,
          newArrivalBooksModel.morePage);
      if (newArrivalBooksModel.result != null &&
          (newArrivalBooksModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (newArrivalBooksModel.result?.length ?? 0); i++) {
          newArrivalBookList
              ?.add(newArrivalBooksModel.result?[i] ?? newarrivalbook.Result());
        }
        final Map<int, newarrivalbook.Result> newarrivalbookMap = {};
        newArrivalBookList?.forEach((item) {
          newarrivalbookMap[item.id ?? 0] = item;
        });
        newArrivalBookList = newarrivalbookMap.values.toList();
        setLoadMore(false);
      }
    }
    newarrivalloading = false;
    notifyListeners();
  }

  Future<void> getAlsoLikeBooks(pageno) async {
    alsolikeloading = true;
    alsoLikeBooksModel = alsolikebook.BookModel();
    alsoLikeBooksModel = await ApiService().alsoLikebooks(pageno);
    if (alsoLikeBooksModel.status == 200) {
      setPagination(alsoLikeBooksModel.totalRows, alsoLikeBooksModel.totalPage,
          alsoLikeBooksModel.currentPage, alsoLikeBooksModel.morePage);
      if (alsoLikeBooksModel.result != null &&
          (alsoLikeBooksModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (alsoLikeBooksModel.result?.length ?? 0); i++) {
          alsoLikeBookList
              ?.add(alsoLikeBooksModel.result?[i] ?? alsolikebook.Result());
        }
        final Map<int, alsolikebook.Result> alsolikebookMap = {};
        alsoLikeBookList?.forEach((item) {
          alsolikebookMap[item.id ?? 0] = item;
        });
        alsoLikeBookList = alsolikebookMap.values.toList();
        setLoadMore(false);
      }
    }
    alsolikeloading = false;
    notifyListeners();
  }

  Future<void> getPoularMagazine(pageno) async {
    popularmagazineloading = true;
    popularMagazineModel = popularmagazine.BookModel();
    popularMagazineModel = await ApiService().popularmagazines(pageno);
    if (popularMagazineModel.status == 200) {
      setPagination(
          popularMagazineModel.totalRows,
          popularMagazineModel.totalPage,
          popularMagazineModel.currentPage,
          popularMagazineModel.morePage);
      if (popularMagazineModel.result != null &&
          (popularMagazineModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (popularMagazineModel.result?.length ?? 0); i++) {
          popularMagazineList?.add(
              popularMagazineModel.result?[i] ?? popularmagazine.Result());
        }
        final Map<int, popularmagazine.Result> popularmagazineMap = {};
        popularMagazineList?.forEach((item) {
          popularmagazineMap[item.id ?? 0] = item;
        });
        popularMagazineList = popularmagazineMap.values.toList();
        setLoadMore(false);
      }
    }
    popularmagazineloading = false;
    notifyListeners();
  }

  Future<void> getMagazineCatagory(pageno) async {
    magazineCatagoryloading = true;
    magazineCatagoryModel = magazinecatagory.CategoryModel();
    magazineCatagoryModel = await ApiService().categoryResponse(pageno);
    if (magazineCatagoryModel.status == 200) {
      setPagination(
          magazineCatagoryModel.totalRows,
          magazineCatagoryModel.totalPage,
          magazineCatagoryModel.currentPage,
          magazineCatagoryModel.morePage);
      if (magazineCatagoryModel.result != null &&
          (magazineCatagoryModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (magazineCatagoryModel.result?.length ?? 0); i++) {
          magazineCatagoryList?.add(
              magazineCatagoryModel.result?[i] ?? magazinecatagory.Result());
        }
        final Map<int, magazinecatagory.Result> magazinecatagoryMap = {};
        magazineCatagoryList?.forEach((item) {
          magazinecatagoryMap[item.id ?? 0] = item;
        });
        magazineCatagoryList = magazinecatagoryMap.values.toList();
        setLoadMore(false);
      }
    }
    magazineCatagoryloading = false;
    notifyListeners();
  }

  Future<void> getTopDownloadMagazine(pageno) async {
    topdownloadmagazineloading = true;
    topDownloadMagazineModel = topdownloadmagazine.BookModel();
    topDownloadMagazineModel = await ApiService().topDownloadMagazine(pageno);
    if (topDownloadMagazineModel.status == 200) {
      setPagination(
          topDownloadMagazineModel.totalRows,
          topDownloadMagazineModel.totalPage,
          topDownloadMagazineModel.currentPage,
          topDownloadMagazineModel.morePage);
      if (topDownloadMagazineModel.result != null &&
          (topDownloadMagazineModel.result?.length ?? 0) > 0) {
        for (var i = 0;
            i < (topDownloadMagazineModel.result?.length ?? 0);
            i++) {
          topDownloadMagazineList?.add(topDownloadMagazineModel.result?[i] ??
              topdownloadmagazine.Result());
        }
        final Map<int, topdownloadmagazine.Result> topdownloadmagazineMap = {};
        topDownloadMagazineList?.forEach((item) {
          topdownloadmagazineMap[item.id ?? 0] = item;
        });
        topDownloadMagazineList = topdownloadmagazineMap.values.toList();
        setLoadMore(false);
      }
    }
    topdownloadmagazineloading = false;
    notifyListeners();
  }

  Future<void> getRelatedItems(categoryid, type, pageno) async {
    releteditemsloading = true;
    reletedBookModel = relateditems.BookModel();
    reletedBookModel =
        await ApiService().getRelatedItems(categoryid, type, pageno);
    if (reletedBookModel.status == 200) {
      setPagination(reletedBookModel.totalRows, reletedBookModel.totalPage,
          reletedBookModel.currentPage, reletedBookModel.morePage);
      if (reletedBookModel.result != null &&
          (reletedBookModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (reletedBookModel.result?.length ?? 0); i++) {
          reletedItemsList
              ?.add(reletedBookModel.result?[i] ?? relateditems.Result());
        }
        final Map<int, relateditems.Result> relateditemsMap = {};
        reletedItemsList?.forEach((item) {
          relateditemsMap[item.id ?? 0] = item;
        });
        reletedItemsList = relateditemsMap.values.toList();
        setLoadMore(false);
      }
    }
    releteditemsloading = false;
    notifyListeners();
  }

  /*  Pagination start */
  int? totalRows, totalPage, currentPage;
  bool? morePage;
  setPagination(
      int? totalRows, int? totalPage, int? currentPage, bool? morePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    this.morePage = morePage;
    notifyListeners();
  }
  /*  Pagination end */

  clearProvider() {
    printLog("-----??clearProvider allViewProvider-----??");
    bestEbookModel = bestebook.BookModel();
    bookCatagoryModel = bookcatagory.CategoryModel();
    autherModel = auther.AuthorModel();
    freeBooksModel = freereleasebook.BookModel();
    paidBooksModel = paidreleasebook.BookModel();
    newArrivalBooksModel = newarrivalbook.BookModel();
    alsoLikeBooksModel = alsolikebook.BookModel();
    popularMagazineModel = popularmagazine.BookModel();
    magazineCatagoryModel = magazinecatagory.CategoryModel();
    topDownloadMagazineModel = topdownloadmagazine.BookModel();
    reletedBookModel = relateditems.BookModel();
    bestEbookList = [];
    autherList = [];
    freeReleaseBookList = [];
    paidReleaseBookList = [];
    newArrivalBookList = [];
    alsoLikeBookList = [];
    popularMagazineList = [];
    magazineCatagoryList = [];
    topDownloadMagazineList = [];
    reletedItemsList = [];
    popularbooksloading = false;
    autherloading = false;
    freebookloading = false;
    paidbooksloading = false;
    newarrivalloading = false;
    alsolikeloading = false;
    popularmagazineloading = false;
    magazineCatagoryloading = false;
    topdownloadmagazineloading = false;
    loadMore = false;
    totalRows = null;
    totalPage = null;
    currentPage = null;
    morePage = null;
    releteditemsloading = false;
  }
}
