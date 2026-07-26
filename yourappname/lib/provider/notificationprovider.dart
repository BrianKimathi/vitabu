import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/model/notificationmodel.dart' as notification;
import 'package:yourappname/webservice/apiservice.dart';

class NotificationProvider extends ChangeNotifier {
  notification.NotificationModel notificationModel =
      notification.NotificationModel();
  SuccessModel readnotificationModel = SuccessModel();

  List<notification.Result>? notificationList = [];

  bool loading = false;
  bool readNotificationloading = false;
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

  getNotification(pageno) async {
    loading = true;
    // notificationModel = notification.NotificationModel();
    notificationModel = await ApiService().notificationResponse(pageno);
    if (notificationModel.status == 200) {
      setPagination(notificationModel.totalRows, notificationModel.totalPage,
          notificationModel.currentPage, notificationModel.morePage);
      if (notificationModel.result != null &&
          (notificationModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (notificationModel.result?.length ?? 0); i++) {
          notificationList
              ?.add(notificationModel.result?[i] ?? notification.Result());
        }
        final Map<int, notification.Result> notificationMap = {};
        notificationList?.forEach((item) {
          notificationMap[item.id ?? 0] = item;
        });
        notificationList = notificationMap.values.toList();
        setLoadMore(false);
      }
    }
    loading = false;
    notifyListeners();
  }

  getReadNotification(index, String notificationid) async {
    readNotificationloading = true;
    readnotificationModel =
        await ApiService().readnotificationResponse(notificationid);
    notificationList?.removeAt(index);
    readNotificationloading = false;
    notifyListeners();
  }

  clearProvider() {
    notificationModel = notification.NotificationModel();
    readnotificationModel = SuccessModel();

    notificationList = [];
    notificationList?.clear();

    loading = false;
    readNotificationloading = false;
    loadMore = false;
  }
}
