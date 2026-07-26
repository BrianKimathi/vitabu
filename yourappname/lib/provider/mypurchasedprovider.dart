import 'package:yourappname/model/bookmodel.dart' as book;
import 'package:yourappname/model/bookmodel.dart' as magazine;
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class MyPurchasedProvider extends ChangeNotifier {
  book.BookModel purchaseBookModel = book.BookModel();
  magazine.BookModel purchaseMagazineModel = magazine.BookModel();

  List<book.Result>? purchaseBookList = [];
  List<magazine.Result>? purchaseMagazineList = [];

  bool purchaseBookloading = false;
  bool purchaseMagazineloading = false;
  bool loadMore = false;

  setLoadMore(loadMore) {
    printLog("setLoadMore loadMore :=> $loadMore");
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

  Future<void> purchasedBook(pageno) async {
    purchaseBookloading = true;
    purchaseBookModel = book.BookModel();
    purchaseBookModel = await ApiService().getPurchaseList("book", pageno);
    if (purchaseBookModel.status == 200) {
      setPagination(purchaseBookModel.totalRows, purchaseBookModel.totalPage,
          purchaseBookModel.currentPage, purchaseBookModel.morePage);
      if (purchaseBookModel.result != null &&
          (purchaseBookModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (purchaseBookModel.result?.length ?? 0); i++) {
          purchaseBookList?.add(purchaseBookModel.result?[i] ?? book.Result());
        }
        final Map<int, book.Result> bookMap = {};
        purchaseBookList?.forEach((item) {
          bookMap[item.id ?? 0] = item;
        });
        purchaseBookList = bookMap.values.toList();
        setLoadMore(false);
      }
    }
    purchaseBookloading = false;
    notifyListeners();
  }

  Future<void> purchasedMagazine(pageno) async {
    purchaseMagazineloading = true;
    purchaseMagazineModel = magazine.BookModel();
    purchaseMagazineModel =
        await ApiService().getPurchaseList("magazine", pageno);
    if (purchaseMagazineModel.status == 200) {
      setPagination(
          purchaseMagazineModel.totalRows,
          purchaseMagazineModel.totalPage,
          purchaseMagazineModel.currentPage,
          purchaseMagazineModel.morePage);
      if (purchaseMagazineModel.result != null &&
          (purchaseMagazineModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (purchaseMagazineModel.result?.length ?? 0); i++) {
          purchaseMagazineList
              ?.add(purchaseMagazineModel.result?[i] ?? magazine.Result());
        }
        final Map<int, magazine.Result> magazineMap = {};
        purchaseMagazineList?.forEach((item) {
          magazineMap[item.id ?? 0] = item;
        });
        purchaseMagazineList = magazineMap.values.toList();
        setLoadMore(false);
      }
    }
    purchaseMagazineloading = false;
    notifyListeners();
  }

  clearProvider() {
    purchaseBookModel = book.BookModel();
    purchaseMagazineModel = magazine.BookModel();

    purchaseBookList = [];
    purchaseMagazineList = [];

    purchaseBookloading = false;
    purchaseMagazineloading = false;
    loadMore = false;
  }
}
