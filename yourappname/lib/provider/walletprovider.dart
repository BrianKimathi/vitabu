import 'package:yourappname/model/transactionhistorymodel.dart'
    as transactionhistory;
import 'package:yourappname/model/transactionhistorymodel.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class WalletProvider extends ChangeNotifier {
  TransactionHistoryModel transactionHistoryModel = TransactionHistoryModel();
  List<transactionhistory.Result>? transactionHistory = [];
  bool loading = false;
  bool loadMore = false;
  String currentIndex = "0";

  setTab(index) {
    currentIndex = index;
    notifyListeners();
  }

  setLoading(bool isLoading) {
    loading = isLoading;
    notifyListeners();
  }

  Future<void> getTransactionHistory(contentType, pageno) async {
    loading = true;
    transactionHistoryModel =
        await ApiService().transactionHistory(contentType, pageno);
    if (transactionHistoryModel.status == 200) {
      setPagination(
          transactionHistoryModel.totalRows,
          transactionHistoryModel.totalPage,
          transactionHistoryModel.currentPage,
          transactionHistoryModel.morePage);
      if (transactionHistoryModel.result != null &&
          (transactionHistoryModel.result?.length ?? 0) > 0) {
        for (var i = 0;
            i < (transactionHistoryModel.result?.length ?? 0);
            i++) {
          transactionHistory?.add(transactionHistoryModel.result?[i] ??
              transactionhistory.Result());
        }
        final Map<int, transactionhistory.Result> transactionHisotryMap = {};
        transactionHistory?.forEach((item) {
          transactionHisotryMap[item.id ?? 0] = item;
        });
        transactionHistory = transactionHisotryMap.values.toList();
        setLoadMore(false);
      }
    }
    loading = false;
    notifyListeners();
  }

  setLoadMore(loadMore) {
    printLog("setLoadMore loadMore :=> $loadMore");
    this.loadMore = loadMore;
    notifyListeners();
  }

  clearProvider() {
    loading = false;
    transactionHistoryModel = TransactionHistoryModel();
    transactionHistory = [];
    transactionHistory?.clear();
    loadMore = false; /*  Pagination start */
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
    currentIndex = "0";
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

  clearData() {
    loading = false;
    transactionHistoryModel = TransactionHistoryModel();
    transactionHistory = [];
    transactionHistory?.clear();
    loadMore = false; /*  Pagination start */
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
  }
}
