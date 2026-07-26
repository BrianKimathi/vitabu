import 'package:yourappname/model/packagemodel.dart';
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/model/userplanhistory.dart' as history;
import 'package:yourappname/model/userscriptionmodel.dart' hide Result;
import 'package:flutter/material.dart';
import 'package:yourappname/webservice/apiservice.dart';

class PackageProvider extends ChangeNotifier {
  bool showBillingHistory = false;

  void showBilling() {
    showBillingHistory = true;
    notifyListeners();
  }

  void showPlan() {
    showBillingHistory = false;
    notifyListeners();
  }

  int selectedIndex = 0;

  bool featureLoading = false;

  PackageModel getpackageModel = PackageModel();

  bool loading = false;
  int cPlanPosition = -1, purchasePos = -1;

  setPurchasedPlan(int position) {
    debugPrint("setPurchasedPlan position :==> $position");
    purchasePos = position;
  }

  setCurrentPlan(int position) {
    debugPrint("setCurrentPlan position :==> $position");
    cPlanPosition = position;
    notifyListeners();
  }

  getPackage() async {
    loading = true;
    getpackageModel = await ApiService().package();
    loading = false;
    notifyListeners();
  }

  clearProvider() {
    getpackageModel = PackageModel();
    loading = false;
    selectedIndex = 0;
    cPlanPosition = -1;
    purchasePos = -1;
  }

  void selectPlan(int index) {
    selectedIndex = index;
    featureLoading = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 500), () {
      featureLoading = false;
      notifyListeners();
    });
  }

  Result? get selectedPlan {
    if (getpackageModel.result == null || getpackageModel.result!.isEmpty) {
      return null;
    }

    return getpackageModel.result![selectedIndex];
  }

/*======================= User subscription plan api =======================*/

  bool planloading = false;

  Usersubscriptionmodel usersubscriptionmodel = Usersubscriptionmodel();
  getuserplan() async {
    planloading = true;
    usersubscriptionmodel = await ApiService().usersubscriptionplan();
    planloading = false;
    notifyListeners();
  }

/*======================= User subscription history api =======================*/
  bool historyloading = false, loadmore = false;

  history.Userplanhistorymodel userplanhistorymodel =
      history.Userplanhistorymodel();

  List<history.Result>? historyList = [];
  int? historytotalRows, historytotalPage, historycurrentPage;
  bool? historyisMorePage;

  void sethistoryPaginationData(int? historytotalRows, int? historytotalPage,
      int? historycurrentPage, bool? historyisMorePage) {
    this.historycurrentPage = historycurrentPage;
    this.historytotalRows = historytotalRows;
    this.historytotalPage = historytotalPage;
    historyisMorePage = historyisMorePage;
    notifyListeners();
  }

  void setLoadMore(bool loadmore) {
    this.loadmore = loadmore;
    notifyListeners();
  }

  Future<void> getSeactionList(int? status, int pageNo) async {
    historyloading = true;

    userplanhistorymodel =
        await ApiService().subscriptionhistory(status, pageNo);

    if (userplanhistorymodel.status == 200) {
      sethistoryPaginationData(
        userplanhistorymodel.totalRows,
        userplanhistorymodel.totalPage,
        userplanhistorymodel.currentPage,
        userplanhistorymodel.morePage,
      );

      if (userplanhistorymodel.result != null) {
        historyList!.addAll(userplanhistorymodel.result!);
      }
    }

    historyloading = false;
    notifyListeners();
  }

  /* Tab Index */

  void changeHistoryFilter(int? status) {
    historyList = [];
    historycurrentPage = 0;
    historytotalPage = 1;
    historyisMorePage = false;

    notifyListeners();
    getSeactionList(status, 1);
  }

  void loadMoreHistory(int? status) {
    if (loadmore) return;

    setLoadMore(true);
    getSeactionList(status, (historycurrentPage ?? 0) + 1);
  }

  bool cancelsubloading = false;

  SuccessModel successModel = SuccessModel();

  cancelsubscription(tid) async {
    cancelsubloading = true;
    notifyListeners();

    successModel = await ApiService().canelsubscription(tid);

    cancelsubloading = false;
    notifyListeners();
  }
}
